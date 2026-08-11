/// vfx_layer.dart
/// Drains [VfxQueue] once per frame and turns each event into particles.
///
/// Sits in the world at priority 10, above the tile map (0) and the drill
/// (1). That means it paints over the fog rects `TileMapComponent._renderTile`
/// draws for unrevealed tiles, so **only ever emit positional VFX for
/// revealed tiles** — otherwise a particle leaks the contents of the dark.
/// This holds by construction today: `explode` and `collapseUnstableAround`
/// both call `revealAround`, and a dig site is revealed by definition. Keep
/// it that way.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

import '../diggle_game.dart';
import '../systems/vfx_queue.dart';

/// Cached `Paint`s, one per colour.
///
/// Particle renderers mutate the colour of the Paint they are handed and
/// then draw, all within one synchronous render pass, so sharing a Paint
/// across bursts of the same colour is safe. What must never happen is
/// allocating a Paint inside a particle's render — the same discipline
/// `TileMapComponent` already follows.
class VfxPalette {
  final Map<int, Paint> _fills = {};
  final Map<int, Paint> _strokes = {};

  Paint fill(int argb) =>
      _fills.putIfAbsent(argb, () => Paint()..color = Color(argb));

  Paint stroke(int argb) => _strokes.putIfAbsent(
        argb,
        () => Paint()
          ..color = Color(argb)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
}

/// One burst of debris chips, drawn as a SINGLE particle.
///
/// The entire burst is one component and one `update` call regardless of
/// chip count — 192 chips cost ~24 components, not 192. Velocities are
/// seeded once into a [Float32List] at spawn, so rendering allocates
/// nothing per frame beyond the single `Color` the shared Paint needs.
///
/// 2x2 rects rather than sprites: no texture bind, and at 32px pixel-art
/// scale flat chips read better than scaled-down artwork anyway.
class ChipBurst {
  ChipBurst({
    required int count,
    required this.paint,
    required int argb,
    required double speed,
    required this.gravity,
    required this.chipSize,
    required math.Random random,
    double coneCenter = 0,
    double coneSpread = math.pi * 2,
    this.yScale = 1.0,
  })  : _v = Float32List(count * 2),
        _r = (argb >> 16) & 0xff,
        _g = (argb >> 8) & 0xff,
        _b = argb & 0xff {
    for (var i = 0; i < count; i++) {
      final angle = coneCenter + (random.nextDouble() - 0.5) * coneSpread;
      // Vary speed per chip so the burst does not read as a ring.
      final s = speed * (0.35 + random.nextDouble() * 0.65);
      _v[i * 2] = math.cos(angle) * s;
      _v[i * 2 + 1] = math.sin(angle) * s * yScale;
    }
  }

  final Float32List _v;
  final Paint paint;
  final double gravity;
  final double chipSize;
  final double yScale;
  final int _r;
  final int _g;
  final int _b;

  int get count => _v.length ~/ 2;

  /// [progress] is 0..1 over the particle's lifespan. Velocities are in
  /// world px per lifespan, so a `speed` of 30 travels ~30px before dying.
  void render(Canvas canvas, double progress) {
    final alpha = ((1.0 - progress) * 255).round().clamp(0, 255);
    if (alpha <= 0) return;
    paint.color = Color.fromARGB(alpha, _r, _g, _b);

    final half = chipSize / 2;
    for (var i = 0; i < count; i++) {
      final x = _v[i * 2] * progress;
      final y = _v[i * 2 + 1] * progress + gravity * progress * progress;
      canvas.drawRect(
        Rect.fromLTWH(x - half, y - half, chipSize, chipSize),
        paint,
      );
    }
  }
}

/// An expanding stroked ring. Used for "absorbed / negated", which has to
/// look nothing like a damage burst — that visual distinction is the whole
/// point of the effect.
class RingPulse {
  RingPulse({
    required this.paint,
    required int argb,
    required this.maxRadius,
  })  : _r = (argb >> 16) & 0xff,
        _g = (argb >> 8) & 0xff,
        _b = argb & 0xff;

  final Paint paint;
  final double maxRadius;
  final int _r;
  final int _g;
  final int _b;

