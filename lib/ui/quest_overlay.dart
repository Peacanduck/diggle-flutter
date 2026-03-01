/// quest_overlay.dart
/// Quest screen overlay showing daily and social quests.
/// All user-facing strings localized via AppLocalizations.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../game/systems/quest_system.dart';

class QuestOverlay extends StatefulWidget {
  final QuestSystem questSystem;
  final VoidCallback onClose;

  const QuestOverlay({
    super.key,
    required this.questSystem,
    required this.onClose,
  });

  @override
  State<QuestOverlay> createState() => _QuestOverlayState();
}

class _QuestOverlayState extends State<QuestOverlay>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tweetUrlController = TextEditingController();

  /// Track which quest is currently being claimed (for loading state).
  String? _claimingQuestId;

  /// Whether the Discord OAuth flow is in progress.
  bool _discordVerifying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tweetUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            _buildTabBar(l10n),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.questSystem,
                builder: (context, _) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDailyTab(l10n),
                      _buildSocialTab(l10n),
                    ],
                  );
                },
              ),
            ),
            _buildCloseButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        border: Border(
          bottom: BorderSide(color: Colors.indigo.shade400, width: 2),
        ),
      ),
      child: Row(
        children: [
          const Text('📋', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.questsTitle,
                    style: TextStyle(
                        color: Colors.indigo.shade200,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                Text(l10n.questsSubtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11)),
              ],
            ),
          ),
          // Daily reset timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: Colors.amber.shade300, size: 14),
                const SizedBox(width: 4),
                Text(
                  widget.questSystem.dailyResetDisplay,
                  style: TextStyle(
                      color: Colors.amber.shade300,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    return Container(
      color: Colors.grey.shade900,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.indigo,
        labelColor: Colors.indigo.shade200,
        unselectedLabelColor: Colors.white54,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📅', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(l10n.questsDailyTab),
                const SizedBox(width: 6),
                _buildCountBadge(
                  widget.questSystem.completedDailyCount,
                  widget.questSystem.totalDailyCount,
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(l10n.questsSocialTab),
                const SizedBox(width: 6),
                _buildCountBadge(
                  widget.questSystem.completedSocialCount,
                  widget.questSystem.totalSocialCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(int completed, int total) {
    final allDone = completed >= total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: allDone
            ? Colors.green.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$completed/$total',
        style: TextStyle(
          color: allDone ? Colors.green : Colors.white54,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDailyTab(AppLocalizations l10n) {
    final quests = widget.questSystem.dailyQuests;

    if (quests.isEmpty) {
      return Center(
        child: Text(l10n.questsNoDailyQuests,
            style: TextStyle(color: Colors.white.withOpacity(0.4))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: quests.length,
      itemBuilder: (context, index) => _buildQuestCard(l10n, quests[index]),
    );
  }

  Widget _buildSocialTab(AppLocalizations l10n) {
    final quests = widget.questSystem.socialQuests;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.indigo.shade900.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.indigo.shade800),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  color: Colors.indigo.shade300, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.questsSocialInfo,
                  style: TextStyle(
                      color: Colors.indigo.shade300, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        ...quests.map((q) => _buildSocialQuestCard(l10n, q)),
      ],
    );
  }

  Widget _buildQuestCard(AppLocalizations l10n, QuestState quest) {
    final def = quest.definition;
    final isComplete = quest.completed;
    final canClaim = quest.isReadyToClaim;
    final isClaiming = _claimingQuestId == def.id;

    final title = _getQuestTitle(l10n, def);
    final description = _getQuestDescription(l10n, def);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isComplete
            ? Colors.green.shade900.withOpacity(0.2)
            : Colors.grey.shade900.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canClaim
              ? Colors.amber.shade600
              : isComplete
              ? Colors.green.shade700
              : Colors.grey.shade700,
          width: canClaim ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(def.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: isComplete ? Colors.green : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(description,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12)),
                  ],
                ),
              ),
              _buildRewardBadge(def),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: quest.progressFraction,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isComplete ? Colors.green : Colors.indigo,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${quest.progress}/${def.target}',
                style: TextStyle(
                    color: isComplete ? Colors.green : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (canClaim) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isClaiming ? null : () => _claimReward(def.id),
                icon: isClaiming
                    ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.card_giftcard, size: 18),
                label: Text(isClaiming ? '...' : l10n.questsClaim),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ] else if (quest.rewardClaimed) ...[
            const SizedBox(height: 6),
            Center(
              child: Text(l10n.questsClaimed,
                  style: TextStyle(
                      color: Colors.green.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialQuestCard(AppLocalizations l10n, QuestState quest) {
    final def = quest.definition;
    final isComplete = quest.completed;
    final canClaim = quest.isReadyToClaim;
    final isClaiming = _claimingQuestId == def.id;
    final title = _getQuestTitle(l10n, def);
    final description = _getQuestDescription(l10n, def);
    final isValidated = def.requiresValidation;
    final isDiscord = def.type == QuestType.joinDiscord;
    final isTweet = def.type == QuestType.postTweet;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isComplete
            ? Colors.green.shade900.withOpacity(0.2)
            : Colors.grey.shade900.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canClaim
              ? Colors.amber.shade600
              : isComplete
              ? Colors.green.shade700
              : Colors.purple.shade800,
          width: canClaim ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(def.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: isComplete ? Colors.green : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(description,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12)),
                    const SizedBox(height: 4),
                    _buildRewardBadge(def),
                  ],
                ),
              ),
              // Action button area for completed/claimable/trust-based
              if (quest.rewardClaimed)
                const Icon(Icons.check_circle, color: Colors.green, size: 28)
              else if (canClaim)
                ElevatedButton(
                  onPressed: isClaiming ? null : () => _claimReward(def.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  child: isClaiming
                      ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                      : Text(l10n.questsClaim,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              else if (!isValidated && !isComplete)
                // Trust-based: single GO button
                  ElevatedButton.icon(
                    onPressed: () => _launchSocialQuest(def),
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: Text(l10n.questsGo,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
            ],
          ),

          // ── Discord OAuth verification flow ──
          if (isDiscord && isValidated && !isComplete) ...[
            const SizedBox(height: 12),
            // Step 1: Join server link
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(def.url!),
                icon: const Text('💬', style: TextStyle(fontSize: 14)),
                label: const Text('Join Discord Server',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5865F2), // Discord blurple
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Step 2: Verify membership via OAuth
            if (_discordVerifying) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Checking membership...',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _verifyDiscord(quest),
                  icon: const Icon(Icons.verified_user, size: 16),
                  label: const Text('Verify Membership',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5865F2),
                    side: const BorderSide(color: Color(0xFF5865F2)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (quest.validationError != null) ...[
                const SizedBox(height: 4),
                Text(
                  quest.validationError!,
                  style: TextStyle(color: Colors.red.shade300, fontSize: 11),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Join the server first, then tap Verify to confirm with Discord',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 11),
              ),
            ],
          ],

          // ── Tweet verification flow ──
          if (isTweet && isValidated && !isComplete) ...[
            const SizedBox(height: 12),
            // Step 1: Post button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(def.url!),
                icon: const Text('🐦', style: TextStyle(fontSize: 14)),
                label: const Text('Post on X',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Step 2: Paste URL + verify
            if (quest.validationPending) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Verifying...',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tweetUrlController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Paste your tweet URL here',
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3), fontSize: 13),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        errorText: quest.validationError,
                        errorStyle: TextStyle(
                            color: Colors.red.shade300, fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _verifyTweet(quest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    child: const Text('Verify',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Post the tweet above, then paste the URL to verify',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 11),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRewardBadge(QuestDefinition def) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.blue.shade900.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '+${def.xpReward} XP',
            style: TextStyle(
                color: Colors.blue.shade300,
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.purple.shade900.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '+${def.pointsReward} 💎',
            style: TextStyle(
                color: Colors.purple.shade300,
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: ElevatedButton.icon(
        onPressed: widget.onClose,
        icon: const Icon(Icons.arrow_back),
        label: Text(l10n.questsClose),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────

  Future<void> _claimReward(String questId) async {
    setState(() => _claimingQuestId = questId);
    try {
      await widget.questSystem.claimReward(questId);
    } finally {
      if (mounted) setState(() => _claimingQuestId = null);
    }
  }

  Future<void> _launchSocialQuest(QuestDefinition def) async {
    if (def.url == null) return;

    final uri = Uri.parse(def.url!);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Mark as complete after launching (trust-based only)
      widget.questSystem.completeSocialQuest(def.id);
    } catch (e) {
      debugPrint('QuestOverlay: failed to launch URL: $e');
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('QuestOverlay: failed to launch URL: $e');
    }
  }

  Future<void> _verifyTweet(QuestState quest) async {
    final url = _tweetUrlController.text.trim();
    if (url.isEmpty) return;

    final result = await widget.questSystem.submitSocialProof(
      questId: quest.definition.id,
      tweetUrl: url,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
      if (result.success) {
        _tweetUrlController.clear();
      }
    }
  }

  Future<void> _verifyDiscord(QuestState quest) async {
    // Step 1: Get the OAuth URL from the server
    setState(() => _discordVerifying = true);

    final authUrl = await widget.questSystem.getDiscordAuthUrl();

    if (authUrl == null) {
      if (mounted) {
        setState(() => _discordVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Discord verification not available. Try again later.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return;
    }

    // Step 2: Open Discord OAuth in browser
    try {
      await launchUrl(Uri.parse(authUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        setState(() => _discordVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open Discord. Please try again.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return;
    }

    // Step 3: Wait for user to return, then poll for completion.
    // We poll a few times with delays since the user needs time to
    // authorize in the browser and for the Edge Function to process.
    await Future.delayed(const Duration(seconds: 3));

    bool verified = false;
    for (int attempt = 0; attempt < 10; attempt++) {
      if (!mounted) return;

      verified = await widget.questSystem.checkDiscordQuestCompleted();
      if (verified) break;

      // Wait before next check
      await Future.delayed(const Duration(seconds: 2));
    }

    if (!mounted) return;

    setState(() => _discordVerifying = false);

    if (verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Discord membership verified! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Could not verify membership. Make sure you joined the server and authorized Discord.'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ── Localization helpers ─────────────────────────────────────

  String _getQuestTitle(AppLocalizations l10n, QuestDefinition def) {
    switch (def.type) {
      case QuestType.mineOre:
        return l10n.questMineOreTitle(def.target);
      case QuestType.reachDepth:
        return l10n.questReachDepthTitle(def.target);
      case QuestType.sellOreValue:
        return l10n.questSellOreTitle(def.target);
      case QuestType.repairDamage:
        return l10n.questRepairTitle(def.target);
      case QuestType.useItems:
        return l10n.questUseItemsTitle(def.target);
      case QuestType.collectSpecificOre:
        return l10n.questMineOreTitle(def.target);
      case QuestType.followTwitter:
        return l10n.questFollowTwitterTitle;
      case QuestType.joinDiscord:
        return l10n.questJoinDiscordTitle;
      case QuestType.postTweet:
        return l10n.questPostTweetTitle;
    }
  }

  String _getQuestDescription(AppLocalizations l10n, QuestDefinition def) {
    switch (def.type) {
      case QuestType.mineOre:
        return l10n.questMineOreDesc(def.target);
      case QuestType.reachDepth:
        return l10n.questReachDepthDesc(def.target);
      case QuestType.sellOreValue:
        return l10n.questSellOreDesc(def.target);
      case QuestType.repairDamage:
        return l10n.questRepairDesc(def.target);
      case QuestType.useItems:
        return l10n.questUseItemsDesc(def.target);
      case QuestType.collectSpecificOre:
        return l10n.questMineOreDesc(def.target);
      case QuestType.followTwitter:
        return l10n.questFollowTwitterDesc;
      case QuestType.joinDiscord:
        return l10n.questJoinDiscordDesc;
      case QuestType.postTweet:
        return l10n.questPostTweetDesc;
    }
  }
}