import 'package:diggle/game/systems/gear_sprites.dart';
import 'package:diggle/game/world/surface_layout.dart';
import 'package:diggle/game/world/tile.dart';
import 'package:diggle/game/world/world_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The live game's world shape (DiggleGame's default config).
  const config = WorldConfig(width: 64, height: 524, surfaceRows: 30, seed: 42);

  group('SurfaceLayout.sites', () {
    final sites = SurfaceLayout.sites(config.width);

    test('one of each building, left to right', () {
      expect(sites.map((s) => s.type), [
        BuildingType.museum,
        BuildingType.quests,
        BuildingType.shop,
        BuildingType.store,
      ]);
      expect(sites.map((s) => s.left), [18, 24, 35, 41]);
    });

    test('footprints never overlap and every floor is in bounds', () {
      for (var i = 0; i < sites.length; i++) {
        expect(sites[i].padLeft, greaterThanOrEqualTo(0));
        expect(sites[i].padRight, lessThan(config.width));
        if (i > 0) {
          expect(sites[i].left, greaterThan(sites[i - 1].right));
        }
      }
    });

    test('the spawn column is open ground, not a building', () {
      final spawn = config.width ~/ 2;
      expect(SurfaceLayout.doorAt(config.width, spawn), isNull);
      expect(SurfaceLayout.isPad(config, spawn, config.surfaceRows), isFalse);
      for (final site in sites) {
        expect(spawn < site.padLeft || spawn > site.padRight, isTrue,
            reason: '${site.type} floor covers the spawn column');
      }
    });

    test('too narrow a world has no buildings', () {
      expect(SurfaceLayout.sites(SurfaceLayout.minWorldWidth - 1), isEmpty);
    });
  });

  group('doorAt', () {
    test('only the two middle columns are the doorway', () {
      final shop = SurfaceLayout.sites(config.width)
          .firstWhere((s) => s.type == BuildingType.shop);
      expect(SurfaceLayout.doorAt(config.width, shop.left), isNull);
      expect(SurfaceLayout.doorAt(config.width, shop.left + 1),
          BuildingType.shop);
      expect(SurfaceLayout.doorAt(config.width, shop.left + 2),
          BuildingType.shop);
      expect(SurfaceLayout.doorAt(config.width, shop.right), isNull);
    });
  });

  group('art contract', () {
    test('building footprint matches the generated sheet', () {
      expect(BuildingSite.width, BuildingSheet.tilesWide);
      expect(BuildingSheet.cellSize, BuildingSite.width * 32);
    });

    test('every building has its own sheet column', () {
      final columns = BuildingType.values.map(BuildingSheet.column).toSet();
      expect(columns.length, BuildingType.values.length);
      expect(columns.every((c) => c >= 0 && c < BuildingSheet.columns),
          isTrue);
    });
  });

  group('applyPads', () {
    test('turns each floor into revealed bedrock and touches nothing else',
        () {
      final before = WorldGenerator(config: config).generate();
      final after = WorldGenerator(config: config).generate();
      SurfaceLayout.applyPads(after, config);

      var pads = 0;
      for (var x = 0; x < config.width; x++) {
        for (var y = 0; y < config.height; y++) {
          final tile = after[x][y];
          if (SurfaceLayout.isPad(config, x, y)) {
            pads++;
            expect(tile.type, TileType.bedrock, reason: 'pad ($x, $y)');
            expect(tile.isRevealed, isTrue, reason: 'pad ($x, $y)');
          } else {
            expect(tile.type, before[x][y].type, reason: '($x, $y)');
          }
        }
      }
      // Four buildings x (4 wide + a 1-tile apron each side).
      expect(pads, 4 * 6);
    });

    test('is idempotent — safe on every save load', () {
      final once = WorldGenerator(config: config).generate();
      SurfaceLayout.applyPads(once, config);
      final twice = WorldGenerator(config: config).generate();
      SurfaceLayout.applyPads(twice, config);
      SurfaceLayout.applyPads(twice, config);
      for (var x = 0; x < config.width; x++) {
        expect(twice[x][config.surfaceRows].type,
            once[x][config.surfaceRows].type);
      }
    });

    test('repairs a floor an old save had dug out', () {
      final grid = WorldGenerator(config: config).generate();
      final shop = SurfaceLayout.sites(config.width)
          .firstWhere((s) => s.type == BuildingType.shop);
      grid[shop.doorLeft][config.surfaceRows].type = TileType.empty;
      SurfaceLayout.applyPads(grid, config);
      expect(grid[shop.doorLeft][config.surfaceRows].type, TileType.bedrock);
    });
  });
}
