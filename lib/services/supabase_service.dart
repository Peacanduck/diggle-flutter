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
  static const String _supabaseAnonKey = 'sb_publishable_3Lt47dggCSWufo6kLq6fzg_B7yvx0Lm';

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
      _playerId = session.user.id;
      debugPrint('Supabase: restored session for player $_playerId');
    }
  }

  // ── Anonymous Auth ─────────────────────────────────────────────

  /// Signs in anonymously and creates/restores the player record.
  /// Returns the player UUID.
  Future<String> ensurePlayer(String deviceId, {String? displayName}) async {
    _assertInitialized();

    // If already authenticated, just update last_seen
    if (_playerId != null) {
      await _touchLastSeen();
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

      // Create player + stats rows via server function
      await client.rpc('create_player_with_stats', params: {
        'p_device_id': deviceId,
        'p_display_name': displayName,
      });

      debugPrint('Supabase: player record ensured');
      return _playerId!;
    } catch (e) {
      debugPrint('Supabase auth error: $e');
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