/// xp_points_system.dart
/// Manages player XP, level progression, and points (premium currency).
///
/// XP is earned through gameplay actions:
/// - Mining tiles (scaled by depth and ore value)
/// - Reaching new max depths
/// - Completing mining runs (returning to surface with ore)
///
/// Points are earned alongside XP but at a lower rate.
/// Points can also be purchased via the premium store.
///
/// Both XP and Points can be boosted by:
/// - Timed boosters (purchased on-chain)
/// - NFT permanent multipliers (held in wallet)

import 'dart:math';
import 'package:flutter/foundation.dart';
import '../world/tile.dart';

/// XP thresholds for each level (cumulative)
class LevelThresholds {
  static const List<int> thresholds = [
    0,       // Level 1
    100,     // Level 2
    300,     // Level 3
    600,     // Level 4
    1000,    // Level 5
    1500,    // Level 6
    2200,    // Level 7
    3000,    // Level 8
    4000,    // Level 9
    5200,    // Level 10
    6600,    // Level 11
    8200,    // Level 12
    10000,   // Level 13
    12000,   // Level 14
    14500,   // Level 15
    17500,   // Level 16
    21000,   // Level 17
    25000,   // Level 18
    30000,   // Level 19
    36000,   // Level 20
    43000,   // Level 21
    51000,   // Level 22
    60000,   // Level 23
    70000,   // Level 24
    82000,   // Level 25  (max for now)
  ];

  static int get maxLevel => thresholds.length;

  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    if (level > maxLevel) return thresholds.last;
    return thresholds[level - 1];
  }

  /// Calculate level from total XP
  static int levelFromXP(int totalXP) {
    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (totalXP >= thresholds[i]) return i + 1;
    }
    return 1;
  }
}

/// Tracks what triggered an XP/points award (for UI notifications)
class RewardEvent {
  final String description;
  final int xpAwarded;
  final int pointsAwarded;
  final double xpMultiplier;
  final double pointsMultiplier;
  final DateTime timestamp;

  RewardEvent({
    required this.description,
    required this.xpAwarded,
    required this.pointsAwarded,
    this.xpMultiplier = 1.0,
    this.pointsMultiplier = 1.0,
  }) : timestamp = DateTime.now();

  int get finalXP => (xpAwarded * xpMultiplier).round();
  int get finalPoints => (pointsAwarded * pointsMultiplier).round();
}

/// Manages XP, levels, and points
class XPPointsSystem extends ChangeNotifier {
  // ============================================================
  // STATE
  // ============================================================

  /// Total lifetime XP earned
  int _totalXP = 0;

  /// Current points balance (spendable)
  int _points = 0;

  /// Total lifetime points earned
  int _lifetimePoints = 0;

  /// Current session XP
  int _sessionXP = 0;

  /// Current session points
  int _sessionPoints = 0;

  /// Active XP multiplier from boosters
  double _xpBoostMultiplier = 1.0;

  /// Active points multiplier from boosters
  double _pointsBoostMultiplier = 1.0;

  /// NFT permanent XP multiplier
  double _nftXPMultiplier = 1.0;

  /// NFT permanent points multiplier
  double _nftPointsMultiplier = 1.0;

  /// Recent reward events (for UI display)
  final List<RewardEvent> _recentEvents = [];
  static const int maxRecentEvents = 20;

  /// Highest depth this session (for depth milestone rewards)
  int _sessionMaxDepth = 0;

  /// Depth milestones already awarded this session
  final Set<int> _depthMilestonesAwarded = {};

  // ============================================================
  // GETTERS
  // ============================================================

  int get totalXP => _totalXP;
  int get points => _points;
  int get lifetimePoints => _lifetimePoints;
  int get sessionXP => _sessionXP;
  int get sessionPoints => _sessionPoints;

  /// Current player level
  int get level => LevelThresholds.levelFromXP(_totalXP);

  /// XP needed for next level
  int get xpForNextLevel {
    final nextLvl = level + 1;
    if (nextLvl > LevelThresholds.maxLevel) return 0;
    return LevelThresholds.xpForLevel(nextLvl);
  }

  /// XP progress within current level (0.0 to 1.0)
  double get levelProgress {
    final currentLevelXP = LevelThresholds.xpForLevel(level);
    final nextLevelXP = xpForNextLevel;
    if (nextLevelXP <= currentLevelXP) return 1.0; // Max level
    return (_totalXP - currentLevelXP) / (nextLevelXP - currentLevelXP);
  }

  /// Whether at max level
  bool get isMaxLevel => level >= LevelThresholds.maxLevel;

  /// Combined XP multiplier (boosters + NFT)
  double get effectiveXPMultiplier => _xpBoostMultiplier * _nftXPMultiplier;

