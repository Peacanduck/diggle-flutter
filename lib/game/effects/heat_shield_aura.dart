/// heat_shield_aura.dart
/// Persistent ring on the drill showing the Heat Shield is up.
///
/// The Heat Shield is a points-priced consumable that, until now, had no
/// on-screen presence at all: no aura while active and no event when it
/// expires. Polling `heatShieldActive` from a component solves both without
/// touching the timer in `DiggleGame.update` — the true->false edge is the
/// expiry notification.
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../diggle_game.dart';

class HeatShieldAura extends Component with HasGameReference<DiggleGame> {
  HeatShieldAura() : super(priority: 5);

  // Deep orange, matching the lava VFX so "heat" reads consistently.
  static const int _r = 0xFF;
  static const int _g = 0x70;
  static const int _b = 0x43;

  /// Ring radius relative to the drill's own size.
  static const double _radiusFactor = 0.72;

  final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  Offset _center = Offset.zero;
  double _radius = 18;

  double _phase = 0;
  bool _wasActive = false;

  /// 1 -> 0 burst on expiry. The only moment the player can be told the
  /// shield ran out.
  double _expiryFlash = 0;

  @override
  void onMount() {
    super.onMount();
    final host = parent;
    if (host is PositionComponent) {
      _center = Offset(host.size.x / 2, host.size.y / 2);
      _radius = host.size.x * _radiusFactor;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final active = game.heatShieldActive;
    if (_wasActive && !active) _expiryFlash = 1.0;
    _wasActive = active;

    if (active) {
      _phase += dt * 3.0;
    } else if (_expiryFlash > 0) {
      _expiryFlash = (_expiryFlash - dt * 2.0).clamp(0.0, 1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_wasActive) {
      // Pulse between half and full alpha so it reads as powered rather
      // than as a static decal.
      final pulse = 0.5 + 0.5 * math.sin(_phase);
      _paint.color =
          Color.fromARGB((90 + 110 * pulse).round().clamp(0, 255), _r, _g, _b);
      canvas.drawCircle(_center, _radius, _paint);
      return;
    }

    if (_expiryFlash > 0) {
      // Expands and fades as it dies — visibly the opposite of the steady
      // pulse, so "shield gone" is not mistaken for "shield still up".
      _paint.color =
          Color.fromARGB((200 * _expiryFlash).round().clamp(0, 255), _r, _g, _b);
      canvas.drawCircle(
          _center, _radius * (1.0 + (1.0 - _expiryFlash) * 0.8), _paint);
    }
  }
}
