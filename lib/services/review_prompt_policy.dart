/// review_prompt_policy.dart
/// Pure decision logic for the in-game store-review prompt.
///
/// No I/O, no Flutter, no Flame — so the "when do we ask?" rules are
/// exhaustively unit-testable. [ReviewPromptService] owns persistence and the
/// deep link; this file owns the invariant that the player is never nagged.
///
/// The design decouples *trigger* from *display* (plan §2): a milestone
/// records a pending flag whenever it happens (mid-prestige, in the hangar,
/// during streak claim); a separate check shows the sheet only at the next
/// safe moment. So we never interrupt a descent.
library;

/// The three moments of accomplishment that can bank a review prompt.
enum ReviewTrigger {
  /// Signed a first Corporate Contract (prestige) — 400m depth or 500k
  /// lifetime cash. Deep into the game.
  firstPrestige,

  /// Equipped a first Rare-or-better gear set. Common/Uncommon is 75% of the
  /// mint and isn't a moment.
  firstRareGearEquip,

  /// Reached a seven-day login streak — the strongest signal of a habit.
  sevenDayStreak,
}

/// How long a dismissal ("Not now") suppresses the prompt.
const int kReviewDismissSuppressionDays = 30;

/// Immutable persisted state for the prompt. Advanced through the pure
/// reducers below so every transition is testable in isolation.
class ReviewPromptState {
  /// The player tapped *Rate* — never ask again.
  final bool hasRated;

  /// Triggers that have already fired once. Each fires once ever.
  final Set<ReviewTrigger> firedTriggers;

  /// When the player last tapped *Not now*. Null if never.
  final DateTime? dismissedAt;

  /// A milestone is banked and waiting for a safe moment to show.
  final bool pending;

  /// The sheet has already been shown once this session (at most one/session).
  final bool shownThisSession;

  const ReviewPromptState({
    this.hasRated = false,
    this.firedTriggers = const {},
    this.dismissedAt,
    this.pending = false,
    this.shownThisSession = false,
  });

  ReviewPromptState copyWith({
    bool? hasRated,
    Set<ReviewTrigger>? firedTriggers,
    DateTime? dismissedAt,
    bool? clearDismissedAt,
    bool? pending,
    bool? shownThisSession,
  }) {
    return ReviewPromptState(
      hasRated: hasRated ?? this.hasRated,
      firedTriggers: firedTriggers ?? this.firedTriggers,
      dismissedAt:
          (clearDismissedAt ?? false) ? null : (dismissedAt ?? this.dismissedAt),
      pending: pending ?? this.pending,
      shownThisSession: shownThisSession ?? this.shownThisSession,
    );
  }

  /// Record a milestone. Banks a pending prompt the first time [trigger]
  /// fires; a no-op for a trigger that already fired, so twenty prestiges
  /// ask once.
  ReviewPromptState recordTrigger(ReviewTrigger trigger) {
    if (firedTriggers.contains(trigger)) return this;
    return copyWith(
      firedTriggers: {...firedTriggers, trigger},
      pending: true,
    );
  }

  /// The sheet is now on screen. At most one per session.
  ReviewPromptState markShownThisSession() =>
      copyWith(shownThisSession: true);

  /// The player tapped *Rate*. Set on launch, not on return — we can't
  /// observe whether they submitted, and re-asking someone who did is worse
  /// than missing someone who didn't (§7).
  ReviewPromptState markRated() =>
      copyWith(hasRated: true, pending: false);

  /// The player tapped *Not now*. Clears the pending milestone; back in 30
  /// days.
  ReviewPromptState markDismissed(DateTime now) =>
      copyWith(dismissedAt: now, pending: false);
}

/// Whether to show the review sheet right now. Pure.
bool shouldShowPrompt({
  required ReviewPromptState state,
  required DateTime now,
  required bool atSafeMoment,
}) {
  if (state.hasRated) return false; // never nag a rater
  if (!state.pending) return false; // no milestone banked
  if (!atSafeMoment) return false; // never mid-descent
  if (state.shownThisSession) return false; // once per session, max
  final d = state.dismissedAt;
  if (d != null && now.difference(d).inDays < kReviewDismissSuppressionDays) {
    return false;
  }
  return true;
}
