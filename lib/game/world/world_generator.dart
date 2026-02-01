/// world_generator.dart
/// Procedural world generation using seeded random.
/// 
/// The world is deterministic - same seed = same world.
/// This allows for:
/// - Consistent gameplay across restarts
/// - Future: shareable world seeds
/// - Future: daily challenge worlds

import 'dart:math';
import 'tile.dart';

/// Configuration for world generation
class WorldConfig {
  /// Width of the world in tiles
  final int width;

  /// Height of the world in tiles
  final int height;

  /// Number of surface rows (empty space above ground)
  final int surfaceRows;

  /// Random seed for deterministic generation
  final int seed;

  /// Depth at which bedrock starts appearing
  final int bedrockStartDepth;

  const WorldConfig({
    this.width = 64,
    this.height = 128,
    this.surfaceRows = 3,
    this.seed = 42,
    this.bedrockStartDepth = 120,
  });
}

/// Generates the game world procedurally
class WorldGenerator {
  final WorldConfig config;
  late final Random _random;

  WorldGenerator({required this.config}) {
    _random = Random(config.seed);
  }

  /// Generate the complete tile grid
  /// Returns a 2D list where [x][y] gives the tile at that position
  List<List<Tile>> generate() {
    // Initialize empty grid
    final grid = List.generate(
      config.width,
      (x) => List.generate(
        config.height,
        (y) => Tile(type: TileType.empty, x: x, y: y),
      ),
    );

    // Generate each column
    for (int x = 0; x < config.width; x++) {
      for (int y = 0; y < config.height; y++) {
        grid[x][y] = Tile(
          type: _getTileTypeAt(x, y),
          x: x,
          y: y,
          isRevealed: y < config.surfaceRows, // Surface is always visible
        );
      }
    }

    // Reveal starting area around player spawn
    _revealArea(grid, config.width ~/ 2, config.surfaceRows, radius: 2);

    return grid;
  }

  /// Determine tile type at given coordinates
  TileType _getTileTypeAt(int x, int y) {
    // Surface rows are empty (sky/air)
    if (y < config.surfaceRows) {
      return TileType.empty;
    }

    // First row below surface is always dirt (spawn platform)
    if (y == config.surfaceRows) {
      return TileType.dirt;
    }

    // Bedrock layer at bottom
    if (y >= config.bedrockStartDepth) {
      // Mix of bedrock and some tough rock near bottom
      if (y >= config.height - 3) {
        return TileType.bedrock;
      }
      // Transition zone
      if (_random.nextDouble() < 0.5) {
        return TileType.bedrock;
      }
      return TileType.rock;
    }

    // Calculate depth (0 = just below surface, increases downward)
    final depth = y - config.surfaceRows;
    final normalizedDepth = depth / (config.bedrockStartDepth - config.surfaceRows);

    // Generate terrain based on depth
    return _generateTerrainTile(normalizedDepth);
  }

  /// Generate terrain tile based on normalized depth (0.0 to 1.0)
  TileType _generateTerrainTile(double normalizedDepth) {
    final roll = _random.nextDouble();

    // Ore probability increases with depth
    final oreChance = _getOreChance(normalizedDepth);
    
    if (roll < oreChance) {
      return _selectOreType(normalizedDepth);
    }

    // Rock probability increases with depth
    final rockChance = _getRockChance(normalizedDepth);
    
    if (roll < oreChance + rockChance) {
      return TileType.rock;
    }

    // Default to dirt
    return TileType.dirt;
  }

  /// Get ore spawn chance based on depth
  double _getOreChance(double normalizedDepth) {
    // Start at 5% near surface, increase to 20% at depth
    return 0.05 + (normalizedDepth * 0.15);
  }

  /// Get rock spawn chance based on depth
  double _getRockChance(double normalizedDepth) {
    // Start at 10% near surface, increase to 50% at depth
    return 0.10 + (normalizedDepth * 0.40);
  }

  /// Select which ore type to spawn based on depth
  TileType _selectOreType(double normalizedDepth) {
    final roll = _random.nextDouble();

    // Gold only appears deep (below 60% depth)
    if (normalizedDepth > 0.6 && roll < 0.15) {
      return TileType.gold;
    }

    // Copper appears from 30% depth
    if (normalizedDepth > 0.3 && roll < 0.40) {
      return TileType.copper;
    }

    // Coal is common everywhere
    return TileType.coal;
  }

  /// Reveal tiles in a radius around a point
  void _revealArea(List<List<Tile>> grid, int centerX, int centerY, {int radius = 1}) {
    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        final x = centerX + dx;
        final y = centerY + dy;
        
        if (_isInBounds(x, y)) {
          grid[x][y].isRevealed = true;
        }
      }
    }
  }

  /// Check if coordinates are within world bounds
  bool _isInBounds(int x, int y) {
    return x >= 0 && x < config.width && y >= 0 && y < config.height;
  }
}

/// Utility class for world-related calculations
class WorldUtils {
  /// Convert grid coordinates to world pixel position
  static double gridToWorld(int gridPos, double tileSize) {
    return gridPos * tileSize;
  }

  /// Convert world pixel position to grid coordinates
  static int worldToGrid(double worldPos, double tileSize) {
    return (worldPos / tileSize).floor();
  }

  /// Get the center position of a tile in world coordinates
  static double getTileCenter(int gridPos, double tileSize) {
    return (gridPos * tileSize) + (tileSize / 2);
  }
}