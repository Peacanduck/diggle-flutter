/// leaderboard_screen.dart
/// Global + weekly leaderboards.
///
/// Tabs: Depth (deepest ever), Points (lifetime earned), and This Week
/// (weekly challenge standings). Data comes from the leaderboard views
/// in Supabase; flagged players never appear.

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../game/systems/quest_system.dart' show QuestSystem;
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final LeaderboardService service;

  const LeaderboardScreen({super.key, required this.service});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LeaderboardEntry>? _byDepth;
  List<LeaderboardEntry>? _byPoints;
  List<WeeklyScoreEntry>? _weekly;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final weekKey = QuestSystem.isoWeekKey(DateTime.now().toUtc());
    final results = await Future.wait([
      widget.service.topByDepth(),
      widget.service.topByPoints(),
      widget.service.weeklyTop(weekKey: weekKey),
    ]);
    if (!mounted) return;
    setState(() {
      _byDepth = results[0] as List<LeaderboardEntry>;
      _byPoints = results[1] as List<LeaderboardEntry>;
      _weekly = results[2] as List<WeeklyScoreEntry>;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text(l10n.leaderboardHeading,
            style: const TextStyle(letterSpacing: 2, fontSize: 18)),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'DEPTH'),
            Tab(text: 'POINTS'),
            Tab(text: 'THIS WEEK'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGlobalList(
                  _byDepth ?? [],
                  (e) => '${e.maxDepth} m',
                ),
                _buildGlobalList(
                  _byPoints ?? [],
                  (e) => '${e.totalPointsEarned} pts',
                ),
                _buildWeeklyList(_weekly ?? []),
              ],
            ),
    );
  }

  Widget _buildGlobalList(
      List<LeaderboardEntry> entries, String Function(LeaderboardEntry) value) {
    if (entries.isEmpty) return _buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final badge = e.prestigeLevel > 0
            ? ' ${'⭐' * e.prestigeLevel.clamp(1, 5)}'
            : '';
        return _buildRow(i, '${e.displayName}$badge', value(e));
      },
    );
  }

  Widget _buildWeeklyList(List<WeeklyScoreEntry> entries) {
    if (entries.isEmpty) return _buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return _buildRow(i, e.displayName, '${e.depth} m');
      },
    );
  }

  Widget _buildRow(int index, String name, String value) {
    final medal = switch (index) {
      0 => '🥇',
      1 => '🥈',
      2 => '🥉',
      _ => '${index + 1}.',
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: index < 3 ? Colors.indigo.shade900 : Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: index < 3
            ? Border.all(color: Colors.amber.shade700, width: 1)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(medal,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Text(value,
              style: TextStyle(
                  color: Colors.amber.shade300,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.leaderboardEmpty,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white38),
      ),
    );
  }
}
