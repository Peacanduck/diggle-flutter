import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/game/systems/xp_points_system.dart';

void main() {
  group('XPPointsSystem.addXP', () {
    test('adds raw XP without multipliers', () {
      final xp = XPPointsSystem();
      xp.setXPBoost(2.0); // boost must NOT apply to fixed rewards

      xp.addXP(100);

      expect(xp.totalXP, 100);
      expect(xp.sessionXP, 100);
    });

    test('triggers level up and bonus points', () {
      final xp = XPPointsSystem();

      xp.addXP(100); // level 2 threshold

      expect(xp.level, 2);
      // Level-up bonus: newLevel * 10
      expect(xp.points, 20);
      expect(xp.lifetimePoints, 20);
    });

    test('ignores zero and negative amounts', () {
      final xp = XPPointsSystem();

      xp.addXP(0);
      xp.addXP(-50);

      expect(xp.totalXP, 0);
    });
  });

  group('quest reward path', () {
    test('offline callback awards XP and points exactly once', () {
      final xp = XPPointsSystem();

      // Mirrors the offline branch of DiggleGame's onAwardReward callback.
      void onAwardReward(int rewardXP, int rewardPoints, String source) {
        xp.addXP(rewardXP);
        xp.addPoints(rewardPoints);
      }

      onAwardReward(50, 10, 'quest_daily_mine_10');

      expect(xp.totalXP, 50);
      expect(xp.points, 10);
      expect(xp.lifetimePoints, 10);
    });
  });
}
