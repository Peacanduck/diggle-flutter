/// stats_service.dart
/// XP and points persistence with periodic batch sync.
///
/// The game updates XP/points locally for instant feedback, then
/// syncs to Supabase periodically (every 30s) and on pause/exit.
/// Uses the award_points() RPC for atomic ledger entries.
///
/// Usage:
///   final service = StatsService();
///   await service.loadStats();              // Load from Supabase on game start
///   service.addLocalXP(50);                 // Instant local update
///   service.addLocalPoints(10, 'mining');   // Queues ledger entry
///   await service.syncToServer();           // Flush to Supabase

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../game/systems/streak_system.dart';
import '../game/systems/xp_points_system.dart';
import 'supabase_service.dart';

/// Snapshot of player stats (mirrors player_stats table).
class PlayerStats {
  int xp;
  int points;
  int level;
  int totalPointsEarned;
  int totalPointsSpent;
  int totalPointsRedeemed;
  int totalXpEarned;
  int maxDepthReached;
  int totalOresMined;
  int totalPlayTimeSeconds;
  DateTime updatedAt;

  PlayerStats({
    this.xp = 0,
    this.points = 0,
    this.level = 1,
    this.totalPointsEarned = 0,
    this.totalPointsSpent = 0,
    this.totalPointsRedeemed = 0,
    this.totalXpEarned = 0,
    this.maxDepthReached = 0,
    this.totalOresMined = 0,
    this.totalPlayTimeSeconds = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalPointsEarned: (json['total_points_earned'] as num?)?.toInt() ?? 0,
      totalPointsSpent: (json['total_points_spent'] as num?)?.toInt() ?? 0,
      totalPointsRedeemed: (json['total_points_redeemed'] as num?)?.toInt() ?? 0,
      totalXpEarned: (json['total_xp_earned'] as num?)?.toInt() ?? 0,
      maxDepthReached: (json['max_depth_reached'] as num?)?.toInt() ?? 0,
      totalOresMined: (json['total_ores_mined'] as num?)?.toInt() ?? 0,
      totalPlayTimeSeconds: (json['total_play_time_seconds'] as num?)?.toInt() ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'points': points,
    'level': level,
    'total_points_earned': totalPointsEarned,
    'total_points_spent': totalPointsSpent,
    'total_points_redeemed': totalPointsRedeemed,
    'total_xp_earned': totalXpEarned,
    'max_depth_reached': maxDepthReached,
    'total_ores_mined': totalOresMined,
    'total_play_time_seconds': totalPlayTimeSeconds,
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  };
}

/// Pending points change to be flushed as a ledger entry.
class _PendingPointsEntry {
  final int amount;
  final String source;
  final Map<String, dynamic>? metadata;
  final String? txSignature;

  _PendingPointsEntry({
    required this.amount,
    required this.source,
    this.metadata,
    this.txSignature,
  });
  Map<String, dynamic> toJson() => {
    'amount': amount,
    'source': source,
    'metadata': metadata,
    'txSignature': txSignature,
  };

  factory _PendingPointsEntry.fromJson(Map<String, dynamic> json) {
    return _PendingPointsEntry(
      amount: (json['amount'] as num).toInt(),
      source: json['source'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      txSignature: json['txSignature'] as String?,
    );
  }
}

class StatsService {
  final _supabase = SupabaseService.instance;

  // SharedPreferences keys
  static const String _pendingLedgerKey = 'diggle_pending_ledger';
  static const String _pendingDeltasKey = 'diggle_pending_deltas';

  /// Current local stats (source of truth during gameplay).
  PlayerStats _stats = PlayerStats();
  PlayerStats get stats => _stats;

  /// Pending ledger entries not yet synced.
  final List<_PendingPointsEntry> _pendingLedger = [];

  /// Accumulated XP delta since last sync.
  int _xpDeltaSinceSync = 0;

  /// Accumulated stat deltas since last sync.
  int _oresMinedDelta = 0;
  int _playTimeDelta = 0;
  int _depthThisSession = 0;

  /// Sync timer.
  Timer? _syncTimer;
  bool _syncing = false;

  // ── Lifecycle ──────────────────────────────────────────────────

