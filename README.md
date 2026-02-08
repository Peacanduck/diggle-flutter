# Diggle ⛏️💎

**Mine Deep. Sell High. Upgrade.**

Diggle is a procedural 2D mining game built with [Flutter](https://flutter.dev/) and the [Flame Engine](https://flame-engine.org/). Players pilot a drill unit deep into the earth, managing fuel, hull integrity, and cargo space while collecting valuable ores ranging from Coal to Diamond.

The game features **Solana Blockchain integration** via the Mobile Wallet Adapter (MWA), enabling on-chain purchases of boosters and utility from NFT cosmetics.

## 🎮 Game Features

### Core Gameplay
* **Procedural World Generation:** Every run offers a unique terrain layout. Deeper layers contain rarer ores and harder rock types.
* **Physics-Based Drilling:** Smooth movement mechanics with drill inertia and gravity.
* **Survival Mechanics:** Manage your **Fuel** to avoid getting stranded and watch your **Hull** integrity to survive fall damage and hazards.

### Economy & Items
* **Mining:** Collect 8 different ore types: Coal, Copper, Silver, Gold, Sapphire, Emerald, Ruby, and Diamond.
* **Shop Services:** Sell ores for cash, refuel your tank, and repair your hull at the surface.
* **Consumables:** Purchase and use items like **Dynamite** (3x3 explosion), **C4** (5x5 explosion), **Repair Bots**, and **Space Rifts** (teleport to surface).

### Upgrade Systems
Use your earnings to upgrade your drill's capabilities:
* **Drill Bit:** Increases mining speed and allows drilling through harder rock tiers (Basic → Diamond).
* **Engine:** Boosts movement speed and flight thrust.
* **Cooling System:** Improves fuel efficiency, allowing for longer runs.
* **Hull Armor:** Increases max HP to withstand more damage.
* **Fuel Tank:** Increases maximum fuel capacity.
* **Cargo Bay:** Increases the amount of ore you can carry.

## 🔗 Solana Integration (Web3)

Diggle integrates with the Solana blockchain using `solana_mobile_client`.

* **Wallet Connection:** Supports connection via MWA-compatible apps like Phantom and Solflare.
* **Network Switching:** Built-in toggle between **Mainnet-Beta** and **Devnet**.
* **Premium Store:** UI implemented for purchasing XP and Point boosters using SOL.
* **NFT Utility:** The game detects specific "Diggle Diamond Drill" NFTs in the connected wallet to apply permanent XP and Point multipliers.

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **Game Engine:** Flame
* **Blockchain:** Solana (solana_mobile_client, solana)
* **State Management:** Provider
* **Architecture:** Component-System pattern (Flame) + Service Locator

## 📂 Project Structure

```text
lib/
├── game/
│   ├── player/         # Drill movement and physics logic
│   ├── systems/        # Logic for Fuel, Economy, Upgrades, and XP
│   ├── world/          # Procedural tile generation and rendering
│   └── diggle_game.dart # Main FlameGame loop
├── solana/
│   └── wallet_service.dart # Wallet connection and MWA logic
├── ui/                 # Flutter overlays (HUD, Shop, Main Menu)
└── main.dart           # Entry point and app wiring
```

## Todo
The core game loop is complete, but the following features are currently in development:

* On-Chain Store Integration:

* Connect the BoostManager UI to a deployed Anchor program.

* Replace simulated transaction signatures with actual SOL transfers/Smart Contract calls.

* NFT Store & Minting:

* Implement Metaplex interaction to fetch NFT metadata for the "Diamond Drill" collection.

* Finalize the Candy Machine integration for the mintNFT function.

* Persistence (Save System):

* Implement local storage (using shared_preferences or hive) to save:

* Current Cash & Points.

[ ] Upgrade Levels.

[ ] XP and Player Level.

[ ] World Generation:

[ ] Add distinct biomes or layers with unique hardness properties.