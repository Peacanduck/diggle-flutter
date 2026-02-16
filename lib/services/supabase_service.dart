/// supabase_service.dart
/// Core Supabase client initialization, anonymous auth, and wallet linking.
///
/// Usage:
///   await SupabaseService.instance.initialize();
///   final playerId = await SupabaseService.instance.ensurePlayer(deviceId);

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._();
  SupabaseService._();

  // ── Configuration ──────────────────────────────────────────────
  // TODO: Move to environment config / --dart-define
  static const String _supabaseUrl = 'https://vdcpbqsnkivokroqxelq.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY3BicXNua2l2b2tyb3F4ZWxxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2MTkzNjAsImV4cCI6MjA4NjE5NTM2MH0.FZOVMRmElsmlGLqJp1QkKVQoMTmc2lkBlF4Sk8yuNi8';

  SupabaseClient get client => Supabase.instance.client;
  bool _initialized = false;
  bool get isInitialized => _initialized;

  String? _playerId;
  String? get playerId => _playerId;
  bool get isAuthenticated => _playerId != null;

  // ── Initialization ─────────────────────────────────────────────

  /// Call once at app startup (main.dart) before runApp.
  Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    _initialized = true;

    // Restore session if user was previously signed in
    final session = client.auth.currentSession;
    if (session != null) {
      // Validate the restored session is still valid server-side
      try {
        final userResponse = await client.auth.getUser();
        if (userResponse.user != null) {
          _playerId = userResponse.user!.id;
          debugPrint('Supabase: restored session for player $_playerId');

          // Verify the player row actually exists in the database
          final playerExists = await _verifyPlayerRow(_playerId!);
          if (!playerExists) {
            debugPrint('Supabase: session valid but player row missing — will re-create on ensurePlayer');
            // Don't clear _playerId — auth is valid, just needs the DB row
          }
        } else {
          debugPrint('Supabase: restored session has no user — clearing');
          await _clearStaleSession();
        }
      } catch (e) {
        debugPrint('Supabase: session validation failed ($e) — clearing stale session');
        await _clearStaleSession();
      }
    }
  }

  /// Clear a stale/invalid session so the next ensurePlayer does a fresh sign-in.
  Future<void> _clearStaleSession() async {
    _playerId = null;
    try {
      await client.auth.signOut(scope: SignOutScope.local);
    } catch (e) {
      debugPrint('Supabase: error during stale session cleanup: $e');
    }
  }

  /// Check if the player row exists in the players table.
  Future<bool> _verifyPlayerRow(String playerId) async {
    try {
      final result = await client
          .from('players')
          .select('id')
          .eq('id', playerId)
          .maybeSingle();
      return result != null;
    } catch (e) {
      debugPrint('Supabase: error verifying player row: $e');
      return false;
    }
  }

  // ── Anonymous Auth ─────────────────────────────────────────────

  /// Signs in anonymously and creates/restores the player record.
  /// Returns the player UUID.
  Future<String> ensurePlayer(String deviceId, {String? displayName}) async {
    _assertInitialized();

    // If already authenticated, verify the player row exists
    if (_playerId != null) {
      final exists = await _verifyPlayerRow(_playerId!);
      if (exists) {
        await _touchLastSeen();
        return _playerId!;
      }
      // Auth user exists but player row doesn't — re-create it
      debugPrint('Supabase: player row missing for $_playerId, re-creating...');
      await _createPlayerRow(deviceId, displayName);
      return _playerId!;
    }

    // Sign in anonymously
    try {
      final response = await client.auth.signInAnonymously();
      final userId = response.user?.id;

      if (userId == null) {
        throw Exception('Anonymous sign-in returned no user');
      }

      _playerId = userId;
      debugPrint('Supabase: signed in anonymously as $_playerId');

      // Create player + stats rows
      await _createPlayerRow(deviceId, displayName);
      return _playerId!;
    } catch (e) {
      debugPrint('Supabase auth error: $e');
      rethrow;
    }
  }

  /// Create the player and stats rows in the database.
  /// Tries the RPC function first, falls back to direct insert.
  Future<void> _createPlayerRow(String deviceId, String? displayName) async {
    try {
      await client.rpc('create_player_with_stats', params: {
        'p_device_id': deviceId,
        'p_display_name': displayName,
      });

      // Verify it actually worked
      final exists = await _verifyPlayerRow(_playerId!);
      if (exists) {
        debugPrint('Supabase: player record ensured via RPC');
        return;
      }

      debugPrint('Supabase: RPC succeeded but player row not found — trying direct insert');
    } catch (e) {
      debugPrint('Supabase: RPC create_player_with_stats failed: $e — trying direct insert');
    }

    // Fallback: direct insert
    try {
      await client.from('players').upsert({
        'id': _playerId!,
        'device_id': deviceId,
        'display_name': displayName,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      });

      // Also create the stats row if it doesn't exist
      try {
        await client.from('player_stats').upsert({
          'player_id': _playerId!,
          'total_xp': 0,
          'total_points': 0,
        });
      } catch (e) {
        debugPrint('Supabase: stats row creation failed (may already exist): $e');
      }

      debugPrint('Supabase: player record ensured via direct insert');
    } catch (e) {
      debugPrint('Supabase: direct insert also failed: $e');
      rethrow;
    }
  }

  // ── Wallet Linking ─────────────────────────────────────────────

  /// Links a Solana wallet address to the current player.
  /// Called when user connects wallet via MWA.
  Future<void> linkWallet(String walletAddress) async {
    _assertAuthenticated();

    try {
      await client
          .from('players')
          .update({
        'wallet_address': walletAddress,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      })
          .eq('id', _playerId!);

      debugPrint('Supabase: linked wallet $walletAddress to player $_playerId');
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation — wallet already linked to another account
        debugPrint('Supabase: wallet $walletAddress already linked to another player');
        // TODO: Handle account merge flow
        throw WalletAlreadyLinkedException(walletAddress);
      }
      rethrow;
    }
  }

  /// Unlinks the wallet from the current player.
  Future<void> unlinkWallet() async {
    _assertAuthenticated();

    await client
        .from('players')
        .update({'wallet_address': null})
        .eq('id', _playerId!);

    debugPrint('Supabase: unlinked wallet from player $_playerId');
  }

  // ── Session Management ─────────────────────────────────────────

  /// Update last_seen timestamp.
  Future<void> _touchLastSeen() async {
    if (_playerId == null) return;
    try {
      await client
          .from('players')
          .update({'last_seen_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', _playerId!);
    } catch (e) {
      debugPrint('Supabase: failed to update last_seen: $e');
    }
  }

  /// Sign out and clear local state.
  Future<void> signOut() async {
    await client.auth.signOut();
    _playerId = null;
    debugPrint('Supabase: signed out');
  }

  // ── Helpers ────────────────────────────────────────────────────

  void _assertInitialized() {
    assert(_initialized, 'SupabaseService.initialize() must be called first');
  }

  void _assertAuthenticated() {
    _assertInitialized();
    assert(_playerId != null, 'Player must be authenticated first');
  }
}

// ── Exceptions ─────────────────────────────────────────────────

class WalletAlreadyLinkedException implements Exception {
  final String walletAddress;
  WalletAlreadyLinkedException(this.walletAddress);

  @override
  String toString() => 'Wallet $walletAddress is already linked to another player';
}