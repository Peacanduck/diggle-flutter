/// achievement_system.dart
/// Lifetime achievements with tiered thresholds.
///
/// Progress counters are fed by explicit record* calls from game code
/// (same touchpoints that already notify QuestSystem). Unlocks award
/// XP/points via the same callback pattern as quests/collection, and
/// persist locally (SharedPreferences) so the game works offline.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What a counter tracks.
enum AchievementStat {
  oresMined,
  maxDepth,
  cashEarned,
  levelReached,
  artifactsFound,
  blastsUsed,
  oreSales,
  deaths,
}

class AchievementDefinition {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementStat stat;
  final int threshold;
  final int xpReward;
  final int pointsReward;

  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.stat,
    required this.threshold,
    required this.xpReward,
    required this.pointsReward,
  });
}

class AchievementSystem extends ChangeNotifier {
  static const _prefsKey = 'diggle_achievements_v1';

  /// Reward callback: (xp, points, description). Wired by DiggleGame.
  void Function(int xp, int points, String description)? onAwardReward;

  /// Lifetime counters per stat.
  final Map<AchievementStat, int> _counters = {};

  /// Unlocked achievement ids.
  final Set<String> _unlocked = {};

  String? _playerId;
  String get _scopedKey => '${_prefsKey}_${_playerId ?? 'default'}';

  static const List<AchievementDefinition> catalog = [
    // ── Ores mined ──
    AchievementDefinition(id: 'ore_10', name: 'First Haul', description: 'Mine 10 ores', icon: '⛏️', stat: AchievementStat.oresMined, threshold: 10, xpReward: 50, pointsReward: 10),
    AchievementDefinition(id: 'ore_100', name: 'Ore Hound', description: 'Mine 100 ores', icon: '⛏️', stat: AchievementStat.oresMined, threshold: 100, xpReward: 200, pointsReward: 40),
    AchievementDefinition(id: 'ore_500', name: 'Vein Chaser', description: 'Mine 500 ores', icon: '⛏️', stat: AchievementStat.oresMined, threshold: 500, xpReward: 600, pointsReward: 120),
    AchievementDefinition(id: 'ore_2000', name: 'Strip Miner', description: 'Mine 2,000 ores', icon: '⛏️', stat: AchievementStat.oresMined, threshold: 2000, xpReward: 2000, pointsReward: 400),
    AchievementDefinition(id: 'ore_10000', name: 'Planet Eater', description: 'Mine 10,000 ores', icon: '🌏', stat: AchievementStat.oresMined, threshold: 10000, xpReward: 8000, pointsReward: 1500),

    // ── Depth ──
    AchievementDefinition(id: 'depth_50', name: 'Below the Roots', description: 'Reach depth 50', icon: '📏', stat: AchievementStat.maxDepth, threshold: 50, xpReward: 75, pointsReward: 15),
    AchievementDefinition(id: 'depth_120', name: 'Into the Frost', description: 'Reach the Permafrost (depth 120)', icon: '❄️', stat: AchievementStat.maxDepth, threshold: 120, xpReward: 200, pointsReward: 40),
    AchievementDefinition(id: 'depth_240', name: 'Crystal Gazer', description: 'Reach the Crystal Caverns (depth 240)', icon: '💠', stat: AchievementStat.maxDepth, threshold: 240, xpReward: 500, pointsReward: 100),
    AchievementDefinition(id: 'depth_360', name: 'Magma Diver', description: 'Reach the Magma Core (depth 360)', icon: '🌋', stat: AchievementStat.maxDepth, threshold: 360, xpReward: 1200, pointsReward: 250),
    AchievementDefinition(id: 'depth_445', name: 'Rock Bottom', description: 'Touch the world floor (depth 445)', icon: '🏆', stat: AchievementStat.maxDepth, threshold: 445, xpReward: 3000, pointsReward: 600),

    // ── Cash earned ──
    AchievementDefinition(id: 'cash_1k', name: 'Pocket Money', description: 'Earn \$1,000 lifetime', icon: '💵', stat: AchievementStat.cashEarned, threshold: 1000, xpReward: 60, pointsReward: 12),
    AchievementDefinition(id: 'cash_25k', name: 'Business Miner', description: 'Earn \$25,000 lifetime', icon: '💵', stat: AchievementStat.cashEarned, threshold: 25000, xpReward: 300, pointsReward: 60),
    AchievementDefinition(id: 'cash_250k', name: 'Ore Baron', description: 'Earn \$250,000 lifetime', icon: '💰', stat: AchievementStat.cashEarned, threshold: 250000, xpReward: 1500, pointsReward: 300),
    AchievementDefinition(id: 'cash_1m', name: 'Diggle Tycoon', description: 'Earn \$1,000,000 lifetime', icon: '🤑', stat: AchievementStat.cashEarned, threshold: 1000000, xpReward: 5000, pointsReward: 1000),

    // ── Level ──
    AchievementDefinition(id: 'level_5', name: 'Getting Serious', description: 'Reach level 5', icon: '⭐', stat: AchievementStat.levelReached, threshold: 5, xpReward: 0, pointsReward: 25),
    AchievementDefinition(id: 'level_10', name: 'Double Digits', description: 'Reach level 10', icon: '⭐', stat: AchievementStat.levelReached, threshold: 10, xpReward: 0, pointsReward: 75),
    AchievementDefinition(id: 'level_18', name: 'Deep Veteran', description: 'Reach level 18', icon: '🌟', stat: AchievementStat.levelReached, threshold: 18, xpReward: 0, pointsReward: 200),
    AchievementDefinition(id: 'level_25', name: 'Maximum Diggle', description: 'Reach level 25', icon: '👑', stat: AchievementStat.levelReached, threshold: 25, xpReward: 0, pointsReward: 1000),

    // ── Artifacts ──
    AchievementDefinition(id: 'artifact_1', name: 'Amateur Archaeologist', description: 'Find your first artifact', icon: '🏺', stat: AchievementStat.artifactsFound, threshold: 1, xpReward: 100, pointsReward: 20),
    AchievementDefinition(id: 'artifact_10', name: 'Museum Donor', description: 'Find 10 artifacts', icon: '🏛️', stat: AchievementStat.artifactsFound, threshold: 10, xpReward: 800, pointsReward: 160),
    AchievementDefinition(id: 'artifact_20', name: 'Master Curator', description: 'Complete the full collection', icon: '🏛️', stat: AchievementStat.artifactsFound, threshold: 20, xpReward: 2500, pointsReward: 500),

    // ── Blasting ──
    AchievementDefinition(id: 'blast_5', name: 'Fire in the Hole', description: 'Detonate 5 explosives', icon: '🧨', stat: AchievementStat.blastsUsed, threshold: 5, xpReward: 150, pointsReward: 30),
    AchievementDefinition(id: 'blast_50', name: 'Controlled Demolition', description: 'Detonate 50 explosives', icon: '💥', stat: AchievementStat.blastsUsed, threshold: 50, xpReward: 1000, pointsReward: 200),

    // ── Sales ──
    AchievementDefinition(id: 'sales_10', name: 'Regular Customer', description: 'Sell ore 10 times', icon: '🛒', stat: AchievementStat.oreSales, threshold: 10, xpReward: 120, pointsReward: 25),
    AchievementDefinition(id: 'sales_100', name: 'Market Mover', description: 'Sell ore 100 times', icon: '🛒', stat: AchievementStat.oreSales, threshold: 100, xpReward: 1200, pointsReward: 240),

    // ── Deaths (badge of honor) ──
    AchievementDefinition(id: 'death_1', name: 'Occupational Hazard', description: 'Lose your first drill', icon: '💀', stat: AchievementStat.deaths, threshold: 1, xpReward: 25, pointsReward: 5),
    AchievementDefinition(id: 'death_25', name: 'Never Say Die', description: 'Lose 25 drills and keep digging', icon: '💀', stat: AchievementStat.deaths, threshold: 25, xpReward: 500, pointsReward: 100),
  ];