  /// Combined points multiplier (boosters + NFT)
  double get effectivePointsMultiplier =>
      _pointsBoostMultiplier * _nftPointsMultiplier;

  /// Whether any boost is active
  bool get hasActiveBoost =>
      _xpBoostMultiplier > 1.0 || _pointsBoostMultiplier > 1.0;

  /// Whether NFT boost is active
  bool get hasNFTBoost =>
      _nftXPMultiplier > 1.0 || _nftPointsMultiplier > 1.0;

  /// Recent reward events
  List<RewardEvent> get recentEvents => List.unmodifiable(_recentEvents);

  // ============================================================
  // XP & POINTS AWARDING
  // ============================================================

  /// Award XP and points for mining a tile
  RewardEvent awardForMining(TileType tileType, int depth) {
    // Base XP scales with ore value and depth
    int baseXP;
    int basePoints;

    if (tileType.isOre) {
      // Ore: XP based on value tier
      baseXP = _xpForOre(tileType);
      basePoints = _pointsForOre(tileType);
    } else {
      // Dirt/rock: small XP, no points
      baseXP = tileType == TileType.rock ? 2 : 1;
      basePoints = 0;
    }

    // Depth bonus: +1% XP per 5 depth
    final depthBonus = 1.0 + (depth / 500.0);
    baseXP = (baseXP * depthBonus).round();

    return _award(baseXP, basePoints, 'Mined ${tileType.displayName}');
  }

  /// Award XP for reaching a new depth milestone
  RewardEvent? checkDepthMilestone(int depth) {
    // Award every 25 depth
    final milestone = (depth ~/ 25) * 25;
    if (milestone <= 0) return null;
    if (_depthMilestonesAwarded.contains(milestone)) return null;
    if (depth < milestone) return null;

    _depthMilestonesAwarded.add(milestone);

    final baseXP = milestone * 2; // 50 XP at depth 25, 100 at 50, etc.
    final basePoints = milestone ~/ 5; // 5 points at depth 25, 10 at 50, etc.

    return _award(baseXP, basePoints, 'Reached ${milestone}m depth!');
  }

  /// Award XP and points for completing a mining run (selling ore)
  RewardEvent awardForSale(int oreValue, int oreCount) {
    final baseXP = (oreValue * 0.5).round(); // 50% of sale value as XP
    final basePoints = (oreValue * 0.1).round(); // 10% of sale value as points

    return _award(baseXP, basePoints, 'Sold $oreCount ore for \$$oreValue');
  }

  /// Award XP for surviving a hazard
  RewardEvent awardForHazardSurvival(String hazardType) {
    return _award(25, 5, 'Survived $hazardType!');
  }

  /// Core award method - applies multipliers and updates state
  RewardEvent _award(int baseXP, int basePoints, String description) {
    final xpMult = effectiveXPMultiplier;
    final ptsMult = effectivePointsMultiplier;

    final event = RewardEvent(
      description: description,
      xpAwarded: baseXP,
      pointsAwarded: basePoints,
      xpMultiplier: xpMult,
      pointsMultiplier: ptsMult,
    );

    final prevLevel = level;

    _totalXP += event.finalXP;
    _sessionXP += event.finalXP;

    if (event.finalPoints > 0) {
      _points += event.finalPoints;
      _lifetimePoints += event.finalPoints;
      _sessionPoints += event.finalPoints;
    }

    // Track event
    _recentEvents.insert(0, event);
    if (_recentEvents.length > maxRecentEvents) {
      _recentEvents.removeLast();
    }

    // Check for level up
    if (level > prevLevel) {
      _onLevelUp(prevLevel, level);
    }

    notifyListeners();
    return event;
  }

  /// Called when player levels up
  void _onLevelUp(int oldLevel, int newLevel) {
    // Award bonus points for leveling up
    final bonusPoints = newLevel * 10;
    _points += bonusPoints;
    _lifetimePoints += bonusPoints;

    _recentEvents.insert(
      0,
      RewardEvent(
        description: 'Level Up! Reached level $newLevel (+$bonusPoints pts)',
        xpAwarded: 0,
        pointsAwarded: bonusPoints,
      ),
    );
  }

  // ============================================================
  // ORE XP/POINTS TABLES
  // ============================================================

  int _xpForOre(TileType type) {
    switch (type) {
      case TileType.coal:
        return 5;
      case TileType.copper:
        return 10;
      case TileType.silver:
        return 18;
      case TileType.gold:
        return 30;
      case TileType.sapphire:
        return 50;
      case TileType.emerald:
        return 75;
      case TileType.ruby:
        return 100;
      case TileType.diamond:
        return 150;
      default:
        return 0;
    }
  }

