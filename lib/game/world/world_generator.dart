/// world_generator.dart
/// Procedural world generation using seeded random.
/// 
/// The world is deterministic - same seed = same world.
/// This allows for:
/// - Consistent gameplay across restarts
/// - Future: shareable world seeds
/// - Future: daily challenge worlds
/// world_generator.dart
/// Procedural world generation using seeded random.

import 'dart:math';
import 'tile.dart';

/// Configuration for world generation
class WorldConfig {
  final int width;
  final int height;
  final int surfaceRows;
  final int seed;
  final int bedrockStartDepth;

  const WorldConfig({
    this.width = 128, //64
    this.height = 512, //128
    this.surfaceRows = 3,
    this.seed = 42,
    this.bedrockStartDepth = 480, // 120
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
  List<List<Tile>> generate() {
    final grid = List.generate(
      config.width,
          (x) => List.generate(
        config.height,
            (y) => Tile(type: TileType.empty, x: x, y: y),
      ),
    );

    for (int x = 0; x < config.width; x++) {
      for (int y = 0; y < config.height; y++) {
        grid[x][y] = Tile(
          type: _getTileTypeAt(x, y),
          x: x,
          y: y,
          isRevealed: y < config.surfaceRows,
        );
      }
    }

    _revealArea(grid, config.width ~/ 2, config.surfaceRows, radius: 2);

    return grid;
  }

  /// Determine tile type at given coordinates
  TileType _getTileTypeAt(int x, int y) {
    // Surface rows are empty
    if (y < config.surfaceRows) {
      return TileType.empty;
    }

    // First row below surface is always dirt
    if (y == config.surfaceRows) {
      return TileType.dirt;
    }

    // Bedrock layer at bottom
    if (y >= config.bedrockStartDepth) {
      if (y >= config.height - 3) {
        return TileType.bedrock;
      }
      if (_random.nextDouble() < 0.5) {
        return TileType.bedrock;
      }
      return TileType.rock;
    }

    // Calculate depth
    final depth = y - config.surfaceRows;

    return _generateTerrainTile(depth);
  }

  /// Generate terrain tile based on depth
  TileType _generateTerrainTile(int depth) {
    final roll = _random.nextDouble();

    // Check for special tiles (ores and hazards) based on depth
    final specialTile = _trySpawnSpecial(depth, roll);
    if (specialTile != null) {
      return specialTile;
    }

    // Rock probability increases with depth
    final rockChance = 0.10 + (depth / 120.0) * 0.45;
    if (_random.nextDouble() < rockChance) {
      return TileType.rock;
    }

    return TileType.dirt;
  }

  /// Try to spawn an ore or hazard tile
  TileType? _trySpawnSpecial(int depth, double roll) {
    // List of spawnable types at this depth with their weights
    final spawnables = <TileType, double>{};

    // Check each ore type
    for (final oreType in [
      TileType.coal,
      TileType.copper,
      TileType.silver,
      TileType.gold,
      TileType.sapphire,
      TileType.emerald,
      TileType.ruby,
      TileType.diamond,
    ]) {
      if (depth >= oreType.minDepth) {
        // Increase spawn rate slightly as you go deeper past min depth
        final depthBonus = (depth - oreType.minDepth) / 100.0;
        spawnables[oreType] = oreType.spawnWeight + (depthBonus * 0.01);
      }
    }

    // Check hazards
    for (final hazardType in [TileType.lava, TileType.gas]) {
      if (depth >= hazardType.minDepth) {
        final depthBonus = (depth - hazardType.minDepth) / 100.0;
        spawnables[hazardType] = hazardType.spawnWeight + (depthBonus * 0.005);
      }
    }

    if (spawnables.isEmpty) return null;

    // Calculate total weight
    double totalWeight = 0;
    for (final weight in spawnables.values) {
      totalWeight += weight;
    }

    // Roll for spawn
    if (roll > totalWeight) return null;

    // Select which type to spawn
    double cumulative = 0;
    for (final entry in spawnables.entries) {
      cumulative += entry.value;
      if (roll < cumulative) {
        return entry.key;
      }
    }

    return null;
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

  bool _isInBounds(int x, int y) {
    return x >= 0 && x < config.width && y >= 0 && y < config.height;
  }
}

/// Utility class for world-related calculations
class WorldUtils {
  static double gridToWorld(int gridPos, double tileSize) {
    return gridPos * tileSize;
  }

  static int worldToGrid(double worldPos, double tileSize) {
    return (worldPos / tileSize).floor();
  }

  static double getTileCenter(int gridPos, double tileSize) {
    return (gridPos * tileSize) + (tileSize / 2);
  }
}