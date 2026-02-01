/// economy_system.dart
/// Manages the game's economy: cash, cargo/inventory, and transactions.
/// 
/// Core mechanics:
/// - Ore is collected into cargo (limited capacity)
/// - Ore is sold at surface for cash
/// - Cash buys fuel refills and upgrades
/// - No premium currency or monetization

import 'package:flutter/foundation.dart';
import '../world/tile.dart';

/// Cargo upgrade levels and capacities
enum CargoLevel {
  level1(maxCapacity: 10, upgradeCost: 0, name: 'Basic Cargo'),
  level2(maxCapacity: 20, upgradeCost: 150, name: 'Extended Cargo'),
  level3(maxCapacity: 40, upgradeCost: 400, name: 'Heavy Cargo');

  final int maxCapacity;
  final int upgradeCost;
  final String name;

  const CargoLevel({
    required this.maxCapacity,
    required this.upgradeCost,
    required this.name,
  });

  CargoLevel? get nextLevel {
    switch (this) {
      case CargoLevel.level1:
        return CargoLevel.level2;
      case CargoLevel.level2:
        return CargoLevel.level3;
      case CargoLevel.level3:
        return null;
    }
  }
}

/// Represents an ore item in cargo
class CargoItem {
  final TileType oreType;
  int quantity;

  CargoItem({required this.oreType, this.quantity = 1});

  int get totalValue => oreType.value * quantity;
}

/// Manages all economy-related state
class EconomySystem extends ChangeNotifier {
  /// Player's cash
  int _cash;

  /// Current cargo upgrade level
  CargoLevel _cargoLevel;

  /// Ore inventory (map of ore type to quantity)
  final Map<TileType, int> _cargo = {};

  /// Lifetime statistics
  int _totalOreCollected = 0;
  int _totalCashEarned = 0;
  int _maxDepthReached = 0;

  EconomySystem({
    int initialCash = 50,
    CargoLevel cargoLevel = CargoLevel.level1,
  })  : _cash = initialCash,
        _cargoLevel = cargoLevel;

  // ============================================================
  // GETTERS
  // ============================================================

  int get cash => _cash;
  CargoLevel get cargoLevel => _cargoLevel;
  int get maxCapacity => _cargoLevel.maxCapacity;
  
  /// Current cargo count (sum of all ore)
  int get cargoCount {
    return _cargo.values.fold(0, (sum, count) => sum + count);
  }

  /// Available cargo space
  int get cargoSpace => maxCapacity - cargoCount;

  /// Whether cargo is full
  bool get isCargoFull => cargoCount >= maxCapacity;

  /// Whether cargo has any ore
  bool get hasOre => cargoCount > 0;

  /// Get current cargo as list
  List<CargoItem> get cargoItems {
    return _cargo.entries
        .where((e) => e.value > 0)
        .map((e) => CargoItem(oreType: e.key, quantity: e.value))
        .toList();
  }

  /// Calculate total value of current cargo
  int get cargoValue {
    int total = 0;
    _cargo.forEach((type, count) {
      total += type.value * count;
    });
    return total;
  }

  /// Statistics
  int get totalOreCollected => _totalOreCollected;
  int get totalCashEarned => _totalCashEarned;
  int get maxDepthReached => _maxDepthReached;

  // ============================================================
  // CARGO OPERATIONS
  // ============================================================

  /// Add ore to cargo (returns false if full)
  bool collectOre(TileType oreType) {
    if (!oreType.isOre) return false;
    if (isCargoFull) return false;

    _cargo[oreType] = (_cargo[oreType] ?? 0) + 1;
    _totalOreCollected++;
    notifyListeners();
    return true;
  }

  /// Get quantity of specific ore type
  int getOreCount(TileType oreType) {
    return _cargo[oreType] ?? 0;
  }

  /// Clear all cargo (after selling)
  void clearCargo() {
    _cargo.clear();
    notifyListeners();
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  /// Sell all ore for cash (returns amount earned)
  int sellAllOre() {
    final value = cargoValue;
    if (value > 0) {
      _cash += value;
      _totalCashEarned += value;
      clearCargo();
      notifyListeners();
    }
    return value;
  }

  /// Spend cash (returns false if insufficient)
  bool spend(int amount) {
    if (amount <= 0) return true;
    if (_cash < amount) return false;
    
    _cash -= amount;
    notifyListeners();
    return true;
  }

  /// Add cash (for bonuses, cheats, etc.)
  void addCash(int amount) {
    if (amount <= 0) return;
    _cash += amount;
    notifyListeners();
  }

  /// Check if can afford amount
  bool canAfford(int amount) => _cash >= amount;

  // ============================================================
  // UPGRADES
  // ============================================================

  /// Check if cargo upgrade available
  bool canUpgradeCargo() {
    return _cargoLevel.nextLevel != null;
  }

  /// Get next cargo upgrade level
  CargoLevel? getNextCargoUpgrade() {
    return _cargoLevel.nextLevel;
  }

  /// Get cargo upgrade cost
  int getCargoUpgradeCost() {
    return _cargoLevel.nextLevel?.upgradeCost ?? 0;
  }

  /// Perform cargo upgrade (returns true if successful)
  bool upgradeCargo() {
    final nextLevel = _cargoLevel.nextLevel;
    if (nextLevel == null) return false;
    if (!canAfford(nextLevel.upgradeCost)) return false;

    spend(nextLevel.upgradeCost);
    _cargoLevel = nextLevel;
    notifyListeners();
    return true;
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Update max depth reached
  void updateMaxDepth(int depth) {
    if (depth > _maxDepthReached) {
      _maxDepthReached = depth;
    }
  }

  // ============================================================
  // STATE CONTROL
  // ============================================================

  /// Reset economy (for new game)
  void reset({bool keepUpgrades = false}) {
    _cash = 50;
    _cargo.clear();
    _totalOreCollected = 0;
    _totalCashEarned = 0;
    _maxDepthReached = 0;
    
    if (!keepUpgrades) {
      _cargoLevel = CargoLevel.level1;
    }
    
    notifyListeners();
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'Economy(\$$_cash, cargo: $cargoCount/$maxCapacity)';
  }
}