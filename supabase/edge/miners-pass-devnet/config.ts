/**
 * miners-pass-devnet/config.ts
 * DEVNET Miner's Pass configuration.
 *
 * This function exists so devnet rehearsals never touch the mainnet
 * miners-pass function serving live users. Supabase secrets are
 * project-wide, so it reads DEVNET_-prefixed names and never the
 * mainnet ones. Passes it grants are stored with network 'devnet' and
 * never count on mainnet.
 *
 * SKR does not exist on devnet: create a dummy 6-decimal mint
 * (`spl-token create-token --decimals 6 -u devnet`) and point
 * DEVNET_SKR_MINT at it.
 *
 * Required secrets:
 *   DEVNET_SKR_MINT             — the dummy SKR mint
 *   DEVNET_SKR_TREASURY_WALLET  — wallet that receives it (its token
 *                                 account must exist)
 *
 * Optional:
 *   DEVNET_SOLANA_RPC_URL       — defaults to public devnet
 *
 * The price lives in the skr_prices table (network 'devnet').
 */

export function getConfig() {
  return {
    network: 'devnet' as const,

    rpcUrl: Deno.env.get('DEVNET_SOLANA_RPC_URL')
      || 'https://api.devnet.solana.com',

    skrMint: Deno.env.get('DEVNET_SKR_MINT') || null,

    treasuryWallet: Deno.env.get('DEVNET_SKR_TREASURY_WALLET') || null,

    computeUnits: 40000,
    computeUnitPrice: parseInt(Deno.env.get('COMPUTE_UNIT_PRICE') || '50000'),
  };
}
