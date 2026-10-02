# Diggle

A 2D mining game inspired by Motherload, built with Flutter and Flame engine, with Solana integration: a Diggle Machine NFT mint and a weekly Miner's Pass paid in SKR (the Seeker token).

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
│   │   └── drill_component.dart      # Player movement, digging, fuel/hull,
│   │                                 #   layered NFT gear rendering (_renderGear)
│   └── systems/
│       ├── fuel_system.dart          # Fuel depletion and refueling
│       ├── economy_system.dart       # Cash, ore selling
│       ├── hull_system.dart          # Hull damage and repair
│       ├── item_system.dart          # Consumable items (dynamite, C4, etc.)
│       ├── drillbit_system.dart      # Drill upgrades (4 tiers)
│       ├── engine_system.dart        # Movement speed upgrades
│       ├── cooling_system.dart       # Fuel efficiency upgrades
│       ├── gear_system.dart          # NFT trait parsing + equip + stat bonuses
│       ├── gear_sprites.dart         # GENERATED gear sprite-sheet lookup (see below)
│       ├── xp_points_system.dart     # XP leveling + points currency
│       └── boost_manager.dart        # Holder boosts (Diggle NFT × Seeker Genesis Token)
├── solana/
│   ├── wallet_service.dart           # MWA wallet connection, signing, cluster switching
│   ├── candy_machine_service.dart    # NFT mint (candy-machine edge fn) + ownership scan
│   └── miners_pass_service.dart      # Miner's Pass paid in SKR (miners-pass edge fn)
├── services/
│   ├── supabase_service.dart         # Supabase client init, auth, core DB operations
│   ├── player_service.dart           # Player profile CRUD, wallet linking
│   ├── stats_service.dart            # XP/points persistence, server-validated awards
│   ├── world_save_service.dart       # World state save/load with compression
│   ├── points_ledger_service.dart    # Auditable points transaction log
│   ├── xp_stats_bridge.dart          # Bridge: XPPointsSystem ↔ StatsService
│   └── game_lifecycle_manager.dart   # Coordinates auth, wallet linking, sync, saves
└── ui/
    ├── main_menu.dart                # Title screen with wallet connect
    ├── hud_overlay.dart              # In-game HUD (fuel, cash, depth)
    ├── shop_overlay.dart             # In-game shop (services, upgrades, items)
    └── premium_store_overlay.dart    # Premium store: Diggle Machine NFT mint
```

## Diggle Mart (closed 2026-09-29)

The Anchor program `CHY3Z9P6icJiB4zDjoemhWWR71yh11Fhz8dhZHaxpsV4` (same ID on
mainnet and devnet; `6CQz…` in its Anchor.toml is only the localnet ID) sold
timed XP/Points/Combo boosters and points packs for SOL. It is being closed and
the app no longer calls it: the premium store's SOL and Points tabs, timed
boosters and `diggle_mart_client.dart` are gone.

Source + admin scripts live in WSL: `/root/projects/diggle_store/diggle_mart`
(program) and `/root/projects/diggle_store/scripts` (`store_admin.js`,
`devnet_skr_token.sh`, README). Payments went to the treasury PDA
`6VgbEz6iebS9ptiAp4w8q5NL3W7aS82HhN7MrTwu7Fch`, not a personal wallet.
Mainnet store authority = program upgrade authority = the CLI keypair
`6tXw…HUR9`; the devnet store authority is a different wallet (`9MNv…yY9U`).

Shutdown order (mainnet — release builds use mainnet; writes simulate unless `--send`):
1. `node store_admin.js deactivate --cluster mainnet --send` — updateStore with the
   current config and `isActive = false`; old clients then fail with `storeInactive`
   (6005), no SOL taken
2. `node store_admin.js withdraw --cluster mainnet --send` — FULL treasury balance.
   Only the program can move SOL out of the treasury PDA; after close it is stranded
3. `solana program close CHY3Z9P6icJiB4zDjoemhWWR71yh11Fhz8dhZHaxpsV4 -u mainnet-beta --bypass-warning`
   — returns the program-data rent (~1.74 SOL); the ID can never be reused
4. Apply `supabase/migrations/20260929_retire_store_sources.sql`

Historical `pack_purchase` / `booster_purchase` ledger rows remain; `award_points`
v4 refuses those sources from clients.

## Solana Integration Architecture

### Transaction Flow (Miner's Pass, paid in SKR)

No on-chain program: a plain SPL `transferChecked` of SKR, built and verified
server-side by the `miners-pass` edge function.

```
User taps "<price> SKR" (Quests → Weekly)
  → miners_pass_service.purchase()
    → edge fn /build-tx — checks price + SKR balance, inserts a pending order, builds a v0 tx:
        compute budget + transferChecked(buyer ATA → treasury ATA) + memo "diggle:miners_pass:<orderId>"
    → wallet_service.signAndSendTransaction(txBytes)
      → wallet_service.signTransaction(txBytes) — MWA session: reauthorize → signTransactions
      → rpcClient.sendTransaction(...) — submit via RPC with retry (network recovery after app switch)
    → persist {orderId, signature} — restore() finishes it if the app dies before verification
    → poll edge fn /confirm — getParsedTransaction; checks mint, destination, amount, payer, memo;
        fulfill_miners_pass_order() records the pass for the current ISO week
    → questSystem.activateMinersPassFor(weekKey)
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

