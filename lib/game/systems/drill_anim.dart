/// drill_anim.dart
/// Maps the drill's action state onto a gear-sprite animation band.
///
/// The sprite sheet's rarity selects the ART; this selects the RATE. Cash
/// upgrade tiers (drillbit / engine / cooling / hull / light) deliberately
/// do not enter into it — animation speed reads as what the machine is
/// doing, not as what the player has bought.
///
/// Flame-free and side-effect-free on purpose: this is the part of the
/// animation worth testing, so it lives where a test can reach it without a
/// game harness. See drill_anim_band_test.dart.
library;

enum DrillAction { digging, flying, driving, falling, idle }

/// Playback rate plus the window of frames the action is allowed to use.
///
/// A bare fps is not enough. Thrusters must not fire while parked, and frame
/// 0 is authored as the shortest plume — so clamping idle and falling to
/// frames 0-1 buys three visually distinct states out of four frames with no
/// extra art.
class DrillAnimBand {
  const DrillAnimBand(this.fps, this.lo, this.hi);

  final double fps;
  final int lo;
  final int hi;

  int get span => hi - lo + 1;
}

const Map<DrillAction, DrillAnimBand> kDrillAnimBands = {
  DrillAction.digging: DrillAnimBand(14.0, 0, 3),
  DrillAction.flying: DrillAnimBand(12.0, 0, 3),
  DrillAction.driving: DrillAnimBand(8.0, 0, 3),
  // Thrusters off — the plume must not extend while the machine is falling.
  DrillAction.falling: DrillAnimBand(2.0, 0, 1),
  // Parked: a slow idle that never fully lights the plume.
  DrillAction.idle: DrillAnimBand(3.0, 0, 1),
};

/// Resolve the action. **Precedence is load-bearing** and is the easy thing
/// to get wrong: digging beats flying beats driving beats falling beats
/// idle. Digging while falling is still digging; holding a direction during
/// a fall still reads as driving.
DrillAction drillActionFor({
  required bool digging,
  required bool flying,
  required bool driving,
  required bool falling,
}) {
  if (digging) return DrillAction.digging;
  if (flying) return DrillAction.flying;
  if (driving) return DrillAction.driving;
  if (falling) return DrillAction.falling;
  return DrillAction.idle;
}

/// Frame index for [action] at accumulated [phase] (in ticks, i.e. seconds
/// times the band's fps). Always within the band — never `hi + 1`.
int drillFrame(DrillAction action, double phase) {
  final band = kDrillAnimBands[action]!;
  if (!phase.isFinite) return band.lo;
  // Reduce as a double BEFORE flooring. A session-long accumulation can
  // exceed what int can represent, and double.floor() throws there. The
  // double modulo is also already non-negative for a positive divisor, so
  // this handles a negative phase without a separate branch.
  return band.lo + (phase % band.span).floor();
}
