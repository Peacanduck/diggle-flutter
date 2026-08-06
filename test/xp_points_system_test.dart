import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/game/systems/xp_points_system.dart';
import 'package:diggle/game/world/tile.dart';

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

  group('HUD reward feed queue', () {
    test('bonus awards queue an announcement, mining does not', () {
      final xp = XPPointsSystem();

      xp.awardForMining(TileType.copper, 10);
      expect(xp.takePendingAnnouncements(), isEmpty,
          reason: 'per-tile mining would spam a toast on every dig');

      xp.awardBonus(300, 120, '📅 Day 7 🔥 login streak!');
      final pending = xp.takePendingAnnouncements();
      expect(pending.length, 1);
      expect(pending.single.description, contains('login streak'));
      expect(pending.single.isBonus, true);
    });

    test('draining clears the queue so a toast never repeats', () {
      final xp = XPPointsSystem();
      xp.awardBonus(25, 5, 'Achievement: First Haul');

      expect(xp.takePendingAnnouncements().length, 1);
      expect(xp.takePendingAnnouncements(), isEmpty);
    });

    test('a burst of bonuses is capped instead of queueing a wall', () {
      final xp = XPPointsSystem();

      // One big haul can unlock several achievement tiers at once.
      for (int i = 0; i < 10; i++) {
        xp.awardBonus(10, 5, 'Achievement $i');
      }

      final pending = xp.takePendingAnnouncements();
      expect(pending.length, XPPointsSystem.maxPendingAnnouncements);
      expect(pending.last.description, 'Achievement 9',
          reason: 'the most recent unlocks are the ones worth showing');
    });

    test('announcements never block the award itself', () {
      final xp = XPPointsSystem();

      // No HUD mounted, so nothing ever drains the queue.
      for (int i = 0; i < 50; i++) {
        xp.awardBonus(10, 5, 'Achievement $i');
      }

      expect(xp.totalXP, 500);
      // At least the 50 × 5 awarded; level-up bonuses push it higher.
      expect(xp.points, greaterThanOrEqualTo(250));
    });
  });
}
