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