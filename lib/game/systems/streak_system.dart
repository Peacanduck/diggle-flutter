/// streak_system.dart
/// Daily login streak with escalating rewards.
///
/// Auto-claims on game start (UTC day boundaries, matching QuestSystem's
/// daily reset). Missing a day resets the streak. Rewards route through
/// the game's award callback so they hit the ledger like everything else;
/// the claim announcement shows in the HUD reward feed — no extra UI
/// needed to ship.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakSystem extends ChangeNotifier {
  static const _streakKey = 'diggle_streak_count_v1';
  static const _lastClaimKey = 'diggle_streak_last_claim_v1';

  /// Reward callback: (xp, points, description). Wired by DiggleGame.
  void Function(int xp, int points, String description)? onAwardReward;

  int _streak = 0;
  String? _lastClaimDay; // 'yyyy-MM-dd' UTC
  String? _playerId;

  int get streak => _streak;

  String _scoped(String key) => '${key}_${_playerId ?? 'default'}';

  /// Escalating daily rewards; day 7+ repeats the weekly jackpot.
  /// (xp, points) per streak day.
  static const List<(int, int)> rewardLadder = [
    (25, 5),    // day 1
    (40, 10),   // day 2
    (60, 15),   // day 3
    (85, 25),   // day 4
    (115, 35),  // day 5
    (150, 50),  // day 6
    (300, 120), // day 7+ jackpot
  ];

  static (int, int) rewardForStreak(int streakDay) {
    final index = (streakDay - 1).clamp(0, rewardLadder.length - 1);
    return rewardLadder[index];
  }

  static String _todayUTC() {
    final now = DateTime.now().toUtc();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  static String _yesterdayUTC() {
    final y = DateTime.now().toUtc().subtract(const Duration(days: 1));
    return '${y.year.toString().padLeft(4, '0')}-'
        '${y.month.toString().padLeft(2, '0')}-'
        '${y.day.toString().padLeft(2, '0')}';
  }

  /// Load state and auto-claim today's reward if not yet claimed.
  /// Returns true if a claim happened.
  Future<bool> initializeAndClaim({String? playerId}) async {
    _playerId = playerId;
    final prefs = await SharedPreferences.getInstance();
    _streak = prefs.getInt(_scoped(_streakKey)) ?? 0;
    _lastClaimDay = prefs.getString(_scoped(_lastClaimKey));

    final today = _todayUTC();
    if (_lastClaimDay == today) {
      notifyListeners();
      return false; // already claimed today
    }

    if (_lastClaimDay == _yesterdayUTC()) {
      _streak += 1; // consecutive day
    } else {
      _streak = 1; // first login or streak broken
    }
    _lastClaimDay = today;

    await prefs.setInt(_scoped(_streakKey), _streak);
    await prefs.setString(_scoped(_lastClaimKey), today);

    final (xp, points) = rewardForStreak(_streak);
    final dayLabel = _streak >= 7 ? '$_streak 🔥' : '$_streak';
    onAwardReward?.call(
        xp, points, '📅 Day $dayLabel login streak! (+$points pts)');

    notifyListeners();
    return true;
  }
}
