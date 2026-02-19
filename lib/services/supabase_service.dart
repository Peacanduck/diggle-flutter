/// supabase_service.dart
/// Core Supabase client initialization and auth management.
///
/// Architecture — player_auth_accounts junction table:
///   players.id   Stable canonical UUID that never changes. All game data
///                foreign-keys to this. Never equals auth.uid() directly.
///
///   auth.users   One row per sign-in identity (email user, wallet user,
///                guest user). A player can have multiple auth identities.
///
///   player_auth_accounts
///                Maps auth_user_id → player_id (many-to-one).
///                Linking a new sign-in method = INSERT one row here.
///                No data migration, no UUID swapping, ever.
///
/// Sign-in flow:
///   1. Authenticate with Supabase (email, wallet, or anonymous)
///   2. Call get_player_id_for_auth_user(auth.uid()) → canonical player_id
///   3. All subsequent operations use player_id, not auth.uid()
///
/// Linking a new sign-in method:
///   - Email → linkEmailToPlayer(): updateUser() on current auth session
///   - Wallet → linkWalletToPlayer(): calls /link edge fn which creates
///     a wallet auth user and inserts player_auth_accounts row
///
/// Guest upgrade:
///   - To email: linkEmailToPlayer() — same player_id, just adds email identity
///   - To wallet: verifyWalletSignature(existingPlayerId: _playerId) — the
///     /verify edge fn links the wallet auth user to the existing player,
///     then client signs in as the wallet user. player_id stays identical.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SupabaseService {
  static final SupabaseService instance = SupabaseService._();
  SupabaseService._();

  // ── Configuration ──────────────────────────────────────────────
  static const String _supabaseUrl =
      'https://vdcpbqsnkivokroqxelq.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_3Lt47dggCSWufo6kLq6fzg_B7yvx0Lm';
  static const String _walletAuthFunctionUrl =
      '$_supabaseUrl/functions/v1/wallet-auth';

  SupabaseClient get client => Supabase.instance.client;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Canonical player UUID from player_auth_accounts.
  /// Use this everywhere — never use auth.currentUser.id as a player id.
  String? _playerId;
  String? get playerId => _playerId;
  bool get isAuthenticated => _playerId != null;

  // ── Linked auth methods ────────────────────────────────────────

  List<LinkedAuthMethod> _linkedMethods = [];
  List<LinkedAuthMethod> get linkedMethods => List.unmodifiable(_linkedMethods);

  /// The email address linked to this player, if any.
  /// Works from any auth session (email or wallet).
  String? get linkedEmail => _linkedMethods
      .where((m) => m.method == 'email')
      .map((m) => m.identifier)
      .firstOrNull;

  /// The wallet address linked to this player, if any.
  String? get linkedWallet => _walletAddress ??
      _linkedMethods
          .where((m) => m.method == 'wallet')
          .map((m) => m.identifier)
          .firstOrNull;

  Future<void> _loadLinkedMethods() async {
    if (_playerId == null) return;
    try {
      final rows = await client.rpc(
        'get_player_auth_methods',
        params: {'p_player_id': _playerId},
      ) as List;

      _linkedMethods = rows
          .map((r) => LinkedAuthMethod(
        method:     r['auth_method'] as String,
        identifier: r['identifier'] as String?,
      ))
          .toList();

      debugPrint(
        'Supabase: loaded ${_linkedMethods.length} linked auth methods',
      );
    } catch (e) {
      debugPrint('Supabase: failed to load linked methods: $e');
    }
  }

  // ── Auth state ─────────────────────────────────────────────────

  AuthMethod _authMethod = AuthMethod.none;
  AuthMethod get authMethod => _authMethod;
  bool get isGuest     => _authMethod == AuthMethod.guest;
  bool get isEmailUser  => _authMethod == AuthMethod.email;
  bool get isWalletUser => _authMethod == AuthMethod.wallet;

  String? _walletAddress;
  String? get walletAddress => _walletAddress;

  /// The user's real email address (hides synthetic wallet emails).
  String? get userEmail {
    final email = client.auth.currentUser?.email;
    if (email == null || email.endsWith('@wallet.diggle.app')) return null;
    return email;
  }

  static Map<String, String> get _edgeFunctionHeaders => {
    'Content-Type': 'application/json',
    'apikey': _supabaseAnonKey,
    'Authorization': 'Bearer $_supabaseAnonKey',
  };

  // ── HTTP retry ─────────────────────────────────────────────────

  static const _retryDelays = [
    Duration(milliseconds: 600),
    Duration(seconds: 2),
  ];

  static bool _isTransientNetworkError(Object e) =>
      e is SocketException ||
          e.toString().toLowerCase().contains('socketexception') ||
          e.toString().toLowerCase().contains('failed host lookup');

  Future<http.Response> _post(
      Uri uri, {
        required Map<String, String> headers,
        required String body,
      }) async {
    Object? lastError;
    for (int attempt = 0; attempt <= _retryDelays.length; attempt++) {
      try {
        return await http.post(uri, headers: headers, body: body);
      } catch (e) {
        lastError = e;
        if (!_isTransientNetworkError(e) || attempt == _retryDelays.length) {
          rethrow;
        }
        final delay = _retryDelays[attempt];
        debugPrint(
          'Supabase: network error (attempt ${attempt + 1}), '
              'retrying in ${delay.inMilliseconds}ms — $e',
        );
        await Future.delayed(delay);
      }
    }
    throw lastError!;
  }

  // ── Initialization ─────────────────────────────────────────────

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

    final session = client.auth.currentSession;
    if (session == null) return;

    try {
      final userResp = await client.auth.getUser();
      final user = userResp.user;
      if (user == null) {
        debugPrint('Supabase: session has no user — clearing');
        await _clearStaleSession();
        return;
      }

      _authMethod    = _detectAuthMethod(user);
      _walletAddress = user.userMetadata?['wallet_address'] as String?;
      _playerId      = await _resolvePlayerId(user.id);
      await _loadLinkedMethods();

      if (_playerId != null) {
        debugPrint(
          'Supabase: restored session — '
              'auth=${user.id.substring(0, 8)} '
              'player=${_playerId!.substring(0, 8)} '
              '(${_authMethod.name})',
        );
      } else {
        debugPrint(
          'Supabase: session restored, no player mapping yet '
              '(will create on ensurePlayer)',
        );
      }
    } catch (e) {
      debugPrint('Supabase: session validation failed ($e) — clearing');
      await _clearStaleSession();
    }
  }

  AuthMethod _detectAuthMethod(User user) {
    if (user.isAnonymous) return AuthMethod.guest;
    if (user.userMetadata?['wallet_address'] != null) return AuthMethod.wallet;
    final email = user.email ?? '';
    if (email.isNotEmpty && !email.endsWith('@wallet.diggle.app')) {
      return AuthMethod.email;
    }
    return AuthMethod.guest;
  }

  Future<String?> _resolvePlayerId(String authUserId) async {
    try {
      final result = await client.rpc(
        'get_player_id_for_auth_user',
        params: {'p_auth_user_id': authUserId},
      );
      return result as String?;
    } catch (e) {
      debugPrint('Supabase: _resolvePlayerId failed: $e');
      return null;
    }
  }

  // ── Email sign-in ──────────────────────────────────────────────

  Future<bool> signUpWithEmail(String email, String password) async {
    _assertInitialized();

    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.session == null) return true;

    _authMethod = AuthMethod.email;
    debugPrint(
      'Supabase: signed up with email — '
          'auth=${response.user!.id.substring(0, 8)}',
    );
    return false;
  }

  Future<void> signInWithEmail(String email, String password) async {
    _assertInitialized();

    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user!;
    _authMethod = AuthMethod.email;
    _playerId   = await _resolvePlayerId(user.id);
    await _loadLinkedMethods();

    debugPrint(
      'Supabase: signed in with email — '
          'auth=${user.id.substring(0, 8)} '
          'player=${_playerId?.substring(0, 8)}',
    );
  }

  // ── Wallet sign-in ─────────────────────────────────────────────

  Future<Uint8List> getWalletSignInMessage(String walletAddress) async {
    _assertInitialized();

    final response = await _post(
      Uri.parse('$_walletAuthFunctionUrl/nonce'),
      headers: _edgeFunctionHeaders,
      body: jsonEncode({'wallet_address': walletAddress}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get sign-in message: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('Supabase: nonce received for ${walletAddress.substring(0, 8)}...');
    return Uint8List.fromList(utf8.encode(data['message'] as String));
  }

  Future<void> verifyWalletSignature({
    required String walletAddress,
    required Uint8List signature,
    required Uint8List message,
    String? existingPlayerId,
  }) async {
    _assertInitialized();

    final response = await _post(
      Uri.parse('$_walletAuthFunctionUrl/verify'),
      headers: _edgeFunctionHeaders,
      body: jsonEncode({
        'wallet_address': walletAddress,
        'signature': base64Encode(signature),
        'message': utf8.decode(message),
        if (existingPlayerId != null) 'existing_player_id': existingPlayerId,
      }),
    );

    if (response.statusCode == 409) {
      throw WalletAlreadyLinkedException(walletAddress);
    }
    if (response.statusCode != 200) {
      final err = (jsonDecode(response.body) as Map)['error'] ?? response.body;
      throw Exception('Wallet verification failed: $err');
    }

    final data       = jsonDecode(response.body) as Map<String, dynamic>;
    final email      = data['email'] as String;
    final password   = data['password'] as String;
    final resolvedId = data['player_id'] as String?;

    final authResponse = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = authResponse.user;
    if (user == null) {
      throw Exception('Failed to establish session after wallet auth');
    }

    _authMethod    = AuthMethod.wallet;
    _walletAddress = walletAddress;
    _playerId      = resolvedId ?? await _resolvePlayerId(user.id);
    await _loadLinkedMethods();

    debugPrint(
      'Supabase: signed in with wallet — '
          'auth=${user.id.substring(0, 8)} '
          'player=${_playerId?.substring(0, 8)}',
    );
  }

  // ── Guest sign-in ──────────────────────────────────────────────

  Future<void> signInAsGuest() async {
    _assertInitialized();

    final response = await client.auth.signInAnonymously();
    final user = response.user;
    if (user == null) throw Exception('Anonymous sign-in returned no user');

    _authMethod = AuthMethod.guest;
    debugPrint('Supabase: signed in as guest — auth=${user.id.substring(0, 8)}');
  }

  // ── Player setup ───────────────────────────────────────────────

  Future<String> ensurePlayer(String deviceId, {String? displayName}) async {
    _assertInitialized();

    final authUser = client.auth.currentUser;
    if (authUser == null) throw StateError('Must be authenticated');

    if (_playerId != null) {
      // Update device_id if it was null — happens for wallet accounts created
      // via the edge function which doesn't know the device_id at creation time
      await client
          .from('players')
          .update({
        'device_id': deviceId,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      })
          .eq('id', _playerId!)
          .isFilter('device_id', null);
      return _playerId!;
    }

    debugPrint(
      'Supabase: creating player for auth user '
          '${authUser.id.substring(0, 8)}...',
    );

    try {
      final result = await client.rpc('create_player_with_stats', params: {
        'p_auth_user_id': authUser.id,
        'p_auth_method':  _authMethod.name,
        'p_device_id':    deviceId,
        'p_display_name': displayName,
      });
      _playerId = result as String;
      await _loadLinkedMethods();
      debugPrint('Supabase: player created — ${_playerId!.substring(0, 8)}');
    } catch (e) {
      debugPrint('Supabase: create_player_with_stats failed: $e');
      _playerId = await _resolvePlayerId(authUser.id);
      if (_playerId == null) rethrow;
      await _loadLinkedMethods();
    }

    return _playerId!;
  }

  // ── Account linking ────────────────────────────────────────────

  /// Add email sign-in to the current account (guest or wallet).
  ///
  /// For guests: converts the anonymous auth user to a named user via
  ///   updateUser(). The existing player_auth_accounts row is updated
  ///   to auth_method='email'.
  ///
  /// For wallet users: creates a SEPARATE email auth user via signUp(),
  ///   then links it to the same player_id via the link_auth_to_player RPC.
  ///   IMPORTANT: updateUser() must NOT be called here — it would change
  ///   the wallet auth user's email from walletaddr@wallet.diggle.app to
  ///   the real email, breaking all future wallet sign-ins.
  ///
  /// Always returns true (Supabase always sends a confirmation email).
  Future<bool> linkEmailToPlayer(String email, String password) async {
    _assertAuthenticated();

    if (isGuest) {
      // Convert anonymous auth user to named user in-place
      await client.auth.updateUser(
        UserAttributes(email: email, password: password),
      );

      await client
          .from('player_auth_accounts')
          .update({'identifier': email, 'auth_method': 'email'})
          .eq('auth_user_id', client.auth.currentUser!.id);

      _authMethod = AuthMethod.email;
      debugPrint('Supabase: guest converted to email account (same player_id)');

    } else if (isWalletUser) {
      // Create a brand new email auth user — do NOT touch the wallet auth user
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      final newUser = response.user;
      if (newUser == null) {
        throw Exception('signUp returned no user');
      }

      // Link the new (possibly unconfirmed) auth user to the current player.
      // Uses SECURITY DEFINER RPC because the new user isn't confirmed yet
      // so RLS would block a direct insert into player_auth_accounts.
      await client.rpc('link_auth_to_player', params: {
        'p_auth_user_id': newUser.id,
        'p_player_id':    _playerId,
        'p_auth_method':  'email',
        'p_identifier':   email,
      });

      debugPrint(
        'Supabase: email auth user created and linked to wallet account '
            '(same player_id)',
      );
    }

    await _loadLinkedMethods();
    return true; // always needs email confirmation
  }

  /// Link a Solana wallet to the current player via the /link edge function.
  /// Throws [WalletAlreadyLinkedException] if the wallet belongs to a
  /// different player.
  Future<void> linkWalletToPlayer({
    required String walletAddress,
    required Uint8List signature,
    required Uint8List message,
  }) async {
    _assertAuthenticated();

    final sessionToken = client.auth.currentSession?.accessToken;
    if (sessionToken == null) throw Exception('No active session');
    if (_playerId == null) throw Exception('Player not initialized');

    final response = await _post(
      Uri.parse('$_walletAuthFunctionUrl/link'),
      headers: {
        ..._edgeFunctionHeaders,
        'Authorization': 'Bearer $sessionToken',
      },
      body: jsonEncode({
        'wallet_address': walletAddress,
        'signature':      base64Encode(signature),
        'message':        utf8.decode(message),
        'player_id':      _playerId,
      }),
    );

    if (response.statusCode == 409) {
      throw WalletAlreadyLinkedException(walletAddress);
    }
    if (response.statusCode != 200) {
      throw Exception('Wallet linking failed: ${response.body}');
    }

    _walletAddress = walletAddress;
    await _loadLinkedMethods();
    debugPrint(
      'Supabase: wallet linked — '
          '${walletAddress.substring(0, 8)}... → player ${_playerId!.substring(0, 8)}',
    );
  }

  /// Upgrade a guest account to wallet sign-in.
  /// player_id is preserved — all game data survives the upgrade.
  Future<void> upgradeGuestToWallet({
    required String walletAddress,
    required Uint8List signature,
    required Uint8List message,
  }) async {
    if (!isGuest) {
      throw StateError('Only guest accounts can call upgradeGuestToWallet');
    }
    _assertAuthenticated();

    await verifyWalletSignature(
      walletAddress:    walletAddress,
      signature:        signature,
      message:          message,
      existingPlayerId: _playerId,
    );

    debugPrint('Supabase: guest upgraded to wallet — same player_id retained');
  }

  // ── Wallet display column ──────────────────────────────────────

  /// Update players.wallet_address to the currently connected adapter wallet.
  /// Called by GameLifecycleManager — NOT a sign-in linking operation.
  Future<void> updateWalletDisplay(String walletAddress) async {
    _assertAuthenticated();
    if (_playerId == null) return;

    try {
      await client
          .from('players')
          .update({
        'wallet_address': walletAddress,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      })
          .eq('id', _playerId!);

      _walletAddress = walletAddress;
      debugPrint('Supabase: wallet_address display updated → $walletAddress');
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw WalletAlreadyLinkedException(walletAddress);
      rethrow;
    }
  }

  Future<void> unlinkWalletDisplay() async {
    _assertAuthenticated();
    if (_playerId == null) return;

    await client
        .from('players')
        .update({'wallet_address': null})
        .eq('id', _playerId!);

    _walletAddress = null;
    debugPrint('Supabase: wallet_address display column cleared');
  }

  // ── Session management ─────────────────────────────────────────

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
    _playerId      = null;
    _authMethod    = AuthMethod.none;
    _walletAddress = null;
    _linkedMethods = [];
    debugPrint('Supabase: signed out');
  }

  Future<void> _clearStaleSession() async {
    _playerId      = null;
    _authMethod    = AuthMethod.none;
    _walletAddress = null;
    _linkedMethods = [];
    try {
      await client.auth.signOut(scope: SignOutScope.local);
    } catch (e) {
      debugPrint('Supabase: error clearing stale session: $e');
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

// ── Enums & models ─────────────────────────────────────────────────

enum AuthMethod { none, email, wallet, guest }

class LinkedAuthMethod {
  final String method;      // 'email', 'wallet', 'guest'
  final String? identifier; // real email address or wallet address

  const LinkedAuthMethod({required this.method, this.identifier});
}

// ── Exceptions ─────────────────────────────────────────────────────

class WalletAlreadyLinkedException implements Exception {
  final String walletAddress;
  WalletAlreadyLinkedException(this.walletAddress);

  @override
  String toString() =>
      'Wallet $walletAddress is already linked to a different player';
}