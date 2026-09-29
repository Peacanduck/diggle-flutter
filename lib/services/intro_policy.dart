/// intro_policy.dart
/// Pure tip-sequencing logic for the first-run coach marks.
///
/// No Flutter, no Flame, no I/O — every decision is a function of the passed
/// state and the current game readings, so it can be exhaustively unit-tested
/// without a game harness. [IntroService] owns persistence and wiring; this
/// file owns *when a tip may show* and *how the state advances*.
///
/// The tips are **event-ordered, not sequence-locked**: whichever real event
/// is happening now wins, regardless of which earlier tips have or haven't
/// shown. A player who drills straight down and takes fall damage before ever
/// filling their cargo gets the fall-damage tip when it happens, not held
/// behind the cargo/fuel tips.
library;

/// The five first-run tips, in the order they naturally occur (not the order
/// they must fire — see the event-ordering note above).
enum IntroTip {
  /// Idle at the surface: hold a direction to drill.
  movement,

  /// First ore mined: cargo is finite.
  firstOre,

  /// Cargo nearly full: surface and sell to afford upgrades.
  cargoFull,

  /// Fuel running low below the surface: refuelling costs cash, at the
  /// surface only.
  lowFuel,

  /// First fall past the safe distance: drops damage the hull.
  fallDamage,
}

/// How long the player must sit at the surface without directional input
/// before the movement tip fires. Anyone who drills sooner has shown they
/// don't need it — see [IntroState.markInputReceived].
const double kMovementIdleSeconds = 1.5;

/// Cargo fraction at which the "surface and sell" tip becomes eligible.
const double kCargoFullFraction = 0.8;

/// Fuel fraction below which the "watch your fuel" tip becomes eligible.
const double kLowFuelFraction = 0.4;

/// Immutable snapshot of the intro's progress. Advanced through the pure
/// reducer methods below so every transition is testable in isolation.
class IntroState {
  /// The player tapped *Skip tips* — no tip ever shows again.
  final bool skipped;

  /// All five tips have been shown — the intro is finished for good.
  final bool completed;

  /// Tips already shown (or consumed without rendering, for [movement]).
  final Set<IntroTip> shown;

  /// A tip card is currently on screen. While true, [nextTip] returns null so
  /// two cards never stack.
  final bool tipVisible;

  const IntroState({
    this.skipped = false,
    this.completed = false,
    this.shown = const {},
    this.tipVisible = false,
  });

  IntroState copyWith({
    bool? skipped,
    bool? completed,
    Set<IntroTip>? shown,
    bool? tipVisible,
  }) {
    return IntroState(
      skipped: skipped ?? this.skipped,
      completed: completed ?? this.completed,
      shown: shown ?? this.shown,
      tipVisible: tipVisible ?? this.tipVisible,
    );
  }

  /// Mark [tip] as shown. Completing the set of five sets [completed]. Always
  /// lowers [tipVisible] — a tip that has been shown no longer has a card up.
  IntroState markShown(IntroTip tip) {
    final next = {...shown, tip};
    return copyWith(
      shown: next,
      completed: completed || next.length == IntroTip.values.length,
      tipVisible: false,
    );
  }

  /// The movement tip is consumed the first time the player provides
  /// directional input, whether or not its card ever rendered — a player who
  /// drilled immediately must not get it later. No-op once movement is shown.
  IntroState markInputReceived() =>
      shown.contains(IntroTip.movement) ? this : markShown(IntroTip.movement);

  /// A card is now on screen. Raises [tipVisible] so nothing stacks on top.
  IntroState markTipVisible() => copyWith(tipVisible: true);

  /// The player tapped *Skip tips*. Nothing shows again.
  IntroState markSkipped() => copyWith(skipped: true, tipVisible: false);
}

/// The tip to show right now, or null if none should show.
///
/// Pure. Given the same inputs it always returns the same tip. The caller is
/// expected to pass live game readings; this function does not read anything
/// itself.
IntroTip? nextTip({
  required IntroState state,
  required bool atSurface,
  required double cargoFraction,
  required double fuelFraction,
  required bool justMinedFirstOre,
  required bool justTookFallDamage,
  required double secondsSinceInput,
}) {
  // A finished or skipped intro never shows anything.
  if (state.skipped || state.completed) return null;
  // One card at a time.
  if (state.tipVisible) return null;

  bool unshown(IntroTip t) => !state.shown.contains(t);

  // Event-ordered: momentary "just happened" events win over standing
  // conditions, so the tip lands at the moment its lesson is most legible.

  // Fall damage just landed — highest priority (the cost is on screen now).
  if (justTookFallDamage && unshown(IntroTip.fallDamage)) {
    return IntroTip.fallDamage;
  }

  // First ore just came up.
  if (justMinedFirstOre && unshown(IntroTip.firstOre)) {
    return IntroTip.firstOre;
  }

  // Low fuel below the surface — the run's real clock, more urgent than a
  // full cargo, so it wins when both are true.
  if (!atSurface && fuelFraction < kLowFuelFraction && unshown(IntroTip.lowFuel)) {
    return IntroTip.lowFuel;
  }

  // Cargo nearly full — only meaningful below the surface, where they can't
  // already sell.
  if (!atSurface &&
      cargoFraction >= kCargoFullFraction &&
      unshown(IntroTip.cargoFull)) {
    return IntroTip.cargoFull;
  }

  // Idle at the surface — the movement tip, and only after real idle, never
  // on a plain timer.
  if (atSurface &&
      secondsSinceInput >= kMovementIdleSeconds &&
      unshown(IntroTip.movement)) {
    return IntroTip.movement;
  }

  return null;
}
