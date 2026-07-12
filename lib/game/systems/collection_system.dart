/// collection_system.dart
/// Artifact collection log ("the museum").
///
/// Artifact tiles placed by the world generator resolve to a specific
/// artifact from the biome's pool when dug (deterministic per position,
/// so the same ruin always holds the same artifact). Finding all
/// artifacts in a biome set pays a completion bonus.
///
/// Local-first (SharedPreferences), same philosophy as QuestSystem:
/// fully functional offline; rewards route through the game's award
/// callback so the XPStatsBridge/ledger pattern is preserved.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../world/biome.dart';

class ArtifactDefinition {
  final String id;
  final String name;
  final String description;
  final String icon; // emoji for the collection log
  final String biomeName; // matches Biome.name

  const ArtifactDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.biomeName,
  });
}

class CollectionSystem extends ChangeNotifier {
  static const _prefsKey = 'diggle_collection_v1';

  /// Reward callback: (xp, points, description). Wired by DiggleGame to
  /// the stats bridge (or local XP system offline).
  void Function(int xp, int points, String description)? onAwardReward;

  /// Rewards
  static const int duplicatePoints = 10;
  static const int setBonusXP = 500;
  static const int setBonusPoints = 150;

  final Set<String> _found = {};
  String? _playerId;

  String get _scopedKey => '${_prefsKey}_${_playerId ?? 'default'}';

  // ── Catalog ────────────────────────────────────────────────────

  static const List<ArtifactDefinition> catalog = [
    // Topsoil — remnants of the surface world
    ArtifactDefinition(id: 'ts_fossil_fern', name: 'Fern Fossil', description: 'A perfect imprint of a prehistoric fern.', icon: '🌿', biomeName: 'Topsoil'),
    ArtifactDefinition(id: 'ts_old_boot', name: 'Prospector\'s Boot', description: 'Somebody dug here long before you.', icon: '🥾', biomeName: 'Topsoil'),
    ArtifactDefinition(id: 'ts_clay_jar', name: 'Clay Jar', description: 'Ancient storage, miraculously unbroken.', icon: '🏺', biomeName: 'Topsoil'),
    ArtifactDefinition(id: 'ts_arrowhead', name: 'Flint Arrowhead', description: 'Knapped by hands ten thousand years gone.', icon: '🗿', biomeName: 'Topsoil'),
    ArtifactDefinition(id: 'ts_coin_hoard', name: 'Coin Hoard', description: 'Corroded coins from a forgotten mint.', icon: '🪙', biomeName: 'Topsoil'),

    // Permafrost — the frozen age
    ArtifactDefinition(id: 'pf_mammoth_tusk', name: 'Mammoth Tusk', description: 'Curved ivory, cold to the touch.', icon: '🦣', biomeName: 'Permafrost'),
    ArtifactDefinition(id: 'pf_ice_lens', name: 'Ice Lens', description: 'A naturally formed lens of ancient ice.', icon: '🧊', biomeName: 'Permafrost'),
    ArtifactDefinition(id: 'pf_frozen_flower', name: 'Frozen Flower', description: 'A bloom preserved mid-blossom for millennia.', icon: '❄️', biomeName: 'Permafrost'),
    ArtifactDefinition(id: 'pf_sled_runner', name: 'Sled Runner', description: 'Part of an expedition that never returned.', icon: '🛷', biomeName: 'Permafrost'),
    ArtifactDefinition(id: 'pf_amber_insect', name: 'Amber Insect', description: 'A tiny passenger frozen in golden resin.', icon: '🐝', biomeName: 'Permafrost'),

    // Crystal Caverns — the deep strange
    ArtifactDefinition(id: 'cc_singing_geode', name: 'Singing Geode', description: 'It hums a note just below hearing.', icon: '🔮', biomeName: 'Crystal Caverns'),
    ArtifactDefinition(id: 'cc_prism_core', name: 'Prism Core', description: 'Splits lamplight into colors with no names.', icon: '💠', biomeName: 'Crystal Caverns'),
    ArtifactDefinition(id: 'cc_petrified_eye', name: 'Petrified Eye', description: 'You are certain it was watching you.', icon: '👁️', biomeName: 'Crystal Caverns'),
    ArtifactDefinition(id: 'cc_resonant_shard', name: 'Resonant Shard', description: 'Vibrates when other crystals are near.', icon: '📿', biomeName: 'Crystal Caverns'),
    ArtifactDefinition(id: 'cc_hollow_bell', name: 'Hollow Bell', description: 'A crystal bell that rings in silence.', icon: '🔔', biomeName: 'Crystal Caverns'),

    // Magma Core — relics of the burning deep
    ArtifactDefinition(id: 'mc_obsidian_blade', name: 'Obsidian Blade', description: 'Volcanic glass, sharper than any drill.', icon: '🗡️', biomeName: 'Magma Core'),
    ArtifactDefinition(id: 'mc_fire_opal', name: 'Fire Opal', description: 'A stone with a living ember inside.', icon: '🔥', biomeName: 'Magma Core'),
    ArtifactDefinition(id: 'mc_basalt_idol', name: 'Basalt Idol', description: 'Carved by something that liked the heat.', icon: '🗿', biomeName: 'Magma Core'),
    ArtifactDefinition(id: 'mc_meteor_fragment', name: 'Meteor Fragment', description: 'It fell from above and sank this deep.', icon: '☄️', biomeName: 'Magma Core'),
    ArtifactDefinition(id: 'mc_heart_of_core', name: 'Heart of the Core', description: 'Still warm. Still beating?', icon: '💎', biomeName: 'Magma Core'),
  ];

