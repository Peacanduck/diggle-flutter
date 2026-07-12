/**
 * _shared/candy-machine-config.ts
 * Candy Machine configuration — shared between edge functions.
 *
 * Secrets should be set via:
 *   supabase secrets set --env-file .env.local
 *
 * Required secrets:
 *   SOLANA_RPC_URL          — Your RPC endpoint (Helius, QuickNode, etc.)
 *
 * Optional (defaults provided):
 *   CANDY_MACHINE_ID        — Your candy machine address
 *   COLLECTION_MINT         — Collection NFT mint address
 *   COLLECTION_UPDATE_AUTH  — Collection update authority
 *   COMPUTE_UNITS           — Compute unit limit for mint tx
 *   COMPUTE_UNIT_PRICE      — Priority fee in microlamports
 */

export function getConfig() {
  return {
    rpcUrl: Deno.env.get('SOLANA_RPC_URL') || 'https://api.mainnet-beta.solana.com',

    candyMachineId: Deno.env.get('CANDY_MACHINE_ID')
      || '7LtViZU4Y672qZVC6jxHPipVEHXeCKUcKR6cG8zMCwqP',

    collectionMint: Deno.env.get('COLLECTION_MINT')
      || '3FJkKz61tMRt3rDzGk1Xp6mTN8kGYXtwSTgYaYEmx5fG',

    collectionUpdateAuthority: Deno.env.get('COLLECTION_UPDATE_AUTH')
      || '6tXwopHLEUr5DEiert4ASgmEQnfV3CQ2dkVWCTVvHUR9',

    computeUnits: parseInt(Deno.env.get('COMPUTE_UNITS') || '400000'),
    computeUnitPrice: parseInt(Deno.env.get('COMPUTE_UNIT_PRICE') || '50000'),
  };
}