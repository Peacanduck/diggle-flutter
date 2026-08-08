/// collection_overlay.dart
/// The museum: artifact collection log grouped by biome, plus the
/// achievements/records tab (lifetime milestones).
///
/// The login streak lives on the Account screen, not here — it has
/// nothing to do with the artifact collection.
///
/// Found artifacts show icon + name + description; unfound ones show a
/// silhouetted "?" card. Completing a biome set is celebrated with a
/// gold border and the set bonus note.

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'content_l10n.dart';
import '../game/systems/achievement_system.dart';
import '../game/systems/collection_system.dart';
import '../game/world/biome.dart';

class CollectionOverlay extends StatelessWidget {
  final CollectionSystem collectionSystem;
  final AchievementSystem achievementSystem;
  final VoidCallback onClose;

  const CollectionOverlay({
    super.key,
    required this.collectionSystem,
    required this.achievementSystem,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AnimatedBuilder(
        animation: Listenable.merge([collectionSystem, achievementSystem]),
        builder: (context, _) {
          final l10n = AppLocalizations.of(context)!;
          return Container(
            color: Colors.black.withOpacity(0.88),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(l10n),
                  TabBar(
                    indicatorColor: Colors.amber,
                    labelColor: Colors.amber,
                    unselectedLabelColor: Colors.white54,
                    tabs: [
                      Tab(text: l10n.museumArtifactsTab),
                      Tab(text: l10n.museumRecordsTab),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            for (final biome in Biome.strata)
                              _buildBiomeSection(l10n, biome.name),
                          ],
                        ),
                        _buildRecordsTab(l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          const Text('🏛️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            l10n.museumTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Text(
            '${collectionSystem.foundCount}/${collectionSystem.totalCount}',
            style: TextStyle(
              color: Colors.amber.shade300,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsTab(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              l10n.achievementsTab,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${achievementSystem.unlockedCount}/${achievementSystem.totalCount}',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final def in AchievementSystem.catalog)
          _buildAchievementRow(l10n, def),
      ],
    );
  }

  Widget _buildAchievementRow(
      AppLocalizations l10n, AchievementDefinition def) {
    final unlocked = achievementSystem.isUnlocked(def.id);
    final progress = achievementSystem.progressFor(def);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: unlocked ? Colors.indigo.shade900 : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: unlocked ? Colors.amber.shade700 : Colors.grey.shade800,
        ),
      ),
      child: Row(
        children: [
          Text(def.icon,
              style: TextStyle(
                  fontSize: 22,
                  color: unlocked ? null : Colors.grey.shade700)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedAchievementName(l10n, def.id, def.name),
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  localizedAchievementDescription(
                      l10n, def.id, def.description),
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11),
                ),
                if (!unlocked) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation(
                          Colors.amber.shade700),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (def.xpReward > 0)
                Text('+${def.xpReward} XP',
                    style: TextStyle(
                        color: Colors.cyan.shade200, fontSize: 10)),
              if (def.pointsReward > 0)
                Text('+${def.pointsReward} pts',
                    style: TextStyle(
                        color: Colors.amber.shade200, fontSize: 10)),
              if (unlocked)
                const Text('✓',
                    style: TextStyle(color: Colors.green, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiomeSection(AppLocalizations l10n, String biomeName) {
    final artifacts = CollectionSystem.catalogForBiome(biomeName);
    if (artifacts.isEmpty) return const SizedBox.shrink();
    final complete = collectionSystem.isSetComplete(biomeName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                // Each locale's arb value carries its own casing, so the
                // header renders it as-is; the fallback is upper-cased to
                // match for a biome we have no key for yet.
                localizedBiomeName(
                    l10n, biomeName, biomeName.toUpperCase()),
                style: TextStyle(
                  color: complete ? Colors.amber : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${collectionSystem.foundInBiome(biomeName)}/${artifacts.length}',
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
              if (complete) ...[
                const SizedBox(width: 6),
                const Text('✨', style: TextStyle(fontSize: 14)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final artifact in artifacts)
                _buildArtifactCard(l10n, artifact),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtifactCard(
      AppLocalizations l10n, ArtifactDefinition artifact) {
    final found = collectionSystem.isFound(artifact.id);

    return Container(
      width: 105,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: found ? Colors.indigo.shade900 : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: found ? Colors.amber.shade700 : Colors.grey.shade800,
          width: found ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            found ? artifact.icon : '❓',
            style: TextStyle(
              fontSize: 28,
              color: found ? null : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            found
                ? localizedArtifactName(l10n, artifact.id, artifact.name)
                : '???',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: found ? Colors.white : Colors.white30,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (found) ...[
            const SizedBox(height: 3),
            Text(
              localizedArtifactDescription(
                  l10n, artifact.id, artifact.description),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
