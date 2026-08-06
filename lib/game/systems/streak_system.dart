/// streak_system.dart
/// Daily login streak with escalating rewards.
///
/// Auto-claims on game start (UTC day boundaries, matching QuestSystem's
/// daily reset). Missing a day resets the streak. Rewards route through
/// the game's award callback so they hit the ledger like everything else;
/// the claim announcement shows in the HUD reward feed — no extra UI
/// needed to ship.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Outcome of a server-side `claim_daily_streak` call.
class ServerStreakResult {
  /// Streak day after the server applied its rules.
  final int streak;

  /// False when the server had already recorded a claim today.
  final bool claimed;

  final int rewardXp;
  final int rewardPoints;

  /// Server's claim date, 'yyyy-MM-dd' UTC.
  final String claimDay;

  const ServerStreakResult({
    required this.streak,
    required this.claimed,
    required this.rewardXp,
    required this.rewardPoints,
    required this.claimDay,
  });
}

/// Calls the server claim RPC. Returns null when the server can't be
/// reached or the player isn't authenticated — the caller then falls
/// back to a local claim so offline play still rewards.
typedef ServerStreakClaim = Future<ServerStreakResult?> Function({
  required int localStreak,
  required String? localLastClaimDay,
});

/// Fetches the reward ladder from the server, ordered by day. Returns
/// null when unreachable — the cached/compiled-in ladder stays in use.
typedef ServerLadderFetch = Future<List<(int, int)>?> Function();

class StreakSystem extends ChangeNotifier {
  static const _streakKey = 'diggle_streak_count_v1';
  static const _lastClaimKey = 'diggle_streak_last_claim_v1';

  /// Cached server ladder. Not player-scoped — the ladder is global.
  static const _ladderKey = 'diggle_streak_ladder_v1';

  /// Reward callback: (xp, points, description). Wired by DiggleGame.
  void Function(int xp, int points, String description)? onAwardReward;

  /// Server claim delegate. When set (and reachable) the server decides
  /// the streak day; when null or failing, claims stay device-local
  /// exactly as before. Wired by DiggleGame.
  ServerStreakClaim? serverClaim;

  /// Whether the last claim was decided by the server.
  bool get lastClaimWasServerAuthoritative => _serverAuthoritative;
  bool _serverAuthoritative = false;

  int _streak = 0;
  String? _lastClaimDay; // 'yyyy-MM-dd' UTC
  String? _playerId;

  /// Days banked in the current unbroken run. Reads 0 once the streak has
  /// lapsed (last claim older than yesterday) — the stored count is stale
  /// at that point and the next claim restarts at day 1.
  int get streak => _isCurrent ? _streak : 0;

  /// Whether today's reward has already been claimed.
  bool get hasClaimedToday => _lastClaimDay == _todayUTC();

  /// The ladder rung the next claim will land on.
  int get nextStreakDay =>
      hasClaimedToday ? _streak : (_isCurrent ? _streak + 1 : 1);

  /// (xp, points) the next claim will pay out.
  (int, int) get nextReward => rewardForStreak(nextStreakDay);

  /// True once the streak sits on the repeating jackpot rung.
  bool get isAtJackpot => streak >= rewardLadder.length;

  /// Claimed today, or yesterday (so today's login continues the run).
  bool get _isCurrent =>
      _lastClaimDay == _todayUTC() || _lastClaimDay == _yesterdayUTC();

  String _scoped(String key) => '${key}_${_playerId ?? 'default'}';

  /// Compiled-in ladder. Mirrors the `streak_rewards` table and is the
  /// fallback on a first run with no connectivity. (xp, points) per day;
  /// the last rung repeats for every day beyond it.
  static const List<(int, int)> defaultRewardLadder = [
    (25, 5),    // day 1
    (40, 10),   // day 2
    (60, 15),   // day 3
    (85, 25),   // day 4
    (115, 35),  // day 5
    (150, 50),  // day 6
    (300, 120), // day 7+ jackpot
  ];

  /// Ladder currently in effect: server values once fetched (cached
  /// across launches), otherwise [defaultRewardLadder].
  List<(int, int)> get rewardLadder => _ladder;
  List<(int, int)> _ladder = defaultRewardLadder;