  /// Load stats from Supabase. Call at game start.
  Future<void> loadStats() async {
    final playerId = _supabase.playerId;
    if (playerId == null) {
      debugPrint('StatsService: no player, using defaults');
      return;
    }

    // Restore any pending data from a previous session that wasn't synced
    await _restorePendingData();

    try {
      final data = await _supabase.client
          .from('player_stats')
          .select()
          .eq('player_id', playerId)
          .maybeSingle();

      if (data != null) {
        _stats = PlayerStats.fromJson(data);
        debugPrint('StatsService: loaded — lvl ${_stats.level}, '
            '${_stats.xp} XP, ${_stats.points} pts');
      } else {
        debugPrint('StatsService: no stats row found, using defaults');
      }
    } catch (e) {
      debugPrint('StatsService.loadStats error: $e');
    }
  }

  /// Start periodic sync (call when game begins).
  void startPeriodicSync({Duration interval = const Duration(seconds: 30)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => syncToServer());
    debugPrint('StatsService: periodic sync started (${interval.inSeconds}s)');
  }

  /// Stop periodic sync (call on pause/exit).
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Flush everything to server. Call on pause, exit, game over.
  Future<void> syncToServer() async {
    debugPrint('StatsService(${identityHashCode(this)}): syncing...');
    if (_syncing) return;
    _syncing = true;

    final playerId = _supabase.playerId;
    if (playerId == null) {
      _syncing = false;
      return;
    }

    try {
      // 1. Flush pending ledger entries via award_points RPC
      await _flushLedger(playerId);

      // 2. Sync cumulative stats
      await _syncStats(playerId);

      // 3. Clear persisted pending data on success
      await _clearPersistedPendingData();

      debugPrint('StatsService: synced to server '
          '(${_stats.xp} XP, ${_stats.points} pts)');
    } catch (e) {
      // Persist pending data so it survives app kill
      await _persistPendingData();
      debugPrint('StatsService.syncToServer error: $e');
    } finally {
      _syncing = false;
    }
  }

  // ── Local Updates (Instant Feedback) ───────────────────────────

  /// Add XP locally. Handles leveling. Synced in batch.
  void addLocalXP(int amount) {
    if (amount <= 0) return;
    _stats.xp += amount;
    _stats.totalXpEarned += amount;
    _xpDeltaSinceSync += amount;
    debugPrint('StatsService(${identityHashCode(this)}): +$amount XP → total ${_stats.xp}');
    // Level up check (exponential curve: 100 * level^1.5)
    _stats.level = LevelThresholds.levelFromXP(_stats.xp);
   /* while (_stats.xp >= _xpForLevel(_stats.level + 1)) {
      _stats.level++;
      debugPrint('StatsService: LEVEL UP! Now level ${_stats.level}');
    }*/
    debugPrint('StatsService: LEVEL UP! Now level ${_stats.level}');
  }

  /// Add points locally and queue a ledger entry.
  void addLocalPoints(int amount, String source, {
    Map<String, dynamic>? metadata,
    String? txSignature,
  }) {
    if (amount == 0) return;

    _stats.points += amount;
    if (amount > 0) {
      _stats.totalPointsEarned += amount;
    } else {
      _stats.totalPointsSpent += amount.abs();
    }

    _pendingLedger.add(_PendingPointsEntry(
      amount: amount,
      source: source,
      metadata: metadata,
      txSignature: txSignature,
    ));
  }

  /// Spend points locally. Returns false if insufficient.
  bool spendLocalPoints(int amount, String source, {
    Map<String, dynamic>? metadata,
  }) {
    if (amount <= 0 || _stats.points < amount) return false;
    addLocalPoints(-amount, source, metadata: metadata);
    return true;
  }

  /// Record mining stats locally.
  void recordMining({int oresMined = 0, int depthReached = 0}) {
    _oresMinedDelta += oresMined;
    _stats.totalOresMined += oresMined;

    if (depthReached > _stats.maxDepthReached) {
      _stats.maxDepthReached = depthReached;
      _depthThisSession = depthReached;
    }
  }

  /// Record play time locally (call periodically or on pause).
  void recordPlayTime(int seconds) {
    _playTimeDelta += seconds;
    _stats.totalPlayTimeSeconds += seconds;
  }

  // ── Server Sync (Internal) ─────────────────────────────────────

