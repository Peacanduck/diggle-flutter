/// tile.dart
/// Defines tile types, properties, and state for the game world.
///
/// Each tile has:
/// - A type (dirt, rock, ore, bedrock, empty)
/// - Dig time (how long to excavate)
/// - Value (for ore tiles)
/// - Hardness (determines which drillbit can mine it)
/// - Visibility state (fog of war)

import 'dart:ui';

/// Enumeration of all tile types in the game
enum TileType {
  // Basic tiles
  empty,
  dirt,
  rock,
  bedrock,

  // Ores (ordered by value: cheapest to most valuable)
  coal,      // $5
  copper,    // $15
  silver,    // $50
  gold,      // $150
  sapphire,  // $400
  emerald,   // $900
  ruby,      // $2000
  diamond,   // $10000

  // Hazards
  lava,  // Instant death
  gas,   // Damage on mine
}

/// Extension to add properties and behavior to TileType
extension TileTypeExtension on TileType {
  /// Time in seconds to dig this tile type (base time, modified by drillbit)
  double get digTime {
    switch (this) {
      case TileType.empty:
        return 0;
      case TileType.dirt:
        return 0.12;
      case TileType.rock:
        return 0.3;
      case TileType.coal:
        return 0.15;
      case TileType.copper:
        return 0.18;
      case TileType.silver:
        return 0.22;
      case TileType.gold:
        return 0.28;
      case TileType.sapphire:
        return 0.35;
      case TileType.emerald:
        return 0.42;
      case TileType.ruby:
        return 0.5;
      case TileType.diamond:
        return 0.6;
      case TileType.lava:
        return 0.1;
      case TileType.gas:
        return 0.1;
      case TileType.bedrock:
        return double.infinity;
    }
  }

  /// Hardness level - determines which drillbit can mine this
  /// 1 = soft (basic bit), 2 = medium (reinforced), 3 = hard (titanium), 4 = very hard (diamond)
  /// 99 = unbreakable (bedrock)
  int get hardness {
    switch (this) {
      case TileType.empty:
        return 0;
      case TileType.dirt:
        return 1;
      case TileType.coal:
        return 1;
      case TileType.rock:
        return 3;
      case TileType.copper:
        return 1;
      case TileType.silver:
        return 2;
      case TileType.gold:
        return 2;
      case TileType.sapphire:
        return 3;
      case TileType.emerald:
        return 3;
      case TileType.ruby:
        return 4;
      case TileType.diamond:
        return 4;
      case TileType.lava:
        return 1;
      case TileType.gas:
        return 1;
      case TileType.bedrock:
        return 99;
    }
  }

  /// Value when sold at surface (0 for non-ore)
  int get value {
    switch (this) {
      case TileType.coal:
        return 5;
      case TileType.copper:
        return 15;
      case TileType.silver:
        return 50;
      case TileType.gold:
        return 150;
      case TileType.sapphire:
        return 400;
      case TileType.emerald:
        return 900;
      case TileType.ruby:
        return 2000;
      case TileType.diamond:
        return 10000;
      default:
        return 0;
    }
  }

  /// Fuel cost to dig/move through this tile (base cost, modified by cooling)
  double get fuelCost {
    switch (this) {
      case TileType.empty:
        return 0.5;
      case TileType.dirt:
        return 1.0;
      case TileType.rock:
        return 1.5;
      case TileType.coal:
        return 1.0;
      case TileType.copper:
        return 1.2;
      case TileType.silver:
        return 1.4;
      case TileType.gold:
        return 1.6;
      case TileType.sapphire:
        return 1.8;
      case TileType.emerald:
        return 2.0;
      case TileType.ruby:
        return 2.2;
      case TileType.diamond:
        return 2.5;
      case TileType.lava:
      case TileType.gas:
        return 1.0;
      case TileType.bedrock:
        return 0;
    }
  }

  /// Whether this tile type is an ore that can be collected
  bool get isOre {
    switch (this) {
      case TileType.coal:
      case TileType.copper:
      case TileType.silver:
      case TileType.gold:
      case TileType.sapphire:
      case TileType.emerald:
      case TileType.ruby:
      case TileType.diamond:
        return true;
      default:
        return false;
    }
  }

  /// Whether this tile is a hazard
  bool get isHazard {
    return this == TileType.lava || this == TileType.gas;
  }

  /// Whether this tile is instant death
  bool get isLethal {
    return this == TileType.lava;
  }

  /// Damage dealt when mining this tile (for gas)
  double get hazardDamage {
    switch (this) {
      case TileType.gas:
        return 25.0;
      default:
        return 0;
    }
  }

  /// Whether this tile can be dug (assuming proper drillbit)
  bool get isDiggable {
    return this != TileType.bedrock && this != TileType.empty;
  }