  void render(Canvas canvas, double progress) {
    final alpha = ((1.0 - progress) * 220).round().clamp(0, 255);
    if (alpha <= 0) return;
    paint.color = Color.fromARGB(alpha, _r, _g, _b);
    canvas.drawCircle(Offset.zero, maxRadius * progress, paint);
  }
}

class VfxLayer extends Component with HasGameReference<DiggleGame> {
  VfxLayer() : super(priority: 10);

  /// Live burst components. Past this the OLDEST is dropped — whatever just
  /// happened is more relevant to the player than a burst already fading.
  static const int maxComponents = 24;

  // Defaults when an event carries no palette hint.
  static const int _rubbleArgb = 0xFF8D6E63;
  static const int _hullHitArgb = 0xFFFF5252;
  static const int _gasArgb = 0xFF9CCC65;
  static const int _crystalArgb = 0xFF80DEEA;
  static const int _lavaArgb = 0xFFFF7043;
  static const int _shieldArgb = 0xFF64FFDA;
  static const int _dustArgb = 0xFFBCAAA4;
  static const int _deathArgb = 0xFFFF8A65;
  static const int _explosionArgb = 0xFFFFB74D;

  final math.Random _random = math.Random();
  final VfxPalette _palette = VfxPalette();
  final List<ParticleSystemComponent> _live = [];

  /// Optional forward sink. [VfxQueue.drain] is single-consumer, so a future
  /// audio layer subscribes here rather than polling the queue itself —
  /// `flame_audio` is already a declared dependency with zero usage.
  void Function(VfxEvent event)? onEvent;

  /// True while the world is hidden behind a full-screen overlay.
  ///
  /// Note this deliberately does NOT include [GameState.gameOver]: the death
  /// effect fires on the frame the state flips, so freezing there would
  /// spawn the explosion and then stop it dead one frame later.
  bool get _gated =>
      game.state == GameState.shopping || game.state == GameState.paused;

  @override
  void updateTree(double dt) {
    // DiggleGame.update calls `super.update(dt)` BEFORE its `_state` early
    // return, so children keep ticking through shop and pause. Overriding
    // updateTree (not update) freezes this whole subtree with them.
    //
    // Drain and DISCARD while gated: replaying a stored burst the instant
    // the shop closes is worse than losing it.
    if (_gated) {
      game.vfx.drain();
      return;
    }
    for (final event in game.vfx.drain()) {
      onEvent?.call(event);
      _spawn(event);
    }
    super.updateTree(dt);
  }

  /// Restart / world regen. `tileMap.reset()` is `async void` and leaves a
  /// blank grid for a few hundred ms, during which live particles would be
  /// drawing over nothing.
  void clearAll() {
    removeAll(children.toList());
    _live.clear();
  }

  // ============================================================
  // SPAWNING
  // ============================================================

