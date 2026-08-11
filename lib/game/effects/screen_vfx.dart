/// screen_vfx.dart
/// Full-screen tints that live in the camera viewport rather than the world,
/// so they do not move, scale or shake with it: damage flashes today, the
/// death fade and whiteout later.
library;

import 'dart:ui';

import 'package:flame/components.dart';

class ScreenVfx extends PositionComponent {
  ScreenVfx() : super(priority: 100);

  /// A damage flash reads as "you got hit", not "the screen broke". Well
  /// under half opacity is enough, and keeps the world legible during the
  /// hit — which matters most exactly when the player is taking damage.
  static const double maxOpacity = 0.45;

  final Paint _paint = Paint();

  // Colour components of the active flash, split once on [flash] so nothing
  // here touches the deprecated Color channel getters.
  int _r = 255;
  int _g = 0;
  int _b = 0;

  double _opacity = 0;
  double _decayPerSecond = 3.0;

  bool get isFlashing => _opacity > 0;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  /// Tint the screen [argb] at [strength] (0..1) and fade it out.
  ///
  /// A weaker flash never interrupts a brighter one still fading — chip
  /// damage during a big hit should not dim the big hit.
  void flash(int argb, double strength, {double decayPerSecond = 3.0}) {
    final target = strength.clamp(0.0, 1.0) * maxOpacity;
    if (target <= _opacity) return;
    _r = (argb >> 16) & 0xff;
    _g = (argb >> 8) & 0xff;
    _b = argb & 0xff;
    _opacity = target;
    _decayPerSecond = decayPerSecond;
  }

  void clear() => _opacity = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (_opacity <= 0) return;
    _opacity = (_opacity - _decayPerSecond * dt).clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    if (_opacity <= 0) return;
    _paint.color =
        Color.fromARGB((_opacity * 255).round().clamp(0, 255), _r, _g, _b);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }
}
