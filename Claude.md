# Diggle

A 2D mining game inspired by Motherload, built with Flutter and Flame engine, with Solana blockchain integration for an on-chain premium store.

## Tech Stack

- **Framework:** Flutter (Dart)
- **Game Engine:** Flame ^1.16.0
- **Audio:** flame_audio ^2.1.8
- **State Management:** Provider ^6.1.2
- **Blockchain:** Solana (devnet/mainnet)
    - `solana: ^0.31.0` — Espresso Cash Solana Dart library (RPC, transaction encoding, key derivation)
    - `solana_mobile_client: ^0.1.2` — Mobile Wallet Adapter (MWA) for Android wallet interaction
- **Target Platform:** Android first (Solana Mobile / Saga / Seeker compatible), iOS bonus
- **Backend:** Supabase (Postgres + Edge Functions)
    - `supabase_flutter: ^2.0.0` — Dart client for auth, database, realtime
    - Player persistence: XP, points, world saves
    - Server-authoritative points ledger for future SPL token redemption
    - Edge Functions (Deno/TypeScript) for validated point awards and token minting

## Project Structure

```
lib/
├── main.dart                         # App entry, Provider setup
├── game/
│   ├── diggle_game.dart              # FlameGame subclass, core game loop
│   ├── world/
│   │   ├── tile.dart                 # Tile types with hardness
│   │   ├── tile_map_component.dart   # Tile map rendering
│   │   └── world_generator.dart      # Seeded procedural generation
│   ├── player/
│   │   └── drill_component.dart      # Player movement, digging, fuel/hull
│   └── systems/
│       ├── fuel_system.dart          # Fuel depletion and refueling
│       ├── economy_system.dart       # Cash, ore selling
│       ├── hull_system.dart          # Hull damage and repair
│       ├── item_system.dart          # Consumable items (dynamite, C4, etc.)
│       ├── drillbit_system.dart      # Drill upgrades (4 tiers)
│       ├── engine_system.dart        # Movement speed upgrades
│       ├── cooling_system.dart       # Fuel efficiency upgrades
│       ├── xp_points_system.dart     # XP leveling + points currency
│       └── boost_manager.dart        # On-chain boost purchases, NFT detection
├── solana/
│   ├── wallet_service.dart           # MWA wallet connection, signing, cluster switching
│   └── diggle_mart_client.dart       # On-chain program client (PDA, tx building, deserialization)
├── services/
│   ├── supabase_service.dart         # Supabase client init, auth, core DB operations
│   ├── player_service.dart           # Player profile CRUD, wallet linking
│   ├── stats_service.dart            # XP/points persistence, server-validated awards
│   ├── world_save_service.dart       # World state save/load with compression
│   └── points_ledger_service.dart    # Auditable points transaction log
└── ui/
    ├── main_menu.dart                # Title screen with wallet connect
    ├── hud_overlay.dart              # In-game HUD (fuel, cash, depth)
    ├── shop_overlay.dart             # In-game shop (services, upgrades, items)
    └── premium_store_overlay.dart    # SOL premium store (boosters, points packs, NFTs)
```

## On-Chain Program: Diggle Mart

**Program ID:** `6CQzNRRyMYox8G3oWLPJ8MwXthznqq6bMREdUwqKDNKA`
**Framework:** Anchor
**IDL:** `target/idl/diggle_mart.json` (TypeScript types in `diggle_mart.ts`)

### Instructions

| Instruction | Args | Description |
|---|---|---|
| `initializeStore` | `config: StoreConfig` | Admin: creates Store + Treasury PDAs |
| `updateStore` | `config: StoreConfig` | Admin: updates pricing/multipliers |
| `withdrawTreasury` | `amount: u64` | Admin: withdraw SOL from treasury |
| `purchaseBooster` | `boosterType: u8, durationSeconds: i64` | Buy timed XP/Points/Combo boost |
| `purchasePointsPack` | `packType: u8` | Buy points (0=small, 1=large) |
| `mintNft` | — | Mint limited edition NFT from collection |
| `initializeNftCollection` | `maxSupply, mintPrice, name, symbol, uri` | Admin: setup NFT collection |

