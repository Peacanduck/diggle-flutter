import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/game/systems/streak_system.dart';
import 'package:diggle/ui/streak_glyph.dart';

void main() {
  group('StreakStage.forStreak', () {
    const jackpot = 7; // default ladder length

    test('early days are an ember', () {
      expect(StreakStage.forStreak(0, jackpot), StreakStage.ember);
      expect(StreakStage.forStreak(1, jackpot), StreakStage.ember);
      expect(StreakStage.forStreak(3, jackpot), StreakStage.ember);
    });

    test('mid streak is burning', () {
      expect(StreakStage.forStreak(4, jackpot), StreakStage.burning);
      expect(StreakStage.forStreak(6, jackpot), StreakStage.burning);
    });

    test('the jackpot rung and beyond is a blaze', () {
      expect(StreakStage.forStreak(7, jackpot), StreakStage.blaze);
      expect(StreakStage.forStreak(8, jackpot), StreakStage.blaze);
      expect(StreakStage.forStreak(365, jackpot), StreakStage.blaze);
    });

    test('thresholds follow a server-tuned ladder length', () {
      // A 10-rung ladder moves the boundaries with it.
      expect(StreakStage.forStreak(4, 10), StreakStage.ember);
      expect(StreakStage.forStreak(5, 10), StreakStage.burning);
      expect(StreakStage.forStreak(9, 10), StreakStage.burning);
      expect(StreakStage.forStreak(10, 10), StreakStage.blaze);
    });

    test('a degenerate ladder length does not throw', () {
      expect(StreakStage.forStreak(5, 0), StreakStage.ember);
      expect(StreakStage.forStreak(5, -1), StreakStage.ember);
    });
  });

  group('generated animation contract', () {
    test('segments tile the timeline the generator produces', () {
      // gen_streak_glyph.py emits three consecutive 30-frame stages.
      // If that changes, the segments here must change with it.
      expect(StreakStage.ember.segment, [0, 30]);
      expect(StreakStage.burning.segment, [30, 60]);
      expect(StreakStage.blaze.segment, [60, 90]);

      final stages = StreakStage.values;
      for (var i = 1; i < stages.length; i++) {
        expect(stages[i].segment.first, stages[i - 1].segment.last,
            reason: 'stage ${stages[i].name} must start where the '
                'previous one ends');
      }
    });

    test('every stage has an emoji fallback', () {
      for (final stage in StreakStage.values) {
        expect(stage.emoji, isNotEmpty);
      }
      // The jackpot keeps the flame the Account card used before.
      expect(StreakStage.blaze.emoji, '🔥');
    });

    test('default ladder still has the length the stages assume', () {
      expect(StreakSystem.defaultRewardLadder.length, 7);
    });
  });
}