  int _pointsForOre(TileType type) {
    switch (type) {
      case TileType.coal:
        return 1;
      case TileType.copper:
        return 2;
      case TileType.silver:
        return 3;
      case TileType.gold:
        return 5;
      case TileType.sapphire:
        return 8;
      case TileType.emerald:
        return 12;
      case TileType.ruby:
        return 18;
      case TileType.diamond:
        return 25;
      default:
        return 0;
    }
  }

  // ============================================================
  // BOOST MANAGEMENT
  // ============================================================

  /// Set XP boost multiplier (from on-chain booster)
  void setXPBoost(double multiplier) {
    _xpBoostMultiplier = multiplier.clamp(1.0, 10.0);
    notifyListeners();
  }

  /// Set points boost multiplier (from on-chain booster)
  void setPointsBoost(double multiplier) {
    _pointsBoostMultiplier = multiplier.clamp(1.0, 10.0);
    notifyListeners();
  }

  /// Set NFT permanent XP multiplier
  void setNFTXPMultiplier(double multiplier) {
    _nftXPMultiplier = multiplier.clamp(1.0, 5.0);
    notifyListeners();
  }

  /// Set NFT permanent points multiplier
  void setNFTPointsMultiplier(double multiplier) {
    _nftPointsMultiplier = multiplier.clamp(1.0, 5.0);
    notifyListeners();
  }

  /// Clear all temporary boosts (not NFT)
  void clearBoosts() {
    _xpBoostMultiplier = 1.0;
    _pointsBoostMultiplier = 1.0;
    notifyListeners();
  }

  // ============================================================
  // POINTS SPENDING
  // ============================================================

  /// Spend points (returns false if insufficient)
  bool spendPoints(int amount) {
    if (amount <= 0) return true;
    if (_points < amount) return false;
    _points -= amount;
    notifyListeners();
    return true;
  }

  /// Add points (from purchase or bonus)
  void addPoints(int amount) {
    if (amount <= 0) return;
    _points += amount;
    _lifetimePoints += amount;
    notifyListeners();
  }

  /// Check if can afford
  bool canAffordPoints(int amount) => _points >= amount;

  // ============================================================
  // SESSION MANAGEMENT
  // ============================================================

  /// Start a new mining session
  void startSession() {
    _sessionXP = 0;
    _sessionPoints = 0;
    _sessionMaxDepth = 0;
    _depthMilestonesAwarded.clear();
    _recentEvents.clear();
    notifyListeners();
  }

  /// Update session max depth
  void updateDepth(int depth) {
    if (depth > _sessionMaxDepth) {
      _sessionMaxDepth = depth;
    }
  }

  // ============================================================
  // PERSISTENCE (save/load for local storage)
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'totalXP': _totalXP,
      'points': _points,
      'lifetimePoints': _lifetimePoints,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _totalXP = json['totalXP'] as int? ?? 0;
    _points = json['points'] as int? ?? 0;
    _lifetimePoints = json['lifetimePoints'] as int? ?? 0;
    notifyListeners();
  }

  /// Restore state from server (called by StatsService on load).
  /// Only updates if server values are higher (anti-cheat).
  void restoreFromServer({
    required int xp,
    required int points,
    required int level,
  }) {
    // Take the higher value (server or local) to handle offline play
    if (xp > _totalXP) _totalXP = xp;
    if (points > _points) _points = points;
    // Level is derived from XP, no need to set separately
    notifyListeners();
    debugPrint('XPPointsSystem: restored from server '
        '(xp: $_totalXP, pts: $_points, lvl: $level)');
  }

  // ============================================================
  // RESET
  // ============================================================

  /// Reset session data (keep lifetime stats)
  void resetSession() {
    _sessionXP = 0;
    _sessionPoints = 0;
    _sessionMaxDepth = 0;
    _depthMilestonesAwarded.clear();
    _recentEvents.clear();
    notifyListeners();
  }

  /// Full reset (new player)
  void reset() {
    _totalXP = 0;
    _points = 0;
    _lifetimePoints = 0;
    _sessionXP = 0;
    _sessionPoints = 0;
    _sessionMaxDepth = 0;
    _xpBoostMultiplier = 1.0;
    _pointsBoostMultiplier = 1.0;
    _nftXPMultiplier = 1.0;
    _nftPointsMultiplier = 1.0;
    _depthMilestonesAwarded.clear();
    _recentEvents.clear();
    notifyListeners();
  }

  @override
  String toString() {
    return 'XPPoints(lvl:$level, xp:$_totalXP, pts:$_points, '
        'xpMult:${effectiveXPMultiplier}x, ptsMult:${effectivePointsMultiplier}x)';
  }
}