### Account Types

| Account | Discriminator | Seeds |
|---|---|---|
| `Store` | `[130, 48, 247, 244, 182, 191, 30, 26]` | `["store"]` |
| `Treasury` (PDA, no data) | — | `["treasury"]` |
| `BoosterAccount` | `[76, 202, 210, 44, 136, 61, 228, 19]` | `["booster", buyer_pubkey, booster_count_u64_le]` |
| `NftCollection` | `[230, 92, 80, 190, 97, 0, 132, 22]` | `["nft_collection"]` |

### Instruction Discriminators

| Instruction | Discriminator |
|---|---|
| `purchaseBooster` | `[251, 49, 11, 156, 68, 194, 21, 140]` |
| `purchasePointsPack` | `[125, 42, 47, 199, 26, 93, 227, 99]` |
| `mintNft` | `[211, 57, 6, 167, 15, 219, 35, 251]` |

### StoreConfig Fields

All prices in lamports, multipliers in basis points (15000 = 1.5x, 20000 = 2.0x):

```
xpBoostPricePerHour: u64
pointsBoostPricePerHour: u64
comboBoostPricePerHour: u64
xpBoostMultiplier: u16
pointsBoostMultiplier: u16
comboBoostMultiplier: u16
pointsPackSmallPrice: u64
pointsPackSmallAmount: u32
pointsPackLargePrice: u64
pointsPackLargeAmount: u32
isActive: bool
```

### Booster Types

- `0` = XP Boost
- `1` = Points Boost
- `2` = Combo Boost (both XP + Points)

### Error Codes

| Code | Name |
|---|---|
| 6000 | `unauthorized` |
| 6001 | `invalidBoosterType` |
| 6002 | `storeInactive` |
| 6003 | `insufficientPayment` |
| 6004 | `invalidPackType` |
| 6005 | `collectionSoldOut` |
| 6006 | `mintingInactive` |
| 6007 | `arithmeticOverflow` |
| 6008 | `invalidDuration` |

## Solana Integration Architecture

### Transaction Flow (Purchase)

```
User taps BUY
  → boost_manager.purchaseWithSOL(item)
    → diggle_mart_client.buildPurchaseBoosterTx() — builds unsigned tx with Anchor discriminator + Borsh args
    → wallet_service.signAndSendTransaction(txBytes)
      → wallet_service.signTransaction(txBytes) — MWA session: reauthorize → signTransactions
      → rpcClient.sendTransaction(base64EncodedSignedTx) — submit via RPC with retry (network recovery after app switch)
    → diggle_mart_client.confirmTransaction(signature) — poll getSignatureStatuses for 30s
    → Apply effects locally (add booster or award points)
```

### MWA (Mobile Wallet Adapter) Pattern

The wallet uses `LocalAssociationScenario` from `solana_mobile_client`:

1. `LocalAssociationScenario.create()` — create session
2. `session.startActivityForResult(null)` — launch wallet app (unawaited)
3. `session.start()` — get MWA client
4. `client.reauthorize(...)` or `client.authorize(...)` — authenticate
5. `client.signTransactions(transactions: [...])` — sign
6. `session.close()` — cleanup

**Important:** After MWA app switch, Android may temporarily lose network connectivity. The `signAndSendTransaction` method retries RPC submission up to 3 times with increasing delays for `SocketException`/host lookup failures.

### Account Data Deserialization

The `solana` dart package returns `BinaryAccountData` when using `encoding: Encoding.base64`. The `.data` property is already decoded bytes (`List<int>`), NOT a base64 string. Do NOT call `base64Decode()` on it:

```dart
// CORRECT
final data = Uint8List.fromList((accountInfo.value!.data as BinaryAccountData).data);

// WRONG — will throw "type 'int' is not a subtype of type 'String'"
final data = base64Decode((accountInfo.value!.data as BinaryAccountData).data[0] as String);
```

