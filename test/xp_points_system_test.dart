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

      // Small enough not to cross a level threshold, which would add a
      // level-up announcement of its own.
      xp.awardBonus(25, 5, '📅 Day 1 login streak!');
      final pending = xp.takePendingAnnouncements();
      expect(pending.length, 1);
      expect(pending.single.description, contains('login streak'));
      expect(pending.single.isBonus, true);
    });

    test('levelling up announces too', () {
      final xp = XPPointsSystem();

      xp.addXP(150); // crosses level 2 at 100 XP

      final pending = xp.takePendingAnnouncements();
      expect(pending, isNotEmpty);
      expect(pending.last.description, contains('Level Up!'));
      expect(pending.last.description, contains('level 2'));
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
      // Zero XP keeps level-up announcements out of the count.
      for (int i = 0; i < 10; i++) {
        xp.awardBonus(0, 5, 'Achievement $i');
      }

      final pending = xp.takePendingAnnouncements();
      expect(pending.length, XPPointsSystem.maxPendingAnnouncements);
      expect(pending.last.description, 'Achievement 9',
          reason: 'the most recent unlocks are the ones worth showing');
    });

    test('a session reset drops queued announcements', () {
      final xp = XPPointsSystem();
      xp.awardBonus(25, 5, 'Achievement: First Haul');

      xp.startSession();

      expect(xp.takePendingAnnouncements(), isEmpty,
          reason: 'a toast from the previous run must not surface after '
              'a reset');
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