  static List<ArtifactDefinition> catalogForBiome(String biomeName) =>
      catalog.where((a) => a.biomeName == biomeName).toList();

  // ── State access ───────────────────────────────────────────────

  bool isFound(String artifactId) => _found.contains(artifactId);
  int get foundCount => _found.length;
  int get totalCount => catalog.length;

  int foundInBiome(String biomeName) =>
      catalogForBiome(biomeName).where((a) => _found.contains(a.id)).length;

  bool isSetComplete(String biomeName) {
    final set = catalogForBiome(biomeName);
    return set.isNotEmpty && set.every((a) => _found.contains(a.id));
  }

  // ── Discovery ──────────────────────────────────────────────────

  /// Resolve which artifact lives at a given dig site.
  /// Deterministic in (x, y, seed) so a ruin always holds the same relic.
  ArtifactDefinition resolveArtifact(int x, int y, int depth, int seed) {
    final biome = Biome.atDepth(depth);
    final pool = catalogForBiome(biome.name);
    final hash = (x * 73856093) ^ (y * 19349663) ^ (seed * 83492791);
    return pool[hash.abs() % pool.length];
  }

  /// Record a dig-up. Returns the artifact and whether it was new.
  /// Awards happen via [onAwardReward]:
  ///  - new artifact: awarded by the caller (DiggleGame) so the reward
  ///    can also show the artifact name in the HUD feed
  ///  - duplicate: small points consolation
  ///  - completed set: big one-time bonus
  ({ArtifactDefinition artifact, bool isNew, bool completedSet}) collect(
      int x, int y, int depth, int seed) {
    final artifact = resolveArtifact(x, y, depth, seed);

    if (_found.contains(artifact.id)) {
      onAwardReward?.call(0, duplicatePoints,
          'Duplicate ${artifact.name} (+$duplicatePoints pts)');
      return (artifact: artifact, isNew: false, completedSet: false);
    }

    _found.add(artifact.id);
    final completed = isSetComplete(artifact.biomeName);
    if (completed) {
      onAwardReward?.call(setBonusXP, setBonusPoints,
          '${artifact.biomeName} collection complete!');
    }
    _saveToPrefs();
    notifyListeners();
    return (artifact: artifact, isNew: true, completedSet: completed);
  }

  // ── Persistence ────────────────────────────────────────────────

  Future<void> initialize({String? playerId}) async {
    _playerId = playerId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scopedKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List).cast<String>();
        _found
          ..clear()
          ..addAll(list);
      } catch (e) {
        debugPrint('CollectionSystem: failed to load: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scopedKey, jsonEncode(_found.toList()));
  }
}
