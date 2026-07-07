import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diggle/game/systems/achievement_system.dart';
import 'package:diggle/game/systems/streak_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AchievementSystem', () {
    test('unlocks at threshold and awards exactly once', () async {
      final system = AchievementSystem();
      await system.initialize();

      final rewards = <String>[];
      system.onAwardReward = (xp, points, desc) => rewards.add(desc);

      for (int i = 0; i < 9; i++) {
        system.recordOreMined();
      }
      expect(system.isUnlocked('ore_10'), false);

      system.recordOreMined(); // 10th
      expect(system.isUnlocked('ore_10'), true);
      expect(rewards.where((r) => r.contains('First Haul')).length, 1);

      system.recordOreMined(); // 11th — no re-award
      expect(rewards.where((r) => r.contains('First Haul')).length, 1);
    });

    test('depth is max-tracked, not accumulated', () async {
      final system = AchievementSystem();
      await system.initialize();

      system.recordDepth(30);
      system.recordDepth(30);
      system.recordDepth(30);
      expect(system.isUnlocked('depth_50'), false);

      system.recordDepth(55);
      expect(system.isUnlocked('depth_50'), true);
    });

    test('a single large increment unlocks multiple tiers', () async {
      final system = AchievementSystem();
      await system.initialize();

      final rewards = <String>[];
      system.onAwardReward = (xp, points, desc) => rewards.add(desc);

      system.recordCashEarned(300000);
      expect(system.isUnlocked('cash_1k'), true);
      expect(system.isUnlocked('cash_25k'), true);
      expect(system.isUnlocked('cash_250k'), true);
      expect(system.isUnlocked('cash_1m'), false);
      expect(rewards.length, 3);
    });
  });

  group('StreakSystem', () {
    test('first login starts streak at 1 and claims once per day', () async {
      final system = StreakSystem();
      var claims = 0;
      system.onAwardReward = (xp, points, desc) => claims++;

      final claimed = await system.initializeAndClaim();
      expect(claimed, true);
      expect(system.streak, 1);
      expect(claims, 1);

      // Same day re-init (app restart): no double claim
      final system2 = StreakSystem();
      system2.onAwardReward = (xp, points, desc) => claims++;
      final claimedAgain = await system2.initializeAndClaim();
      expect(claimedAgain, false);
      expect(system2.streak, 1);
      expect(claims, 1);
    });

    test('reward ladder escalates and caps at day 7 jackpot', () {
      final (xp1, pts1) = StreakSystem.rewardForStreak(1);
      final (xp7, pts7) = StreakSystem.rewardForStreak(7);
      final (xp30, pts30) = StreakSystem.rewardForStreak(30);

      expect(xp7, greaterThan(xp1));
      expect(pts7, greaterThan(pts1));
      expect(xp30, xp7); // day 7+ repeats jackpot
      expect(pts30, pts7);
    });
  });
}
