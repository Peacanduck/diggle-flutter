/// fuel_system.dart
/// Manages fuel consumption, capacity, and upgrades.
/// 
/// Fuel is the core survival mechanic:
/// - Depletes when moving/digging
/// - Running out underground = game over
/// - Can be refilled at surface shop
/// - Capacity upgradeable (levels 1-3)

import 'package:flutter/foundation.dart';

/// Fuel tank upgrade levels and their capacities
enum FuelTankLevel {
  level1(maxFuel: 100.0, upgradeCost: 0, name: 'Basic Tank'),
  level2(maxFuel: 150.0, upgradeCost: 200, name: 'Reinforced Tank'),
  level3(maxFuel: 250.0, upgradeCost: 500, name: 'Advanced Tank');

  final double maxFuel;
  final int upgradeCost;
  final String name;

  const FuelTankLevel({
    required this.maxFuel,
    required this.upgradeCost,
    required this.name,
  });

  /// Get the next upgrade level (null if max)
  FuelTankLevel? get nextLevel {
    switch (this) {
      case FuelTankLevel.level1:
        return FuelTankLevel.level2;
      case FuelTankLevel.level2:
        return FuelTankLevel.level3;
      case FuelTankLevel.level3:
        return null;
    }
  }
}

/// Manages fuel state and operations
class FuelSystem extends ChangeNotifier {
  /// Current fuel amount
  double _fuel;

  /// Current tank upgrade level
  FuelTankLevel _tankLevel;

  /// Whether fuel depletion is paused (e.g., in menus)
  bool _isPaused = false;

  FuelSystem({
    double? initialFuel,
    FuelTankLevel tankLevel = FuelTankLevel.level1,
  })  : _tankLevel = tankLevel,
        _fuel = initialFuel ?? tankLevel.maxFuel;

  // ============================================================
  // GETTERS
  // ============================================================

  /// Current fuel amount
  double get fuel => _fuel;

  /// Maximum fuel capacity
  double get maxFuel => _tankLevel.maxFuel;

  /// Fuel as percentage (0.0 to 1.0)
  double get fuelPercentage => _fuel / maxFuel;

  /// Current tank level
  FuelTankLevel get tankLevel => _tankLevel;

  /// Whether fuel is empty
  bool get isEmpty => _fuel <= 0;

  /// Whether fuel is low (below 20%)
  bool get isLow => fuelPercentage < 0.2;

  /// Whether fuel is critical (below 10%)
  bool get isCritical => fuelPercentage < 0.1;

  /// Whether at full capacity
  bool get isFull => _fuel >= maxFuel;

  /// Whether system is paused
  bool get isPaused => _isPaused;

  // ============================================================
  // FUEL OPERATIONS
  // ============================================================

  /// Consume fuel (returns false if not enough fuel)
  bool consume(double amount) {
    if (_isPaused) return true;
    if (amount <= 0) return true;
    if (_fuel < amount) {
      _fuel = 0;
      notifyListeners();
      return false;
    }
    
    _fuel -= amount;
    notifyListeners();
    return true;
  }

  /// Add fuel (capped at max capacity)
  void add(double amount) {
    if (amount <= 0) return;
    _fuel = (_fuel + amount).clamp(0, maxFuel);
    notifyListeners();
  }

  /// Refill to full capacity
  void refill() {
    _fuel = maxFuel;
    notifyListeners();
  }

  /// Get cost to refill from current level
  int getRefillCost() {
    final fuelNeeded = maxFuel - _fuel;
    // 1 cash per 2 fuel units
    return (fuelNeeded / 2).ceil();
  }

  // ============================================================
  // UPGRADES
  // ============================================================

  /// Check if upgrade is available
  bool canUpgrade() {
    return _tankLevel.nextLevel != null;
  }

  /// Get next upgrade level (null if maxed)
  FuelTankLevel? getNextUpgrade() {
    return _tankLevel.nextLevel;
  }

  /// Get cost for next upgrade (0 if no upgrade available)
  int getUpgradeCost() {
    return _tankLevel.nextLevel?.upgradeCost ?? 0;
  }

  /// Perform upgrade (returns true if successful)
  bool upgrade() {
    final nextLevel = _tankLevel.nextLevel;
    if (nextLevel == null) return false;

    _tankLevel = nextLevel;
    // Keep current fuel, but cap at new max
    _fuel = _fuel.clamp(0, maxFuel);
    notifyListeners();
    return true;
  }

  // ============================================================
  // STATE CONTROL
  // ============================================================

  /// Pause fuel consumption
  void pause() {
    _isPaused = true;
  }

  /// Resume fuel consumption
  void resume() {
    _isPaused = false;
  }

  /// Reset to initial state
  void reset({FuelTankLevel? keepLevel}) {
    _tankLevel = keepLevel ?? FuelTankLevel.level1;
    _fuel = _tankLevel.maxFuel;
    _isPaused = false;
    notifyListeners();
  }

  /// Restore fuel state from a saved game.
  void restore({
    required double fuel,
    required double maxFuel,
    required int level,
  }) {
    // Find the matching tank level
    _tankLevel = FuelTankLevel.values.firstWhere(
          (l) => l.maxFuel == maxFuel,
      orElse: () {
        // Fallback: pick by index
        if (level >= 0 && level < FuelTankLevel.values.length) {
          return FuelTankLevel.values[level];
        }
        return FuelTankLevel.level1;
      },
    );
    _fuel = fuel.clamp(0, _tankLevel.maxFuel);
    _isPaused = false;
    notifyListeners();
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'FuelSystem(${_fuel.toStringAsFixed(1)}/${maxFuel} - ${_tankLevel.name})';
  }
}