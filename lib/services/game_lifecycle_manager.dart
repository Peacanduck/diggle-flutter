/// game_lifecycle_manager.dart
/// Coordinates Supabase auth, wallet linking, stats sync, and world saves.
///
/// This is the glue between game systems and backend services.
/// It listens for wallet connect/disconnect events and manages
/// the player's Supabase session accordingly.
///
/// Usage:
///   Created in main.dart, registered with Provider.
///   Call bootstrap() once after authentication.
///   Call reset() on sign-out so the next user can bootstrap fresh.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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

  /// Call once after authentication succeeds.
  /// Creates the player row (if needed) and loads stats.
  Future<void> bootstrap() async {
    if (_bootstrapped) return;

    try {
      if (!SupabaseService.instance.isInitialized) {
        debugPrint('GameLifecycle: Supabase not initialized, skipping bootstrap');
        return;
      }

      if (!SupabaseService.instance.isAuthenticated) {
        debugPrint('GameLifecycle: not authenticated, skipping bootstrap');
        return;
      }

      // Generate a stable device ID
      final deviceId = await _getDeviceId();

      // Create player record if it doesn't exist
      final playerId = await SupabaseService.instance.ensurePlayer(deviceId);
      debugPrint('GameLifecycle: player ensured ($playerId)');

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

  // ── Reset ──────────────────────────────────────────────────────

  /// Reset state so the next user can bootstrap fresh.
  /// Call this on sign-out before navigating to the auth screen.
  void reset() {
    _bootstrapped = false;
    statsService.stopPeriodicSync();
    debugPrint('GameLifecycle: reset for new session');
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

  static const String _deviceIdKey = 'diggle_device_id';

  /// Get or create a stable device identifier.
  /// Generated once on first launch, persisted in SharedPreferences.
  Future<String> _getDeviceId() async {
    final prefs = SharedPreferencesAsync();
    final existing = await prefs.getString(_deviceIdKey);
    if (existing != null) {
      return existing;
    }

    final deviceId = const Uuid().v4();
    await prefs.setString(_deviceIdKey, deviceId);
    debugPrint('GameLifecycle: generated new device ID: $deviceId');
    return deviceId;
  }

  // ── Disposal ───────────────────────────────────────────────────

  void dispose() {
    walletService.removeListener(_onWalletChanged);
    statsService.dispose();
  }
}