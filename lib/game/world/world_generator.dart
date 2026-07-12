/// world_generator.dart
/// Procedural world generation using seeded random.
///
/// The world is deterministic - same seed = same world.
/// Generation runs in ordered passes, each with its own Random derived
/// from (seed + passIndex) so adding/reordering logic inside one pass
/// never changes the output of the others:
///   Pass 0: biome-aware base terrain fill
///   Pass 1: cave pocket carving
///   Pass 2: structures (abandoned shafts, buried ruins)
///
/// Determinism matters: the weekly challenge mode gives every player the
/// same seed and expects an identical world on every device.

import 'dart:math';
import 'biome.dart';
import 'tile.dart';

/// Configuration for world generation
class WorldConfig {
  final int width;
  final int height;
  final int surfaceRows;
  final int seed;
  final int bedrockStartDepth;

  /// Prestige "hardcore seams": scale ore / hazard spawn weights.
  final double oreRichness;
  final double hazardIntensity;

  const WorldConfig({
    this.width = 128, //64
    this.height = 512, //128
    this.surfaceRows = 3,
    this.seed = 42,
    this.bedrockStartDepth = 480, // 120
    this.oreRichness = 1.0,
    this.hazardIntensity = 1.0,
  });
}

/// Generates the game world procedurally
class WorldGenerator {
  final WorldConfig config;

  WorldGenerator({required this.config});

  /// Generate the complete tile grid
  List<List<Tile>> generate() {
    final grid = List.generate(
      config.width,
      (x) => List.generate(
        config.height,
        (y) => Tile(type: TileType.empty, x: x, y: y),
      ),
    );

    _fillBaseTerrain(grid, Random(config.seed));
    _carveCaves(grid, Random(config.seed + 1));
    _placeStructures(grid, Random(config.seed + 2));

    for (int x = 0; x < config.width; x++) {
      for (int y = 0; y < config.surfaceRows; y++) {
        grid[x][y].isRevealed = true;
      }
    }
    _revealArea(grid, config.width ~/ 2, config.surfaceRows, radius: 2);

    return grid;
  }

  // ============================================================
  // PASS 0: BASE TERRAIN
  // ============================================================

  void _fillBaseTerrain(List<List<Tile>> grid, Random random) {
    for (int x = 0; x < config.width; x++) {
      for (int y = 0; y < config.height; y++) {
        grid[x][y].type = _getTileTypeAt(x, y, random);
      }
    }
  }

  /// Determine tile type at given coordinates
  TileType _getTileTypeAt(int x, int y, Random random) {
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
      if (random.nextDouble() < 0.5) {
        return TileType.bedrock;
      }
      return TileType.rock;
    }

    // Calculate depth
    final depth = y - config.surfaceRows;

