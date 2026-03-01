/// quest_sync_service.dart
/// Handles syncing quest state to Supabase's player_quests table.
///
/// Local-first design: SharedPreferences is the source of truth,
/// server sync is best-effort. Offline play is fully supported.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestSyncService {
  final SupabaseClient _client;
  final String _playerId;

  QuestSyncService({
    required SupabaseClient client,
    required String playerId,
  })  : _client = client,
        _playerId = playerId;

  // ============================================================
  // UPSERT QUEST STATE
  // ============================================================

  /// Sync a single quest's progress to the server.
  /// Uses select-then-insert/update because PostgREST's upsert
  /// doesn't support partial unique indexes (WHERE category = ...).
  Future<bool> syncQuest({
    required String questId,
    required String category,
    required int progress,
    required int target,
    required bool completed,
    required bool rewardClaimed,
    required int xpReward,
    required int pointsReward,
    DateTime? completedAt,
    String? resetDate, // 'YYYY-MM-DD' for daily, null for social
  }) async {
    try {
      // Check if row already exists
      Map<String, dynamic>? existing;
      if (category == 'daily' && resetDate != null) {
        final res = await _client
            .from('player_quests')
            .select('id')
            .eq('player_id', _playerId)
            .eq('quest_id', questId)
            .eq('category', 'daily')
            .eq('reset_date', resetDate)
            .maybeSingle();
        existing = res;
      } else if (category == 'social') {
        final res = await _client
            .from('player_quests')
            .select('id')
            .eq('player_id', _playerId)
            .eq('quest_id', questId)
            .eq('category', 'social')
            .maybeSingle();
        existing = res;
      }

      if (existing != null) {
        // UPDATE existing row
        await _client
            .from('player_quests')
            .update({
          'progress': progress,
          'target': target,
          'completed': completed,
          'reward_claimed': rewardClaimed,
          'xp_reward': xpReward,
          'points_reward': pointsReward,
          'completed_at': completedAt?.toUtc().toIso8601String(),
        })
            .eq('id', existing['id']);
      } else {
        // INSERT new row
        final row = <String, dynamic>{
          'player_id': _playerId,
          'quest_id': questId,
          'category': category,
          'progress': progress,
          'target': target,
          'completed': completed,
          'reward_claimed': rewardClaimed,
          'xp_reward': xpReward,
          'points_reward': pointsReward,
          'completed_at': completedAt?.toUtc().toIso8601String(),
        };

        if (category == 'daily' && resetDate != null) {
          row['reset_date'] = resetDate;
          row['reset_at'] = '${resetDate}T00:00:00Z';
        }
        await _client.from('player_quests').insert(row);
      }
      return true;
    } catch (e) {
      debugPrint('QuestSync: failed to sync quest $questId: $e');
      return false;
    }
  }

  /// Batch sync all active quests.
  Future<void> syncAll({
    required List<Map<String, dynamic>> quests,
  }) async {
    for (final q in quests) {
      await syncQuest(
        questId: q['quest_id'] as String,
        category: q['category'] as String,
        progress: q['progress'] as int,
        target: q['target'] as int,
        completed: q['completed'] as bool,
        rewardClaimed: q['reward_claimed'] as bool,
        xpReward: q['xp_reward'] as int,
        pointsReward: q['points_reward'] as int,
        completedAt: q['completed_at'] != null
            ? DateTime.tryParse(q['completed_at'] as String)
            : null,
        resetDate: q['reset_date'] as String?,
      );
    }
  }

  // ============================================================
  // LOAD FROM SERVER
  // ============================================================

  /// Load all quests for this player from the server.
  /// Returns null on failure (caller should fall back to local).
  Future<List<Map<String, dynamic>>?> loadQuests() async {
    try {
      final response = await _client
          .from('player_quests')
          .select()
          .eq('player_id', _playerId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('QuestSync: failed to load quests: $e');
      return null;
    }
  }

  /// Load today's daily quests from the server.
  Future<List<Map<String, dynamic>>?> loadDailyQuests(String resetDate) async {
    try {
      final response = await _client
          .from('player_quests')
          .select()
          .eq('player_id', _playerId)
          .eq('category', 'daily')
          .eq('reset_date', resetDate);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('QuestSync: failed to load daily quests: $e');
      return null;
    }
  }

  /// Load social quests from the server.
  Future<List<Map<String, dynamic>>?> loadSocialQuests() async {
    try {
      final response = await _client
          .from('player_quests')
          .select()
          .eq('player_id', _playerId)
          .eq('category', 'social');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('QuestSync: failed to load social quests: $e');
      return null;
    }
  }

  // ============================================================
  // CLAIM REWARD (SERVER-SIDE RPC)
  // ============================================================

  /// Claim a quest reward atomically on the server.
  /// Returns the RPC result, or null on failure.
  Future<Map<String, dynamic>?> claimRewardServer({
    required String questId,
    required String category,
    String? resetDate, // 'YYYY-MM-DD' for daily, null for social
  }) async {
    try {
      final response = await _client.rpc('claim_quest_reward', params: {
        'p_player_id': _playerId,
        'p_quest_id': questId,
        'p_reset_date': category == 'daily' ? resetDate : null,
      });

      if (response is Map<String, dynamic>) {
        return response;
      }

      // Some Supabase versions return a nested structure
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      debugPrint('QuestSync: failed to claim reward for $questId: $e');
      return null;
    }
  }

  // ============================================================
  // SOCIAL QUEST VALIDATION (via Edge Function)
  // ============================================================

  /// Validate a social quest by calling the Edge Function.
  /// Returns {valid: bool, reason: String?}
  Future<Map<String, dynamic>> validateSocialQuest({
    required String questId,
    String? tweetUrl,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'validate-social-quest',
        body: {
          'player_id': _playerId,
          'quest_id': questId,
          'tweet_url': tweetUrl,
        },
      );

      if (response.status != 200) {
        return {
          'valid': false,
          'reason': 'Validation service unavailable (${response.status})',
        };
      }

      final data = response.data as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('QuestSync: validation failed for $questId: $e');
      return {
        'valid': false,
        'reason': 'Could not reach validation service',
      };
    }
  }

  // ============================================================
  // DISCORD OAUTH
  // ============================================================

  /// Get the Discord OAuth authorization URL from the Edge Function.
  /// The Edge Function builds the URL with the correct client_id,
  /// redirect_uri, and player_id in the state param.
  Future<String?> getDiscordAuthUrl() async {
    try {
      final response = await _client.functions.invoke(
        'discord-oauth-callback',
        body: {
          'player_id': _playerId,
        },
      );

      if (response.status != 200) {
        debugPrint('QuestSync: Discord auth URL request failed (${response.status})');
        return null;
      }

      final data = response.data as Map<String, dynamic>;
      return data['auth_url'] as String?;
    } catch (e) {
      debugPrint('QuestSync: getDiscordAuthUrl error: $e');
      return null;
    }
  }

  /// Check if the Discord quest was completed server-side.
  /// Called after user returns from the OAuth flow.
  Future<bool> checkDiscordQuestCompleted() async {
    try {
      final response = await _client
          .from('player_quests')
          .select('completed')
          .eq('player_id', _playerId)
          .eq('quest_id', 'social_join_discord')
          .eq('category', 'social')
          .maybeSingle();

      if (response == null) return false;
      return response['completed'] as bool? ?? false;
    } catch (e) {
      debugPrint('QuestSync: checkDiscordQuestCompleted error: $e');
      return false;
    }
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  /// Delete old daily quest records (older than N days).
  /// Call periodically to keep the table clean.
  Future<void> pruneOldDailies({int keepDays = 7}) async {
    try {
      final cutoff = DateTime.now()
          .toUtc()
          .subtract(Duration(days: keepDays));
      final cutoffDate =
          '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';

      await _client
          .from('player_quests')
          .delete()
          .eq('player_id', _playerId)
          .eq('category', 'daily')
          .lt('reset_date', cutoffDate);
    } catch (e) {
      debugPrint('QuestSync: failed to prune old dailies: $e');
    }
  }
}