### Solana Dart Package Gotchas

- **Import conflicts:** Both `dto.dart` and `encoder.dart` export `Instruction`. Use `hide Instruction` on `dto.dart` and `solana.dart`:
  ```dart
  import 'package:solana/dto.dart' hide Instruction;
  import 'package:solana/encoder.dart';
  import 'package:solana/solana.dart' hide Instruction;
  ```
- **AccountMeta:** Uses British spelling `AccountMeta.writeable()`, not `writable`. No `writableSigner()` — use `AccountMeta.writeable(pubKey: key, isSigner: true)`.
- **CompiledMessage:** Does NOT have a `.data` getter or `.toList()`. Use `SignedTx` for serialization:
  ```dart
  final tx = SignedTx(
    compiledMessage: compiledMessage,
    signatures: List.filled(numSigs, Signature(List.filled(64, 0), publicKey: feePayer)),
  );
  final bytes = Uint8List.fromList(tx.toByteArray().toList());
  ```
- **ParsedAccountData:** The `.parsed` property returns `Object`, must cast to `Map<String, dynamic>` before indexing.

## Game Systems

### XP & Points System (`xp_points_system.dart`)

- XP drives leveling (exponential curve)
- Points are spendable currency for in-game shop items
- Both can be boosted by on-chain multipliers
- API: `addXP()`, `addPoints()`, `spendPoints()`, `setXPBoost()`, `setPointsBoost()`

### Boost Manager (`boost_manager.dart`)

- Extends `ChangeNotifier` for UI reactivity
- Manages both local (points-bought) and on-chain (SOL-bought) boosters
- Fetches store config on init and wallet connect
- `_fetchStoreConfig(silent: true)` during purchases to avoid UI flicker
- Syncs active on-chain boosters via `getProgramAccounts` with memcmp filters
- 30-second timer checks for expired boosters
- `refreshStoreConfig()` public method for manual retry

### Premium Store UI (`premium_store_overlay.dart`)

- Green dot = on-chain prices loaded, Orange dot = using defaults
- Refresh button when showing defaults
- Cyan highlight for on-chain boosters, green for local
- Loading spinner during transactions
- Displays transaction signature on success

## Development Notes

### Running

```bash
flutter pub get
flutter run  # Android device with wallet app installed
```

### Devnet Testing

- Default cluster is devnet (`https://api.devnet.solana.com`)
- Phantom wallet has best devnet MWA support
- Store must be initialized on-chain via `initializeStore` before purchases work
- Airdrop devnet SOL to test wallet for purchases

### Cluster Switching

`WalletService` supports devnet/mainnet toggle:
```dart
walletService.setCluster(SolanaCluster.mainnet);
walletService.toggleCluster(); // switches between devnet/mainnet
```

### NFT Integration Status

- `mintNft` transaction building is implemented
- NFT detection via wallet token account scanning is basic (checks for decimals=0, amount=1)
- Full Metaplex metadata verification (collection field check) is TODO
- NFT mint requires pre-created mint keypair (not yet integrated into UI flow)

## Supabase Backend

### Why Supabase over Firebase

- **Postgres** — proper transactional guarantees for points ledger (critical when points become redeemable SPL tokens)
- **Edge Functions** — Deno/TypeScript runtime where server-side Solana signing can run for SPL token minting
- **Row-Level Security (RLS)** — players can only read/write their own data
- **JSONB columns** — clean storage for game system state (upgrades, inventory) without document size limits
- **SQL foundation** — audit trail queries, anti-cheat analytics, leaderboards via simple queries
- **Real-time subscriptions** — future leaderboards or multiplayer features

### Database Schema

