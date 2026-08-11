/// thruster_trail.dart
/// Exhaust puffs behind the drill while it is flying.
///
/// A **continuous emitter, not a queue event.** `heldDirection == up` is
/// true on every frame the button is held, so queueing an event per frame
/// would hit [VfxQueue.maxPending] in under a second and starve everything
/// else in the game of effects.
///
/// The whole trail is ONE component with no children: positions live in
/// three fixed [Float32List]s written as a ring buffer, so flying costs no
/// allocations and no component churn at all.
///
/// It lives in the world (inside `VfxLayer`) rather than on the drill, so
/// puffs stay where they were emitted instead of travelling along with the
/// ship.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';

import '../diggle_game.dart';
import '../player/drill_component.dart';

class ThrusterTrail extends Component with HasGameReference<DiggleGame> {
  ThrusterTrail() : super(priority: -1); // behind the burst particles

  static const int maxPuffs = 14;

  /// Seconds between puffs at full quality — about 22 per second.
  static const double spawnInterval = 0.045;

  /// How long one puff lives, in seconds.
  static const double puffLifetime = 0.45;

  // Warm exhaust, matching the flame keys in the gear sprite art.
  static const int _r = 0xFF;
  static const int _g = 0xA7;
  static const int _b = 0x26;

  final Float32List _x = Float32List(maxPuffs);
  final Float32List _y = Float32List(maxPuffs);

  /// Remaining life, 1 -> 0. Zero means the slot is free.
  final Float32List _life = Float32List(maxPuffs);

  final math.Random _random = math.Random();
  final Paint _paint = Paint();

  int _next = 0;
  double _accumulator = 0;

  void clear() {
    _life.fillRange(0, maxPuffs, 0);
    _accumulator = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (var i = 0; i < maxPuffs; i++) {
      if (_life[i] > 0) {
        _life[i] = math.max(0, _life[i] - dt / puffLifetime);
      }
    }

    final quality = game.vfx.quality;
    if (quality <= 0 || game.drill.heldDirection != MoveDirection.up) {
      _accumulator = 0;
      return;
    }

    // Lower quality thins the trail rather than shortening it, so the
    // effect still reads as continuous exhaust.
    _accumulator += dt * quality;
    while (_accumulator >= spawnInterval) {
      _accumulator -= spawnInterval;
      final drill = game.drill;
      _x[_next] = drill.position.x + (_random.nextDouble() - 0.5) * 6;
      _y[_next] = drill.position.y + drill.size.y * 0.45;
      _life[_next] = 1.0;
      _next = (_next + 1) % maxPuffs;
    }
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < maxPuffs; i++) {
      final life = _life[i];
      if (life <= 0) continue;
      _paint.color =
          Color.fromARGB((life * 190).round().clamp(0, 255), _r, _g, _b);
      // Puffs expand as they cool.
      canvas.drawCircle(
          Offset(_x[i], _y[i]), 1.5 + (1.0 - life) * 3.5, _paint);
    }
  }
}
