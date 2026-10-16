/**
 * supabase/functions/candy-machine-devnet/index.ts
 *
 * DEVNET twin of the candy-machine edge function. Deployed as its own
 * slug so devnet testing (debug builds route here automatically when
 * the wallet is on devnet) never disturbs mainnet users.
 *
 *   GET  /candy-machine-devnet/mint-info      — Devnet CM state
 *   POST /candy-machine-devnet/build-mint-tx  — Unsigned mintV2 tx
 *
 * Config lives in ./candy-machine-config.ts (DEVNET_* secrets with
 * safe public defaults — no secrets strictly required).
 *
 * URL: https://vdcpbqsnkivokroqxelq.supabase.co/functions/v1/candy-machine-devnet
 * Deploy:
 *   supabase functions deploy candy-machine-devnet --no-verify-jwt
 */

import { createUmi } from '@metaplex-foundation/umi-bundle-defaults';
import {
  mplCandyMachine,
  fetchCandyMachine,
  fetchCandyGuard,
  mintV2,
} from '@metaplex-foundation/mpl-candy-machine';
import {
  setComputeUnitLimit,
  setComputeUnitPrice,
} from '@metaplex-foundation/mpl-toolbox';
import {
  publicKey,
  generateSigner,
  transactionBuilder,
  some,
  createNoopSigner,
  signerIdentity,
} from '@metaplex-foundation/umi';
import {
  toWeb3JsTransaction,
  fromWeb3JsPublicKey,
  toWeb3JsPublicKey,
} from '@metaplex-foundation/umi-web3js-adapters';
import { Connection, PublicKey, Keypair, VersionedTransaction } from '@solana/web3.js';

import { handleCors, jsonResponse, errorResponse } from './cors.ts';
import { getConfig } from './candy-machine-config.ts';

// =============================================================
// ROUTE HANDLER
// =============================================================

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const url = new URL(req.url);
  // Edge function is mounted at /candy-machine-devnet, strip the prefix
  const path = url.pathname.replace(/^\/candy-machine-devnet\/?/, '/');

  try {
    switch (true) {
      case req.method === 'GET' && (path === '/mint-info' || path === '/mint-info/'):
        return await handleMintInfo();

      case req.method === 'POST' && (path === '/build-mint-tx' || path === '/build-mint-tx/'):
        return await handleBuildMintTx(req);

      case path === '/' || path === '/health' || path === '/health/':
        return jsonResponse({
          status: 'ok',
          function: 'candy-machine-devnet',
          network: 'devnet',
          routes: ['/mint-info', '/build-mint-tx'],
        });

      default:
        return errorResponse(`Not found: ${req.method} ${path}`, 404);
    }
  } catch (err) {
    console.error('Unhandled error:', err);
    return errorResponse('Internal server error', 500);
  }
});

// =============================================================
// GET /mint-info
// =============================================================