```sql
-- ============================================================
-- PLAYERS
-- ============================================================

create table players (
  id uuid primary key default gen_random_uuid(),
  wallet_address text unique,             -- Solana pubkey (set on wallet connect)
  device_id text unique,                  -- Anonymous play before wallet connect
  display_name text,
  created_at timestamptz default now(),
  last_seen_at timestamptz default now()
);

-- Index for fast wallet lookups
create index idx_players_wallet on players(wallet_address);

-- ============================================================
-- PLAYER STATS (XP, Points, Level)
-- ============================================================

create table player_stats (
  player_id uuid primary key references players(id) on delete cascade,
  xp bigint default 0,
  points bigint default 0,
  level int default 1,
  total_points_earned bigint default 0,   -- lifetime total (never decreases)
  total_points_spent bigint default 0,    -- in-game shop spending
  total_points_redeemed bigint default 0, -- SPL token redemptions
  total_xp_earned bigint default 0,
  max_depth_reached int default 0,
  total_ores_mined bigint default 0,
  total_play_time_seconds bigint default 0,
  updated_at timestamptz default now()
);

-- ============================================================
-- WORLD SAVES
-- ============================================================

create table world_saves (
  id uuid primary key default gen_random_uuid(),
  player_id uuid references players(id) on delete cascade,
  slot int default 0,                     -- save slot (0-2)
  seed int not null,                      -- world generation seed
  world_data bytea,                       -- zlib-compressed tile map
  player_position jsonb,                  -- {x, y} tile coordinates
  depth_reached int default 0,
  playtime_seconds int default 0,
  game_systems jsonb,                     -- snapshot of all system states:
                                          -- fuel, hull, cash, inventory,
                                          -- drillbit/engine/cooling levels,
                                          -- active boosters
  saved_at timestamptz default now(),
  unique(player_id, slot)                 -- one save per slot per player
);

-- ============================================================
-- POINTS LEDGER (Audit Trail)
-- ============================================================
-- Critical for future SPL token redemption. Every point earned,
-- spent, or redeemed is logged with source and optional tx sig.

create table points_ledger (
  id uuid primary key default gen_random_uuid(),
  player_id uuid references players(id) on delete cascade,
  amount bigint not null,                 -- positive = earn, negative = spend/redeem
  balance_after bigint not null,          -- snapshot for reconciliation
  source text not null,                   -- see Point Sources below
  metadata jsonb,                         -- source-specific data (ores, pack_type, etc.)
  tx_signature text,                      -- Solana tx sig (for on-chain operations)
  created_at timestamptz default now()
);

create index idx_ledger_player on points_ledger(player_id, created_at desc);
create index idx_ledger_source on points_ledger(source);

-- ============================================================
-- ROW-LEVEL SECURITY
-- ============================================================

alter table players enable row level security;
alter table player_stats enable row level security;
alter table world_saves enable row level security;
alter table points_ledger enable row level security;

-- Players can read/update their own data
create policy "players_own" on players
  for all using (id = auth.uid());

create policy "stats_own" on player_stats
  for all using (player_id = auth.uid());

create policy "saves_own" on world_saves
  for all using (player_id = auth.uid());

-- Ledger is insert-only from client (server function handles updates)
create policy "ledger_read_own" on points_ledger
  for select using (player_id = auth.uid());
```

### Point Sources

| Source | Direction | Description |
|---|---|---|
| `mining` | + | Points earned from mining ores |
| `level_up` | + | Bonus points on level up |
| `achievement` | + | Achievement/milestone rewards |
| `pack_purchase` | + | On-chain points pack (SOL → points) |
| `shop_spend` | − | Spent in in-game shop |
| `booster_purchase` | − | Spent on local booster |
| `spl_redemption` | − | Redeemed for SPL tokens (future) |

### Auth Strategy

Players start anonymous (device ID) and optionally link a wallet:

```
1. First launch → Supabase anonymous auth → create player with device_id
2. Connect wallet → link wallet_address to existing player
3. Future launches → auth via device_id, wallet_address used for on-chain ops
```

This means the game is fully playable without a wallet. Wallet connection unlocks premium store and future SPL redemption.

### Data Flow

