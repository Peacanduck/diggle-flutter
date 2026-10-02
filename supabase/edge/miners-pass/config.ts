/**
 * miners-pass/config.ts
 * MAINNET Miner's Pass configuration.
 *
 * Set secrets via:
 *   supabase secrets set --env-file .env.local
 *
 * Required secrets:
 *   SOLANA_RPC_URL        — mainnet RPC (shared with candy-machine)
 *   SKR_TREASURY_WALLET   — wallet that receives SKR. Its SKR token
 *                           account must exist before going live
 *                           (`spl-token create-account <SKR mint> --owner <wallet>`).
 *
 * Optional:
 *   SKR_MINT              — defaults to the Seeker (SKR) mint
 *   COMPUTE_UNIT_PRICE    — priority fee in microlamports (shared)
 *
 * The price lives in the skr_prices table (network 'mainnet'), not here,
 * so it can change without a redeploy.
 */

export function getConfig() {
  return {
    network: 'mainnet' as const,

    rpcUrl: Deno.env.get('SOLANA_RPC_URL') || 'https://api.mainnet-beta.solana.com',

    // Seeker (SKR): classic SPL Token program, 6 decimals.
    skrMint: Deno.env.get('SKR_MINT')
      || 'SKRbvo6Gf7GondiT3BbTfuRDPqLWei4j2Qy2NPGZhW3',

    treasuryWallet: Deno.env.get('SKR_TREASURY_WALLET') || null,

    // transferChecked + memo fit comfortably.
    computeUnits: 40000,
    computeUnitPrice: parseInt(Deno.env.get('COMPUTE_UNIT_PRICE') || '50000'),
  };
}
