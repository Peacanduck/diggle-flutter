/// game_lifecycle_manager.dart
/// Coordinates Supabase auth, wallet linking, stats sync, and world saves.
///
/// This is the glue between game systems and backend services.
/// It listens for wallet connect/disconnect events and manages
/// the player's Supabase session accordingly.
///
/// Usage:
///   Created in main.dart, registered with Provider.
///   Call bootstrap() once at startup.
///   Call onGamePause() / onGameResume() from game lifecycle.

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../solana/wallet_service.dart';
import 'supabase_service.dart';
import 'stats_service.dart';
import 'world_save_service.dart';
import 'player_service.dart';

class GameLifecycleManager {
  final WalletService walletService;
  final StatsService statsService;
  final WorldSaveService worldSaveService;
  final PlayerService playerService;

  bool _bootstrapped = false;
  bool get isReady => _bootstrapped;

  GameLifecycleManager({
    required this.walletService,
    required this.statsService,
    required this.worldSaveService,
    required this.playerService,
  }) {
    // Listen for wallet changes to link/unlink
    walletService.addListener(_onWalletChanged);
  }

  // ── Bootstrap ──────────────────────────────────────────────────

  /// Call once at app startup. Signs in anonymously and loads player data.
  Future<void> bootstrap() async {
    if (_bootstrapped) return;

    try {
      if (!SupabaseService.instance.isInitialized) {
        debugPrint('GameLifecycle: Supabase not initialized, skipping bootstrap');
        return;
      }

      // Generate a stable device ID
      final deviceId = _getDeviceId();

      // Anonymous auth + create player record
      await SupabaseService.instance.ensurePlayer(deviceId);
      debugPrint('GameLifecycle: player authenticated');

      // Load stats from server
      await statsService.loadStats();
      debugPrint('GameLifecycle: stats loaded');

      // If wallet is already connected (restored session), link it
      if (walletService.isConnected && walletService.publicKey != null) {
        await _linkWallet(walletService.publicKey!);
      }

      _bootstrapped = true;
      debugPrint('GameLifecycle: bootstrap complete');
    } catch (e) {
      debugPrint('GameLifecycle: bootstrap error (game will work offline): $e');
    }
  }

  // ── Wallet Events ──────────────────────────────────────────────

  void _onWalletChanged() {
    if (walletService.isConnected && walletService.publicKey != null) {
      _linkWallet(walletService.publicKey!);
    }
  }

  Future<void> _linkWallet(String walletAddress) async {
    if (!SupabaseService.instance.isAuthenticated) return;

    try {
      await SupabaseService.instance.linkWallet(walletAddress);
      debugPrint('GameLifecycle: wallet linked $walletAddress');
    } catch (e) {
      debugPrint('GameLifecycle: wallet link error: $e');
      // WalletAlreadyLinkedException could trigger account merge UI
    }
  }

  // ── Game Lifecycle Hooks ───────────────────────────────────────

  /// Called when game session starts (player taps START MINING).
  void onGameStart() {
    statsService.startPeriodicSync();
    debugPrint('GameLifecycle: game started, sync enabled');
  }

  /// Called when game is paused (overlay, app backgrounded).
  Future<void> onGamePause() async {
    await statsService.syncToServer();
    debugPrint('GameLifecycle: game paused, stats synced');
  }

  /// Called when game resumes from pause.
  void onGameResume() {
    // Nothing special needed; periodic sync is still running
  }

  /// Called when game session ends (game over, return to menu).
  Future<void> onGameEnd() async {
    statsService.stopPeriodicSync();
    await statsService.syncToServer();
    debugPrint('GameLifecycle: game ended, final sync done');
  }

  /// Called when app goes to background (AppLifecycleState.paused).
  Future<void> onAppBackground() async {
    await statsService.syncToServer();
    debugPrint('GameLifecycle: app backgrounded, stats synced');
  }

  // ── World Save/Load ────────────────────────────────────────────

  /// Save current world state to a slot.
  Future<void> saveWorld({
    required int slot,
    required int seed,
    required Uint8List tileMapBytes,
    required Map<String, dynamic> gameSystems,
    Map<String, double>? playerPosition,
    int depthReached = 0,
    int playtimeSeconds = 0,
  }) async {
    // Sync stats first
    await statsService.syncToServer();

    // Then save world
    await worldSaveService.save(
      slot: slot,
      seed: seed,
      tileMapBytes: tileMapBytes,
      gameSystems: gameSystems,
      playerPosition: playerPosition,
      depthReached: depthReached,
      playtimeSeconds: playtimeSeconds,
    );
  }

  /// Load a saved world from a slot.
  Future<WorldSave?> loadWorld({required int slot}) async {
    final save = await worldSaveService.load(slot: slot);
    if (save != null) {
      // Reload stats from server (in case they were updated)
      await statsService.loadStats();
    }
    return save;
  }

  /// Get list of available save summaries.
  Future<List<WorldSaveSummary>> getSaveSummaries() async {
    return worldSaveService.listSaves();
  }

  // ── Device ID ──────────────────────────────────────────────────

  /// Generate a stable device identifier.
  /// In production, use a proper device ID package or store in SharedPreferences.
  String _getDeviceId() {
    // Simple approach: use a hash of platform info
    // Replace with device_info_plus or stored UUID for production
    final platformInfo = '${Platform.operatingSystem}_${Platform.localHostname}';
    return 'device_${platformInfo.hashCode.toUnsigned(32).toRadixString(16)}';
  }

  // ── Disposal ───────────────────────────────────────────────────

  void dispose() {
    walletService.removeListener(_onWalletChanged);
    statsService.dispose();
  }
}