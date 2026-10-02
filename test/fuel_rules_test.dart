import 'package:diggle/game/systems/fuel_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The live world: rows 0-29 are sky, row 30 is the ground row.
  const surface = 30;

  group('fuelStrandsDrill — the run ends only when stranded underground', () {
    bool strands(int row, int targetRow, {bool empty = true}) =>
        fuelStrandsDrill(
          tankEmpty: empty,
          row: row,
          targetRow: targetRow,
          surfaceRows: surface,
        );

    test('never on the surface, wherever the drill is headed', () {
      expect(strands(29, 29), isFalse); // parked on the surface
      expect(strands(30, 30), isFalse); // in the ground row
      expect(strands(20, 21), isFalse); // in the sky
    });

    test('the last drop of fuel finishes the climb out of the shaft', () {
      // Fuel ran out starting the move 31 -> 30: that move lands on the
      // surface, so it is not a death one tile short of the top.
      expect(strands(31, 30), isFalse);
    });

    test('empty underground with the move ending underground is stranded',
        () {
      expect(strands(31, 31), isTrue);
      expect(strands(32, 31), isTrue);
      expect(strands(200, 201), isTrue);
    });

    test('fuel left is never stranded', () {
      expect(strands(200, 201, empty: false), isFalse);
    });
  });

  group('fuelBlocksDescent — an empty tank never leaves the surface down',
      () {
    bool blocks(int row, int toRow, {bool empty = true}) => fuelBlocksDescent(
          tankEmpty: empty,
          row: row,
          toRow: toRow,
          surfaceRows: surface,
        );

    test('from the ground row into the first underground row', () {
      expect(blocks(30, 31), isTrue);
    });

    test('moving within the surface is still allowed', () {
      expect(blocks(29, 30), isFalse); // dig/drop into the ground row
      expect(blocks(29, 29), isFalse); // drive along the surface
      expect(blocks(30, 30), isFalse); // dig sideways in the ground row
      expect(blocks(30, 29), isFalse); // fly back up
    });

    test('with fuel, descending is never blocked', () {
      expect(blocks(30, 31, empty: false), isFalse);
    });

    test('already underground is not this rule (stranding handles it)', () {
      expect(blocks(31, 32), isFalse);
    });
  });
}
