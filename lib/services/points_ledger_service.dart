/// points_ledger_service.dart
/// Read-only access to the points audit trail.
///
/// Points are awarded/deducted via StatsService (which calls the
/// award_points RPC). This service provides query access to the
/// ledger for UI display, history, and redemption eligibility checks.
///
/// Usage:
///   final service = PointsLedgerService();
///   final history = await service.getHistory(limit: 50);
///   final earned = await service.getTotalEarnedSince(since);

import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// A single points ledger entry.
class PointsLedgerEntry {
  final String id;
  final String playerId;
  final int amount;
  final int balanceAfter;
  final String source;
  final Map<String, dynamic>? metadata;
  final String? txSignature;
  final DateTime createdAt;

  PointsLedgerEntry({
    required this.id,
    required this.playerId,
    required this.amount,
    required this.balanceAfter,
    required this.source,
    this.metadata,
    this.txSignature,
    required this.createdAt,
  });

  factory PointsLedgerEntry.fromJson(Map<String, dynamic> json) {
    return PointsLedgerEntry(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      amount: (json['amount'] as num).toInt(),
      balanceAfter: (json['balance_after'] as num).toInt(),
      source: json['source'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      txSignature: json['tx_signature'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isEarning => amount > 0;
  bool get isSpending => amount < 0;
  bool get isOnChain => txSignature != null;

  /// Human-readable description.
  String get description {
    switch (source) {
      case 'mining':
        final oreType = metadata?['ore_type'] ?? 'ore';
        return 'Mined $oreType';
      case 'level_up':
        final level = metadata?['level'] ?? '?';
        return 'Level $level bonus';
      case 'achievement':
        return metadata?['achievement_name'] ?? 'Achievement';
      case 'pack_purchase':
        final packType = metadata?['pack_type'] == 0 ? 'Small' : 'Large';
        return '$packType points pack';
      case 'shop_spend':
        return metadata?['item_name'] ?? 'Shop purchase';
      case 'booster_purchase':
        return metadata?['booster_name'] ?? 'Booster';
      case 'spl_redemption':
        return 'Token redemption';
      default:
        return source;
    }
  }
}

class PointsLedgerService {
  final _supabase = SupabaseService.instance;

  // ── Query History ──────────────────────────────────────────────

  /// Get recent ledger entries, newest first.
  Future<List<PointsLedgerEntry>> getHistory({
    int limit = 50,
    int offset = 0,
    String? sourceFilter,
  }) async {
    final playerId = _supabase.playerId;
    if (playerId == null) return [];

    try {
      var query = _supabase.client
          .from('points_ledger')
          .select()
          .eq('player_id', playerId);

      if (sourceFilter != null) {
        query = query.eq('source', sourceFilter);
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map((row) => PointsLedgerEntry.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('PointsLedgerService.getHistory error: $e');
      return [];
    }
  }

  // ── Aggregates ─────────────────────────────────────────────────

  /// Get total points earned since a given date (for rate limiting redemptions).
  Future<int> getTotalEarnedSince(DateTime since) async {
    final playerId = _supabase.playerId;
    if (playerId == null) return 0;

    try {
      final data = await _supabase.client
          .from('points_ledger')
          .select('amount')
          .eq('player_id', playerId)
          .gt('amount', 0)
          .gte('created_at', since.toUtc().toIso8601String());

      int total = 0;
      for (final row in (data as List)) {
        total += ((row as Map<String, dynamic>)['amount'] as num).toInt();
      }
      return total;
    } catch (e) {
      debugPrint('PointsLedgerService.getTotalEarnedSince error: $e');
      return 0;
    }
  }

  /// Get count of redemptions in last 24h (for cooldown check).
  Future<int> getRedemptionCountLast24h() async {
    final playerId = _supabase.playerId;
    if (playerId == null) return 0;

    try {
      final since = DateTime.now().subtract(const Duration(hours: 24));
      final data = await _supabase.client
          .from('points_ledger')
          .select('id')
          .eq('player_id', playerId)
          .eq('source', 'spl_redemption')
          .gte('created_at', since.toUtc().toIso8601String());

      return (data as List).length;
    } catch (e) {
      debugPrint('PointsLedgerService.getRedemptionCountLast24h error: $e');
      return 0;
    }
  }

  /// Check if player is eligible for SPL token redemption.
  Future<RedemptionEligibility> checkRedemptionEligibility({
    required int pointsToRedeem,
    required int currentBalance,
    int minimumRedemption = 1000,
    int maxRedemptionsPerDay = 1,
  }) async {
    if (pointsToRedeem < minimumRedemption) {
      return RedemptionEligibility(
        eligible: false,
        reason: 'Minimum redemption is $minimumRedemption points',
      );
    }

    if (currentBalance < pointsToRedeem) {
      return RedemptionEligibility(
        eligible: false,
        reason: 'Insufficient balance ($currentBalance points)',
      );
    }

    final recentRedemptions = await getRedemptionCountLast24h();
    if (recentRedemptions >= maxRedemptionsPerDay) {
      return RedemptionEligibility(
        eligible: false,
        reason: 'Redemption cooldown: max $maxRedemptionsPerDay per 24h',
      );
    }

    return RedemptionEligibility(eligible: true);
  }
}

/// Result of redemption eligibility check.
class RedemptionEligibility {
  final bool eligible;
  final String? reason;

  RedemptionEligibility({required this.eligible, this.reason});
}