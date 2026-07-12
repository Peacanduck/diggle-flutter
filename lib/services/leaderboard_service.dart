/// leaderboard_service.dart
/// Global + weekly leaderboards backed by Supabase.
///
/// Reads go through the `leaderboard_global` view (see
/// supabase/migrations/) which only exposes non-flagged players'
/// public stats. Weekly scores are submitted via the
/// `submit_weekly_score` RPC, which keeps the best score per player
/// per ISO week and rejects unauthenticated writes.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardEntry {
  final String displayName;
  final int maxDepth;
  final int totalPointsEarned;
  final int totalCashEarned;
  final int prestigeLevel;

  const LeaderboardEntry({
    required this.displayName,
    required this.maxDepth,
    required this.totalPointsEarned,
    required this.totalCashEarned,
    required this.prestigeLevel,
  });

  factory LeaderboardEntry.fromRow(Map<String, dynamic> row) {
    return LeaderboardEntry(
      displayName: (row['display_name'] as String?)?.trim().isNotEmpty == true
          ? row['display_name'] as String
          : 'Anonymous Miner',
      maxDepth: (row['max_depth_reached'] as num?)?.toInt() ?? 0,
      totalPointsEarned:
          (row['total_points_earned'] as num?)?.toInt() ?? 0,
      totalCashEarned: (row['total_cash_earned'] as num?)?.toInt() ?? 0,
      prestigeLevel: (row['prestige_level'] as num?)?.toInt() ?? 0,
    );
  }
}

class WeeklyScoreEntry {
  final String displayName;
  final int depth;
  final int cashEarned;

  const WeeklyScoreEntry({
    required this.displayName,
    required this.depth,
    required this.cashEarned,
  });

  factory WeeklyScoreEntry.fromRow(Map<String, dynamic> row) {
    return WeeklyScoreEntry(
      displayName: (row['display_name'] as String?)?.trim().isNotEmpty == true
          ? row['display_name'] as String
          : 'Anonymous Miner',
      depth: (row['depth'] as num?)?.toInt() ?? 0,
      cashEarned: (row['cash_earned'] as num?)?.toInt() ?? 0,
    );
  }
}

class LeaderboardService {
  final SupabaseClient client;

  LeaderboardService({required this.client});

  /// Top players by max depth reached.
  Future<List<LeaderboardEntry>> topByDepth({int limit = 50}) async {
    try {
      final rows = await client
          .from('leaderboard_global')
          .select()
          .order('max_depth_reached', ascending: false)
          .limit(limit);
      return (rows as List)
          .map((r) => LeaderboardEntry.fromRow(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('LeaderboardService.topByDepth: $e');
      return [];
    }
  }

  /// Top players by lifetime points earned.
  Future<List<LeaderboardEntry>> topByPoints({int limit = 50}) async {
    try {
      final rows = await client
          .from('leaderboard_global')
          .select()
          .order('total_points_earned', ascending: false)
          .limit(limit);
      return (rows as List)
          .map((r) => LeaderboardEntry.fromRow(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('LeaderboardService.topByPoints: $e');
      return [];
    }
  }

  /// Submit a weekly challenge score (best per player per week is kept
  /// server-side).
  Future<bool> submitWeeklyScore({
    required String weekKey,
    required int depth,
    required int cashEarned,
  }) async {
    try {
      await client.rpc('submit_weekly_score', params: {
        'p_week': weekKey,
        'p_depth': depth,
        'p_cash_earned': cashEarned,
      });
      debugPrint('LeaderboardService: weekly score submitted '
          '($weekKey depth=$depth cash=$cashEarned)');
      return true;
    } catch (e) {
      debugPrint('LeaderboardService.submitWeeklyScore: $e');
      return false;
    }
  }

  /// Weekly challenge standings for a given ISO week.
  Future<List<WeeklyScoreEntry>> weeklyTop({
    required String weekKey,
    int limit = 50,
  }) async {
    try {
      final rows = await client
          .from('leaderboard_weekly')
          .select()
          .eq('week', weekKey)
          .order('depth', ascending: false)
          .limit(limit);
      return (rows as List)
          .map((r) => WeeklyScoreEntry.fromRow(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('LeaderboardService.weeklyTop: $e');
      return [];
    }
  }
}
