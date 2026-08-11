/// vfx_queue.dart
/// Cosmetic effect requests: produced by game logic, consumed by the Flame
/// effect layer once per frame.
///
/// This file imports nothing — not Flame, not `dart:ui`. Nothing under
/// `lib/game/systems/` depends on Flame and this must not be the exception.
///
/// It exists because the *cause* of a hit is known only at the call site.
/// `HullSystem.takeDamage` only ever sees a `double`, so by the time damage
/// is applied it is no longer possible to tell lava from gas from falling
/// rubble. The call site records the cause here instead.
///
/// Shaped deliberately like `XPPointsSystem`'s pending-announcement queue:
/// fixed cap, drop-oldest, drain-and-clear, `const []` on empty. Everything
/// in it is cosmetic, so dropping is always safe.
library;

enum VfxKind {
  digChip,
  tileBreak,
  oreBurst,
  explosion,
  gasBurst,
  rubbleFall,
  lavaScald,
  shieldAbsorb,
  crystalShard,
  hullHit,
  landImpact,
  teleportOut,
  teleportIn,
  scanPulse,
  repairSparkle,
  crateOpen,
  artifactNew,
  artifactDupe,
  surfaced,
  death,
}

/// One cosmetic effect request, in world pixel space.
class VfxEvent {
  const VfxEvent(
    this.kind, {
    required this.worldX,
    required this.worldY,
    this.argb,
    this.intensity = 1.0,
  });

  final VfxKind kind;

  /// Pixel centre in WORLD space — not grid coordinates. Callers holding a
  /// tile should convert with `tileSize * n + tileSize / 2`.
  final double worldX;
  final double worldY;

  /// Palette hint, usually `tile.type.color.value`. Null means "use the
  /// kind's default colour".
  final int? argb;

  /// 0..1. Scales particle count, and for the damage kinds it *is* the
  /// screen-shake trauma — so a 3-tile rubble collapse shakes three times
  /// as hard as a 1-tile one. The layer clamps; callers need not.
  final double intensity;
}

/// Single-producer, single-consumer queue of pending [VfxEvent]s.
///
/// Not a `ChangeNotifier`: this is polled by a Flame component every frame
/// and never listened to by a widget.
class VfxQueue {
  /// Cap on undrained events. The worst realistic burst — C4 into a gas
  /// field — is 16 detonations plus their hull hits, so this is several
  /// frames of headroom. Past the cap the OLDEST is dropped: whatever just
  /// happened matters more to the player than a stale burst.
  static const int maxPending = 48;

  final List<VfxEvent> _pending = [];
  int _droppedCount = 0;

  /// Master switch — settings `vfxQuality: off`.
  bool enabled = true;

  /// 0.0 / 0.5 / 1.0 for settings `off` / `low` / `full`. The layer
  /// multiplies particle counts by this; the queue only reads it to
  /// short-circuit emission entirely at zero.
  double quality = 1.0;

  /// Events dropped since the last [clear], for profiling. A non-zero value
  /// in normal play means the cap or the drain rate is wrong.
  int get droppedCount => _droppedCount;

  bool get isEmpty => _pending.isEmpty;
  int get pendingCount => _pending.length;

  void emit(VfxEvent event) {
    if (!enabled || quality <= 0) return;
    _pending.add(event);
    if (_pending.length > maxPending) {
      _pending.removeAt(0);
      _droppedCount++;
    }
  }

  /// Convenience for the common call shape.
  void emitAt(
    VfxKind kind,
    double worldX,
    double worldY, {
    int? argb,
    double intensity = 1.0,
  }) {
    if (!enabled || quality <= 0) return; // skip allocating the event
    emit(VfxEvent(kind,
        worldX: worldX, worldY: worldY, argb: argb, intensity: intensity));
  }

  /// Take (and clear) everything queued. Returns `const []` when empty so an
  /// idle frame allocates nothing.
  List<VfxEvent> drain() {
    if (_pending.isEmpty) return const [];
    final drained = List<VfxEvent>.unmodifiable(_pending);
    _pending.clear();
    return drained;
  }

  /// Restart / world regen: anything queued refers to a world that no
  /// longer exists.
  void clear() {
    _pending.clear();
    _droppedCount = 0;
  }
}
