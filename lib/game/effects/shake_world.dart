/// shake_world.dart
/// The game world, with screen shake applied as a render transform.
library;

import 'dart:math' as math;
import 'dart:ui' show Canvas;

import 'package:flame/components.dart';

/// Screen shake that lives in the world's render transform.
///
/// Why not a viewfinder effect: `camera.follow` installs a `FollowBehavior`
/// that lerps the viewfinder every frame, and `camera.setBounds` stacks a
/// `BoundedPositionBehavior` on top of it — a viewfinder `MoveEffect` gets
/// fought and damped by both. And `World extends Component`, not
/// `PositionComponent`, so there is no `.position` on the world to shake in
/// the first place.
///
/// Shaking in [renderFromCamera] instead gives:
/// - **zero coordinate-frame change** — `drill.position`, the tile grid
///   math and `getSpawnPosition()` are all untouched, so nothing that reads
///   world coordinates has to know this exists;
/// - **zero interaction with the camera behaviours**, which act on the
///   viewfinder during `update`, long before anything renders;
/// - **unaffected culling** — `visibleWorldRect` is viewfinder-derived, and
///   a translate of at most [maxAmp] is absorbed by `TileMapComponent`'s
///   `renderBuffer = 2` (64px) with a large margin.
///
/// The one cost: the translate bypasses `camera.setBounds`, so shaking at a
/// world edge can slide the background into view. [maxAmp] is clamped low
/// enough that this stays sub-pixel at the game's 1.5 zoom.
class ShakeWorld extends World {
  ShakeWorld({super.children});

  /// Peak amplitude in WORLD pixels. ~6 screen px at zoom 1.5.
  static const double maxAmp = 4.0;

  /// Trauma bled off per second — a full-strength shake runs ~1.4s.
  static const double decayPerSecond = 0.7;

  final math.Random _random = math.Random();

  double _trauma = 0;
  double _offsetX = 0;
  double _offsetY = 0;

  double get trauma => _trauma;
  bool get isShaking => _trauma > 0;

  /// Add [amount] trauma (0..1). Additive and capped, so a burst of small
  /// hits builds into one shake instead of each one restarting it.
  void addTrauma(double amount) {
    if (amount <= 0) return;
    _trauma = (_trauma + amount).clamp(0.0, 1.0);
  }

  /// Restart / world regen.
  void clearShake() {
    _trauma = 0;
    _offsetX = 0;
    _offsetY = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_trauma <= 0) return;

    _trauma = (_trauma - decayPerSecond * dt).clamp(0.0, 1.0);
    if (_trauma <= 0) {
      _offsetX = 0;
      _offsetY = 0;
      return;
    }
    // Quadratic falloff — punchy on impact, quiet on the tail. A linear
    // fade reads as a wobble that overstays.
    final amp = maxAmp * _trauma * _trauma;
    _offsetX = (_random.nextDouble() * 2 - 1) * amp;
    _offsetY = (_random.nextDouble() * 2 - 1) * amp;
  }

  @override
  void renderFromCamera(Canvas canvas) {
    if (_trauma <= 0) {
      super.renderFromCamera(canvas);
      return;
    }
    canvas.save();
    canvas.translate(_offsetX, _offsetY);
    super.renderFromCamera(canvas);
    canvas.restore();
  }
}