  /// Display color for this tile type
  Color get color {
    switch (this) {
      case TileType.empty:
        return const Color(0xFF1a1a2e);
      case TileType.dirt:
        return const Color(0xFF8B4513);
      case TileType.rock:
        return const Color(0xFF696969);
      case TileType.coal:
        return const Color(0xFF2F2F2F);
      case TileType.copper:
        return const Color(0xFFB87333);
      case TileType.silver:
        return const Color(0xFFC0C0C0);
      case TileType.gold:
        return const Color(0xFFFFD700);
      case TileType.sapphire:
        return const Color(0xFF0F52BA);
      case TileType.emerald:
        return const Color(0xFF50C878);
      case TileType.ruby:
        return const Color(0xFFE0115F);
      case TileType.diamond:
        return const Color(0xFFB9F2FF);
      case TileType.lava:
        return const Color(0xFFFF4500);
      case TileType.gas:
        return const Color(0xFF7CFC00);
      case TileType.bedrock:
        return const Color(0xFF1C1C1C);
    }
  }

  /// Secondary color for visual detail
  Color get highlightColor {
    switch (this) {
      case TileType.empty:
        return const Color(0xFF16213e);
      case TileType.dirt:
        return const Color(0xFFA0522D);
      case TileType.rock:
        return const Color(0xFF808080);
      case TileType.coal:
        return const Color(0xFF4A4A4A);
      case TileType.copper:
        return const Color(0xFFCD853F);
      case TileType.silver:
        return const Color(0xFFE8E8E8);
      case TileType.gold:
        return const Color(0xFFFFE135);
      case TileType.sapphire:
        return const Color(0xFF1E90FF);
      case TileType.emerald:
        return const Color(0xFF3CB371);
      case TileType.ruby:
        return const Color(0xFFFF1744);
      case TileType.diamond:
        return const Color(0xFFE0FFFF);
      case TileType.lava:
        return const Color(0xFFFF6347);
      case TileType.gas:
        return const Color(0xFFADFF2F);
      case TileType.bedrock:
        return const Color(0xFF2D2D2D);
    }
  }

  /// Human-readable name
  String get displayName {
    switch (this) {
      case TileType.empty:
        return 'Empty';
      case TileType.dirt:
        return 'Dirt';
      case TileType.rock:
        return 'Rock';
      case TileType.coal:
        return 'Coal';
      case TileType.copper:
        return 'Copper';
      case TileType.silver:
        return 'Silver';
      case TileType.gold:
        return 'Gold';
      case TileType.sapphire:
        return 'Sapphire';
      case TileType.emerald:
        return 'Emerald';
      case TileType.ruby:
        return 'Ruby';
      case TileType.diamond:
        return 'Diamond';
      case TileType.lava:
        return 'Lava';
      case TileType.gas:
        return 'Gas Pocket';
      case TileType.bedrock:
        return 'Bedrock';
    }
  }

  /// Hardness name for display
  String get hardnessName {
    switch (hardness) {
      case 1:
        return 'Soft';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      case 4:
        return 'Very Hard';
      case 99:
        return 'Unbreakable';
      default:
        return 'None';
    }
  }

  /// Minimum depth where this tile can spawn
  int get minDepth {
    switch (this) {
      case TileType.coal:
        return 0;
      case TileType.copper:
        return 5;
      case TileType.silver:
        return 22;
      case TileType.gold:
        return 50;
      case TileType.sapphire:
        return 150;
      case TileType.emerald:
        return 200;
      case TileType.ruby:
        return 350;
      case TileType.diamond:
        return 370;
      case TileType.gas:
        return 200;
      case TileType.lava:
        return 270;
      default:
        return 0;
    }
  }

  /// Spawn chance (relative weight) at appropriate depth
  double get spawnWeight {
    switch (this) {
      case TileType.coal:
        return 0.10;
      case TileType.copper:
        return 0.08;
      case TileType.silver:
        return 0.06;
      case TileType.gold:
        return 0.05;
      case TileType.sapphire:
        return 0.04;
      case TileType.emerald:
        return 0.03;
      case TileType.ruby:
        return 0.02;
      case TileType.diamond:
        return 0.015;
      case TileType.gas:
        return 0.03;
      case TileType.lava:
        return 0.025;
      default:
        return 0;
    }
  }
}

/// Represents a single tile in the game world
class Tile {
  TileType type;
  bool isRevealed;
  bool isBeingDug;
  double digProgress;
  final int x;
  final int y;

  Tile({
    required this.type,
    required this.x,
    required this.y,
    this.isRevealed = false,
    this.isBeingDug = false,
    this.digProgress = 0.0,
  });

  bool isAdjacentTo(int otherX, int otherY) {
    final dx = (x - otherX).abs();
    final dy = (y - otherY).abs();
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  void resetDig() {
    isBeingDug = false;
    digProgress = 0.0;
  }

  void completeDig() {
    type = TileType.empty;
    isBeingDug = false;
    digProgress = 0.0;
  }

  Tile copy() {
    return Tile(
      type: type,
      x: x,
      y: y,
      isRevealed: isRevealed,
      isBeingDug: isBeingDug,
      digProgress: digProgress,
    );
  }

  @override
  String toString() => 'Tile($x, $y, ${type.displayName})';
}