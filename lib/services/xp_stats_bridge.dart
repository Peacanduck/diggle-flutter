/// xp_stats_bridge.dart
/// Bridge between XPPointsSystem (local game state) and StatsService (Supabase).
///
/// Instead of modifying XPPointsSystem directly, this bridge listens
/// for changes and forwards them to StatsService for persistence.
///
/// The bridge also provides convenience methods that award XP/points
/// through XPPointsSystem AND record them in StatsService's ledger.
///
/// Usage:
///   final bridge = XPStatsBridge(xpSystem: xpSystem, statsService: statsService);
///   bridge.awardMiningReward(tileType, depth);  // Awards + logs
///   bridge.spendPoints(100, 'shop_spend');       // Spends + logs
///   bridge.awardPackPurchase(500, txSig);        // Pack + logs with tx sig

import 'package:flutter/foundation.dart';
import '../game/systems/xp_points_system.dart';
import '../game/world/tile.dart';
import 'stats_service.dart';

class XPStatsBridge {
  final XPPointsSystem xpSystem;
  final StatsService statsService;

  /// Track the XP system's level so we can detect level-ups
  int _lastKnownLevel = 1;

  XPStatsBridge({
    required this.xpSystem,
    required this.statsService,
  }) {
    _lastKnownLevel = xpSystem.level;
  }

  // ── Mining Rewards ─────────────────────────────────────────────

  /// Award XP and points for mining a tile.
  /// Calls XPPointsSystem.awardForMining() AND logs to StatsService.
  RewardEvent awardForMining(TileType tileType, int depth) {
    final event = xpSystem.awardForMining(tileType, depth);

    // Forward to stats service
    if (event.finalXP > 0) {
      statsService.addLocalXP(event.finalXP);
    }
    if (event.finalPoints > 0) {
      statsService.addLocalPoints(event.finalPoints, 'mining', metadata: {
        'ore_type': tileType.name,
        'depth': depth,
      });
    }

    // Track mining stats
    if (tileType.isOre) {
      statsService.recordMining(oresMined: 1, depthReached: depth);
    } else {
      statsService.recordMining(depthReached: depth);
    }

    // Check for level-up that happened inside awardForMining
    _checkForLevelUp();

    return event;
  }

  // ── Depth Milestones ───────────────────────────────────────────

  /// Check and award depth milestones.
  void checkDepthMilestone(int depth) {
    final event = xpSystem.checkDepthMilestone(depth);
    if (event == null) return;

    if (event.finalXP > 0) {
      statsService.addLocalXP(event.finalXP);
    }
    if (event.finalPoints > 0) {
      statsService.addLocalPoints(event.finalPoints, 'achievement', metadata: {
        'achievement_name': 'Depth milestone: ${depth}m',
        'depth': depth,
      });
    }

    _checkForLevelUp();
  }

  // ── Selling Ores ───────────────────────────────────────────────

  /// Award XP/points for selling ores.
  RewardEvent awardForSale(int cashEarned, int totalOresSold) {
    final event = xpSystem.awardForSale(cashEarned, totalOresSold);

    if (event.finalXP > 0) {
      statsService.addLocalXP(event.finalXP);
    }
    if (event.finalPoints > 0) {
      statsService.addLocalPoints(event.finalPoints, 'mining', metadata: {
        'sale_cash': cashEarned,
        'total_ores_sold': totalOresSold,
      });
    }

    _checkForLevelUp();

    return event;
  }

  // ── Points Spending (In-Game Shop) ─────────────────────────────

  /// Spend points in the in-game shop.
  /// Returns false if insufficient balance.
  bool spendPoints(int amount, {String? itemName}) {
    if (!xpSystem.canAffordPoints(amount)) return false;

    xpSystem.spendPoints(amount);
    statsService.addLocalPoints(-amount, 'shop_spend', metadata: {
      if (itemName != null) 'item_name': itemName,
    });

    return true;
  }

  // ── On-Chain Purchase Awards ───────────────────────────────────

  /// Award points from an on-chain points pack purchase.
  void awardPackPurchase(int pointsAmount, int packType, String? txSignature) {
    xpSystem.addPoints(pointsAmount);

    statsService.addLocalPoints(pointsAmount, 'pack_purchase',
      metadata: {
        'pack_type': packType,
        'points_amount': pointsAmount,
      },
      txSignature: txSignature,
    );

    debugPrint('XPStatsBridge: awarded $pointsAmount pts from pack (tx: $txSignature)');
  }

  /// Log a booster purchase in the ledger (no points change, just audit trail).
  void logBoosterPurchase({
    required int boosterType,
    required int durationSeconds,
    required double priceSOL,
    String? txSignature,
  }) {
    statsService.addLocalPoints(0, 'booster_purchase', metadata: {
      'booster_type': boosterType,
      'duration_seconds': durationSeconds,
      'price_sol': priceSOL,
    }, txSignature: txSignature);

    debugPrint('XPStatsBridge: logged booster purchase (tx: $txSignature)');
  }

  // ── Level-Up Detection ─────────────────────────────────────────

  /// Detect if XPPointsSystem leveled up and forward bonus points to StatsService.
  void _checkForLevelUp() {
    final currentLevel = xpSystem.level;
    if (currentLevel > _lastKnownLevel) {
      // XPPointsSystem._onLevelUp already added bonus points locally.
      // Forward that same bonus to StatsService so they stay in sync.
      for (int lvl = _lastKnownLevel + 1; lvl <= currentLevel; lvl++) {
        final bonusPoints = lvl * 10; // Must match XPPointsSystem._onLevelUp
        statsService.addLocalPoints(bonusPoints, 'level_up', metadata: {
          'level': lvl,
        });
      }
      debugPrint('XPStatsBridge: forwarded level-up bonuses '
          '(${_lastKnownLevel} → $currentLevel)');
      _lastKnownLevel = currentLevel;
    }
  }

  // ── Play Time Tracking ─────────────────────────────────────────

  /// Record play time (call periodically or on pause).
  void recordPlayTime(int seconds) {
    statsService.recordPlayTime(seconds);
  }

  // ── Sync ───────────────────────────────────────────────────────

  /// Force sync to server (call on pause/exit).
  Future<void> syncNow() async {
    await statsService.syncToServer();
  }

  // ── State Access ───────────────────────────────────────────────

  /// Whether stats have been loaded from server.
  bool get isLoaded => statsService.stats.xp > 0 || statsService.stats.points > 0;

  /// Server-side stats (for reconciliation).
  PlayerStats get serverStats => statsService.stats;
}