/// engine_system.dart
/// Manages the engine upgrades that affect movement speed.
///
/// The engine determines:
/// - How fast the drill moves through empty space
/// - How fast the drill flies upward
/// - Overall movement responsiveness

import 'package:flutter/foundation.dart';

/// Engine upgrade levels
enum EngineLevel {
  basic(
    speedMultiplier: 1.0,
    flySpeedMultiplier: 1.0,
    upgradeCost: 0,
    name: 'Basic Engine',
    description: 'Standard engine. Gets the job done.',
  ),
  improved(
    speedMultiplier: 1.25,
    flySpeedMultiplier: 1.2,
    upgradeCost: 200,
    name: 'Improved Engine',
    description: 'Faster movement and better thrust.',
  ),
  turbo(
    speedMultiplier: 1.5,
    flySpeedMultiplier: 1.5,
    upgradeCost: 500,
    name: 'Turbo Engine',
    description: 'Significantly faster all-around.',
  ),
  quantum(
    speedMultiplier: 2.0,
    flySpeedMultiplier: 1.8,
    upgradeCost: 1000,
    name: 'Quantum Engine',
    description: 'Maximum speed. Blazing fast movement.',
  );

  /// Multiplier for normal movement speed
  final double speedMultiplier;

  /// Multiplier for flying/upward movement speed
  final double flySpeedMultiplier;

  /// Cost to upgrade to this level
  final int upgradeCost;

  /// Display name
  final String name;

  /// Description
  final String description;

  const EngineLevel({
    required this.speedMultiplier,
    required this.flySpeedMultiplier,
    required this.upgradeCost,
    required this.name,
    required this.description,
  });

  EngineLevel? get nextLevel {
    switch (this) {
      case EngineLevel.basic:
        return EngineLevel.improved;
      case EngineLevel.improved:
        return EngineLevel.turbo;
      case EngineLevel.turbo:
        return EngineLevel.quantum;
      case EngineLevel.quantum:
        return null;
    }
  }

  /// Get icon for this engine level
  String get icon {
    switch (this) {
      case EngineLevel.basic:
        return '🔧';
      case EngineLevel.improved:
        return '⚡';
      case EngineLevel.turbo:
        return '🚀';
      case EngineLevel.quantum:
        return '✨';
    }
  }
}

/// Manages engine state and upgrades
class EngineSystem extends ChangeNotifier {
  EngineLevel _level;

  EngineSystem({
    EngineLevel level = EngineLevel.basic,
  }) : _level = level;

  // ============================================================
  // GETTERS
  // ============================================================

  EngineLevel get level => _level;

  /// Current movement speed multiplier
  double get speedMultiplier => _level.speedMultiplier;

  /// Current fly speed multiplier
  double get flySpeedMultiplier => _level.flySpeedMultiplier;

  /// Display name
  String get name => _level.name;

  /// Description
  String get description => _level.description;

  /// Icon
  String get icon => _level.icon;

  // ============================================================
  // SPEED CALCULATIONS
  // ============================================================

  /// Get effective movement speed
  double getEffectiveSpeed(double baseSpeed) {
    return baseSpeed * _level.speedMultiplier;
  }

  /// Get effective fly speed
  double getEffectiveFlySpeed(double baseFlySpeed) {
    return baseFlySpeed * _level.flySpeedMultiplier;
  }

  // ============================================================
  // UPGRADES
  // ============================================================

  bool canUpgrade() => _level.nextLevel != null;

  EngineLevel? getNextUpgrade() => _level.nextLevel;

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

  void reset({EngineLevel? keepLevel}) {
    _level = keepLevel ?? EngineLevel.basic;
    notifyListeners();
  }

  /// Restore engine state from a saved game.
  void restore({required int level}) {
    if (level >= 0 && level < EngineLevel.values.length) {
      _level = EngineLevel.values[level];
    } else {
      _level = EngineLevel.basic;
    }
    notifyListeners();
  }

  @override
  String toString() {
    return 'EngineSystem(${_level.name}, speed: ${speedMultiplier}x, fly: ${flySpeedMultiplier}x)';
  }
}