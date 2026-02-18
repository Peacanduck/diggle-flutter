/// cooling_system.dart
/// Manages the cooling system upgrades that affect fuel efficiency.
///
/// The cooling system determines:
/// - How efficiently fuel is burned
/// - Lower fuel consumption = longer mining sessions
/// - Better cooling = more profit per tank

import 'package:flutter/foundation.dart';

/// Cooling system upgrade levels
enum CoolingLevel {
  basic(
    fuelEfficiency: 1.0,
    upgradeCost: 0,
    name: 'Basic Cooling',
    description: 'Standard radiator. Normal fuel consumption.',
  ),
  improved(
    fuelEfficiency: 0.85,
    upgradeCost: 3000,
    name: 'Improved Cooling',
    description: '15% less fuel consumption.',
  ),
  advanced(
    fuelEfficiency: 0.70,
    upgradeCost: 70000,
    name: 'Advanced Cooling',
    description: '30% less fuel consumption.',
  ),
  cryo(
    fuelEfficiency: 0.50,
    upgradeCost: 150000,
    name: 'Cryo Cooling',
    description: '50% less fuel consumption. Maximum efficiency.',
  );

  /// Fuel consumption multiplier (lower = more efficient)
  final double fuelEfficiency;

  /// Cost to upgrade to this level
  final int upgradeCost;

  /// Display name
  final String name;

  /// Description
  final String description;

  const CoolingLevel({
    required this.fuelEfficiency,
    required this.upgradeCost,
    required this.name,
    required this.description,
  });

  CoolingLevel? get nextLevel {
    switch (this) {
      case CoolingLevel.basic:
        return CoolingLevel.improved;
      case CoolingLevel.improved:
        return CoolingLevel.advanced;
      case CoolingLevel.advanced:
        return CoolingLevel.cryo;
      case CoolingLevel.cryo:
        return null;
    }
  }

  /// Get icon for this cooling level
  String get icon {
    switch (this) {
      case CoolingLevel.basic:
        return '🌡️';
      case CoolingLevel.improved:
        return '❄️';
      case CoolingLevel.advanced:
        return '🧊';
      case CoolingLevel.cryo:
        return '💠';
    }
  }

  /// Get fuel savings percentage for display
  int get savingsPercent {
    return ((1.0 - fuelEfficiency) * 100).round();
  }
}

/// Manages cooling system state and upgrades
class CoolingSystem extends ChangeNotifier {
  CoolingLevel _level;

  CoolingSystem({
    CoolingLevel level = CoolingLevel.basic,
  }) : _level = level;

  // ============================================================
  // GETTERS
  // ============================================================

  CoolingLevel get level => _level;

  /// Current fuel efficiency multiplier (lower = better)
  double get fuelEfficiency => _level.fuelEfficiency;

  /// Display name
  String get name => _level.name;

  /// Description
  String get description => _level.description;

  /// Icon
  String get icon => _level.icon;

  /// Savings percentage
  int get savingsPercent => _level.savingsPercent;

  // ============================================================
  // FUEL CALCULATIONS
  // ============================================================

  /// Get effective fuel cost (base cost * efficiency multiplier)
  double getEffectiveFuelCost(double baseCost) {
    return baseCost * _level.fuelEfficiency;
  }

  // ============================================================
  // UPGRADES
  // ============================================================

  bool canUpgrade() => _level.nextLevel != null;

  CoolingLevel? getNextUpgrade() => _level.nextLevel;

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

  void reset({CoolingLevel? keepLevel}) {
    _level = keepLevel ?? CoolingLevel.basic;
    notifyListeners();
  }

  /// Restore cooling state from a saved game.
  void restore({required int level}) {
    if (level >= 0 && level < CoolingLevel.values.length) {
      _level = CoolingLevel.values[level];
    } else {
      _level = CoolingLevel.basic;
    }
    notifyListeners();
  }

  @override
  String toString() {
    return 'CoolingSystem(${_level.name}, efficiency: ${fuelEfficiency}x, saves: $savingsPercent%)';
  }
}