  // ── State access ───────────────────────────────────────────────

  bool isUnlocked(String id) => _unlocked.contains(id);
  int get unlockedCount => _unlocked.length;
  int get totalCount => catalog.length;
  int counterFor(AchievementStat stat) => _counters[stat] ?? 0;

  /// Progress 0.0–1.0 toward an achievement.
  double progressFor(AchievementDefinition def) {
    if (_unlocked.contains(def.id)) return 1.0;
    final value = _counters[def.stat] ?? 0;
    return (value / def.threshold).clamp(0.0, 1.0);
  }

  // ── Recording ──────────────────────────────────────────────────

  void recordOreMined() => _increment(AchievementStat.oresMined, 1);
  void recordCashEarned(int amount) =>
      _increment(AchievementStat.cashEarned, amount);
  void recordOreSale() => _increment(AchievementStat.oreSales, 1);
  void recordBlast() => _increment(AchievementStat.blastsUsed, 1);
  void recordDeath() => _increment(AchievementStat.deaths, 1);
  void recordArtifactFound() =>
      _increment(AchievementStat.artifactsFound, 1);

  /// Max-tracked stats: only advances, cheap to call every frame.
  void recordDepth(int depth) => _setMax(AchievementStat.maxDepth, depth);
  void recordLevel(int level) => _setMax(AchievementStat.levelReached, level);

  Timer? _saveDebounce;

  void _increment(AchievementStat stat, int amount) {
    if (amount <= 0) return;
    _counters[stat] = (_counters[stat] ?? 0) + amount;
    _checkUnlocks(stat);
    _scheduleSave();
  }

  void _setMax(AchievementStat stat, int value) {
    if (value <= (_counters[stat] ?? 0)) return;
    _counters[stat] = value;
    _checkUnlocks(stat);
    _scheduleSave();
  }

  /// Debounced counter persistence (mining fires every dig).
  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(seconds: 5), _saveToPrefs);
  }

  void _checkUnlocks(AchievementStat stat) {
    final value = _counters[stat] ?? 0;
    bool changed = false;
    for (final def in catalog) {
      if (def.stat != stat) continue;
      if (_unlocked.contains(def.id)) continue;
      if (value < def.threshold) continue;
      _unlocked.add(def.id);
      changed = true;
      onAwardReward?.call(def.xpReward, def.pointsReward,
          '${def.icon} Achievement: ${def.name}!');
    }
    if (changed) {
      _saveToPrefs();
    }
    notifyListeners();
  }

  // ── Persistence ────────────────────────────────────────────────

  Future<void> initialize({String? playerId}) async {
    _playerId = playerId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scopedKey);
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _unlocked
          ..clear()
          ..addAll((data['unlocked'] as List).cast<String>());
        final counters = data['counters'] as Map<String, dynamic>;
        _counters.clear();
        for (final entry in counters.entries) {
          final stat = AchievementStat.values
              .where((s) => s.name == entry.key)
              .firstOrNull;
          if (stat != null) {
            _counters[stat] = (entry.value as num).toInt();
          }
        }
      } catch (e) {
        debugPrint('AchievementSystem: failed to load: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scopedKey,
      jsonEncode({
        'unlocked': _unlocked.toList(),
        'counters': {
          for (final entry in _counters.entries) entry.key.name: entry.value,
        },
      }),
    );
  }
}