  /// Flush pending ledger entries using award_points RPC.
  Future<void> _flushLedger(String playerId) async {
    if (_pendingLedger.isEmpty) return;

    // Copy and clear so new entries during sync aren't lost
    final entries = List<_PendingPointsEntry>.from(_pendingLedger);
    _pendingLedger.clear();

    for (final entry in entries) {
      try {
        await _supabase.client.rpc('award_points', params: {
          'p_player_id': playerId,
          'p_amount': entry.amount,
          'p_source': entry.source,
          'p_metadata': entry.metadata,
          'p_tx_signature': entry.txSignature,
        });
      } catch (e) {
        debugPrint('StatsService: ledger flush error for '
            '${entry.source}/${entry.amount}: $e');
        // Re-queue failed entry
        _pendingLedger.add(entry);
      }
    }
  }

  /// Sync cumulative stats (XP, level, depth, ores, playtime).
  Future<void> _syncStats(String playerId) async {
    // Only sync if there are changes
    if (_xpDeltaSinceSync == 0 &&
        _oresMinedDelta == 0 &&
        _playTimeDelta == 0 &&
        _depthThisSession == 0) {
      return;
    }

    try {
      await _supabase.client
          .from('player_stats')
          .update({
        'xp': _stats.xp,
        'points': _stats.points,
        'level': _stats.level,
        'total_xp_earned': _stats.totalXpEarned,
        'total_points_earned': _stats.totalPointsEarned,
        'total_points_spent': _stats.totalPointsSpent,
        'max_depth_reached': _stats.maxDepthReached,
        'total_ores_mined': _stats.totalOresMined,
        'total_play_time_seconds': _stats.totalPlayTimeSeconds,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      })
          .eq('player_id', playerId);

      // Reset deltas
      _xpDeltaSinceSync = 0;
      _oresMinedDelta = 0;
      _playTimeDelta = 0;
      _depthThisSession = 0;
    } catch (e) {
      debugPrint('StatsService._syncStats error: $e');
    }
  }

  // ── Daily Login Streak (server-owned) ──────────────────────────

  /// Claim today's login streak on the server.
  ///
  /// The server owns the streak day (it computes the UTC boundary from
  /// its own clock, so a device clock can't mint days). It does NOT
  /// award the XP/points — it returns them, and the caller applies them
  /// through XPStatsBridge.awardBonus so they flow down the normal
  /// local-update + ledger path. Awarding server-side would be undone
  /// by [_syncStats], which writes absolute values from local state.
  ///
  /// Returns null when there's no player, no connectivity, or the RPC
  /// errors — callers fall back to a local claim.
  Future<ServerStreakResult?> claimDailyStreak({
    required int localStreak,
    required String? localLastClaimDay,
  }) async {
    final playerId = _supabase.playerId;
    if (playerId == null) return null;

    try {
      final rows = await _supabase.client.rpc('claim_daily_streak', params: {
        'p_player_id': playerId,
        'p_local_streak': localStreak,
        'p_local_last_claim': localLastClaimDay,
      });

      // RETURNS TABLE arrives as a list of rows.
      final row = (rows is List && rows.isNotEmpty)
          ? rows.first as Map<String, dynamic>
          : (rows is Map<String, dynamic> ? rows : null);
      if (row == null) {
        debugPrint('StatsService: claim_daily_streak returned no row');
        return null;
      }

      final result = ServerStreakResult(
        streak: (row['new_streak'] as num?)?.toInt() ?? 0,
        claimed: row['did_claim'] == true,
        rewardXp: (row['reward_xp'] as num?)?.toInt() ?? 0,
        rewardPoints: (row['reward_points'] as num?)?.toInt() ?? 0,
        claimDay: row['claim_date'] as String? ?? '',
      );
      if (result.claimDay.isEmpty) return null;

      debugPrint('StatsService: streak day ${result.streak} '
          '(claimed: ${result.claimed})');
      return result;
    } catch (e) {
      debugPrint('StatsService.claimDailyStreak error: $e');
      return null;
    }
  }

  /// Fetch the streak reward ladder from the server, ordered by day.
  ///
  /// Read-only and public (the ladder is just what the UI already
  /// displays), so this works before auth completes. Returns null on
  /// any failure — callers keep their cached/compiled-in ladder.
  Future<List<(int, int)>?> fetchStreakRewards() async {
    try {
      final rows = await _supabase.client
          .from('streak_rewards')
          .select('day, xp, points')
          .order('day');

      if (rows is! List || rows.isEmpty) return null;

      final ladder = <(int, int)>[];
      for (final row in rows) {
        final map = row as Map<String, dynamic>;
        ladder.add((
          (map['xp'] as num?)?.toInt() ?? 0,
          (map['points'] as num?)?.toInt() ?? 0,
        ));
      }
      debugPrint('StatsService: fetched ${ladder.length}-rung streak ladder');
      return ladder;
    } catch (e) {
      debugPrint('StatsService.fetchStreakRewards error: $e');
      return null;
    }
  }