  /// Fetches the server ladder. Wired by main(); optional.
  ServerLadderFetch? serverLadder;

  (int, int) rewardForStreak(int streakDay) {
    final index = (streakDay - 1).clamp(0, _ladder.length - 1);
    return _ladder[index];
  }

  /// Pull the ladder from the server and cache it. Safe to call
  /// fire-and-forget: failures leave the current ladder untouched.
  Future<void> refreshLadder() async {
    if (serverLadder == null) return;
    try {
      final fetched = await serverLadder!();
      if (fetched == null || fetched.isEmpty) return;
      _ladder = List.unmodifiable(fetched);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ladderKey, _encodeLadder(fetched));
      notifyListeners();
    } catch (e) {
      debugPrint('StreakSystem: ladder refresh failed, keeping current: $e');
    }
  }

  static String _encodeLadder(List<(int, int)> ladder) =>
      jsonEncode(ladder.map((r) => [r.$1, r.$2]).toList());

  static List<(int, int)>? _decodeLadder(String raw) {
    try {
      final rows = jsonDecode(raw) as List;
      final out = <(int, int)>[];
      for (final row in rows) {
        final pair = row as List;
        out.add(((pair[0] as num).toInt(), (pair[1] as num).toInt()));
      }
      return out.isEmpty ? null : out;
    } catch (_) {
      return null; // corrupt cache — fall back to the defaults
    }
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

  /// Read persisted state WITHOUT claiming. Used by menu/account screens
  /// that need to show the streak outside a game session — claiming has
  /// to happen where the reward callback is wired (DiggleGame), otherwise
  /// the XP/points would be dropped on the floor.
  Future<void> load({String? playerId}) async {
    _playerId = playerId;
    final prefs = await SharedPreferences.getInstance();
    _streak = prefs.getInt(_scoped(_streakKey)) ?? 0;
    _lastClaimDay = prefs.getString(_scoped(_lastClaimKey));

    // Last known server ladder, so an offline launch still shows the
    // real values rather than snapping back to the compiled-in ones.
    final cached = prefs.getString(_ladderKey);
    if (cached != null) {
      final decoded = _decodeLadder(cached);
      if (decoded != null) _ladder = List.unmodifiable(decoded);
    }

    notifyListeners();
  }

  /// Load state and auto-claim today's reward if not yet claimed.
  /// Returns true if a claim happened.
  ///
  /// Prefers the server (which owns the streak day and can't be fooled
  /// by a device clock); falls back to the local ladder when offline so
  /// a player without connectivity still gets their reward.
  Future<bool> initializeAndClaim({String? playerId}) async {
    await load(playerId: playerId);
    _serverAuthoritative = false;

    if (serverClaim != null) {
      final result = await _claimOnServer();
      if (result != null) return result;
      // Server unreachable — fall through to the local claim.
    }

    return _claimLocally();
  }

  /// Server-decided claim. Returns null if the server couldn't be
  /// reached, so the caller can fall back.
  Future<bool?> _claimOnServer() async {
    final ServerStreakResult? result;
    try {
      result = await serverClaim!(
        localStreak: _streak,
        localLastClaimDay: _lastClaimDay,
      );
    } catch (e) {
      debugPrint('StreakSystem: server claim failed, using local: $e');
      return null;
    }
    if (result == null) return null;

    // Server is truth — adopt its state even when it disagrees with
    // (or is lower than) what this device had cached.
    _streak = result.streak;
    _lastClaimDay = result.claimDay;
    _serverAuthoritative = true;
    await _persist();

    if (result.claimed) {
      _announce(result.rewardXp, result.rewardPoints);
    }

    notifyListeners();
    return result.claimed;
  }

  /// Device-local claim — the original behavior, and the offline path.
  Future<bool> _claimLocally() async {
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
    await _persist();

    final (xp, points) = rewardForStreak(_streak);
    _announce(xp, points);

    notifyListeners();
    return true;
  }

  void _announce(int xp, int points) {
    final dayLabel = _streak >= rewardLadder.length ? '$_streak 🔥' : '$_streak';
    onAwardReward?.call(
        xp, points, '📅 Day $dayLabel login streak! (+$points pts)');
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scoped(_streakKey), _streak);
    await prefs.setString(_scoped(_lastClaimKey), _lastClaimDay!);
  }
}
