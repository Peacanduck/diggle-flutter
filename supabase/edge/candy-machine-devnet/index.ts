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
import { Connection, PublicKey, Keypair } from '@solana/web3.js';

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

async function handleBuildMintTx(req: Request): Promise<Response> {
  const config = getConfig();

  // Parse request body
  let minter: string;
  try {
    const body = await req.json();
    minter = body.minter;
    if (!minter || typeof minter !== 'string') {
      return errorResponse('Missing or invalid "minter" public key', 400);
    }
  } catch (_e) {
    return errorResponse('Invalid JSON body', 400);
  }

  // Validate the pubkey
  let minterPubkey: PublicKey;
  try {
    minterPubkey = new PublicKey(minter);
    if (!PublicKey.isOnCurve(minterPubkey.toBytes())) {
      return errorResponse('Public key is not on curve', 400);
    }
  } catch (_e) {
    return errorResponse('Invalid public key format', 400);
  }

  try {
    console.log(`Building mint tx for: ${minter}`);

    const connection = new Connection(config.rpcUrl, 'confirmed');

    // Create Umi with the minter as a noop signer identity
    // (we don't have their private key — they sign on-device via MWA)
    const minterUmiKey = fromWeb3JsPublicKey(minterPubkey);
    const minterSigner = createNoopSigner(minterUmiKey);

    const mintUmi = createUmi(config.rpcUrl)
      .use(mplCandyMachine())
      .use(signerIdentity(minterSigner, true));

    // Generate a new mint keypair for the NFT
    const nftMint = generateSigner(mintUmi);

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

    try {
      const guard = await fetchCandyGuard(mintUmi, candyGuardKey);
      if (guard.guards.solPayment.__option === 'Some') {
        solPaymentDestination = guard.guards.solPayment.value.destination;
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
            mintLimit: some({ id: 1 }),
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

    // The nftMint keypair must sign (it's a new account being created).
    // We sign it here because the client doesn't have this keypair.
    // The minter's signature gets added by MWA on the client.
    const nftMintKeypair = Keypair.fromSecretKey(nftMint.secretKey);
    web3Tx.sign([nftMintKeypair]);

    // Serialize the partially-signed transaction
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
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    console.error('Error building mint tx:', message);
    return errorResponse(`Failed to build mint transaction: ${message}`);
  }
}