    return _generateTerrainTile(depth, random);
  }

  /// Generate terrain tile based on depth and biome
  TileType _generateTerrainTile(int depth, Random random) {
    final biome = Biome.atDepth(depth);
    final roll = random.nextDouble();

    // Check for special tiles (ores and hazards) based on depth
    final specialTile = _trySpawnSpecial(depth, roll, biome);
    if (specialTile != null) {
      return _substitute(specialTile, biome);
    }

    // Rock probability increases with depth
    final rockChance = 0.10 + (depth / 120.0) * 0.45;
    if (random.nextDouble() < rockChance) {
      return _substitute(TileType.rock, biome);
    }

    return _substitute(TileType.dirt, biome);
  }

  /// Apply the biome's base-tile substitution (dirt→frozenDirt etc.)
  TileType _substitute(TileType type, Biome biome) {
    return biome.substitutions[type] ?? type;
  }

  /// Try to spawn an ore or hazard tile
  TileType? _trySpawnSpecial(int depth, double roll, Biome biome) {
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
      TileType.crystalOre,
    ]) {
      if (depth >= oreType.minDepth) {
        // Increase spawn rate slightly as you go deeper past min depth
        final depthBonus = (depth - oreType.minDepth) / 100.0;
        final baseWeight = oreType.spawnWeight + (depthBonus * 0.01);
        final weight = baseWeight *
            (biome.weightMultipliers[oreType] ?? 1.0) *
            config.oreRichness;
        if (weight > 0) spawnables[oreType] = weight;
      }
    }

    // Check hazards + unstable rock
    for (final hazardType in [
      TileType.lava,
      TileType.gas,
      TileType.unstableRock,
    ]) {
      if (depth >= hazardType.minDepth) {
        final depthBonus = (depth - hazardType.minDepth) / 100.0;
        final baseWeight = hazardType.spawnWeight + (depthBonus * 0.005);
        final weight = baseWeight *
            (biome.weightMultipliers[hazardType] ?? 1.0) *
            config.hazardIntensity;
        if (weight > 0) spawnables[hazardType] = weight;
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

  // ============================================================
  // PASS 1: CAVE POCKETS
  // ============================================================

  /// Carve empty pockets via short drunken walks, density per biome.
  void _carveCaves(List<List<Tile>> grid, Random random) {
    // Leave a buffer below the surface so the first dig isn't a free fall,
    // and never carve into the bedrock band.
    final minY = config.surfaceRows + 8;
    final maxY = config.bedrockStartDepth - 2;

    for (final biome in Biome.strata) {
      final bandTop = (config.surfaceRows + biome.minDepth).clamp(minY, maxY);
      final bandBottom =
          (config.surfaceRows + biome.maxDepth).clamp(minY, maxY);
      if (bandBottom <= bandTop) continue;

      final bandArea = config.width * (bandBottom - bandTop);
      final pocketCount = (bandArea / 1000.0 * biome.caveDensity).round();

      for (int i = 0; i < pocketCount; i++) {
        int cx = random.nextInt(config.width);
        int cy = bandTop + random.nextInt(bandBottom - bandTop);
        final steps = 4 + random.nextInt(7); // 4–10 walk steps

        for (int s = 0; s < steps; s++) {
          _carveBlob(grid, cx, cy, random.nextBool() ? 1 : 2, minY, maxY);
          cx += random.nextInt(3) - 1;
          cy += random.nextInt(3) - 1;
          cx = cx.clamp(0, config.width - 1);
          cy = cy.clamp(bandTop, bandBottom - 1);
        }
      }
    }
  }

  void _carveBlob(
      List<List<Tile>> grid, int cx, int cy, int radius, int minY, int maxY) {
    for (int dx = -radius; dx <= radius; dx++) {
      for (int dy = -radius; dy <= radius; dy++) {
        if (dx * dx + dy * dy > radius * radius) continue;
        final x = cx + dx;
        final y = cy + dy;
        if (x < 0 || x >= config.width || y < minY || y >= maxY) continue;
        if (grid[x][y].type == TileType.bedrock) continue;
        grid[x][y].type = TileType.empty;
      }
    }
  }

  // ============================================================
  // PASS 2: STRUCTURES
  // ============================================================

  void _placeStructures(List<List<Tile>> grid, Random random) {
    final minY = config.surfaceRows + 6;
    final maxY = config.bedrockStartDepth - 4;

    for (final biome in Biome.strata) {
      final bandTop = (config.surfaceRows + biome.minDepth).clamp(minY, maxY);
      final bandBottom =
          (config.surfaceRows + biome.maxDepth).clamp(minY, maxY);
      if (bandBottom <= bandTop) continue;

      // Abandoned shafts: vertical empty channel with a supply crate at
      // the bottom. A dug-out trail that leads somewhere worth going.
      for (int i = 0; i < biome.shaftCount; i++) {
        final x = 2 + random.nextInt(config.width - 4);
        final startY = bandTop + random.nextInt(
            (bandBottom - bandTop - 10).clamp(1, 1 << 30));
        final length = 8 + random.nextInt(9); // 8–16
        final endY = (startY + length).clamp(startY, maxY - 1);

        for (int y = startY; y < endY; y++) {
          if (grid[x][y].type == TileType.bedrock) break;
          grid[x][y].type = TileType.empty;
        }
        if (grid[x][endY].type != TileType.bedrock) {
          grid[x][endY].type = TileType.lootCrate;
        }
      }

      // Buried ruins: small rock-walled room with an artifact at the
      // center and sometimes a crate in a corner.
      for (int i = 0; i < biome.ruinCount; i++) {
        final roomW = 4 + random.nextInt(3); // 4–6
        final roomH = 3 + random.nextInt(2); // 3–4
        final left = 2 + random.nextInt((config.width - roomW - 4).clamp(1, 1 << 30));
        final top = bandTop +
            random.nextInt((bandBottom - bandTop - roomH - 1).clamp(1, 1 << 30));

        bool touchesBedrock = false;
        for (int x = left; x < left + roomW && !touchesBedrock; x++) {
          for (int y = top; y < top + roomH; y++) {
            if (grid[x][y].type == TileType.bedrock) {
              touchesBedrock = true;
              break;
            }
          }
        }
        if (touchesBedrock) continue;

        final wallType = _substitute(TileType.rock, biome);
        for (int x = left; x < left + roomW; x++) {
          for (int y = top; y < top + roomH; y++) {
            final isWall = x == left ||
                x == left + roomW - 1 ||
                y == top ||
                y == top + roomH - 1;
            grid[x][y].type = isWall ? wallType : TileType.empty;
          }
        }

        // Artifact at room center
        final centerX = left + roomW ~/ 2;
        final centerY = top + roomH ~/ 2;
        grid[centerX][centerY].type = TileType.artifact;

        // 50% chance of a bonus crate inside
        if (random.nextBool() && roomW >= 5) {
          grid[left + 1][top + roomH - 2].type = TileType.lootCrate;
        }
      }
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

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
