/// item_system.dart
/// Manages usable items in the player's inventory.

import 'package:flutter/foundation.dart';

/// Types of usable items
enum ItemType {
  backupFuel,
  repairBot,
  dynamite,
  c4,
  spaceRift,
}

/// Extension for item properties
extension ItemTypeExtension on ItemType {
  String get displayName {
    switch (this) {
      case ItemType.backupFuel:
        return 'Backup Fuel';
      case ItemType.repairBot:
        return 'Repair Bot';
      case ItemType.dynamite:
        return 'Dynamite';
      case ItemType.c4:
        return 'C4';
      case ItemType.spaceRift:
        return 'Space Rift';
    }
  }

  String get description {
    switch (this) {
      case ItemType.backupFuel:
        return 'Restores 50 fuel';
      case ItemType.repairBot:
        return 'Repairs 40 hull HP';
      case ItemType.dynamite:
        return 'Blows up 3x3 area';
      case ItemType.c4:
        return 'Blows up 5x5 area';
      case ItemType.spaceRift:
        return 'Teleport to surface';
    }
  }

  int get price {
    switch (this) {
      case ItemType.backupFuel:
        return 30;
      case ItemType.repairBot:
        return 50;
      case ItemType.dynamite:
        return 75;
      case ItemType.c4:
        return 150;
      case ItemType.spaceRift:
        return 200;
    }
  }

  String get icon {
    switch (this) {
      case ItemType.backupFuel:
        return '⛽';
      case ItemType.repairBot:
        return '🔧';
      case ItemType.dynamite:
        return '🧨';
      case ItemType.c4:
        return '💣';
      case ItemType.spaceRift:
        return '🌀';
    }
  }

  // Effect values
  double get fuelAmount => this == ItemType.backupFuel ? 50.0 : 0;
  double get repairAmount => this == ItemType.repairBot ? 40.0 : 0;
  int get explosionRadius {
    switch (this) {
      case ItemType.dynamite:
        return 1; // 3x3
      case ItemType.c4:
        return 2; // 5x5
      default:
        return 0;
    }
  }
}

/// Manages the player's item inventory
class ItemSystem extends ChangeNotifier {
  /// Items in inventory (type -> quantity)
  final Map<ItemType, int> _items = {};

  /// Max items per slot
  static const int maxStack = 5;

  /// Total item slots available
  static const int maxSlots = 5;

  // Getters
  Map<ItemType, int> get items => Map.unmodifiable(_items);

  int getQuantity(ItemType type) => _items[type] ?? 0;

  bool hasItem(ItemType type) => getQuantity(type) > 0;

  int get totalItems {
    int total = 0;
    for (final qty in _items.values) {
      total += qty;
    }
    return total;
  }

  int get usedSlots => _items.keys.length;

  bool get hasSpace => usedSlots < maxSlots;

  /// Check if can add item
  bool canAddItem(ItemType type) {
    final current = getQuantity(type);
    if (current > 0) {
      return current < maxStack;
    }
    return hasSpace;
  }

  /// Add item to inventory
  bool addItem(ItemType type) {
    if (!canAddItem(type)) return false;

    _items[type] = getQuantity(type) + 1;
    notifyListeners();
    return true;
  }

  /// Use item (removes from inventory)
  bool useItem(ItemType type) {
    if (!hasItem(type)) return false;

    final current = getQuantity(type);
    if (current <= 1) {
      _items.remove(type);
    } else {
      _items[type] = current - 1;
    }
    notifyListeners();
    return true;
  }

  /// Get list of item types in inventory (for UI)
  List<ItemType> get itemSlots {
    return _items.keys.toList();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}