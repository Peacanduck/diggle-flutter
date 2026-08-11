import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/game/systems/vfx_queue.dart';

VfxEvent _event(VfxKind kind, {double x = 0, double y = 0}) =>
    VfxEvent(kind, worldX: x, worldY: y);

void main() {
  group('VfxQueue emit/drain', () {
    test('round-trips events in emission order', () {
      final queue = VfxQueue();

      queue.emit(_event(VfxKind.hullHit, x: 10, y: 20));
      queue.emit(_event(VfxKind.gasBurst, x: 30, y: 40));

      final drained = queue.drain();

      expect(drained.length, 2);
      expect(drained[0].kind, VfxKind.hullHit);
      expect(drained[0].worldX, 10);
      expect(drained[0].worldY, 20);
      expect(drained[1].kind, VfxKind.gasBurst);
    });

    test('drain clears the queue', () {
      final queue = VfxQueue();
      queue.emit(_event(VfxKind.rubbleFall));

      expect(queue.drain().length, 1);
      expect(queue.drain(), isEmpty);
      expect(queue.isEmpty, isTrue);
    });

    test('returns a const empty list when nothing is pending', () {
      final queue = VfxQueue();

      // Identical to XPPointsSystem.takePendingAnnouncements: an idle frame
      // must not allocate. Two drains handing back the same instance is the
      // observable consequence of `const []`.
      expect(identical(queue.drain(), queue.drain()), isTrue);
    });

    test('emitAt builds an equivalent event', () {
      final queue = VfxQueue();

      queue.emitAt(VfxKind.landImpact, 5, 6, argb: 0xFF102030, intensity: 0.5);

      final e = queue.drain().single;
      expect(e.kind, VfxKind.landImpact);
      expect(e.worldX, 5);
      expect(e.worldY, 6);
      expect(e.argb, 0xFF102030);
      expect(e.intensity, 0.5);
    });

    test('argb and intensity default sensibly', () {
      final queue = VfxQueue();
      queue.emit(_event(VfxKind.death));

      final e = queue.drain().single;
      expect(e.argb, isNull); // layer picks the kind's colour
      expect(e.intensity, 1.0);
    });
  });

  group('VfxQueue cap', () {
    test('drops the OLDEST past maxPending and counts the drops', () {
      final queue = VfxQueue();

      for (var i = 0; i < VfxQueue.maxPending + 3; i++) {
        queue.emit(_event(VfxKind.digChip, x: i.toDouble()));
      }

      expect(queue.pendingCount, VfxQueue.maxPending);
      expect(queue.droppedCount, 3);

      final drained = queue.drain();
      // The three oldest went, so the window starts at x == 3 and the most
      // recent event survives — that is the one the player is looking at.
      expect(drained.first.worldX, 3);
      expect(drained.last.worldX, (VfxQueue.maxPending + 2).toDouble());
    });

    test('clear resets both the backlog and the drop counter', () {
      final queue = VfxQueue();
      for (var i = 0; i < VfxQueue.maxPending + 5; i++) {
        queue.emit(_event(VfxKind.digChip));
      }

      queue.clear();

      expect(queue.isEmpty, isTrue);
      expect(queue.droppedCount, 0);
    });
  });

  group('VfxQueue settings', () {
    test('enabled = false drops everything', () {
      final queue = VfxQueue()..enabled = false;

      queue.emit(_event(VfxKind.explosion));
      queue.emitAt(VfxKind.hullHit, 1, 2);

      expect(queue.isEmpty, isTrue);
      // Suppression is not a capacity failure — it must not look like one.
      expect(queue.droppedCount, 0);
    });

    test('quality 0 suppresses emission, quality 0.5 does not', () {
      final queue = VfxQueue()..quality = 0;
      queue.emit(_event(VfxKind.oreBurst));
      expect(queue.isEmpty, isTrue);

      // Fractional quality scales particle COUNT in the layer; the queue
      // still carries every event.
      queue.quality = 0.5;
      queue.emit(_event(VfxKind.oreBurst));
      expect(queue.pendingCount, 1);
    });

    test('re-enabling resumes emission', () {
      final queue = VfxQueue()..enabled = false;
      queue.emit(_event(VfxKind.surfaced));

      queue.enabled = true;
      queue.emit(_event(VfxKind.surfaced));

      expect(queue.drain().length, 1);
    });
  });
}
