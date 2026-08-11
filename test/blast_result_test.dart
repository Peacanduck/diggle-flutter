import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/game/world/tile.dart';
import 'package:diggle/game/world/tile_map_component.dart';
import 'package:diggle/game/world/world_generator.dart';

/// A uniform grid, so structural assertions are not at the mercy of the
/// world generator.
List<List<Tile>> _flatGrid(WorldConfig config,
        {TileType fill = TileType.dirt}) =>
    List.generate(
      config.width,
      (x) => List.generate(
          config.height, (y) => Tile(type: fill, x: x, y: y)),
    );

/// Byte-for-byte copy of `DiggleGame._collectBlastYield`'s selection rule.
/// If that changes, this must change with it — and the golden lists below
/// will fail first, which is the point.
List<TileType> _survivingYield(List<TileType> ores) {
  final kept = <TileType>[];
  for (int i = 0; i < ores.length; i++) {
    if (i.isOdd) continue; // 50% yield
    kept.add(ores[i]);
  }
  return kept;
}

void main() {
  // ============================================================
  // GOLDEN YIELD — the regression lock
  // ============================================================
  //
  // The 50% blast yield keeps every OTHER entry of BlastResult.ores, so it
  // depends entirely on the order computeBlast visits tiles. Any change to
  // those loops — including one made for a reason that looks unrelated,
  // like collecting coordinates for particles — silently changes how much
  // loot an explosion pays out. These lists were captured from the code as
  // it behaved before BlastResult existed.
  group('blast yield is order-dependent and pinned', () {
    const config = WorldConfig(seed: 12345);

    test('seed 12345 at (64, 200) radius 3 — 3 detonations', () {
      final grid = WorldGenerator(config: config).generate();
      final result = TileMapComponent.computeBlast(grid, config, 64, 200, 3);

      expect(
        result.ores.map((t) => t.name).toList(),
        [
          'coal', 'coal', 'coal', 'gold', 'copper', 'sapphire', 'copper',
          'gold', 'gold', 'silver', 'coal', 'silver', 'coal', 'sapphire',
          'sapphire', 'gold', 'copper', 'coal', 'silver', 'copper', 'coal',
          'copper', 'silver', 'emerald',
        ],
      );
      expect(
        _survivingYield(result.ores).map((t) => t.name).toList(),
        [
          'coal', 'coal', 'copper', 'copper', 'gold', 'coal', 'coal',
          'sapphire', 'copper', 'silver', 'coal', 'silver',
        ],
      );
      expect(result.detonations, [64, 200, 3, 66, 203, 1, 67, 203, 1]);
      expect(result.destroyedCount, 55);
    });

    test('seed 12345 at (30, 400) radius 3 — 4 detonations', () {
      final grid = WorldGenerator(config: config).generate();
      final result = TileMapComponent.computeBlast(grid, config, 30, 400, 3);

      expect(
        _survivingYield(result.ores).map((t) => t.name).toList(),
        [
          'copper', 'coal', 'gold', 'silver', 'silver', 'copper', 'gold',
          'coal', 'coal', 'copper', 'gold', 'gold', 'silver', 'emerald',
          'coal', 'gold', 'diamond', 'sapphire',
        ],
      );
      expect(result.detonations,
          [30, 400, 3, 27, 401, 1, 29, 402, 1, 33, 399, 1]);
      expect(result.destroyedCount, 55);
    });
  });

  // ============================================================
  // DETONATIONS
  // ============================================================
  group('detonations', () {
    const config = WorldConfig(width: 40, height: 40);

    test('includes the initial blast even with nothing to chain', () {
      final grid = _flatGrid(config);

      final result = TileMapComponent.computeBlast(grid, config, 20, 20, 2);

      expect(result.detonationCount, 1);
      expect(result.detonations, [20, 20, 2]);
    });

    test('a gas pocket in the blast appends a radius-1 chain', () {
      final grid = _flatGrid(config);
      grid[22][20].type = TileType.gas;

      final result = TileMapComponent.computeBlast(grid, config, 20, 20, 2);

      expect(result.detonationCount, 2);
      expect(result.detonations.sublist(0, 3), [20, 20, 2]);
      expect(result.detonations.sublist(3), [22, 20, 1]);
    });

    test('gas at the epicentre does not chain off itself', () {
      final grid = _flatGrid(config);
      grid[20][20].type = TileType.gas;

      final result = TileMapComponent.computeBlast(grid, config, 20, 20, 2);

      expect(result.detonationCount, 1);
      expect(grid[20][20].type, TileType.empty);
    });

    test('a gas field is capped at maxChainedBlasts', () {
      // Every tile is gas: without the cap this would cascade across the
      // whole grid and destroy thousands of tiles inside one frame.
      final grid = _flatGrid(config, fill: TileType.gas);

      final result = TileMapComponent.computeBlast(grid, config, 20, 20, 3);

      expect(result.detonationCount, TileMapComponent.maxChainedBlasts);
      expect(result.detonationCount, 16);
    });
  });

  // ============================================================
  // WHAT IS AND IS NOT DESTROYED
  // ============================================================
  group('destruction', () {
    const config = WorldConfig(width: 40, height: 40);

    test('bedrock survives and is not reported destroyed', () {
      final grid = _flatGrid(config);
      grid[21][20].type = TileType.bedrock;

      final result = TileMapComponent.computeBlast(grid, config, 20, 20, 1);

      expect(grid[21][20].type, TileType.bedrock);
      for (int i = 0; i < result.destroyed.length; i += 2) {
        expect(
          [result.destroyed[i], result.destroyed[i + 1]],
          isNot([21, 20]),
        );
      }
    });

    test('already-empty tiles are skipped, not re-reported', () {
      final grid = _flatGrid(config, fill: TileType.empty);
      grid[20][20].type = TileType.dirt;

      final result = TileMapComponent.computeBlast(grid, config, 20, 20, 2);

      expect(result.destroyedCount, 1);
      expect(result.destroyed, [20, 20]);
    });

    test('every destroyed coordinate is a tile that is now empty', () {
      final grid = _flatGrid(config, fill: TileType.gold);

      final result = TileMapComponent.computeBlast(grid, config, 20, 20, 2);

      // 5x5 area, all gold, all destroyed.
      expect(result.destroyedCount, 25);
      expect(result.ores.length, 25);
      for (int i = 0; i < result.destroyed.length; i += 2) {
        expect(grid[result.destroyed[i]][result.destroyed[i + 1]].type,
            TileType.empty);
      }
    });

    test('out-of-bounds tiles are clamped away, not indexed', () {
      final grid = _flatGrid(config);

      // Corner blast: two thirds of the radius falls outside the grid.
      final result = TileMapComponent.computeBlast(grid, config, 0, 0, 3);

      expect(result.destroyedCount, 16); // 4x4 quadrant
      for (int i = 0; i < result.destroyed.length; i += 2) {
        expect(result.destroyed[i], inInclusiveRange(0, config.width - 1));
        expect(result.destroyed[i + 1], inInclusiveRange(0, config.height - 1));
      }
    });

    test('a chain reaction beyond the grid edge is still safe', () {
      final grid = _flatGrid(config);
      grid[0][0].type = TileType.gas;

      final result = TileMapComponent.computeBlast(grid, config, 1, 1, 1);

      expect(result.detonationCount, 2);
      expect(result.detonations.sublist(3), [0, 0, 1]);
    });
  });

  group('BlastResult.empty', () {
    test('reports nothing', () {
      expect(BlastResult.empty.detonationCount, 0);
      expect(BlastResult.empty.destroyedCount, 0);
      expect(BlastResult.empty.ores, isEmpty);
    });
  });
}
