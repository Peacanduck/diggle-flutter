/// quest_system.dart
/// Manages daily and social quests with progress tracking and rewards.
///
/// Daily quests reset every 24 hours (UTC midnight).
/// Social quests are one-time completions verified client-side.
///
/// Quest progress is tracked locally and synced to Supabase.
/// Rewards are XP and points, awarded through XPStatsBridge.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// QUEST DEFINITIONS
// ============================================================

enum QuestCategory { daily, social }

enum QuestType {
  // Daily quests
  mineOre,
  reachDepth,
  sellOreValue,
  repairDamage,
  useItems,
  collectSpecificOre,

  // Social quests
  followTwitter,
  joinDiscord,
  postTweet,
}

/// Static quest template — defines what a quest looks like.
class QuestDefinition {
  final String id;
  final QuestType type;
  final QuestCategory category;
  final String titleKey; // l10n key
  final String descriptionKey; // l10n key
  final String icon;
  final int target; // e.g. mine 10 ore
  final int xpReward;
  final int pointsReward;
  final String? url; // For social quests — opens external link

  const QuestDefinition({
    required this.id,
    required this.type,
    required this.category,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.target,
    required this.xpReward,
    required this.pointsReward,
    this.url,
  });
}

/// Runtime quest state — tracks progress for a specific quest instance.
class QuestState {
  final QuestDefinition definition;
  int progress;
  bool completed;
  bool rewardClaimed;
  DateTime? completedAt;

  QuestState({
    required this.definition,
    this.progress = 0,
    this.completed = false,
    this.rewardClaimed = false,
    this.completedAt,
  });

  double get progressFraction =>
      (progress / definition.target).clamp(0.0, 1.0);

  bool get isReadyToClaim => completed && !rewardClaimed;

  Map<String, dynamic> toJson() => {
    'quest_id': definition.id,
    'progress': progress,
    'completed': completed,
    'reward_claimed': rewardClaimed,
    'completed_at': completedAt?.toIso8601String(),
  };