  void _spawn(VfxEvent event) {
    final quality = game.vfx.quality.clamp(0.0, 1.0);
    if (quality <= 0) return;
    final intensity = event.intensity.clamp(0.0, 1.0);

    switch (event.kind) {
      case VfxKind.rubbleFall:
        // Up to 45 hull damage arrives with this and, until now, nothing on
        // screen explained it. Heavy gravity in a narrow downward cone so it
        // reads as the ceiling coming down.
        _burst(event, quality,
            count: 6,
            argb: event.argb ?? _rubbleArgb,
            speed: 10,
            gravity: 46,
            chipSize: 3,
            lifespan: 0.55,
            coneCenter: math.pi / 2,
            coneSpread: 1.2);

      case VfxKind.hullHit:
        _burst(event, quality,
            count: 8,
            argb: event.argb ?? _hullHitArgb,
            speed: 26,
            gravity: 8,
            chipSize: 2,
            lifespan: 0.4);
        game.world.addTrauma(intensity);
        game.screenVfx.flash(_hullHitArgb, intensity);

      case VfxKind.gasBurst:
        // Rises and lingers. Emitted at half intensity when the legendary
        // hull halves the damage, so that bonus becomes visible.
        _burst(event, quality,
            count: 14,
            argb: event.argb ?? _gasArgb,
            speed: 34,
            gravity: -14,
            chipSize: 3,
            lifespan: 0.7);

      case VfxKind.crystalShard:
        _burst(event, quality,
            count: 10,
            argb: event.argb ?? _crystalArgb,
            speed: 40,
            gravity: 0,
            chipSize: 2,
            lifespan: 0.45);

      case VfxKind.lavaScald:
        _burst(event, quality,
            count: 12,
            argb: event.argb ?? _lavaArgb,
            speed: 20,
            gravity: -18,
            chipSize: 3,
            lifespan: 0.8);

      case VfxKind.landImpact:
        // Flattened spray rather than a radial puff: dust kicked sideways
        // along the ground reads as landing, a circle reads as an explosion.
        // One component, because this is the most frequent event in the game.
        _burst(event, quality,
            count: 8,
            argb: event.argb ?? _dustArgb,
            speed: 24,
            gravity: 14,
            chipSize: 2,
            lifespan: 0.35,
            yScale: 0.3);

      case VfxKind.explosion:
        // Emitted once per detonation, so a gas chain produces a visible
        // run of these instead of one silent mass deletion. Trauma
        // accumulates and saturates, which is why a 16-blast chain shakes
        // harder than a single charge without any special-casing.
        _burst(event, quality,
            count: 12,
            argb: event.argb ?? _explosionArgb,
            speed: 55,
            gravity: 20,
            chipSize: 3,
            lifespan: 0.6);
        game.world.addTrauma(0.7 * intensity);
        game.screenVfx.flash(_explosionArgb, 0.35 * intensity);

      case VfxKind.tileBreak:
        _burst(event, quality,
            count: 4,
            argb: event.argb ?? _rubbleArgb,
            speed: 18,
            gravity: 30,
            chipSize: 2,
            lifespan: 0.35);

      case VfxKind.shieldAbsorb:
        _ring(event, argb: event.argb ?? _shieldArgb);

      case VfxKind.death:
        _burst(event, quality,
            count: 20,
            argb: _deathArgb,
            speed: 60,
            gravity: 30,
            chipSize: 3,
            lifespan: 1.0);
        game.world.addTrauma(1.0);
        game.screenVfx.flash(_deathArgb, 1.0, decayPerSecond: 1.2);

      default:
        // digChip / oreBurst / crateOpen / artifactNew / artifactDupe /
        // scanPulse / repairSparkle / teleportOut / teleportIn / surfaced
        // belong to A3. Ignored rather than shown as a placeholder that
        // would have to be undone.
        break;
    }
  }

  void _burst(
    VfxEvent event,
    double quality, {
    required int count,
    required int argb,
    required double speed,
    required double gravity,
    required double chipSize,
    required double lifespan,
    double coneCenter = 0,
    double coneSpread = math.pi * 2,
    double yScale = 1.0,
  }) {
    final n = (count * quality).round().clamp(1, count);
    final burst = ChipBurst(
      count: n,
      paint: _palette.fill(argb),
      argb: argb,
      speed: speed,
      gravity: gravity,
      chipSize: chipSize,
      random: _random,
      coneCenter: coneCenter,
      coneSpread: coneSpread,
      yScale: yScale,
    );
    _track(ParticleSystemComponent(
      particle: ComputedParticle(
        lifespan: lifespan,
        renderer: (canvas, particle) => burst.render(canvas, particle.progress),
      ),
      position: Vector2(event.worldX, event.worldY),
    ));
  }

  void _ring(VfxEvent event, {required int argb, double radius = 22}) {
    final pulse = RingPulse(
      paint: _palette.stroke(argb),
      argb: argb,
      maxRadius: radius,
    );
    _track(ParticleSystemComponent(
      particle: ComputedParticle(
        lifespan: 0.45,
        renderer: (canvas, particle) => pulse.render(canvas, particle.progress),
      ),
      position: Vector2(event.worldX, event.worldY),
    ));
  }

  void _track(ParticleSystemComponent component) {
    // Finished bursts remove themselves from the tree; drop their stale
    // handles before deciding whether we are over the ceiling.
    _live.removeWhere((p) => p.particle?.shouldRemove ?? true);
    _live.add(component);
    while (_live.length > maxComponents) {
      _live.removeAt(0).removeFromParent();
    }
    add(component);
  }
}