async function handleMintInfo(): Promise<Response> {
  const config = getConfig();

  try {
    const umi = createUmi(config.rpcUrl).use(mplCandyMachine());
    const cmKey = publicKey(config.candyMachineId);
    const cm = await fetchCandyMachine(umi, cmKey);

    // Try to fetch candy guard
    let guardInfo: Record<string, unknown> | null = null;
    try {
      const guard = await fetchCandyGuard(umi, cm.mintAuthority);
      const guards = guard.guards;

      const hasSolPayment = guards.solPayment.__option === 'Some';
      const hasStartDate = guards.startDate.__option === 'Some';
      const hasMintLimit = guards.mintLimit.__option === 'Some';
      const hasBotTax = guards.botTax.__option === 'Some';

      guardInfo = {
        address: String(guard.publicKey),
        hasSolPayment,
        solPaymentLamports: hasSolPayment
          ? Number(guards.solPayment.value.lamports.basisPoints)
          : null,
        solPaymentDestination: hasSolPayment
          ? String(guards.solPayment.value.destination)
          : null,
        hasStartDate,
        startDate: hasStartDate
          ? String(guards.startDate.value.date)
          : null,
        hasMintLimit,
        mintLimit: hasMintLimit
          ? Number(guards.mintLimit.value.limit)
          : null,
        hasBotTax,
      };
    } catch (_e) {
      // Guard not set up yet — that's fine
      console.log('No candy guard found (may not be wrapped yet)');
    }

    // Detect network from RPC URL
    const network = config.rpcUrl.includes('devnet') ? 'devnet'
      : config.rpcUrl.includes('testnet') ? 'testnet'
      : 'mainnet-beta';

    return jsonResponse({
      candyMachine: config.candyMachineId,
      collectionMint: config.collectionMint,
      itemsAvailable: Number(cm.data.itemsAvailable),
      itemsRedeemed: Number(cm.itemsRedeemed),
      itemsRemaining: Number(cm.data.itemsAvailable) - Number(cm.itemsRedeemed),
      symbol: String(cm.data.symbol),
      isMutable: Boolean(cm.data.isMutable),
      sellerFeeBasisPoints: Number(cm.data.sellerFeeBasisPoints),
      guard: guardInfo,
      rpcUrl: config.rpcUrl,
      network,
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    console.error('Error fetching mint info:', message);
    return errorResponse('Failed to fetch candy machine info');
  }
}

// =============================================================
// POST /build-mint-tx
// =============================================================

/**
 * Body: { minter: string, nftMint?: string }
 *
 * With `nftMint` (current app): the app generated the NFT mint keypair, so
 * the transaction comes back with NO signatures. The wallet signs first and
 * the app adds the mint keypair's signature after — the order Phantom needs
 * to simulate a multi-signer transaction and add its Lighthouse guards.
 *
 * Without it (app versions released before this change): the server
 * generates the mint keypair and pre-signs, as before.
 *
 * Either way the transaction is simulated before it is returned, so the
 * wallet is never asked to sign a mint that would fail — or, with the
 * guard's bot tax, land and charge the tax for nothing. The response
 * carries the simulated cost so the app can show it before signing.
 */
async function handleBuildMintTx(req: Request): Promise<Response> {
  const config = getConfig();

  // Parse request body
  let minter: string;
  let nftMintAddress: string | undefined;
  try {
    const body = await req.json();
    minter = body.minter;
    if (!minter || typeof minter !== 'string') {
      return errorResponse('Missing or invalid "minter" public key', 400);
    }
    if (body.nftMint !== undefined) {
      if (typeof body.nftMint !== 'string') {
        return errorResponse('Invalid "nftMint" public key', 400);
      }
      nftMintAddress = body.nftMint;
    }
  } catch (_e) {
    return errorResponse('Invalid JSON body', 400);
  }

  // Validate the pubkeys
  let minterPubkey: PublicKey;
  try {
    minterPubkey = new PublicKey(minter);
    if (!PublicKey.isOnCurve(minterPubkey.toBytes())) {
      return errorResponse('Public key is not on curve', 400);
    }
    if (nftMintAddress !== undefined) {
      const nftMintPubkey = new PublicKey(nftMintAddress);
      if (!PublicKey.isOnCurve(nftMintPubkey.toBytes()) || nftMintPubkey.equals(minterPubkey)) {
        return errorResponse('Invalid "nftMint" public key', 400);
      }
    }
  } catch (_e) {
    return errorResponse('Invalid public key format', 400);
  }

  try {
    console.log(`Building mint tx for: ${minter}${nftMintAddress ? ' (client mint key)' : ''}`);

    const connection = new Connection(config.rpcUrl, 'confirmed');

    // Create Umi with the minter as a noop signer identity
    // (we don't have their private key — they sign on-device via MWA)
    const minterUmiKey = fromWeb3JsPublicKey(minterPubkey);
    const minterSigner = createNoopSigner(minterUmiKey);

    const mintUmi = createUmi(config.rpcUrl)
      .use(mplCandyMachine())
      .use(signerIdentity(minterSigner, true));

    // The NFT mint account is new, so its key must sign. The current app
    // holds that keypair and signs after the wallet; older apps get a
    // server-generated one, signed below.
    const serverMint = nftMintAddress ? null : generateSigner(mintUmi);
    const nftMint = serverMint ?? createNoopSigner(publicKey(nftMintAddress!));

    // Build the mintV2 instruction
    const candyMachineKey = publicKey(config.candyMachineId);
    const collectionMintKey = publicKey(config.collectionMint);
    const collectionUpdateAuthKey = publicKey(config.collectionUpdateAuthority);

    // Fetch the candy machine and its guard
    const cm = await fetchCandyMachine(mintUmi, candyMachineKey);

    // The candy guard address is stored as the CM's mintAuthority
    const candyGuardKey = cm.mintAuthority;
    console.log(`Candy guard: ${candyGuardKey}`);

    let solPaymentDestination = collectionUpdateAuthKey;
    let priceLamports = 0n;
    let mintLimitId = 1;

    try {
      const guard = await fetchCandyGuard(mintUmi, candyGuardKey);
      if (guard.guards.solPayment.__option === 'Some') {
        solPaymentDestination = guard.guards.solPayment.value.destination;
        priceLamports = BigInt(guard.guards.solPayment.value.lamports.basisPoints);
      }
      if (guard.guards.mintLimit.__option === 'Some') {
        mintLimitId = guard.guards.mintLimit.value.id;
      }
    } catch (_e) {
      console.log('Using default SOL payment destination');
    }

    const txBuilder = transactionBuilder()
      .add(setComputeUnitLimit(mintUmi, { units: config.computeUnits }))
      .add(setComputeUnitPrice(mintUmi, { microLamports: config.computeUnitPrice }))
      .add(
        mintV2(mintUmi, {
          candyMachine: candyMachineKey,
          candyGuard: candyGuardKey,
          nftMint,
          collectionMint: collectionMintKey,
          collectionUpdateAuthority: collectionUpdateAuthKey,
          mintArgs: {
            solPayment: some({ destination: solPaymentDestination }),
            mintLimit: some({ id: mintLimitId }),
          },
        })
      );

    // Get a fresh blockhash
    const latestBlockhash = await connection.getLatestBlockhash('confirmed');

    // Build the transaction
    const tx = await txBuilder.buildWithLatestBlockhash(mintUmi, {
      ...latestBlockhash,
      lastValidBlockHeight: latestBlockhash.lastValidBlockHeight,
    });

    // Convert to web3.js VersionedTransaction for serialization
    const web3Tx = toWeb3JsTransaction(tx);

    // Legacy clients don't have the mint keypair, so sign it here.
    if (serverMint) {
      web3Tx.sign([Keypair.fromSecretKey(serverMint.secretKey)]);
    }

    // Refuse to hand the wallet a mint that would fail.
    const check = await simulateMint(
      connection,
      web3Tx,
      minterPubkey,
      toWeb3JsPublicKey(nftMint.publicKey),
      priceLamports,
    );
    if ('reason' in check) {
      console.log(`Mint tx refused for ${minter}: ${check.reason} (${check.detail})`);
      return jsonResponse({ error: 'simulation_failed', reason: check.reason, detail: check.detail }, 400);
    }

    // Serialize (unsigned, or partially signed for legacy clients)
    // VersionedTransaction.serialize() doesn't validate signatures by default
    const serialized = web3Tx.serialize();

    // Encode as base64 for transport
    const base64Tx = btoa(String.fromCharCode(...serialized));

    console.log(`✅ Built mint tx — NFT mint: ${nftMint.publicKey}, size: ${serialized.length} bytes`);

    return jsonResponse({
      transaction: base64Tx,
      mint: nftMint.publicKey.toString(),
      blockhash: latestBlockhash.blockhash,
      lastValidBlockHeight: latestBlockhash.lastValidBlockHeight,
      quote: {
        priceLamports,
        destination: String(solPaymentDestination),
        feeLamports: check.feeLamports,
        rentLamports: check.rentLamports,
        totalLamports: priceLamports + check.feeLamports + check.rentLamports,
      },
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    console.error('Error building mint tx:', message);
    return errorResponse(`Failed to build mint transaction: ${message}`);
  }
}

// =============================================================
// PRE-SIGN SIMULATION
// =============================================================

type SimulationReason =
  | 'insufficient_sol'
  | 'mint_limit'
  | 'sold_out'
  | 'not_started'
  | 'bot_tax'
  | 'unknown';

type MintCheck =
  | { feeLamports: bigint; rentLamports: bigint }
  | { reason: SimulationReason; detail: string };

/**
 * Simulate the mint without signatures (sigVerify off, so neither the
 * wallet's nor the client's mint signature is needed yet).
 *
 * The guard has bot tax: a failed guard check doesn't fail the transaction,
 * it charges the tax and mints nothing. So a clean simulation isn't enough —
 * the new mint account is read back from the simulated state, and a mint
 * that wasn't created counts as a failure.
 *
 * The simulated payer balance already has the fee taken out, so what the
 * minter spends beyond the price and the fee is rent for the new accounts.
 */
async function simulateMint(
  connection: Connection,
  tx: VersionedTransaction,
  minter: PublicKey,
  nftMint: PublicKey,
  priceLamports: bigint,
): Promise<MintCheck> {
  const [balance, sim, fee] = await Promise.all([
    connection.getBalance(minter, 'confirmed'),
    connection.simulateTransaction(tx, {
      sigVerify: false,
      replaceRecentBlockhash: true,
      commitment: 'confirmed',
      accounts: { encoding: 'base64', addresses: [minter.toBase58(), nftMint.toBase58()] },
    }),
    connection.getFeeForMessage(tx.message, 'confirmed'),
  ]);

  const { err, logs, accounts } = sim.value;
  const text = [err ? JSON.stringify(err) : '', ...(logs ?? [])].join('\n');
  const [minterAfter, mintAfter] = accounts ?? [];
  const minted = !!mintAfter && mintAfter.lamports > 0;

  if (err || !minted) {
    const detail = err ? JSON.stringify(err) : 'mint account not created (guard rejected the mint)';
    return { reason: simulationReason(text, minted), detail };
  }

  const feeLamports = BigInt(fee.value ?? 0);
  const spent = minterAfter ? BigInt(balance) - BigInt(minterAfter.lamports) : 0n;
  const rentLamports = spent > priceLamports + feeLamports ? spent - priceLamports - feeLamports : 0n;
  return { feeLamports, rentLamports };
}

/** Why the guard (or the runtime) would refuse this mint. Matches error
 *  names and messages in the logs; a bot-taxed mint logs the guard error
 *  that triggered the tax, so specific reasons win over `bot_tax`. */
function simulationReason(text: string, minted: boolean): SimulationReason {
  if (/NotEnoughSOL|Not enough SOL|AccountNotFound|InsufficientFundsForFee|insufficient (funds|lamports)/i.test(text)) {
    return 'insufficient_sol';
  }
  if (/AllowedMintLimitReached|maximum number of allowed mints|MintLimit/i.test(text)) return 'mint_limit';
  if (/CandyMachineEmpty|Candy machine is empty|MaximumRedeemedAmount|NotEnoughItems/i.test(text)) return 'sold_out';
  if (/MintNotLive|Mint is not live|AfterEndDate|after the set end date/i.test(text)) return 'not_started';
  if (!minted) return 'bot_tax';
  return 'unknown';
}