### NFT Gear Sprites (added 2026-07-09)

Equipped Diggle Machine NFTs now render as **layered per-slot pixel sprites**
instead of the tinted base sprite. Art matches the reveal collection
(pixel-art pivot in `D:\code\DiggleAssets\svgart\`).

**Assets** (registered in pubspec):
- `assets/images/DiggleGearSpriteSheet.png` — 32px cells, 5 columns =
  `GearRarity.index`, 10 rows = slot × view. Rows 0-4 = side view (faces
  RIGHT), rows 5-9 = down view (drilling down: flames up, drill at bottom).
- `assets/images/gear/` — 25 × 512px transparent per-part preview PNGs
  for UI (hangar trait cards use them via `GearSpriteSheet.previewAsset`).

**Code**:
- `lib/game/systems/gear_sprites.dart` — GENERATED by
  `DiggleAssets/svgart/sprites.py`. Do not hand-edit; regenerate + re-copy
  (must stay UTF-8). Provides `GearSpriteSheet.cell(slot, rarity, down:)`,
  `drawOrder` (hull → fuelTank → thruster → drill → cargoHold, same
  painter's order as the NFT reveal compositor) and `previewAsset(partName)`.
- `drill_component.dart::_renderGear` — draws the 5 slot layers when
  `gearSystem.equipped != null && equipped.isComplete`; mirrors the side
  view for facing left, rotates the down view 180° for flying up, and keeps
  the critical-hull/out-of-fuel color filters. Anything else (no NFT,
  sealed crate) falls back to the original base sprite + rarity tint.

**Art workflow**: edit part art in `DiggleAssets/svgart/sprites.py` →
`python sprites.py` → copy `sprites_out/DiggleGearSpriteSheet.png` to
`assets/images/` and `sprites_out/gear_sprites.dart` to
`lib/game/systems/`.

**Collection facts** (locked 2026-07-10): 10k tokens, rarity curve per slot
Common 50% / Uncommon 25% / Rare 15% / Epic 8% / Legendary 2%
(~200 tokens per legendary part), all combos unique. The Common tier has
TWO parts per slot (Standard Prospector + Rusty Hauler, Ion Drive +
Turbo Fan, Diesel Canister + Oil Drum, Steel Augur + Iron Pike,
Standard Bin + Scrap Basket) — 30 gameplay parts total; this is what
makes the steep curve feasible under uniqueness. Both Common variants
give identical stats and share the Common sprite-sheet cell (previews
in `assets/images/gear/` are per-part). Reveal set:
`DiggleAssets/final_pixel/`. Trait names in metadata match
`_partNameRarity` in gear_system.dart 1:1.

### XP & Points System (`xp_points_system.dart`)

- XP drives leveling (exponential curve)
- Points are spendable currency for in-game shop items and Emergency Recovery;
  they are only earned through play (points packs were retired with the Diggle Mart)
- Both are boosted by holder multipliers (Diggle NFT, Seeker Genesis Token)
- API: `addXP()`, `addPoints()`, `spendPoints()`, `setXPBoost()`, `setPointsBoost()`

### Boost Manager (`boost_manager.dart`)

- Extends `ChangeNotifier` for UI reactivity
- Holder boosts only: Diggle NFT (via `CandyMachineService`) × Seeker Genesis Token (1.05x)
- Keeps `nftCollection` (supply, mint price) in sync with the candy machine
- Pushes the holder multiplier into `XPPointsSystem.setNFT*Multiplier`
- Timed boosters were removed with the Diggle Mart; `XPPointsSystem.setXPBoost` /
  `setPointsBoost` remain but have no caller

### Premium Store UI (`premium_store_overlay.dart`)

- Level / XP / Points bar, then the Diggle Machine NFT mint section (no tabs)
- Wallet-required view when no wallet is connected
- Multi-mint (1–3 per batch, capped by the guard's mint limit) with per-mint progress

### Miner's Pass (SKR) — `miners_pass_service.dart` + `supabase/edge/miners-pass/`

- Weekly pass: 2x weekly quest rewards. Costs SKR (mint
  `SKRbvo6Gf7GondiT3BbTfuRDPqLWei4j2Qy2NPGZhW3`, classic SPL Token, 6 decimals),
  paid into the treasury wallet. Bought from the Weekly tab of the quest screen.
- Price: `skr_prices` row (`network`, `item = 'miners_pass'`, `amount_base`, `active`).
  Inactive → the button shows "Unavailable". Change it in SQL; no release needed.
- Records: `miners_pass_orders` (audit trail, unique `tx_signature`) and
  `miners_passes` (one per player / network / ISO week). Service-role only.
- Secrets — mainnet: `SOLANA_RPC_URL`, `SKR_TREASURY_WALLET` (its SKR token account
  must exist), optional `SKR_MINT`. Devnet: `DEVNET_SKR_MINT` (a dummy 6-decimal
  mint), `DEVNET_SKR_TREASURY_WALLET`, optional `DEVNET_SOLANA_RPC_URL`.
- `miners-pass` and `miners-pass-devnet` share an identical `index.ts`; only
  `config.ts` differs. Devnet passes are stored with `network = 'devnet'` and
  never count on mainnet.
- The quest screen calls `restore()` on open: it finishes a payment interrupted
  after sending and picks up a pass bought on another device.
- Weekly quest reward claims are still client-trusted; the server record gives
  restore and an audit trail, not enforcement.
- SQL tests: `supabase/tests/store_fixture.sql` + `store_tests.sql` (see
  `supabase/tests/README.md`).

## Development Notes

### Running

```bash
flutter pub get
flutter run  # Android device with wallet app installed
```

### Devnet Testing

- Default cluster is devnet (`https://api.devnet.solana.com`)
- Phantom wallet has best devnet MWA support
- The Miner's Pass on devnet needs a dummy SKR mint and the `miners-pass-devnet`
  function (see the Miner's Pass section)
- Airdrop devnet SOL to the test wallet for fees

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
| `pack_purchase` | + | RETIRED: on-chain points pack (Diggle Mart). Clients refused since `award_points` v4 |
| `shop_spend` | − | Spent in in-game shop |
| `booster_purchase` | 0 | RETIRED: on-chain booster audit row (Diggle Mart). Clients refused since `award_points` v4 |
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

Deployed functions live in `supabase/edge/` (`candy-machine`, `miners-pass`,
`wallet-auth`, `validate-social-quest`, …). Planned:

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

### Wiring Architecture

The `XPStatsBridge` sits between game systems and Supabase:

```
Game Code (drill, shop, quests)
  ↓ calls bridge methods
XPStatsBridge
  ├→ XPPointsSystem (instant local UI update)
  └→ StatsService (queued for batch sync)
       ├→ addLocalXP/addLocalPoints (local delta tracking)
       └→ (every 30s or on pause) syncToServer()
            ├→ _flushLedger() → award_points RPC (atomic)
            └→ _syncStats() → player_stats UPDATE
```

**Key design decision:** The bridge is optional. If `statsBridge` is null (Supabase failed to init), the game falls back to direct `XPPointsSystem` calls. The game is always playable offline.

**Provider registration order** in main.dart:
1. `WalletService` — ChangeNotifierProvider (UI listens)
2. `StatsService` — Provider (service, not UI-reactive)
3. `WorldSaveService` — Provider
4. `PlayerService` — Provider
5. `PointsLedgerService` — Provider
6. `GameLifecycleManager` — Provider (orchestrator)

`BoostManager` is NOT in Provider — `GameScreen` creates it, and it only handles holder multipliers (it no longer touches `XPStatsBridge`). `CandyMachineService` and `MinersPassService` are ChangeNotifierProviders next to `WalletService`.

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
| `SocketException` after wallet signing | Android network drops during app switch | Built-in retry with 1-3s delays handles this |
| `type 'int' is not a subtype of 'String'` | Calling `base64Decode` on already-decoded bytes | Use `Uint8List.fromList(binaryAccountData.data)` |
| `ambiguous_import` for `Instruction` | Both `dto.dart` and `encoder.dart` export it | Add `hide Instruction` to `dto.dart` and `solana.dart` imports |
| `undefined_method 'writableSigner'` | Wrong API name | Use `AccountMeta.writeable(pubKey: ..., isSigner: true)` |
| Wallet opens but no transaction prompt | Malformed transaction bytes | Verify `SignedTx.toByteArray()` serialization; check byte count in logs |
| Miner's Pass button says "Unavailable" | `skr_prices` row inactive, treasury SKR account missing, or no Supabase session | Check `skr_prices`, create the treasury's SKR token account, check the `miners-pass` function logs |