```
Game Session:
  Mining ores → local XP/points update (immediate feedback)
                → batch sync to Supabase every 30s or on pause/exit
                → stats_service.syncStats() validates and persists

World Save:
  Pause/exit → compress tile map with zlib
             → serialize game systems to JSON
             → world_save_service.save(slot)

Points Ledger:
  Every points change → insert ledger entry with source + metadata
  On-chain purchases → include tx_signature in ledger entry

Future SPL Redemption:
  User requests redemption
    → Edge Function: begin tx → verify points balance → deduct points
    → Sign SPL mint/transfer with treasury keypair
    → Insert ledger entry with source='spl_redemption' + tx_signature
    → Commit (or rollback on chain failure)
```

### Server-Authoritative Validation

Points will have real token value, so the server must validate earnings:

- **Session reports** contain: ores mined (types + counts), depth reached, play time, active boosters
- **Edge Function** calculates expected points from session data and compares to claimed amount
- **Rate limits**: max points per minute based on theoretical maximum mining speed
- **Anti-cheat flags**: impossible depth without proper drillbit level, points earned while offline, etc.
- **Client sends both local total and session delta** — server reconciles and rejects anomalies

### Compression for World Saves

Tile maps (64×128+ tiles) are compressed before storage:

```dart
// Save: compress tile map
final tileBytes = tileMap.serialize();        // custom compact binary format
final compressed = zlib.encode(tileBytes);    // dart:io ZLibCodec
// Store compressed in world_saves.world_data (bytea)

// Load: decompress
final decompressed = zlib.decode(compressedBytes);
final tileMap = TileMap.deserialize(decompressed);
```

Each tile needs ~2 bytes (type + mined flag), so a 64×128 map is ~16KB raw, ~2-4KB compressed.

### Supabase Edge Functions (Future)

Located in `supabase/functions/`:

| Function | Purpose |
|---|---|
| `validate-session` | Validates mining session data, awards points server-side |
| `redeem-points` | Burns points, mints SPL tokens to player wallet |
| `leaderboard` | Aggregated stats queries for public leaderboard |

### Environment Config

```
SUPABASE_URL=https://<project-id>.supabase.co
SUPABASE_ANON_KEY=eyJ...                    # Public anon key (safe in client)
SUPABASE_SERVICE_KEY=eyJ...                  # Server-only (Edge Functions)
TREASURY_KEYPAIR=<base58-encoded>            # For SPL minting (Edge Functions only)
```

### SPL Token Redemption (Future Roadmap)

The points → SPL token pipeline will work as follows:

1. **NFT gate** — only wallets holding a Diggle NFT can redeem points
2. **Minimum redemption** — e.g., 1000 points minimum per redemption
3. **Cooldown** — one redemption per 24h per wallet
4. **Exchange rate** — configurable in Supabase (e.g., 100 points = 1 token)
5. **Flow**: client requests → Edge Function verifies NFT ownership on-chain → deducts points atomically → mints/transfers SPL tokens → logs tx_signature in ledger
6. **Token mint authority** lives in Edge Function env, never on client

## Common Issues

| Symptom | Cause | Fix |
|---|---|---|
| "Using default prices" in store | Store PDA not found or fetch failed | Check if store is initialized on-chain; check debug logs for PDA address |
| `SocketException` after wallet signing | Android network drops during app switch | Built-in retry with 1-3s delays handles this |
| `type 'int' is not a subtype of 'String'` | Calling `base64Decode` on already-decoded bytes | Use `Uint8List.fromList(binaryAccountData.data)` |
| `ambiguous_import` for `Instruction` | Both `dto.dart` and `encoder.dart` export it | Add `hide Instruction` to `dto.dart` and `solana.dart` imports |
| `undefined_method 'writableSigner'` | Wrong API name | Use `AccountMeta.writeable(pubKey: ..., isSigner: true)` |
| Wallet opens but no transaction prompt | Malformed transaction bytes | Verify `SignedTx.toByteArray()` serialization; check byte count in logs |
| Store prices not updating UI | Missing `notifyListeners()` | `_fetchStoreConfig()` calls `notifyListeners()` after successful load |