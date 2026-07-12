/**
 * candy-machine-devnet/candy-machine-config.ts
 * DEVNET candy machine configuration.
 *
 * This function exists so devnet testing never touches the mainnet
 * candy-machine function serving live users. Supabase secrets are
 * project-wide, so the devnet function uses DEVNET_-prefixed names
 * (with safe public defaults) and never reads the mainnet secrets.
 *
 * Optional secrets:
 *   DEVNET_SOLANA_RPC_URL — devnet RPC (defaults to public devnet)
 */

export function getConfig() {
  return {
    rpcUrl: Deno.env.get('DEVNET_SOLANA_RPC_URL')
      || 'https://api.devnet.solana.com',

    candyMachineId: Deno.env.get('DEVNET_CANDY_MACHINE_ID')
      || '3iniDHsBymdEdxB7yvRG4sE11JXP1d89dqvXfTsXWNr2',

    collectionMint: Deno.env.get('DEVNET_COLLECTION_MINT')
      || '4eFNHpLUiVEAh2wi9K1YLUEeTdDYJgjiLhgEkxbw8upV',

    collectionUpdateAuthority: Deno.env.get('DEVNET_COLLECTION_UPDATE_AUTH')
      || '6tXwopHLEUr5DEiert4ASgmEQnfV3CQ2dkVWCTVvHUR9',

    computeUnits: parseInt(Deno.env.get('COMPUTE_UNITS') || '400000'),
    computeUnitPrice: parseInt(Deno.env.get('COMPUTE_UNIT_PRICE') || '50000'),
  };
}
