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
      final system = StreakSystem();
      final (xp1, pts1) = system.rewardForStreak(1);
      final (xp7, pts7) = system.rewardForStreak(7);
      final (xp30, pts30) = system.rewardForStreak(30);

      expect(xp7, greaterThan(xp1));
      expect(pts7, greaterThan(pts1));
      expect(xp30, xp7); // day 7+ repeats jackpot
      expect(pts30, pts7);
    });

    test('eight consecutive logins walk the ladder to the jackpot', () async {
      final awarded = <(int, int)>[];

      // One claim per simulated day. StreakSystem reads the wall clock,
      // so instead of moving time we rewind the *persisted* claim date
      // to yesterday between logins — the same state the app would be
      // in the next morning.
      for (int day = 1; day <= 8; day++) {
        final system = StreakSystem();
        system.onAwardReward = (xp, points, _) => awarded.add((xp, points));
        final claimed = await system.initializeAndClaim();

        expect(claimed, true, reason: 'day $day should claim');
        expect(system.streak, day);

        await rewindLastClaimToYesterday();
      }

      expect(awarded, [
        (25, 5),     // day 1
        (40, 10),    // day 2
        (60, 15),    // day 3
        (85, 25),    // day 4
        (115, 35),   // day 5
        (150, 50),   // day 6
        (300, 120),  // day 7 jackpot
        (300, 120),  // day 8 stays on the jackpot rung
      ]);
    });

    test('day 7 claim announces the jackpot with the fire marker', () async {
      await seedStreak(streak: 6, lastClaimDaysAgo: 1);

      String? description;
      final system = StreakSystem();
      system.onAwardReward = (xp, points, desc) => description = desc;
      await system.initializeAndClaim();

      expect(system.streak, 7);
      expect(description, contains('Day 7 🔥'));
      expect(description, contains('+120 pts'));
    });

    test('missing a single day resets the streak to 1', () async {
      await seedStreak(streak: 6, lastClaimDaysAgo: 2); // skipped yesterday

      final awarded = <(int, int)>[];
      final system = StreakSystem();
      system.onAwardReward = (xp, points, _) => awarded.add((xp, points));
      await system.initializeAndClaim();

      expect(system.streak, 1, reason: 'a gap breaks the streak');
      expect(awarded.single, (25, 5), reason: 'back to the bottom rung');
    });

    test('a long absence resets rather than resuming the jackpot', () async {
      await seedStreak(streak: 30, lastClaimDaysAgo: 45);

      final system = StreakSystem();
      await system.initializeAndClaim();

      expect(system.streak, 1);
    });

    test('load() reports state for the account screen without claiming',
        () async {
      await seedStreak(streak: 3, lastClaimDaysAgo: 1);

      var claims = 0;
      final system = StreakSystem();
      system.onAwardReward = (xp, points, desc) => claims++;
      await system.load();

      expect(claims, 0, reason: 'load must never award');
      expect(system.streak, 3);
      expect(system.hasClaimedToday, false);
      expect(system.nextStreakDay, 4);
      expect(system.nextReward, (85, 25));
      expect(system.isAtJackpot, false);
    });

    test('a lapsed streak reads as 0 before the next claim', () async {
      await seedStreak(streak: 6, lastClaimDaysAgo: 4);

      final system = StreakSystem();
      await system.load();

      expect(system.streak, 0, reason: 'stale count must not be displayed');
      expect(system.nextStreakDay, 1);
      expect(system.nextReward, (25, 5));
    });

    test('after claiming, load() reports the jackpot rung as reached',
        () async {
      await seedStreak(streak: 8, lastClaimDaysAgo: 1);

      final system = StreakSystem();
      await system.initializeAndClaim();
      expect(system.streak, 9);
      expect(system.hasClaimedToday, true);
      expect(system.isAtJackpot, true);
      expect(system.nextStreakDay, 9,
          reason: 'already claimed today — no further rung today');
      expect(system.nextReward, (300, 120));
    });

    test('server result wins over local state and is cached to prefs',
        () async {
      // Device thinks it is on day 2; server says day 9 (they played on
      // another device). Server is truth.
      await seedStreak(streak: 2, lastClaimDaysAgo: 1);

      final awarded = <(int, int)>[];
      final system = StreakSystem();
      system.onAwardReward = (xp, points, _) => awarded.add((xp, points));
      system.serverClaim = ({
        required int localStreak,
        required String? localLastClaimDay,
      }) async =>
          ServerStreakResult(
            streak: 9,
            claimed: true,
            rewardXp: 300,
            rewardPoints: 120,
            claimDay: _dayUTC(0),
          );

      final claimed = await system.initializeAndClaim();

      expect(claimed, true);
      expect(system.streak, 9);
      expect(system.hasClaimedToday, true);
      expect(system.lastClaimWasServerAuthoritative, true);
      expect(awarded.single, (300, 120),
          reason: 'the server decides the reward, not the local ladder');

      // Cached, so the Account screen shows the server value offline.
      final reloaded = StreakSystem();
      await reloaded.load();
      expect(reloaded.streak, 9);
    });

    test('server sends the local state so pre-server history survives',
        () async {
      await seedStreak(streak: 30, lastClaimDaysAgo: 1);

      int? sentStreak;
      String? sentDay;
      final system = StreakSystem();
      system.serverClaim = ({
        required int localStreak,
        required String? localLastClaimDay,
      }) async {
        sentStreak = localStreak;
        sentDay = localLastClaimDay;
        return ServerStreakResult(
          streak: 31,
          claimed: true,
          rewardXp: 300,
          rewardPoints: 120,
          claimDay: _dayUTC(0),
        );
      };

      await system.initializeAndClaim();

      expect(sentStreak, 30, reason: 'migration needs the local run');
      expect(sentDay, _dayUTC(1));
      expect(system.streak, 31);
    });

    test('an already-claimed server day awards nothing', () async {
      await seedStreak(streak: 4, lastClaimDaysAgo: 1);

      var claims = 0;
      final system = StreakSystem();
      system.onAwardReward = (xp, points, desc) => claims++;
      system.serverClaim = ({
        required int localStreak,
        required String? localLastClaimDay,
      }) async =>
          ServerStreakResult(
            streak: 5,
            claimed: false, // another device already claimed today
            rewardXp: 0,
            rewardPoints: 0,
            claimDay: _dayUTC(0),
          );

      final claimed = await system.initializeAndClaim();

      expect(claimed, false);
      expect(claims, 0, reason: 'no double reward across devices');
      expect(system.streak, 5, reason: 'still adopts the server streak');
    });

    test('offline falls back to a local claim so the reward is not lost',
        () async {
      await seedStreak(streak: 3, lastClaimDaysAgo: 1);

      final awarded = <(int, int)>[];
      final system = StreakSystem();
      system.onAwardReward = (xp, points, _) => awarded.add((xp, points));
      system.serverClaim = ({
        required int localStreak,
        required String? localLastClaimDay,
      }) async =>
          null; // unreachable

      final claimed = await system.initializeAndClaim();

      expect(claimed, true);
      expect(system.streak, 4, reason: 'local ladder continues offline');
      expect(awarded.single, (85, 25));
      expect(system.lastClaimWasServerAuthoritative, false);
    });

    test('a throwing server claim degrades to local, never crashes',
        () async {
      await seedStreak(streak: 1, lastClaimDaysAgo: 1);

      final system = StreakSystem();
      system.serverClaim = ({
        required int localStreak,
        required String? localLastClaimDay,
      }) async =>
          throw Exception('SocketException: host lookup failed');

      final claimed = await system.initializeAndClaim();

      expect(claimed, true);
      expect(system.streak, 2);
    });

    test('with no server delegate the behavior is unchanged', () async {
      await seedStreak(streak: 5, lastClaimDaysAgo: 1);

      final system = StreakSystem();
      expect(system.serverClaim, isNull);

      await system.initializeAndClaim();

      expect(system.streak, 6);
      expect(system.lastClaimWasServerAuthoritative, false);
    });

    test('server ladder replaces the defaults and is cached', () async {
      final tuned = <(int, int)>[
        (50, 10), (80, 20), (120, 30), (170, 50), (230, 70), (300, 100),
        (600, 240),
      ];

      final system = StreakSystem();
      system.serverLadder = () async => tuned;
      await system.load();
      expect(system.rewardLadder, StreakSystem.defaultRewardLadder,
          reason: 'defaults until the fetch lands');

      await system.refreshLadder();
      expect(system.rewardLadder, tuned);
      expect(system.rewardForStreak(7), (600, 240));

      // A later launch with no connectivity reads the cached ladder.
      final offline = StreakSystem();
      await offline.load();
      expect(offline.rewardLadder, tuned);
    });

    test('a tuned ladder is what an offline claim actually pays', () async {
      final tuned = <(int, int)>[(99, 42)];

      final seeded = StreakSystem();
      seeded.serverLadder = () async => tuned;
      await seeded.load();
      await seeded.refreshLadder();

      final awarded = <(int, int)>[];
      final system = StreakSystem();
      system.onAwardReward = (xp, points, _) => awarded.add((xp, points));
      await system.initializeAndClaim(); // no serverClaim → local path

      expect(system.streak, 1);
      expect(awarded.single, (99, 42),
          reason: 'offline claims must use the cached server ladder');
    });

    test('a failing ladder fetch leaves the current ladder intact', () async {
      final system = StreakSystem();
      system.serverLadder = () async => throw Exception('offline');
      await system.load();
      await system.refreshLadder();

      expect(system.rewardLadder, StreakSystem.defaultRewardLadder);
      expect(system.rewardForStreak(7), (300, 120));
    });

    test('an empty ladder response is ignored, not adopted', () async {
      final system = StreakSystem();
      system.serverLadder = () async => <(int, int)>[];
      await system.load();
      await system.refreshLadder();

      expect(system.rewardLadder, StreakSystem.defaultRewardLadder,
          reason: 'an empty table must never zero out rewards');
    });

    test('a corrupt cached ladder falls back to the defaults', () async {
      SharedPreferences.setMockInitialValues({
        'diggle_streak_ladder_v1': 'not json at all',
      });

      final system = StreakSystem();
      await system.load();

      expect(system.rewardLadder, StreakSystem.defaultRewardLadder);
    });

    test('streaks are tracked per player, not per device', () async {
      await seedStreak(streak: 6, lastClaimDaysAgo: 1, playerId: 'player-a');

      final a = StreakSystem();
      await a.initializeAndClaim(playerId: 'player-a');
      expect(a.streak, 7, reason: 'player-a keeps their own ladder position');

      final b = StreakSystem();
      await b.initializeAndClaim(playerId: 'player-b');
      expect(b.streak, 1, reason: 'player-b starts fresh on the same device');
    });
  });
}

// ── Helpers: drive the streak through its persisted state ──────
//
// StreakSystem has no injectable clock, so tests steer it by writing
// the same SharedPreferences keys the production code reads.

String _dayUTC(int daysAgo) {
  final d = DateTime.now().toUtc().subtract(Duration(days: daysAgo));
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

String _countKey(String? playerId) =>
    'diggle_streak_count_v1_${playerId ?? 'default'}';
String _lastClaimKey(String? playerId) =>
    'diggle_streak_last_claim_v1_${playerId ?? 'default'}';

/// Put the player mid-ladder: [streak] days banked, last claimed
/// [lastClaimDaysAgo] days ago (1 = yesterday, so the next login continues).
Future<void> seedStreak({
  required int streak,
  required int lastClaimDaysAgo,
  String? playerId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_countKey(playerId), streak);
  await prefs.setString(_lastClaimKey(playerId), _dayUTC(lastClaimDaysAgo));
}

/// Simulate "the next day arrives" without moving the clock.
Future<void> rewindLastClaimToYesterday({String? playerId}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_lastClaimKey(playerId), _dayUTC(1));
}