  // ── Offline Persistence ────────────────────────────────────────
  /// Persist pending ledger entries and deltas to SharedPreferences.
  /// Called when sync fails so data survives app kill.
  Future<void> _persistPendingData() async {
    try {
      final prefs = SharedPreferencesAsync();
      // Persist pending ledger
      if (_pendingLedger.isNotEmpty) {
        final ledgerJson = _pendingLedger.map((e) => e.toJson()).toList();
        await prefs.setString(_pendingLedgerKey, jsonEncode(ledgerJson));
      }
      // Persist deltas
      if (_xpDeltaSinceSync > 0 || _oresMinedDelta > 0 ||
          _playTimeDelta > 0 || _depthThisSession > 0) {
        final deltas = {
          'xpDelta': _xpDeltaSinceSync,
          'oresDelta': _oresMinedDelta,
          'playTimeDelta': _playTimeDelta,
          'depthSession': _depthThisSession,
          'stats': _stats.toJson(),
        };
        await prefs.setString(_pendingDeltasKey, jsonEncode(deltas));
      }
      debugPrint('StatsService: persisted ${_pendingLedger.length} '
          'ledger entries and deltas to disk');
    } catch (e) {
      debugPrint('StatsService: failed to persist pending data: $e');
    }
  }
  /// Restore pending data from SharedPreferences (previous session crash/kill).
  Future<void> _restorePendingData() async {
    try {
      final prefs = SharedPreferencesAsync();
      // Restore pending ledger
      final ledgerStr = await prefs.getString(_pendingLedgerKey);
      if (ledgerStr != null) {
        final ledgerList = jsonDecode(ledgerStr) as List;
        for (final item in ledgerList) {
          _pendingLedger.add(
            _PendingPointsEntry.fromJson(item as Map<String, dynamic>),
          );
        }
        debugPrint('StatsService: restored ${_pendingLedger.length} '
            'pending ledger entries from disk');
      }

      // Restore deltas
      final deltasStr = await prefs.getString(_pendingDeltasKey);
      if (deltasStr != null) {
        final deltas = jsonDecode(deltasStr) as Map<String, dynamic>;
        _xpDeltaSinceSync += (deltas['xpDelta'] as num?)?.toInt() ?? 0;
        _oresMinedDelta += (deltas['oresDelta'] as num?)?.toInt() ?? 0;
        _playTimeDelta += (deltas['playTimeDelta'] as num?)?.toInt() ?? 0;
        final savedDepth = (deltas['depthSession'] as num?)?.toInt() ?? 0;
        if (savedDepth > _depthThisSession) {
          _depthThisSession = savedDepth;
        }

        // Restore full stats snapshot if server load fails
        if (deltas.containsKey('stats')) {
          final savedStats = PlayerStats.fromJson(
            deltas['stats'] as Map<String, dynamic>,
          );
          // Use saved stats as baseline (server load will override if available)
          _stats = savedStats;
          debugPrint('StatsService: restored stats snapshot from disk');
        }
        debugPrint('StatsService: restored deltas from disk '
            '(xp: $_xpDeltaSinceSync, ores: $_oresMinedDelta)');
      }
    } catch (e) {
      debugPrint('StatsService: failed to restore pending data: $e');
    }
  }

  /// Clear persisted pending data after successful sync.
  Future<void> _clearPersistedPendingData() async {
    try {
      final prefs = SharedPreferencesAsync();
      // Only clear our specific keys
      if (await prefs.containsKey(_pendingLedgerKey)) {
        await prefs.remove(_pendingLedgerKey);
      }
      if (await prefs.containsKey(_pendingDeltasKey)) {
        await prefs.remove(_pendingDeltasKey);
      }
    } catch (e) {
      debugPrint('StatsService: failed to clear persisted data: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────


  /// Dispose resources.
  void dispose() {
    stopPeriodicSync();
  }
}