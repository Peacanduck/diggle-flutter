/// supabase_service.dart
/// Core Supabase client initialization, email auth, wallet auth, and guest auth.
///
/// Auth methods:
///   - Email sign up / sign in (Supabase native)
///   - Web3 wallet (Sign In With Solana → edge function verification)
///   - Guest (anonymous auth, can be upgraded later)
///
/// Usage:
///   await SupabaseService.instance.initialize();
///   await SupabaseService.instance.signInWithEmail(email, password);
///   await SupabaseService.instance.ensurePlayer(deviceId);

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SupabaseService {
  static final SupabaseService instance = SupabaseService._();
  SupabaseService._();

  // ── Configuration ──────────────────────────────────────────────
  static const String _supabaseUrl = 'https://vdcpbqsnkivokroqxelq.supabase.co';
  static const String _supabaseAnonKey = 'sb_publishable_3Lt47dggCSWufo6kLq6fzg_B7yvx0Lm';
  static const String _walletAuthFunctionUrl = '$_supabaseUrl/functions/v1/wallet-auth';

  SupabaseClient get client => Supabase.instance.client;
  bool _initialized = false;
  bool get isInitialized => _initialized;

  String? _playerId;
  String? get playerId => _playerId;
  bool get isAuthenticated => _playerId != null;

  /// Auth method used for the current session
  AuthMethod _authMethod = AuthMethod.none;
  AuthMethod get authMethod => _authMethod;
  bool get isGuest => _authMethod == AuthMethod.guest;
  bool get isEmailUser => _authMethod == AuthMethod.email;
  bool get isWalletUser => _authMethod == AuthMethod.wallet;

  /// Connected wallet address (if signed in via wallet)
  String? _walletAddress;
  String? get walletAddress => _walletAddress;

  /// User email (if signed in via email)
  String? get userEmail => client.auth.currentUser?.email;

  /// Common headers for edge function calls (anon key as both apikey and bearer)
  static Map<String, String> get _edgeFunctionHeaders => {
    'Content-Type': 'application/json',
    'apikey': _supabaseAnonKey,
    'Authorization': 'Bearer $_supabaseAnonKey',
  };

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
      try {
        final userResponse = await client.auth.getUser();
        if (userResponse.user != null) {
          final user = userResponse.user!;
          _playerId = user.id;
          _authMethod = _detectAuthMethod(user);
          _walletAddress = user.userMetadata?['wallet_address'] as String?;

          debugPrint('Supabase: restored session for player $_playerId (${_authMethod.name})');

          // Verify the player row exists
          final playerExists = await _verifyPlayerRow(_playerId!);
          if (!playerExists) {
            debugPrint('Supabase: session valid but player row missing — will create on ensurePlayer');
          }
        } else {
          debugPrint('Supabase: restored session has no user — clearing');
          await _clearStaleSession();
        }
      } catch (e) {
        debugPrint('Supabase: session validation failed ($e) — clearing');
        await _clearStaleSession();
      }
    }
  }

  /// Detect auth method from user metadata
  AuthMethod _detectAuthMethod(User user) {
    if (user.isAnonymous ?? false) return AuthMethod.guest;
    if (user.userMetadata?['wallet_address'] != null) return AuthMethod.wallet;
    if (user.email != null && user.email!.isNotEmpty) return AuthMethod.email;
    return AuthMethod.guest;
  }

  // ── Email Auth ─────────────────────────────────────────────────

  /// Sign up with email and password.
  /// Returns true if email confirmation is required, false if auto-confirmed.
  Future<bool> signUpWithEmail(String email, String password) async {
    _assertInitialized();

    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    // If session is null, email confirmation is required
    if (response.session == null) {
      return true; // Needs email confirmation
    }

    // Auto-confirmed (e.g. if email confirmation is disabled)
    _playerId = response.user!.id;
    _authMethod = AuthMethod.email;
    debugPrint('Supabase: signed up with email as $_playerId');
    return false;
  }

  /// Sign in with email and password.
  Future<void> signInWithEmail(String email, String password) async {
    _assertInitialized();

    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    _playerId = response.user!.id;
    _authMethod = AuthMethod.email;
    debugPrint('Supabase: signed in with email as $_playerId');
  }

  // ── Wallet Auth (Sign In With Solana) ──────────────────────────

  /// Get the sign-in message that the wallet needs to sign.
  /// Returns the raw message bytes for signing.
  Future<Uint8List> getWalletSignInMessage(String walletAddress) async {
    _assertInitialized();

    debugPrint('Supabase: requesting nonce for wallet ${walletAddress.substring(0, 8)}...');

    final response = await http.post(
      Uri.parse('$_walletAuthFunctionUrl/nonce'),
      headers: _edgeFunctionHeaders,
      body: jsonEncode({'wallet_address': walletAddress}),
    );

    if (response.statusCode != 200) {
      debugPrint('Supabase: nonce request failed (${response.statusCode}): ${response.body}');
      throw Exception('Failed to get sign-in message: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final message = data['message'] as String;
    debugPrint('Supabase: nonce received, message length: ${message.length}');

    // Return the message as UTF-8 bytes for wallet signing
    return Uint8List.fromList(utf8.encode(message));
  }

  /// Verify the wallet signature and establish a session.
  Future<void> verifyWalletSignature({
    required String walletAddress,
    required Uint8List signature,
    required Uint8List message,
  }) async {
    _assertInitialized();

    debugPrint('Supabase: verifying wallet signature...');

    final response = await http.post(
      Uri.parse('$_walletAuthFunctionUrl/verify'),
      headers: _edgeFunctionHeaders,
      body: jsonEncode({
        'wallet_address': walletAddress,
        'signature': base64Encode(signature),
        'message': utf8.decode(message),
      }),
    );

    if (response.statusCode != 200) {
      debugPrint('Supabase: wallet verify failed (${response.statusCode}): ${response.body}');
      throw Exception('Wallet verification failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final email = data['email'] as String;
    final password = data['password'] as String;

    debugPrint('Supabase: wallet verified, signing in natively...');

    // Sign in using the Supabase client directly — proper session management
    final authResponse = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('Failed to establish session after wallet auth');
    }

    _playerId = user.id;
    _authMethod = AuthMethod.wallet;
    _walletAddress = walletAddress;
    debugPrint('Supabase: signed in with wallet as $_playerId ($walletAddress)');
  }

  // ── Guest Auth (Anonymous) ─────────────────────────────────────

  /// Sign in as guest (anonymous auth).
  Future<void> signInAsGuest() async {
    _assertInitialized();

    final response = await client.auth.signInAnonymously();
    final userId = response.user?.id;

    if (userId == null) {
      throw Exception('Anonymous sign-in returned no user');
    }

    _playerId = userId;
    _authMethod = AuthMethod.guest;
    debugPrint('Supabase: signed in as guest $_playerId');
  }

  // ── Account Upgrade ────────────────────────────────────────────

  /// Upgrade a guest account to email auth.
  Future<void> upgradeToEmail(String email, String password) async {
    _assertAuthenticated();

    await client.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
      ),
    );

    _authMethod = AuthMethod.email;
    debugPrint('Supabase: upgraded guest to email account');
  }

  /// Upgrade a guest account by linking a wallet.
  Future<void> upgradeToWallet(String walletAddress, Uint8List signature, Uint8List message) async {
    _assertAuthenticated();

    final response = await http.post(
      Uri.parse('$_walletAuthFunctionUrl/link'),
      headers: {
        ..._edgeFunctionHeaders,
        // Override Authorization with the user's actual session token
        'Authorization': 'Bearer ${client.auth.currentSession?.accessToken}',
      },
      body: jsonEncode({
        'wallet_address': walletAddress,
        'signature': base64Encode(signature),
        'message': utf8.decode(message),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Wallet linking failed: ${response.body}');
    }

    _authMethod = AuthMethod.wallet;
    _walletAddress = walletAddress;
    debugPrint('Supabase: linked wallet $walletAddress to player $_playerId');
  }

  // ── Player Management ──────────────────────────────────────────

  /// Ensures the player row exists in the database.
  /// Call after authentication succeeds.
  Future<String> ensurePlayer(String deviceId, {String? displayName}) async {
    _assertInitialized();

    if (_playerId == null) {
      throw StateError('Must authenticate before calling ensurePlayer');
    }

    final exists = await _verifyPlayerRow(_playerId!);
    if (exists) {
      debugPrint('Supabase: player row exists for $_playerId');
      await _touchLastSeen();
      return _playerId!;
    }

    debugPrint('Supabase: creating player row for $_playerId...');
    await _createPlayerRow(deviceId, displayName);
    return _playerId!;
  }

  Future<void> _createPlayerRow(String deviceId, String? displayName) async {
    // Try RPC first (SECURITY DEFINER bypasses RLS)
    try {
      await client.rpc('create_player_with_stats', params: {
        'p_device_id': deviceId,
        'p_display_name': displayName,
      });

      final exists = await _verifyPlayerRow(_playerId!);
      if (exists) {
        debugPrint('Supabase: player record created via RPC');
        return;
      }
      debugPrint('Supabase: RPC returned OK but player row not found — trying direct insert');
    } catch (e) {
      debugPrint('Supabase: RPC create_player_with_stats failed: $e — trying direct insert');
    }

    // Fallback: direct insert
    try {
      await client.from('players').upsert({
        'id': _playerId!,
        'device_id': deviceId,
        'display_name': displayName,
        'wallet_address': _walletAddress,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      });

      try {
        await client.from('player_stats').upsert({
          'player_id': _playerId!,
          'total_xp': 0,
          'total_points': 0,
        });
      } catch (e) {
        debugPrint('Supabase: stats row creation failed: $e');
      }

      debugPrint('Supabase: player record created via direct insert');
    } catch (e) {
      debugPrint('Supabase: direct insert also failed: $e');
      rethrow;
    }
  }

  // ── Wallet Linking (for existing accounts) ─────────────────────

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

      _walletAddress = walletAddress;
      debugPrint('Supabase: linked wallet $walletAddress to player $_playerId');
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw WalletAlreadyLinkedException(walletAddress);
      }
      rethrow;
    }
  }

  Future<void> unlinkWallet() async {
    _assertAuthenticated();

    await client
        .from('players')
        .update({'wallet_address': null})
        .eq('id', _playerId!);

    _walletAddress = null;
    debugPrint('Supabase: unlinked wallet from player $_playerId');
  }

  // ── Session Management ─────────────────────────────────────────

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

  Future<void> signOut() async {
    await client.auth.signOut();
    _playerId = null;
    _authMethod = AuthMethod.none;
    _walletAddress = null;
    debugPrint('Supabase: signed out');
  }

  Future<void> _clearStaleSession() async {
    _playerId = null;
    _authMethod = AuthMethod.none;
    _walletAddress = null;
    try {
      await client.auth.signOut(scope: SignOutScope.local);
    } catch (e) {
      debugPrint('Supabase: error during stale session cleanup: $e');
    }
  }

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

  // ── Helpers ────────────────────────────────────────────────────

  void _assertInitialized() {
    assert(_initialized, 'SupabaseService.initialize() must be called first');
  }

  void _assertAuthenticated() {
    _assertInitialized();
    assert(_playerId != null, 'Player must be authenticated first');
  }
}

// ── Auth Method Enum ───────────────────────────────────────────

enum AuthMethod {
  none,
  email,
  wallet,
  guest,
}

// ── Exceptions ─────────────────────────────────────────────────

class WalletAlreadyLinkedException implements Exception {
  final String walletAddress;
  WalletAlreadyLinkedException(this.walletAddress);

  @override
  String toString() => 'Wallet $walletAddress is already linked to another player';
}