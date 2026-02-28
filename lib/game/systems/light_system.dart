/// light_system.dart
/// Manages the lighting system upgrades that affect fog-of-war reveal radius.
///
/// The light system determines:
/// - How many tiles around the drill are revealed (fog cleared)
/// - Higher levels = larger visible area = better navigation
/// - Essential for spotting ores and hazards before you reach them

import 'package:flutter/foundation.dart';

/// Light system upgrade levels
enum LightLevel {
  candle(
    revealRadius: 1,
    upgradeCost: 0,
    name: 'Candle',
    description: 'Dim candlelight. Reveals 1 tile around you.',
  ),
  lantern(
    revealRadius: 2,
    upgradeCost: 1500,
    name: 'Lantern',
    description: 'Oil lantern. Reveals 2 tiles around you.',
  ),
  floodlight(
    revealRadius: 3,
    upgradeCost: 8000,
    name: 'Floodlight',
    description: 'Bright floodlight. Reveals 3 tiles around you.',
  ),
  spotlight(
    revealRadius: 4,
    upgradeCost: 35000,
    name: 'Spotlight',
    description: 'Powerful spotlight. Reveals 4 tiles around you.',
  ),
  solarArray(
    revealRadius: 5,
    upgradeCost: 100000,
    name: 'Solar Array',
    description: 'Maximum illumination. Reveals 5 tiles around you.',
  );

  /// Number of tiles revealed around the drill
  final int revealRadius;

  /// Cost to upgrade to this level
  final int upgradeCost;

  /// Display name
  final String name;

  /// Description
  final String description;

  const LightLevel({
    required this.revealRadius,
    required this.upgradeCost,
    required this.name,
    required this.description,
  });

  LightLevel? get nextLevel {
    switch (this) {
      case LightLevel.candle:
        return LightLevel.lantern;
      case LightLevel.lantern:
        return LightLevel.floodlight;
      case LightLevel.floodlight:
        return LightLevel.spotlight;
      case LightLevel.spotlight:
        return LightLevel.solarArray;
      case LightLevel.solarArray:
        return null;
    }
  }

  /// Get icon for this light level
  String get icon {
    switch (this) {
      case LightLevel.candle:
        return '🕯️';
      case LightLevel.lantern:
        return '🏮';
      case LightLevel.floodlight:
        return '🔦';
      case LightLevel.spotlight:
        return '💡';
      case LightLevel.solarArray:
        return '☀️';
    }
  }
}

/// Manages light system state and upgrades
class LightSystem extends ChangeNotifier {
  LightLevel _level;

  LightSystem({
    LightLevel level = LightLevel.candle,
  }) : _level = level;

  // ============================================================
  // GETTERS
  // ============================================================

  LightLevel get level => _level;

  /// Current reveal radius in tiles
  int get revealRadius => _level.revealRadius;

  /// Display name
  String get name => _level.name;

  /// Description
  String get description => _level.description;

  /// Icon
  String get icon => _level.icon;

  // ============================================================
  // UPGRADES
  // ============================================================

  bool canUpgrade() => _level.nextLevel != null;

  LightLevel? getNextUpgrade() => _level.nextLevel;

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

  void reset({LightLevel? keepLevel}) {
    _level = keepLevel ?? LightLevel.candle;
    notifyListeners();
  }

  /// Restore light state from a saved game.
  void restore({required int level}) {
    if (level >= 0 && level < LightLevel.values.length) {
      _level = LightLevel.values[level];
    } else {
      _level = LightLevel.candle;
    }
    notifyListeners();
  }

  @override
  String toString() {
    return 'LightSystem(${_level.name}, radius: $revealRadius)';
  }
}