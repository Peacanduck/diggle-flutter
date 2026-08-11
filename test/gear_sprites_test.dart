import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/game/systems/gear_sprites.dart';
import 'package:diggle/game/systems/gear_system.dart';

/// gear_sprites.dart is GENERATED and copied by hand from DiggleAssets. This
/// file re-validates the layout on every regeneration, forever — it is the
/// cheapest possible guard on a file nobody is supposed to read closely.
void main() {
  group('sheet geometry', () {
    test('columns is exactly rarities x frames', () {
      expect(GearSpriteSheet.columns,
          GearRarity.values.length * GearSpriteSheet.frames);
    });

    test('rows is slots x two views', () {
      expect(GearSpriteSheet.rows, GearSpriteSheet.drawOrder.length * 2);
    });

    test('pixel dimensions agree with the cell counts', () {
      expect(GearSpriteSheet.sheetWidth,
          GearSpriteSheet.columns * GearSpriteSheet.cellSize);
      expect(GearSpriteSheet.sheetHeight,
          GearSpriteSheet.rows * GearSpriteSheet.cellSize);
    });
  });

  group('cell()', () {
    test('every slot/rarity/view/frame maps to a DISTINCT cell', () {
      // This is the assertion that catches the whole bug class the old
      // `row * 8 + col` cache key had: a collision produces no crash, just
      // silently wrong art. A set-size check finds it immediately.
      final seen = <String>{};
      var total = 0;

      for (final slot in GearSpriteSheet.drawOrder) {
        for (final rarity in GearRarity.values) {
          for (final down in [false, true]) {
            for (var frame = 0; frame < GearSpriteSheet.frames; frame++) {
              final (col, row) =
                  GearSpriteSheet.cell(slot, rarity, down: down, frame: frame);
              seen.add('$col,$row');
              total++;
            }
          }
        }
      }

      expect(total, 5 * GearRarity.values.length * 2 * GearSpriteSheet.frames);
      expect(seen.length, total, reason: 'two cells collided');
    });

    test('every cell lands inside the sheet', () {
      for (final slot in GearSpriteSheet.drawOrder) {
        for (final rarity in GearRarity.values) {
          for (final down in [false, true]) {
            for (var frame = 0; frame < GearSpriteSheet.frames; frame++) {
              final (col, row) =
                  GearSpriteSheet.cell(slot, rarity, down: down, frame: frame);
              expect(col, inInclusiveRange(0, GearSpriteSheet.columns - 1));
              expect(row, inInclusiveRange(0, GearSpriteSheet.rows - 1));
            }
          }
        }
      }
    });

    test('frame defaults to 0, keeping pre-animation call sites correct', () {
      for (final slot in GearSpriteSheet.drawOrder) {
        for (final rarity in GearRarity.values) {
          expect(GearSpriteSheet.cell(slot, rarity),
              GearSpriteSheet.cell(slot, rarity, frame: 0));
          expect(GearSpriteSheet.cell(slot, rarity, down: true),
              GearSpriteSheet.cell(slot, rarity, down: true, frame: 0));
        }
      }
    });

    test('frames of one part are contiguous along the column axis', () {
      // The layout was widened rather than deepened precisely so a part's
      // frames sit next to each other on the fastest-changing axis.
      for (final rarity in GearRarity.values) {
        final (base, row) = GearSpriteSheet.cell(GearSlot.hull, rarity);
        for (var frame = 0; frame < GearSpriteSheet.frames; frame++) {
          final (col, r) =
              GearSpriteSheet.cell(GearSlot.hull, rarity, frame: frame);
          expect(col, base + frame);
          expect(r, row);
        }
      }
    });

    test('down view is the side row plus five, unchanged by the frame axis',
        () {
      for (final slot in GearSpriteSheet.drawOrder) {
        for (final rarity in GearRarity.values) {
          final (_, sideRow) = GearSpriteSheet.cell(slot, rarity);
          final (_, downRow) = GearSpriteSheet.cell(slot, rarity, down: true);
          expect(downRow, sideRow + 5);
        }
      }
    });
  });

  group('BaseDrillSheet', () {
    test('geometry is self-consistent', () {
      expect(BaseDrillSheet.columns, BaseDrillSheet.frames);
      expect(BaseDrillSheet.rows, 2); // side + down
      expect(BaseDrillSheet.sheetWidth,
          BaseDrillSheet.columns * BaseDrillSheet.cellSize);
      expect(BaseDrillSheet.sheetHeight,
          BaseDrillSheet.rows * BaseDrillSheet.cellSize);
    });

    test('runs on the same frame count as the gear sheet', () {
      // Both are driven by one _animFrame in DrillComponent. If these ever
      // diverge, the base drill would index off the end of its own sheet.
      expect(BaseDrillSheet.frames, GearSpriteSheet.frames);
    });

    test('every view/frame maps to a distinct in-bounds cell', () {
      final seen = <String>{};
      for (final down in [false, true]) {
        for (var frame = 0; frame < BaseDrillSheet.frames; frame++) {
          final (col, row) = BaseDrillSheet.cell(down: down, frame: frame);
          expect(col, inInclusiveRange(0, BaseDrillSheet.columns - 1));
          expect(row, inInclusiveRange(0, BaseDrillSheet.rows - 1));
          seen.add('$col,$row');
        }
      }
      expect(seen.length, 2 * BaseDrillSheet.frames);
    });

    test('side is row 0 and down is row 1', () {
      expect(BaseDrillSheet.cell().$2, 0);
      expect(BaseDrillSheet.cell(down: true).$2, 1);
    });

    test('frame defaults to 0', () {
      expect(BaseDrillSheet.cell(), BaseDrillSheet.cell(frame: 0));
    });
  });

  group('drawOrder', () {
    test('covers every slot exactly once', () {
      expect(GearSpriteSheet.drawOrder.toSet().length,
          GearSpriteSheet.drawOrder.length);
      expect(GearSpriteSheet.drawOrder.toSet(), GearSlot.values.toSet());
    });
  });
}