  factory QuestState.fromJson(
      Map<String, dynamic> json, QuestDefinition def) {
    return QuestState(
      definition: def,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
      rewardClaimed: json['reward_claimed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }
}

// ============================================================
// QUEST CATALOG
// ============================================================

class QuestCatalog {
  /// Daily quest pool — a subset is picked each day.
  static const List<QuestDefinition> dailyPool = [
    QuestDefinition(
      id: 'daily_mine_10',
      type: QuestType.mineOre,
      category: QuestCategory.daily,
      titleKey: 'questMineOreTitle',
      descriptionKey: 'questMineOreDesc',
      icon: '⛏️',
      target: 10,
      xpReward: 50,
      pointsReward: 10,
    ),
    QuestDefinition(
      id: 'daily_mine_25',
      type: QuestType.mineOre,
      category: QuestCategory.daily,
      titleKey: 'questMineOreLargeTitle',
      descriptionKey: 'questMineOreLargeDesc',
      icon: '⛏️',
      target: 25,
      xpReward: 120,
      pointsReward: 25,
    ),
    QuestDefinition(
      id: 'daily_depth_50',
      type: QuestType.reachDepth,
      category: QuestCategory.daily,
      titleKey: 'questReachDepthTitle',
      descriptionKey: 'questReachDepthDesc',
      icon: '📏',
      target: 50,
      xpReward: 75,
      pointsReward: 15,
    ),
    QuestDefinition(
      id: 'daily_depth_150',
      type: QuestType.reachDepth,
      category: QuestCategory.daily,
      titleKey: 'questReachDepthDeepTitle',
      descriptionKey: 'questReachDepthDeepDesc',
      icon: '📏',
      target: 150,
      xpReward: 200,
      pointsReward: 40,
    ),
    QuestDefinition(
      id: 'daily_sell_500',
      type: QuestType.sellOreValue,
      category: QuestCategory.daily,
      titleKey: 'questSellOreTitle',
      descriptionKey: 'questSellOreDesc',
      icon: '💰',
      target: 500,
      xpReward: 80,
      pointsReward: 20,
    ),
    QuestDefinition(
      id: 'daily_sell_2000',
      type: QuestType.sellOreValue,
      category: QuestCategory.daily,
      titleKey: 'questSellOreLargeTitle',
      descriptionKey: 'questSellOreLargeDesc',
      icon: '💰',
      target: 2000,
      xpReward: 200,
      pointsReward: 50,
    ),
    QuestDefinition(
      id: 'daily_repair_50',
      type: QuestType.repairDamage,
      category: QuestCategory.daily,
      titleKey: 'questRepairTitle',
      descriptionKey: 'questRepairDesc',
      icon: '🔧',
      target: 50,
      xpReward: 60,
      pointsReward: 12,
    ),
    QuestDefinition(
      id: 'daily_use_items_3',
      type: QuestType.useItems,
      category: QuestCategory.daily,
      titleKey: 'questUseItemsTitle',
      descriptionKey: 'questUseItemsDesc',
      icon: '🎒',
      target: 3,
      xpReward: 40,
      pointsReward: 8,
    ),
  ];

  /// Social quests — one-time, never reset.
  static const List<QuestDefinition> socialQuests = [
    QuestDefinition(
      id: 'social_follow_twitter',
      type: QuestType.followTwitter,
      category: QuestCategory.social,
      titleKey: 'questFollowTwitterTitle',
      descriptionKey: 'questFollowTwitterDesc',
      icon: '🐦',
      target: 1,
      xpReward: 100,
      pointsReward: 50,
      url: 'https://x.com/DiggleOnSol',
    ),
    QuestDefinition(
      id: 'social_join_discord',
      type: QuestType.joinDiscord,
      category: QuestCategory.social,
      titleKey: 'questJoinDiscordTitle',
      descriptionKey: 'questJoinDiscordDesc',
      icon: '💬',
      target: 1,
      xpReward: 100,
      pointsReward: 50,
      url: 'https://discord.gg/QH4uUfK2wR',
    ),
    QuestDefinition(
      id: 'social_post_tweet',
      type: QuestType.postTweet,
      category: QuestCategory.social,
      titleKey: 'questPostTweetTitle',
      descriptionKey: 'questPostTweetDesc',
      icon: '📢',
      target: 1,
      xpReward: 150,
      pointsReward: 75,
      url:
      'https://x.com/intent/tweet?text=Playing%20Diggle%20%E2%9B%8F%EF%B8%8F%20Mine%20deep%2C%20earn%20rewards!%20%40DiggleOnSol',
    ),
  ];

  /// Number of daily quests to assign each day.
  static const int dailyQuestCount = 3;

  /// Look up a definition by ID.
  static QuestDefinition? getById(String id) {
    for (final q in dailyPool) {
      if (q.id == id) return q;
    }
    for (final q in socialQuests) {
      if (q.id == id) return q;
    }
    return null;
  }
}

// ============================================================
// QUEST SYSTEM
// ============================================================

class QuestSystem extends ChangeNotifier {
  static const String _prefsKey = 'diggle_quests';
  static const String _dailyDateKey = 'diggle_quests_daily_date';

  /// Currently active daily quests.
  final List<QuestState> _dailyQuests = [];

  /// Social quests (persistent).
  final List<QuestState> _socialQuests = [];

  /// Callback to award rewards (set by bridge or game).
  void Function(int xp, int points, String source)? onAwardReward;

  // ============================================================
  // GETTERS
  // ============================================================

  List<QuestState> get dailyQuests => List.unmodifiable(_dailyQuests);
  List<QuestState> get socialQuests => List.unmodifiable(_socialQuests);
  List<QuestState> get allQuests => [..._dailyQuests, ..._socialQuests];

  int get completedDailyCount =>
      _dailyQuests.where((q) => q.completed).length;
  int get totalDailyCount => _dailyQuests.length;

  int get completedSocialCount =>
      _socialQuests.where((q) => q.completed).length;
  int get totalSocialCount => _socialQuests.length;

  /// Whether there are unclaimed rewards.
  bool get hasUnclaimedRewards =>
      allQuests.any((q) => q.isReadyToClaim);

  /// Time until daily reset (next UTC midnight).
  Duration get timeUntilDailyReset {
    final now = DateTime.now().toUtc();
    final nextMidnight = DateTime.utc(now.year, now.month, now.day + 1);
    return nextMidnight.difference(now);
  }

  String get dailyResetDisplay {
    final rem = timeUntilDailyReset;
    return '${rem.inHours}h ${rem.inMinutes % 60}m';
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Load quest state from local storage. Call at game start.
  Future<void> initialize() async {
    await _loadFromPrefs();
    _checkDailyReset();
    _ensureSocialQuests();
    notifyListeners();
  }

  void _checkDailyReset() {
    final todayStr = _todayKey();

    // Check if we need to assign new daily quests
    final needsReset = _dailyQuests.isEmpty ||
        _lastDailyDate() != todayStr;

    if (needsReset) {
      _assignDailyQuests(todayStr);
    }
  }

  void _assignDailyQuests(String dateKey) {
    _dailyQuests.clear();

    // Deterministic selection based on date so all players get same quests
    final seed = dateKey.hashCode;
    final indices = <int>[];
    final pool = QuestCatalog.dailyPool;
    var hash = seed;

    while (indices.length < QuestCatalog.dailyQuestCount &&
        indices.length < pool.length) {
      hash = (hash * 1103515245 + 12345) & 0x7fffffff;
      final idx = hash % pool.length;
      if (!indices.contains(idx)) {
        indices.add(idx);
      }
    }

    for (final idx in indices) {
      _dailyQuests.add(QuestState(definition: pool[idx]));
    }

    _saveDailyDate(dateKey);
    _saveToPrefs();
    debugPrint('QuestSystem: assigned ${_dailyQuests.length} daily quests for $dateKey');
  }

  void _ensureSocialQuests() {
    // Add any social quests not yet tracked
    for (final def in QuestCatalog.socialQuests) {
      if (!_socialQuests.any((q) => q.definition.id == def.id)) {
        _socialQuests.add(QuestState(definition: def));
      }
    }
  }

  // ============================================================
  // PROGRESS TRACKING
  // ============================================================

  /// Called when player mines an ore tile.
  void onOreMined() {
    _incrementDaily(QuestType.mineOre, 1);
  }

  /// Called when player reaches a new depth.
  void onDepthReached(int depth) {
    for (final quest in _dailyQuests) {
      if (quest.definition.type == QuestType.reachDepth && !quest.completed) {
        if (depth >= quest.definition.target) {
          quest.progress = quest.definition.target;
          quest.completed = true;
          quest.completedAt = DateTime.now();
        } else if (depth > quest.progress) {
          quest.progress = depth;
        }
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  /// Called when player sells ore.
  void onOreSold(int cashEarned) {
    _incrementDaily(QuestType.sellOreValue, cashEarned);
  }

  /// Called when player repairs hull (amount of HP repaired).
  void onHullRepaired(int amountRepaired) {
    _incrementDaily(QuestType.repairDamage, amountRepaired);
  }

  /// Called when player uses an item.
  void onItemUsed() {
    _incrementDaily(QuestType.useItems, 1);
  }

  /// Called when a social quest action is performed.
  void completeSocialQuest(String questId) {
    final quest = _socialQuests.firstWhere(
          (q) => q.definition.id == questId,
      orElse: () => QuestState(
        definition: QuestCatalog.socialQuests.first,
      ),
    );

    if (quest.completed) return;

    quest.progress = quest.definition.target;
    quest.completed = true;
    quest.completedAt = DateTime.now();
    _saveToPrefs();
    notifyListeners();
  }

  void _incrementDaily(QuestType type, int amount) {
    bool changed = false;
    for (final quest in _dailyQuests) {
      if (quest.definition.type == type && !quest.completed) {
        quest.progress += amount;
        if (quest.progress >= quest.definition.target) {
          quest.progress = quest.definition.target;
          quest.completed = true;
          quest.completedAt = DateTime.now();
        }
        changed = true;
      }
    }
    if (changed) {
      _saveToPrefs();
      notifyListeners();
    }
  }

  // ============================================================
  // REWARD CLAIMING
  // ============================================================

  /// Claim reward for a completed quest. Returns true if successful.
  bool claimReward(String questId) {
    final quest = allQuests.firstWhere(
          (q) => q.definition.id == questId,
      orElse: () => QuestState(
        definition: QuestCatalog.dailyPool.first,
      ),
    );

    if (!quest.isReadyToClaim) return false;

    quest.rewardClaimed = true;

    // Award via callback
    onAwardReward?.call(
      quest.definition.xpReward,
      quest.definition.pointsReward,
      'quest_${quest.definition.id}',
    );

    _saveToPrefs();
    notifyListeners();
    return true;
  }

  // ============================================================
  // PERSISTENCE (SharedPreferences)
  // ============================================================

  String _todayKey() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String? _lastDailyDate() {
    // Stored in _savedDailyDate, loaded from prefs
    return _savedDailyDate;
  }

  String? _savedDailyDate;

  Future<void> _saveDailyDate(String dateKey) async {
    _savedDailyDate = dateKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dailyDateKey, dateKey);
    } catch (e) {
      debugPrint('QuestSystem: failed to save daily date: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final data = {
        'daily': _dailyQuests.map((q) => q.toJson()).toList(),
        'social': _socialQuests.map((q) => q.toJson()).toList(),
      };

      await prefs.setString(_prefsKey, jsonEncode(data));
    } catch (e) {
      debugPrint('QuestSystem: failed to save: $e');
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load daily date
      _savedDailyDate = prefs.getString(_dailyDateKey);

      // Load quest state
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;

      final data = jsonDecode(raw) as Map<String, dynamic>;

      // Restore daily quests
      if (data.containsKey('daily')) {
        final dailyList = data['daily'] as List;
        _dailyQuests.clear();
        for (final item in dailyList) {
          final json = item as Map<String, dynamic>;
          final questId = json['quest_id'] as String?;
          if (questId == null) continue;
          final def = QuestCatalog.getById(questId);
          if (def != null) {
            _dailyQuests.add(QuestState.fromJson(json, def));
          }
        }
      }

      // Restore social quests
      if (data.containsKey('social')) {
        final socialList = data['social'] as List;
        _socialQuests.clear();
        for (final item in socialList) {
          final json = item as Map<String, dynamic>;
          final questId = json['quest_id'] as String?;
          if (questId == null) continue;
          final def = QuestCatalog.getById(questId);
          if (def != null) {
            _socialQuests.add(QuestState.fromJson(json, def));
          }
        }
      }

      debugPrint('QuestSystem: loaded ${_dailyQuests.length} daily, '
          '${_socialQuests.length} social quests');
    } catch (e) {
      debugPrint('QuestSystem: failed to load: $e');
    }
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    _dailyQuests.clear();
    // Don't reset social quests — they're permanent
    _checkDailyReset();
    _ensureSocialQuests();
    notifyListeners();
  }

  /// Full reset including social quests (for testing/new player).
  void fullReset() {
    _dailyQuests.clear();
    _socialQuests.clear();
    _savedDailyDate = null;
    _checkDailyReset();
    _ensureSocialQuests();
    _saveToPrefs();
    notifyListeners();
  }
}