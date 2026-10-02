/**
 * supabase/edge/miners-pass/index.ts
 *
 * Supabase Edge Function: the weekly Miner's Pass, paid in SKR.
 *
 * There is NO on-chain program. The payment is a plain SPL Token
 * transferChecked of SKR from the player's wallet into the treasury
 * wallet's SKR account. This function builds that transfer, and once the
 * player has signed and sent it, verifies it on-chain and records the
 * pass (migration 20260929_skr_miners_pass.sql).
 *
 * All routes are POST (supabase-js functions.invoke's default):
 *
 *   /config    — { active, amountBase, amount, decimals, mint, network }
 *   /status    — { active, weekKey } for the caller, current ISO week
 *   /build-tx  — { buyer } → { transaction (base64, unsigned), orderId }
 *   /confirm   — { orderId, signature } → { status: pending|paid|failed }
 *
 * /status, /build-tx and /confirm need the player's session JWT; the
 * player is resolved server-side and never taken from the body.
 *
 * The devnet twin (miners-pass-devnet) has an IDENTICAL index.ts —
 * only config.ts differs. Keep them in sync.
 *
 * Deploy (JWT verification ON — do not pass --no-verify-jwt):
 *   supabase functions deploy miners-pass          (mainnet)
 *   supabase functions deploy miners-pass-devnet   (devnet twin)
 */

import { Buffer } from 'node:buffer';
import { createClient } from '@supabase/supabase-js';
import {
  ComputeBudgetProgram,
  Connection,
  PublicKey,
  TransactionInstruction,
  TransactionMessage,
  VersionedTransaction,
  type ParsedAccountData,
  type ParsedInstruction,
} from '@solana/web3.js';

import { handleCors, jsonResponse, errorResponse } from './cors.ts';
import { getConfig } from './config.ts';

const ITEM = 'miners_pass';

const TOKEN_PROGRAM_ID = new PublicKey(
  'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
);
const ASSOCIATED_TOKEN_PROGRAM_ID = new PublicKey(
  'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL',
);
const MEMO_PROGRAM_ID = new PublicKey(
  'MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr',
);

/** Token program instruction index for TransferChecked. */
const TRANSFER_CHECKED = 12;

/** Abandoned build attempts allowed per player per 10 minutes. */
const MAX_PENDING_ORDERS = 5;

const SIGNATURE_RE = /^[1-9A-HJ-NP-Za-km-z]{64,88}$/;

type Admin = ReturnType<typeof getAdminClient>;

// =============================================================
// ROUTE HANDLER
// =============================================================

Deno.serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  // Mounted at /miners-pass (or /miners-pass-devnet): route on the
  // last path segment.
  const route = new URL(req.url).pathname.split('/').filter(Boolean).pop();

  try {
    if (req.method !== 'POST') {
      return errorResponse(`Use POST (got ${req.method})`, 405);
    }
    switch (route) {
      case 'config':
        return await handleConfig();
      case 'status':
        return await withPlayer(req, handleStatus);
      case 'build-tx':
        return await withPlayer(req, handleBuildTx);
      case 'confirm':
        return await withPlayer(req, handleConfirm);
      default:
        return errorResponse(`Not found: ${route}`, 404);
    }
  } catch (err) {
    console.error('Unhandled error:', err);
    return errorResponse('Internal server error', 500);
  }
});

// =============================================================
// SHARED
// =============================================================

function getAdminClient() {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  );
}

/**
 * Resolve the caller's player from their session JWT (same mapping as
 * wallet-auth /link), then run [handler]. The anon key alone is not a
 * player session and is rejected.
 */
async function withPlayer(
  req: Request,
  handler: (req: Request, admin: Admin, playerId: string) => Promise<Response>,
): Promise<Response> {
  const authHeader = req.headers.get('Authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return errorResponse('Missing authorization token.', 401);
  }

  const admin = getAdminClient();
  const token = authHeader.replace('Bearer ', '');
  const { data: { user }, error: userError } = await admin.auth.getUser(token);
  if (userError || !user) return errorResponse('Sign in required.', 401);

  const { data: mapping } = await admin
    .from('player_auth_accounts')
    .select('player_id')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!mapping) return errorResponse('No player for this session.', 403);

  return await handler(req, admin, mapping.player_id as string);
}

/** Associated token account of [owner] for [mint] (classic Token program). */
function associatedTokenAddress(mint: PublicKey, owner: PublicKey): PublicKey {
  return PublicKey.findProgramAddressSync(
    [owner.toBuffer(), TOKEN_PROGRAM_ID.toBuffer(), mint.toBuffer()],
    ASSOCIATED_TOKEN_PROGRAM_ID,
  )[0];
}

