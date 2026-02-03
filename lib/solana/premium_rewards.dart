/// premium_rewards.dart
/// Handles applying premium purchase rewards to the game.

import '../game/diggle_game.dart';
import '../game/systems/item_system.dart';

/// Premium pack definitions and reward application
class PremiumRewards {
  /// Apply rewards for a purchased pack
  static void applyReward(DiggleGame game, String packName) {
    switch (packName) {
      case 'Starter Pack':
        _applyStarterPack(game);
        break;
      case 'Booster Pack':
        _applyBoosterPack(game);
        break;
      case 'Mega Pack':
        _applyMegaPack(game);
        break;
      case 'Explosives Bundle':
        _applyExplosivesBundle(game);
        break;
      case 'Emergency Kit':
        _applyEmergencyKit(game);
        break;
      case 'VIP Pass (30 Days)':
        _applyVipPass(game);
        break;
    }
  }

  static void _applyStarterPack(DiggleGame game) {
    // 500 Cash + 3 Space Rifts
    game.economySystem.addCash(500);
    for (int i = 0; i < 3; i++) {
      game.itemSystem.addItem(ItemType.spaceRift);
    }
  }

  static void _applyBoosterPack(DiggleGame game) {
    // 1500 Cash + 5 Backup Fuel + 5 Repair Bots
    game.economySystem.addCash(1500);
    for (int i = 0; i < 5; i++) {
      game.itemSystem.addItem(ItemType.backupFuel);
      game.itemSystem.addItem(ItemType.repairBot);
    }
  }

  static void _applyMegaPack(DiggleGame game) {
    // All upgrades maxed + 10 of each item + 5000 Cash
    game.economySystem.addCash(5000);

    // Max fuel tank
    while (game.fuelSystem.canUpgrade()) {
      game.fuelSystem.upgrade();
    }
    game.fuelSystem.refill();

    // Max cargo
    while (game.economySystem.canUpgradeCargo()) {
      game.economySystem.forceUpgradeCargo();
    }

    // Max hull
    while (game.hullSystem.canUpgrade()) {
      game.hullSystem.upgrade();
    }
    game.hullSystem.fullRepair();

    // 10 of each item (up to max stack)
    for (int i = 0; i < 10; i++) {
      game.itemSystem.addItem(ItemType.backupFuel);
      game.itemSystem.addItem(ItemType.repairBot);
      game.itemSystem.addItem(ItemType.dynamite);
      game.itemSystem.addItem(ItemType.c4);
      game.itemSystem.addItem(ItemType.spaceRift);
    }
  }

  static void _applyExplosivesBundle(DiggleGame game) {
    // 10 Dynamite + 5 C4
    for (int i = 0; i < 10; i++) {
      game.itemSystem.addItem(ItemType.dynamite);
    }
    for (int i = 0; i < 5; i++) {
      game.itemSystem.addItem(ItemType.c4);
    }
  }

  static void _applyEmergencyKit(DiggleGame game) {
    // 5 Backup Fuel + 5 Repair Bots + 3 Space Rifts
    for (int i = 0; i < 5; i++) {
      game.itemSystem.addItem(ItemType.backupFuel);
      game.itemSystem.addItem(ItemType.repairBot);
    }
    for (int i = 0; i < 3; i++) {
      game.itemSystem.addItem(ItemType.spaceRift);
    }
  }

  static void _applyVipPass(DiggleGame game) {
    // VIP benefits would be stored and checked during gameplay
    // For now, give some immediate rewards
    game.economySystem.addCash(1000);
    game.fuelSystem.refill();
    game.hullSystem.fullRepair();

    // TODO: Store VIP status with expiration date
    // game.setVipStatus(days: 30);
  }
}