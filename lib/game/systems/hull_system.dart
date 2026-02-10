/// hull_system.dart
/// Manages drill health/hull integrity.
///
/// Hull can be damaged by:
/// - Fall damage
/// - Future: enemies, hazards
///
/// Hull can be repaired at the surface shop.

import 'package:flutter/foundation.dart';

enum HullLevel {
  level1(maxHull: 100.0, upgradeCost: 0, name: 'Basic Hull'),
  level2(maxHull: 150.0, upgradeCost: 300, name: 'Reinforced Hull'),
  level3(maxHull: 200.0, upgradeCost: 600, name: 'Titanium Hull');

  final double maxHull;
  final int upgradeCost;
  final String name;

  const HullLevel({
    required this.maxHull,
    required this.upgradeCost,
    required this.name,
  });

  HullLevel? get nextLevel {
    switch (this) {
      case HullLevel.level1:
        return HullLevel.level2;
      case HullLevel.level2:
        return HullLevel.level3;
      case HullLevel.level3:
        return null;
    }
  }
}

class HullSystem extends ChangeNotifier {
  double _hull;
  HullLevel _hullLevel;

  HullSystem({
    double? initialHull,
    HullLevel hullLevel = HullLevel.level1,
  })  : _hullLevel = hullLevel,
        _hull = initialHull ?? hullLevel.maxHull;

  // Getters
  double get hull => _hull;
  double get maxHull => _hullLevel.maxHull;
  double get hullPercentage => _hull / maxHull;
  HullLevel get hullLevel => _hullLevel;
  bool get isDestroyed => _hull <= 0;
  bool get isDamaged => _hull < maxHull;
  bool get isCritical => hullPercentage < 0.25;
  bool get isLow => hullPercentage < 0.5;

  /// Take damage (returns true if still alive)
  bool takeDamage(double amount) {
    if (amount <= 0) return true;
    _hull = (_hull - amount).clamp(0, maxHull);
    notifyListeners();
    return _hull > 0;
  }

  /// Repair hull
  void repair(double amount) {
    if (amount <= 0) return;
    _hull = (_hull + amount).clamp(0, maxHull);
    notifyListeners();
  }

  /// Full repair
  void fullRepair() {
    _hull = maxHull;
    notifyListeners();
  }

  /// Get repair cost
  int getRepairCost() {
    final damage = maxHull - _hull;
    return (damage / 2).ceil();
  }

  // Upgrades
  bool canUpgrade() => _hullLevel.nextLevel != null;
  HullLevel? getNextUpgrade() => _hullLevel.nextLevel;
  int getUpgradeCost() => _hullLevel.nextLevel?.upgradeCost ?? 0;

  bool upgrade() {
    final next = _hullLevel.nextLevel;
    if (next == null) return false;
    _hullLevel = next;
    _hull = _hull.clamp(0, maxHull);
    notifyListeners();
    return true;
  }

  void reset({HullLevel? keepLevel}) {
    _hullLevel = keepLevel ?? HullLevel.level1;
    _hull = _hullLevel.maxHull;
    notifyListeners();
  }

  /// Hull level as int index (for serialization).
  int get level => _hullLevel.index;

  /// Restore hull state from a saved game.
  void restore({
    required double hull,
    required double maxHull,
    required int level,
  }) {
    _hullLevel = HullLevel.values.firstWhere(
          (l) => l.maxHull == maxHull,
      orElse: () {
        if (level >= 0 && level < HullLevel.values.length) {
          return HullLevel.values[level];
        }
        return HullLevel.level1;
      },
    );
    _hull = hull.clamp(0, _hullLevel.maxHull);
    notifyListeners();
  }
}