/** SPL Token TransferChecked: [12, amount u64 LE, decimals u8]. */
function transferCheckedInstruction(
  source: PublicKey,
  mint: PublicKey,
  destination: PublicKey,
  owner: PublicKey,
  amount: bigint,
  decimals: number,
): TransactionInstruction {
  const data = Buffer.alloc(10);
  data.writeUInt8(TRANSFER_CHECKED, 0);
  data.writeBigUInt64LE(amount, 1);
  data.writeUInt8(decimals, 9);
  return new TransactionInstruction({
    programId: TOKEN_PROGRAM_ID,
    keys: [
      { pubkey: source, isSigner: false, isWritable: true },
      { pubkey: mint, isSigner: false, isWritable: false },
      { pubkey: destination, isSigner: false, isWritable: true },
      { pubkey: owner, isSigner: true, isWritable: false },
    ],
    data,
  });
}

function memoFor(orderId: string): string {
  return `diggle:miners_pass:${orderId}`;
}

interface Accounts {
  mint: PublicKey;
  treasuryAta: PublicKey;
  decimals: number;
}

/**
 * Resolve the SKR mint + treasury token account for this network and
 * sanity-check them on-chain. Returns a reason string when the store
 * cannot take payments (fails closed).
 */
async function resolveAccounts(
  connection: Connection,
): Promise<Accounts | string> {
  const config = getConfig();
  if (!config.skrMint) return 'SKR mint not configured';
  if (!config.treasuryWallet) return 'treasury wallet not configured';

  const mint = new PublicKey(config.skrMint);
  const mintInfo = await connection.getParsedAccountInfo(mint);
  const mintAccount = mintInfo.value;
  if (!mintAccount || !mintAccount.owner.equals(TOKEN_PROGRAM_ID)) {
    return 'SKR mint is not a Token program mint';
  }
  const decimals = (mintAccount.data as ParsedAccountData).parsed?.info
    ?.decimals;
  if (typeof decimals !== 'number') return 'could not read SKR decimals';

  const treasuryAta = associatedTokenAddress(
    mint,
    new PublicKey(config.treasuryWallet),
  );
  if (!(await connection.getAccountInfo(treasuryAta))) {
    return 'treasury SKR token account does not exist';
  }

  return { mint, treasuryAta, decimals };
}

/** Active price row for the pass on this network, or null. */
async function activePrice(admin: Admin): Promise<bigint | null> {
  const { data } = await admin
    .from('skr_prices')
    .select('amount_base, active')
    .eq('network', getConfig().network)
    .eq('item', ITEM)
    .maybeSingle();
  if (!data?.active) return null;
  return BigInt(data.amount_base);
}

async function currentWeekKey(admin: Admin): Promise<string> {
  const { data, error } = await admin.rpc('iso_week_key', {
    p_ts: new Date().toISOString(),
  });
  if (error || typeof data !== 'string') {
    throw new Error(`iso_week_key failed: ${error?.message}`);
  }
  return data;
}

async function hasPass(
  admin: Admin,
  playerId: string,
  weekKey: string,
): Promise<boolean> {
  const { data } = await admin
    .from('miners_passes')
    .select('week_key')
    .eq('player_id', playerId)
    .eq('network', getConfig().network)
    .eq('week_key', weekKey)
    .maybeSingle();
  return !!data;
}

function toUiAmount(amountBase: bigint, decimals: number): number {
  return Number(amountBase) / 10 ** decimals;
}

// =============================================================
// POST /config
// =============================================================

async function handleConfig(): Promise<Response> {
  const config = getConfig();
  const admin = getAdminClient();

  const price = await activePrice(admin);
  if (price === null) {
    return jsonResponse({ active: false, network: config.network });
  }

  const connection = new Connection(config.rpcUrl, 'confirmed');
  const accounts = await resolveAccounts(connection);
  if (typeof accounts === 'string') {
    console.warn(`Miner's Pass unavailable: ${accounts}`);
    return jsonResponse({ active: false, network: config.network });
  }

  return jsonResponse({
    active: true,
    network: config.network,
    mint: accounts.mint.toBase58(),
    decimals: accounts.decimals,
    amountBase: price.toString(),
    amount: toUiAmount(price, accounts.decimals),
  });
}

// =============================================================
// POST /status
// =============================================================

