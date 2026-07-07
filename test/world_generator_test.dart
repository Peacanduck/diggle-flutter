import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/game/world/biome.dart';
import 'package:diggle/game/world/tile.dart';
import 'package:diggle/game/world/tile_map_component.dart';
import 'package:diggle/game/world/world_generator.dart';

void main() {
  const config = WorldConfig(seed: 12345);

  group('WorldGenerator determinism', () {
    test('same seed produces identical worlds', () {
      final a = WorldGenerator(config: config).generate();
      final b = WorldGenerator(config: config).generate();

      for (int x = 0; x < config.width; x++) {
        for (int y = 0; y < config.height; y++) {
          expect(a[x][y].type, b[x][y].type,
              reason: 'Mismatch at ($x, $y)');
        }
      }
    });

    test('different seeds produce different worlds', () {
      final a = WorldGenerator(config: config).generate();
      final b = WorldGenerator(config: const WorldConfig(seed: 99999))
          .generate();

      int differences = 0;
      for (int x = 0; x < config.width; x++) {
        for (int y = 0; y < config.height; y++) {
          if (a[x][y].type != b[x][y].type) differences++;
        }
      }
      expect(differences, greaterThan(1000));
    });
  });

  group('biome strata', () {
    late List<List<Tile>> grid;

    setUpAll(() {
      grid = WorldGenerator(config: config).generate();
    });

    Map<TileType, int> countInBand(int minDepth, int maxDepth) {
      final counts = <TileType, int>{};
      for (int x = 0; x < config.width; x++) {
        for (int y = 0; y < config.height; y++) {
          final depth = y - config.surfaceRows;
          if (depth < minDepth || depth >= maxDepth) continue;
          counts[grid[x][y].type] = (counts[grid[x][y].type] ?? 0) + 1;
        }
      }
      return counts;
    }

    test('Biome.atDepth maps bands correctly', () {
      expect(Biome.atDepth(0).name, 'Topsoil');
      expect(Biome.atDepth(119).name, 'Topsoil');
      expect(Biome.atDepth(120).name, 'Permafrost');
      expect(Biome.atDepth(240).name, 'Crystal Caverns');
      expect(Biome.atDepth(360).name, 'Magma Core');
      expect(Biome.atDepth(5000).name, 'Magma Core');
    });

    test('Permafrost substitutes dirt with frozen dirt', () {
      final permafrost = countInBand(120, 240);
      expect(permafrost[TileType.frozenDirt] ?? 0, greaterThan(0));
      expect(permafrost[TileType.dirt] ?? 0, 0);

      final topsoil = countInBand(1, 120);
      expect(topsoil[TileType.frozenDirt] ?? 0, 0);
      expect(topsoil[TileType.dirt] ?? 0, greaterThan(0));
    });

    test('Magma Core substitutes rock with magma rock', () {
      final magma = countInBand(360, 470);
      expect(magma[TileType.magmaRock] ?? 0, greaterThan(0));
      expect(magma[TileType.rock] ?? 0, 0);
    });

    test('crystal ore only spawns in Crystal Caverns and below', () {
      final above = countInBand(0, 240);
      expect(above[TileType.crystalOre] ?? 0, 0);

      final caverns = countInBand(240, 360);
      expect(caverns[TileType.crystalOre] ?? 0, greaterThan(0));
    });

    test('world contains caves, crates, and artifacts', () {
      int caveTiles = 0;
      int crates = 0;
      int artifacts = 0;
      for (int x = 0; x < config.width; x++) {
        for (int y = config.surfaceRows + 8; y < config.height; y++) {
          switch (grid[x][y].type) {
            case TileType.empty:
              caveTiles++;
              break;
            case TileType.lootCrate:
              crates++;
              break;
            case TileType.artifact:
              artifacts++;
              break;
            default:
              break;
          }
        }
      }
      expect(caveTiles, greaterThan(100));
      expect(crates, greaterThan(3));
      expect(artifacts, greaterThan(2));
    });
  });

  group('tile grid serialization', () {
    test('versioned round-trip preserves all tile types', () {
      final grid = WorldGenerator(config: config).generate();
      final bytes = TileMapComponent.encodeTileGrid(grid, config);

      // Version byte + one byte per tile
      expect(bytes.length, 1 + config.width * config.height);
      expect(bytes[0], 1);

      final restored = WorldGenerator(config: const WorldConfig(seed: 1))
          .generate();
      TileMapComponent.decodeTileGrid(bytes, restored, config);

      for (int x = 0; x < config.width; x++) {
        for (int y = 0; y < config.height; y++) {
          expect(restored[x][y].type, grid[x][y].type,
              reason: 'Mismatch at ($x, $y)');
        }
      }
    });

    test('legacy headerless payload still decodes', () {
      final grid = WorldGenerator(config: config).generate();
      final versioned = TileMapComponent.encodeTileGrid(grid, config);
      final legacy = Uint8List.sublistView(versioned, 1);

      final restored = WorldGenerator(config: const WorldConfig(seed: 1))
          .generate();
      TileMapComponent.decodeTileGrid(legacy, restored, config);

      expect(restored[10][100].type, grid[10][100].type);
      expect(restored[60][300].type, grid[60][300].type);
    });

    test('wrong length throws', () {
      final grid = WorldGenerator(config: config).generate();
      expect(
        () => TileMapComponent.decodeTileGrid(
            Uint8List(17), grid, config),
        throwsArgumentError,
      );
    });
  });
}
