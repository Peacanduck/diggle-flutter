/// world_save_service.dart
/// World state save/load with zlib compression.
///
/// Handles serializing the tile map and all game system states
/// into compressed binary + JSON, stored in Supabase.
///
/// Usage:
///   final service = WorldSaveService();
///   await service.save(slot: 0, worldData: tiles, systems: systemsJson, ...);
///   final save = await service.load(slot: 0);
///   final saves = await service.listSaves();

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Represents a saved game world.
class WorldSave {
  final String id;
  final String playerId;
  final int slot;
  final int seed;
  final Uint8List? worldData;  // Decompressed tile map bytes
  final Map<String, double>? playerPosition;
  final int depthReached;
  final int playtimeSeconds;
  final Map<String, dynamic>? gameSystems;
  final DateTime savedAt;

  WorldSave({
    required this.id,
    required this.playerId,
    required this.slot,
    required this.seed,
    this.worldData,
    this.playerPosition,
    this.depthReached = 0,
    this.playtimeSeconds = 0,
    this.gameSystems,
    required this.savedAt,
  });

  /// Friendly label for UI.
  String get label => 'Slot ${slot + 1}';
  String get summary => 'Depth: $depthReached | ${_formatTime(playtimeSeconds)}';

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }
}

/// Summary of a save (no world data loaded).
class WorldSaveSummary {
  final String id;
  final int slot;
  final int seed;
  final int depthReached;
  final int playtimeSeconds;
  final DateTime savedAt;

  WorldSaveSummary({
    required this.id,
    required this.slot,
    required this.seed,
    required this.depthReached,
    required this.playtimeSeconds,
    required this.savedAt,
  });

  factory WorldSaveSummary.fromJson(Map<String, dynamic> json) {
    return WorldSaveSummary(
      id: json['id'] as String,
      slot: (json['slot'] as num).toInt(),
      seed: (json['seed'] as num).toInt(),
      depthReached: (json['depth_reached'] as num?)?.toInt() ?? 0,
      playtimeSeconds: (json['playtime_seconds'] as num?)?.toInt() ?? 0,
      savedAt: DateTime.parse(json['saved_at'] as String),
    );
  }

  String get label => 'Slot ${slot + 1}';
  String get summary {
    final m = playtimeSeconds ~/ 60;
    return 'Depth: $depthReached | ${m}m played';
  }
}

class WorldSaveService {
  final _supabase = SupabaseService.instance;

  static const int maxSlots = 3;

  // ── Save ───────────────────────────────────────────────────────

  /// Save the current world state to a slot (0-2).
  ///
  /// [tileMapBytes] - Raw tile map data (will be zlib-compressed).
  /// [gameSystems] - JSON-serializable map of all system states.
  /// [playerPosition] - Player's current {x, y} tile position.
  Future<void> save({
    required int slot,
    required int seed,
    required Uint8List tileMapBytes,
    required Map<String, dynamic> gameSystems,
    Map<String, double>? playerPosition,
    int depthReached = 0,
    int playtimeSeconds = 0,
  }) async {
    assert(slot >= 0 && slot < maxSlots, 'Slot must be 0-${maxSlots - 1}');
    final playerId = _supabase.playerId;
    if (playerId == null) {
      debugPrint('WorldSaveService: no player, cannot save');
      return;
    }

    try {
      // Compress tile map
      final compressed = _compress(tileMapBytes);
      debugPrint('WorldSaveService: compressed ${tileMapBytes.length}B → '
          '${compressed.length}B (${(compressed.length * 100 / tileMapBytes.length).toStringAsFixed(1)}%)');

      // Encode compressed bytes as base64 for JSONB transport
      // Supabase bytea columns accept hex or base64 via \\x prefix or decode()
      final compressedBase64 = base64Encode(compressed);

      // Upsert (insert or update by player_id + slot)
      await _supabase.client.from('world_saves').upsert(
        {
          'player_id': playerId,
          'slot': slot,
          'seed': seed,
          'world_data': compressedBase64, // Stored as text, decoded on load
          'player_position': playerPosition != null
              ? {'x': playerPosition['x'], 'y': playerPosition['y']}
              : null,
          'depth_reached': depthReached,
          'playtime_seconds': playtimeSeconds,
          'game_systems': gameSystems,
          'saved_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'player_id,slot',
      );

      debugPrint('WorldSaveService: saved to slot $slot '
          '(depth: $depthReached, ${playtimeSeconds}s)');
    } catch (e) {
      debugPrint('WorldSaveService.save error: $e');
      rethrow;
    }
  }

  // ── Load ───────────────────────────────────────────────────────

  /// Load a saved world from a slot. Returns null if no save exists.
  Future<WorldSave?> load({required int slot}) async {
    final playerId = _supabase.playerId;
    if (playerId == null) return null;

    try {
      final data = await _supabase.client
          .from('world_saves')
          .select()
          .eq('player_id', playerId)
          .eq('slot', slot)
          .maybeSingle();

      if (data == null) return null;

      // Decompress world data
      Uint8List? worldData;
      if (data['world_data'] != null) {
        final compressedBase64 = data['world_data'] as String;
        final compressed = base64Decode(compressedBase64);
        worldData = _decompress(Uint8List.fromList(compressed));
        debugPrint('WorldSaveService: decompressed ${compressed.length}B → '
            '${worldData.length}B');
      }

      // Parse player position
      Map<String, double>? playerPos;
      if (data['player_position'] != null) {
        final pos = data['player_position'] as Map<String, dynamic>;
        playerPos = {
          'x': (pos['x'] as num).toDouble(),
          'y': (pos['y'] as num).toDouble(),
        };
      }

      return WorldSave(
        id: data['id'] as String,
        playerId: playerId,
        slot: slot,
        seed: (data['seed'] as num).toInt(),
        worldData: worldData,
        playerPosition: playerPos,
        depthReached: (data['depth_reached'] as num?)?.toInt() ?? 0,
        playtimeSeconds: (data['playtime_seconds'] as num?)?.toInt() ?? 0,
        gameSystems: data['game_systems'] as Map<String, dynamic>?,
        savedAt: DateTime.parse(data['saved_at'] as String),
      );
    } catch (e) {
      debugPrint('WorldSaveService.load error: $e');
      return null;
    }
  }

  // ── List Saves ─────────────────────────────────────────────────

  /// Get summaries of all saves (without loading world data).
  Future<List<WorldSaveSummary>> listSaves() async {
    final playerId = _supabase.playerId;
    if (playerId == null) return [];

    try {
      final data = await _supabase.client
          .from('world_saves')
          .select('id, slot, seed, depth_reached, playtime_seconds, saved_at')
          .eq('player_id', playerId)
          .order('slot');

      return (data as List)
          .map((row) => WorldSaveSummary.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('WorldSaveService.listSaves error: $e');
      return [];
    }
  }

  // ── Delete ─────────────────────────────────────────────────────

  /// Delete a save from a slot.
  Future<void> deleteSave({required int slot}) async {
    final playerId = _supabase.playerId;
    if (playerId == null) return;

    await _supabase.client
        .from('world_saves')
        .delete()
        .eq('player_id', playerId)
        .eq('slot', slot);

    debugPrint('WorldSaveService: deleted slot $slot');
  }

  // ── Compression ────────────────────────────────────────────────

  Uint8List _compress(Uint8List data) {
    final codec = ZLibCodec(level: 6); // Balanced speed/ratio
    return Uint8List.fromList(codec.encode(data));
  }

  Uint8List _decompress(Uint8List data) {
    final codec = ZLibCodec();
    return Uint8List.fromList(codec.decode(data));
  }
}