/// tile.dart
/// Defines tile types, properties, and state for the game world.
/// 
/// Each tile has:
/// - A type (dirt, rock, ore, bedrock, empty)
/// - Dig time (how long to excavate)
/// - Value (for ore tiles)
/// - Visibility state (fog of war)

import 'dart:ui';

/// Enumeration of all tile types in the game
enum TileType {
  /// Empty space - already dug or surface
  empty,
  
  /// Standard dirt - fast to dig
  dirt,
  
  /// Rock - slower to dig
  rock,
  
  /// Coal ore - common, low value
  coal,
  
  /// Copper ore - medium rarity/value
  copper,
  
  /// Gold ore - rare, high value
  gold,
  
  /// Bedrock - cannot be dug
  bedrock,
}

/// Extension to add properties and behavior to TileType
extension TileTypeExtension on TileType {
  /// Time in seconds to dig this tile type
  double get digTime {
    switch (this) {
      case TileType.empty:
        return 0;
      case TileType.dirt:
        return 0.3;
      case TileType.rock:
        return 0.8;
      case TileType.coal:
        return 0.4;
      case TileType.copper:
        return 0.5;
      case TileType.gold:
        return 0.6;
      case TileType.bedrock:
        return double.infinity; // Cannot dig
    }
  }

  /// Value when sold at surface (0 for non-ore)
  int get value {
    switch (this) {
      case TileType.coal:
        return 10;
      case TileType.copper:
        return 25;
      case TileType.gold:
        return 100;
      default:
        return 0;
    }
  }

  /// Fuel cost to dig/move through this tile
  double get fuelCost {
    switch (this) {
      case TileType.empty:
        return 0.5; // Moving through empty space
      case TileType.dirt:
        return 1.0;
      case TileType.rock:
        return 2.0;
      case TileType.coal:
      case TileType.copper:
      case TileType.gold:
        return 1.5;
      case TileType.bedrock:
        return 0; // Can't dig anyway
    }
  }

  /// Whether this tile type is an ore that can be collected
  bool get isOre {
    return this == TileType.coal ||
        this == TileType.copper ||
        this == TileType.gold;
  }

  /// Whether this tile can be dug
  bool get isDiggable {
    return this != TileType.bedrock && this != TileType.empty;
  }

  /// Display color for this tile type
  Color get color {
    switch (this) {
      case TileType.empty:
        return const Color(0xFF1a1a2e); // Dark background
      case TileType.dirt:
        return const Color(0xFF8B4513); // Saddle brown
      case TileType.rock:
        return const Color(0xFF696969); // Dim gray
      case TileType.coal:
        return const Color(0xFF2F2F2F); // Dark gray with shine
      case TileType.copper:
        return const Color(0xFFB87333); // Copper orange
      case TileType.gold:
        return const Color(0xFFFFD700); // Gold
      case TileType.bedrock:
        return const Color(0xFF1C1C1C); // Near black
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
      case TileType.gold:
        return const Color(0xFFFFE135);
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
      case TileType.gold:
        return 'Gold';
      case TileType.bedrock:
        return 'Bedrock';
    }
  }
}

/// Represents a single tile in the game world
class Tile {
  /// The type of this tile
  TileType type;

  /// Whether this tile has been revealed (fog of war)
  bool isRevealed;

  /// Whether this tile is currently being dug
  bool isBeingDug;

  /// Progress of current dig operation (0.0 to 1.0)
  double digProgress;

  /// Grid position X
  final int x;

  /// Grid position Y
  final int y;

  Tile({
    required this.type,
    required this.x,
    required this.y,
    this.isRevealed = false,
    this.isBeingDug = false,
    this.digProgress = 0.0,
  });

  /// Check if this tile is adjacent to given coordinates
  bool isAdjacentTo(int otherX, int otherY) {
    final dx = (x - otherX).abs();
    final dy = (y - otherY).abs();
    // Adjacent means exactly 1 tile away in cardinal direction
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  /// Reset dig progress (e.g., when player moves away)
  void resetDig() {
    isBeingDug = false;
    digProgress = 0.0;
  }

  /// Complete the dig - convert to empty tile
  void completeDig() {
    type = TileType.empty;
    isBeingDug = false;
    digProgress = 0.0;
  }

  /// Create a copy of this tile
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