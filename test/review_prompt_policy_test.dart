import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/services/review_prompt_policy.dart';

void main() {
  final now = DateTime(2026, 9, 6, 12);

  group('shouldShowPrompt', () {
    test('a rater is never prompted, regardless of anything else', () {
      final state = ReviewPromptState(
        hasRated: true,
        pending: true,
        firedTriggers: {ReviewTrigger.firstPrestige},
      );
      expect(
        shouldShowPrompt(state: state, now: now, atSafeMoment: true),
        isFalse,
      );
    });

    test('no pending milestone → no prompt', () {
      const state = ReviewPromptState(pending: false);
      expect(
        shouldShowPrompt(state: state, now: now, atSafeMoment: true),
        isFalse,
      );
    });

    test('pending but unsafe moment → no prompt', () {
      const state = ReviewPromptState(pending: true);
      expect(
        shouldShowPrompt(state: state, now: now, atSafeMoment: false),
        isFalse,
      );
    });

    test('pending + safe + clean → prompts', () {
      const state = ReviewPromptState(pending: true);
      expect(
        shouldShowPrompt(state: state, now: now, atSafeMoment: true),
        isTrue,
      );
    });

    test('already shown this session → no prompt', () {
      const state = ReviewPromptState(pending: true, shownThisSession: true);
      expect(
        shouldShowPrompt(state: state, now: now, atSafeMoment: true),
        isFalse,
      );
    });

    group('30-day dismissal suppression', () {
      test('dismissed 29 days ago → no prompt', () {
        final state = ReviewPromptState(
          pending: true,
          dismissedAt: now.subtract(const Duration(days: 29)),
        );
        expect(
          shouldShowPrompt(state: state, now: now, atSafeMoment: true),
          isFalse,
        );
      });

      test('dismissed exactly 30 days ago → prompts', () {
        final state = ReviewPromptState(
          pending: true,
          dismissedAt: now.subtract(const Duration(days: 30)),
        );
        expect(
          shouldShowPrompt(state: state, now: now, atSafeMoment: true),
          isTrue,
        );
      });

      test('dismissed 31 days ago → prompts', () {
        final state = ReviewPromptState(
          pending: true,
          dismissedAt: now.subtract(const Duration(days: 31)),
        );
        expect(
          shouldShowPrompt(state: state, now: now, atSafeMoment: true),
          isTrue,
        );
      });
    });
  });

  group('ReviewPromptState.recordTrigger', () {
    test('the first firing banks a pending milestone', () {
      final s = const ReviewPromptState()
          .recordTrigger(ReviewTrigger.firstPrestige);
      expect(s.pending, isTrue);
      expect(s.firedTriggers, contains(ReviewTrigger.firstPrestige));
    });

    test('the same trigger recorded twice fires once', () {
      var s = const ReviewPromptState()
          .recordTrigger(ReviewTrigger.firstPrestige);
      // Dismiss it, then the same trigger fires again — must not re-bank.
      s = s.markDismissed(now);
      expect(s.pending, isFalse);
      final again = s.recordTrigger(ReviewTrigger.firstPrestige);
      expect(again.pending, isFalse,
          reason: 'a trigger fires once ever, even after dismissal');
      expect(again.firedTriggers.length, 1);
    });

    test('a different trigger banks its own pending milestone', () {
      var s = const ReviewPromptState()
          .recordTrigger(ReviewTrigger.firstPrestige)
          .markDismissed(now);
      s = s.recordTrigger(ReviewTrigger.sevenDayStreak);
      expect(s.pending, isTrue);
      expect(s.firedTriggers,
          containsAll([ReviewTrigger.firstPrestige, ReviewTrigger.sevenDayStreak]));
      // ...but the 30-day dismissal still gates actually showing it.
      expect(
        shouldShowPrompt(state: s, now: now, atSafeMoment: true),
        isFalse,
        reason: 'dismissed just now — suppressed for 30 days',
      );
    });
  });

  group('ReviewPromptState transitions', () {
    test('markRated clears pending and sticks', () {
      final s = const ReviewPromptState(pending: true).markRated();
      expect(s.hasRated, isTrue);
      expect(s.pending, isFalse);
      expect(shouldShowPrompt(state: s, now: now, atSafeMoment: true), isFalse);
    });

    test('markDismissed records the time and clears pending', () {
      final s = const ReviewPromptState(pending: true).markDismissed(now);
      expect(s.dismissedAt, now);
      expect(s.pending, isFalse);
    });

    test('markShownThisSession blocks a second prompt this session', () {
      final s = const ReviewPromptState(pending: true).markShownThisSession();
      expect(shouldShowPrompt(state: s, now: now, atSafeMoment: true), isFalse);
    });
  });

  group('a realistic prestige → dismiss → streak arc', () {
    test('one prompt, dismissed, then no nag from a second milestone', () {
      // Prestige mid-run: bank the milestone (not shown yet — unsafe moment).
      var s = const ReviewPromptState()
          .recordTrigger(ReviewTrigger.firstPrestige);
      expect(shouldShowPrompt(state: s, now: now, atSafeMoment: false), isFalse);

      // Back on the menu — a safe moment. It shows.
      expect(shouldShowPrompt(state: s, now: now, atSafeMoment: true), isTrue);
      s = s.markShownThisSession();

      // Player taps Not now.
      s = s.markDismissed(now);

      // A week later a seven-day streak lands. New session, new milestone…
      final later = now.add(const Duration(days: 7));
      s = s.copyWith(shownThisSession: false).recordTrigger(
            ReviewTrigger.sevenDayStreak,
          );
      // …but still inside the 30-day dismissal window, so no nag.
      expect(
        shouldShowPrompt(state: s, now: later, atSafeMoment: true),
        isFalse,
      );

      // 31 days after the dismissal, the streak milestone finally shows.
      final muchLater = now.add(const Duration(days: 31));
      expect(
        shouldShowPrompt(state: s, now: muchLater, atSafeMoment: true),
        isTrue,
      );
    });
  });
}
