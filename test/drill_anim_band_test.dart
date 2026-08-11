import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/game/systems/drill_anim.dart';
import 'package:diggle/game/systems/gear_sprites.dart';

void main() {
  group('action precedence', () {
    // The order is the easy thing to get wrong, and getting it wrong is
    // invisible in code review: every case still produces *an* animation.
    test('digging beats everything', () {
      expect(
        drillActionFor(
            digging: true, flying: true, driving: true, falling: true),
        DrillAction.digging,
      );
    });

    test('flying beats driving and falling', () {
      expect(
        drillActionFor(
            digging: false, flying: true, driving: true, falling: true),
        DrillAction.flying,
      );
    });

    test('driving beats falling — holding a direction mid-fall still drives',
        () {
      expect(
        drillActionFor(
            digging: false, flying: false, driving: true, falling: true),
        DrillAction.driving,
      );
    });

    test('falling beats idle', () {
      expect(
        drillActionFor(
            digging: false, flying: false, driving: false, falling: true),
        DrillAction.falling,
      );
    });

    test('nothing held and nothing happening is idle', () {
      expect(
        drillActionFor(
            digging: false, flying: false, driving: false, falling: false),
        DrillAction.idle,
      );
    });
  });

  group('band table', () {
    test('every action has a band', () {
      for (final action in DrillAction.values) {
        expect(kDrillAnimBands[action], isNotNull, reason: '$action');
      }
    });

    test('idle and falling never light the plume fully', () {
      // Frame 0 is authored as the shortest plume and frame 3 the longest.
      // Thrusters must not fire while parked or dropping.
      for (final action in [DrillAction.idle, DrillAction.falling]) {
        expect(kDrillAnimBands[action]!.hi, 1, reason: '$action');
      }
    });

    test('digging is the fastest band', () {
      final digging = kDrillAnimBands[DrillAction.digging]!.fps;
      for (final action in DrillAction.values) {
        if (action == DrillAction.digging) continue;
        expect(kDrillAnimBands[action]!.fps, lessThan(digging),
            reason: '$action should be slower than digging');
      }
    });

    test('no band reaches past the sheet it indexes', () {
      // The bands and the sprite sheet are edited in different repos. This
      // is the only place that fact is checked.
      for (final entry in kDrillAnimBands.entries) {
        expect(entry.value.lo, greaterThanOrEqualTo(0),
            reason: '${entry.key}');
        expect(entry.value.hi, lessThan(GearSpriteSheet.frames),
            reason: '${entry.key}');
        expect(entry.value.lo, lessThanOrEqualTo(entry.value.hi),
            reason: '${entry.key}');
      }
    });
  });

  group('drillFrame', () {
    test('starts at the band floor', () {
      for (final action in DrillAction.values) {
        expect(drillFrame(action, 0), kDrillAnimBands[action]!.lo);
      }
    });

    test('wraps without ever returning hi + 1', () {
      for (final action in DrillAction.values) {
        final band = kDrillAnimBands[action]!;
        for (var i = 0; i < 200; i++) {
          final frame = drillFrame(action, i * 0.37);
          expect(frame, inInclusiveRange(band.lo, band.hi),
              reason: '$action at phase ${i * 0.37}');
        }
      }
    });

    test('advances one frame per whole tick and returns to the floor', () {
      const action = DrillAction.digging; // span 4
      expect(drillFrame(action, 0.0), 0);
      expect(drillFrame(action, 1.0), 1);
      expect(drillFrame(action, 2.0), 2);
      expect(drillFrame(action, 3.0), 3);
      expect(drillFrame(action, 4.0), 0);
      expect(drillFrame(action, 4.9), 0);
    });

    test('idle only ever alternates between frames 0 and 1', () {
      final seen = <int>{};
      for (var i = 0; i < 50; i++) {
        seen.add(drillFrame(DrillAction.idle, i * 0.5));
      }
      expect(seen, {0, 1});
    });

    test('a negative phase is safe and still in band', () {
      for (final action in DrillAction.values) {
        final band = kDrillAnimBands[action]!;
        for (final phase in [-0.5, -1.0, -3.7, -1000.0]) {
          expect(drillFrame(action, phase),
              inInclusiveRange(band.lo, band.hi),
              reason: '$action at $phase');
        }
      }
    });

    test('a session-long phase does not overflow', () {
      // Accumulated ticks are reduced as a double before flooring; a plain
      // phase.floor() throws once the value exceeds what int can hold.
      for (final action in DrillAction.values) {
        final band = kDrillAnimBands[action]!;
        for (final phase in [1e12, 1e18, 1e300, double.maxFinite]) {
          expect(drillFrame(action, phase),
              inInclusiveRange(band.lo, band.hi),
              reason: '$action at $phase');
        }
      }
    });

    test('non-finite phase falls back to the band floor', () {
      for (final phase in [double.nan, double.infinity, -double.infinity]) {
        expect(drillFrame(DrillAction.driving, phase),
            kDrillAnimBands[DrillAction.driving]!.lo);
      }
    });
  });
}
