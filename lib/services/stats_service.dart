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
import 'package:flutter/foundation.dart';
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
}

class StatsService {
  final _supabase = SupabaseService.instance;

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

      debugPrint('StatsService: synced to server '
          '(${_stats.xp} XP, ${_stats.points} pts)');
    } catch (e) {
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

    // Level up check (exponential curve: 100 * level^1.5)
    while (_stats.xp >= _xpForLevel(_stats.level + 1)) {
      _stats.level++;
      debugPrint('StatsService: LEVEL UP! Now level ${_stats.level}');
    }
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
        'level': _stats.level,
        'total_xp_earned': _stats.totalXpEarned,
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

  // ── Helpers ────────────────────────────────────────────────────

  /// XP required to reach a given level.
  /// Curve: 100 * level^1.5 (same as xp_points_system.dart).
  int _xpForLevel(int level) {
    if (level <= 1) return 0;
    return (100 * _pow(level.toDouble(), 1.5)).toInt();
  }

  double _pow(double base, double exp) {
    // dart:math pow
    return base <= 0 ? 0 : (base == 1 ? 1 : _fastPow(base, exp));
  }

  double _fastPow(double base, double exp) {
    // Simple power function without importing dart:math at top
    double result = 1.0;
    // Use repeated multiplication for integer part
    int intExp = exp.toInt();
    double fracExp = exp - intExp;
    for (int i = 0; i < intExp; i++) {
      result *= base;
    }
    // Approximate fractional part: base^frac ≈ 1 + frac*ln(base)
    if (fracExp > 0) {
      // Good enough for level calculations
      double ln = 0;
      double term = (base - 1) / (base + 1);
      double termSq = term * term;
      double current = term;
      for (int i = 0; i < 10; i++) {
        ln += current / (2 * i + 1);
        current *= termSq;
      }
      ln *= 2;
      result *= (1.0 + fracExp * ln);
    }
    return result;
  }

  /// Dispose resources.
  void dispose() {
    stopPeriodicSync();
  }
}