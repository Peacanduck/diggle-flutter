/// drillbit_system.dart
/// Manages the drill bit upgrades that affect mining capabilities.
///
/// The drill bit determines:
/// - How fast you can dig through materials
/// - What materials you can dig through (higher tiers unlock harder ores)
/// - Dig speed multiplier

import 'package:flutter/foundation.dart';

/// Drill bit upgrade levels
enum DrillbitLevel {
  basic(
    digSpeedMultiplier: 1.0,
    maxHardness: 1,
    upgradeCost: 0,
    name: 'Basic Bit',
    description: 'Standard drill bit. Can mine dirt and soft ores.',
  ),
  reinforced(
    digSpeedMultiplier: 1.3,
    maxHardness: 2,
    upgradeCost: 250,
    name: 'Reinforced Bit',
    description: 'Faster drilling. Can mine rock and medium ores.',
  ),
  titanium(
    digSpeedMultiplier: 1.6,
    maxHardness: 3,
    upgradeCost: 600,
    name: 'Titanium Bit',
    description: 'Much faster drilling. Can mine hard ores.',
  ),
  diamond(
    digSpeedMultiplier: 2.0,
    maxHardness: 4,
    upgradeCost: 1200,
    name: 'Diamond Bit',
    description: 'Superior drilling. Can mine the hardest materials.',
  );

  /// Multiplier applied to dig speed (higher = faster)
  final double digSpeedMultiplier;

  /// Maximum material hardness this bit can mine
  final int maxHardness;

  /// Cost to upgrade to this level
  final int upgradeCost;

  /// Display name
  final String name;

  /// Description of capabilities
  final String description;

  const DrillbitLevel({
    required this.digSpeedMultiplier,
    required this.maxHardness,
    required this.upgradeCost,
    required this.name,
    required this.description,
  });

  DrillbitLevel? get nextLevel {
    switch (this) {
      case DrillbitLevel.basic:
        return DrillbitLevel.reinforced;
      case DrillbitLevel.reinforced:
        return DrillbitLevel.titanium;
      case DrillbitLevel.titanium:
        return DrillbitLevel.diamond;
      case DrillbitLevel.diamond:
        return null;
    }
  }

  /// Get icon for this drill bit level
  String get icon {
    switch (this) {
      case DrillbitLevel.basic:
        return '⛏️';
      case DrillbitLevel.reinforced:
        return '🔨';
      case DrillbitLevel.titanium:
        return '⚙️';
      case DrillbitLevel.diamond:
        return '💎';
    }
  }
}

/// Material hardness levels (for determining if drillbit can mine it)
class MaterialHardness {
  static const int soft = 1;      // Dirt, coal
  static const int medium = 2;    // Rock, copper, silver
  static const int hard = 3;      // Gold, sapphire, emerald
  static const int veryHard = 4;  // Ruby, diamond
  static const int unbreakable = 99; // Bedrock
}

/// Manages drill bit state and upgrades
class DrillbitSystem extends ChangeNotifier {
  DrillbitLevel _level;

  DrillbitSystem({
    DrillbitLevel level = DrillbitLevel.basic,
  }) : _level = level;

  // ============================================================
  // GETTERS
  // ============================================================

  DrillbitLevel get level => _level;

  /// Current dig speed multiplier
  double get digSpeedMultiplier => _level.digSpeedMultiplier;

  /// Maximum hardness this bit can mine
  int get maxHardness => _level.maxHardness;

  /// Display name
  String get name => _level.name;

  /// Description
  String get description => _level.description;

  /// Icon
  String get icon => _level.icon;

  // ============================================================
  // MINING CHECKS
  // ============================================================

  /// Check if this drillbit can mine a material of given hardness
  bool canMine(int hardness) {
    return hardness <= _level.maxHardness;
  }

  /// Get effective dig time for a material (base time / speed multiplier)
  double getEffectiveDigTime(double baseDigTime) {
    return baseDigTime / _level.digSpeedMultiplier;
  }

  // ============================================================
  // UPGRADES
  // ============================================================

  bool canUpgrade() => _level.nextLevel != null;

  DrillbitLevel? getNextUpgrade() => _level.nextLevel;

  int getUpgradeCost() => _level.nextLevel?.upgradeCost ?? 0;

  bool upgrade() {
    final next = _level.nextLevel;
    if (next == null) return false;
    _level = next;
    notifyListeners();
    return true;
  }

  // ============================================================
  // STATE CONTROL
  // ============================================================

  void reset({DrillbitLevel? keepLevel}) {
    _level = keepLevel ?? DrillbitLevel.basic;
    notifyListeners();
  }

  /// Restore drillbit state from a saved game.
  void restore({required int level}) {
    if (level >= 0 && level < DrillbitLevel.values.length) {
      _level = DrillbitLevel.values[level];
    } else {
      _level = DrillbitLevel.basic;
    }
    notifyListeners();
  }

  @override
  String toString() {
    return 'DrillbitSystem(${_level.name}, speed: ${digSpeedMultiplier}x, hardness: $maxHardness)';
  }
}