async function handleStatus(
  _req: Request,
  admin: Admin,
  playerId: string,
): Promise<Response> {
  const weekKey = await currentWeekKey(admin);
  return jsonResponse({
    active: await hasPass(admin, playerId, weekKey),
    weekKey,
  });
}

// =============================================================
// POST /build-tx
// =============================================================

async function handleBuildTx(
  req: Request,
  admin: Admin,
  playerId: string,
): Promise<Response> {
  const config = getConfig();

  let buyer: PublicKey;
  try {
    const body = await req.json();
    buyer = new PublicKey(body.buyer);
    if (!PublicKey.isOnCurve(buyer.toBytes())) {
      return errorResponse('Buyer public key is not on curve', 400);
    }
  } catch (_e) {
    return errorResponse('Missing or invalid "buyer" public key', 400);
  }

  const price = await activePrice(admin);
  if (price === null) {
    return jsonResponse({ error: 'unavailable' }, 409);
  }

  const connection = new Connection(config.rpcUrl, 'confirmed');
  const accounts = await resolveAccounts(connection);
  if (typeof accounts === 'string') {
    console.warn(`Miner's Pass unavailable: ${accounts}`);
    return jsonResponse({ error: 'unavailable' }, 409);
  }

  const weekKey = await currentWeekKey(admin);
  if (await hasPass(admin, playerId, weekKey)) {
    return jsonResponse({ error: 'already_active', weekKey }, 409);
  }

  // Each build inserts an order; cap abandoned attempts.
  const { count } = await admin
    .from('miners_pass_orders')
    .select('id', { count: 'exact', head: true })
    .eq('player_id', playerId)
    .eq('status', 'pending')
    .gte('created_at', new Date(Date.now() - 10 * 60 * 1000).toISOString());
  if ((count ?? 0) >= MAX_PENDING_ORDERS) {
    return jsonResponse({ error: 'too_many_attempts' }, 429);
  }

  // Refuse up front if the wallet can't cover it — a friendlier error
  // than a failed simulation in the wallet app.
  const buyerAta = associatedTokenAddress(accounts.mint, buyer);
  let balance = 0n;
  try {
    const result = await connection.getTokenAccountBalance(buyerAta);
    balance = BigInt(result.value.amount);
  } catch (_e) {
    // No SKR token account: balance is zero.
  }
  if (balance < price) {
    return jsonResponse({
      error: 'insufficient_skr',
      needed: toUiAmount(price, accounts.decimals),
    }, 400);
  }

  const { data: order, error: orderError } = await admin
    .from('miners_pass_orders')
    .insert({
      player_id: playerId,
      network: config.network,
      buyer: buyer.toBase58(),
      amount_base: price.toString(),
    })
    .select('id')
    .single();
  if (orderError || !order) {
    console.error('Order insert failed:', orderError);
    return errorResponse('Could not create order', 500);
  }
  const orderId = order.id as string;

  const instructions = [
    ComputeBudgetProgram.setComputeUnitLimit({ units: config.computeUnits }),
    ComputeBudgetProgram.setComputeUnitPrice({
      microLamports: config.computeUnitPrice,
    }),
    transferCheckedInstruction(
      buyerAta,
      accounts.mint,
      accounts.treasuryAta,
      buyer,
      price,
      accounts.decimals,
    ),
    // Binds this transfer to this order, so nobody can claim someone
    // else's payment with its signature.
    new TransactionInstruction({
      programId: MEMO_PROGRAM_ID,
      keys: [{ pubkey: buyer, isSigner: true, isWritable: false }],
      data: Buffer.from(memoFor(orderId), 'utf8'),
    }),
  ];

  const latestBlockhash = await connection.getLatestBlockhash('confirmed');
  const message = new TransactionMessage({
    payerKey: buyer,
    recentBlockhash: latestBlockhash.blockhash,
    instructions,
  }).compileToV0Message();
  const serialized = new VersionedTransaction(message).serialize();

  console.log(
    `Built Miner's Pass tx: order ${orderId}, ` +
      `${toUiAmount(price, accounts.decimals)} SKR, ${serialized.length} bytes`,
  );

  return jsonResponse({
    transaction: Buffer.from(serialized).toString('base64'),
    orderId,
    amount: toUiAmount(price, accounts.decimals),
    lastValidBlockHeight: latestBlockhash.lastValidBlockHeight,
  });
}

// =============================================================
// POST /confirm
// =============================================================

async function handleConfirm(
  req: Request,
  admin: Admin,
  playerId: string,
): Promise<Response> {
  const config = getConfig();

  let orderId: string;
  let signature: string;
  try {
    const body = await req.json();
    orderId = body.orderId;
    signature = body.signature;
  } catch (_e) {
    return errorResponse('Invalid JSON body', 400);
  }
  if (typeof orderId !== 'string' || typeof signature !== 'string' ||
      !SIGNATURE_RE.test(signature)) {
    return errorResponse('Missing or invalid orderId / signature', 400);
  }

  const { data: order } = await admin
    .from('miners_pass_orders')
    .select('id, network, buyer, amount_base, status, week_key')
    .eq('id', orderId)
    .eq('player_id', playerId)
    .maybeSingle();
  if (!order) return errorResponse('Order not found', 404);
  if (order.network !== config.network) {
    return errorResponse('Order belongs to another network', 400);
  }

  // Idempotent: a retry after success just reports the pass.
  if (order.status === 'paid') {
    return jsonResponse({ status: 'paid', weekKey: order.week_key });
  }
  if (order.status === 'failed') {
    return jsonResponse({ status: 'failed' });
  }

  const connection = new Connection(config.rpcUrl, 'confirmed');
  const tx = await connection.getParsedTransaction(signature, {
    commitment: 'confirmed',
    maxSupportedTransactionVersion: 0,
  });
  if (!tx) {
    // Not landed (or not visible to this RPC) yet — client polls.
    return jsonResponse({ status: 'pending' });
  }

  if (tx.meta?.err) {
    await admin
      .from('miners_pass_orders')
      .update({ status: 'failed' })
      .eq('id', orderId)
      .eq('status', 'pending');
    return jsonResponse({ status: 'failed' });
  }

  // Accounts are re-derived from config, not from the price row: a
  // payment built before the price was deactivated must still count.
  const accounts = await resolveAccounts(connection);
  if (typeof accounts === 'string') {
    console.error(`Cannot verify order ${orderId}: ${accounts}`);
    return errorResponse('Verification unavailable, try again later', 503);
  }

  const problem = checkPayment(tx.transaction.message.instructions, {
    mint: accounts.mint.toBase58(),
    destination: accounts.treasuryAta.toBase58(),
    authority: order.buyer as string,
    amountBase: BigInt(order.amount_base),
    memo: memoFor(orderId),
  });
  if (problem) {
    // Leave the order pending: the player may still send the real tx.
    console.warn(`Order ${orderId} rejected signature ${signature}: ${problem}`);
    return jsonResponse({ status: 'invalid', error: problem }, 400);
  }

  const { data: weekKey, error: fulfillError } = await admin.rpc(
    'fulfill_miners_pass_order',
    { p_order_id: orderId, p_signature: signature },
  );
  if (fulfillError) {
    console.error(`Fulfil failed for ${orderId}:`, fulfillError);
    if (fulfillError.code === '23505') {
      return jsonResponse({
        status: 'invalid',
        error: 'This transaction already paid for another order',
      }, 409);
    }
    return errorResponse('Could not record the pass', 500);
  }

  console.log(`✅ Miner's Pass ${weekKey} for player ${playerId.slice(0, 8)}`);
  return jsonResponse({ status: 'paid', weekKey });
}

/**
 * Check a confirmed transaction's top-level instructions pay [expect].
 * Returns null when they do, otherwise what is wrong.
 */
function checkPayment(
  instructions: ReadonlyArray<unknown>,
  expect: {
    mint: string;
    destination: string;
    authority: string;
    amountBase: bigint;
    memo: string;
  },
): string | null {
  const parsed = instructions.filter(
    (ix): ix is ParsedInstruction =>
      typeof ix === 'object' && ix !== null && 'parsed' in ix,
  );

  const transfer = parsed.find((ix) =>
    ix.program === 'spl-token' && ix.parsed?.type === 'transferChecked'
  );
  if (!transfer) return 'no SKR transfer in transaction';

  const info = transfer.parsed.info;
  if (info.mint !== expect.mint) return 'wrong token';
  if (info.destination !== expect.destination) return 'wrong recipient';
  if (info.authority !== expect.authority) return 'wrong payer';
  if (BigInt(info.tokenAmount?.amount ?? '0') !== expect.amountBase) {
    return 'wrong amount';
  }

  const memoMatches = parsed.some((ix) =>
    ix.program === 'spl-memo' && ix.parsed === expect.memo
  );
  if (!memoMatches) return 'transaction is not for this order';

  return null;
}
