/// player_service.dart
/// Player profile and account linking operations.
///
/// Linking model (all methods work from any auth state):
///   linkEmailToPlayer()    — adds email sign-in to guest or wallet account
///   linkWalletToPlayer()   — adds wallet sign-in to email or guest account
///   upgradeGuestToWallet() — shorthand for guest → wallet (same player_id)
///   unlinkWalletDisplay()  — clears wallet_address display column (email users)
///
/// All linking operations insert into player_auth_accounts without touching
/// the players table or changing the canonical player_id.


import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

// ── Models ─────────────────────────────────────────────────────────

class PlayerProfile {
  final String id;
  final String? walletAddress;
  final String? deviceId;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastSeenAt;

  const PlayerProfile({
    required this.id,
    this.walletAddress,
    this.deviceId,
    this.displayName,
    required this.createdAt,
    required this.lastSeenAt,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
    id:            json['id'] as String,
    walletAddress: json['wallet_address'] as String?,
    deviceId:      json['device_id'] as String?,
    displayName:   json['display_name'] as String?,
    createdAt:     DateTime.parse(json['created_at'] as String),
    lastSeenAt:    DateTime.parse(json['last_seen_at'] as String),
  );

  bool get hasWallet => walletAddress != null && walletAddress!.isNotEmpty;
}

class LinkResult {
  final bool success;
  /// True when the operation worked but requires email confirmation before
  /// the new sign-in method becomes active.
  final bool requiresEmailConfirmation;
  final String? error;

  const LinkResult._({
    required this.success,
    this.requiresEmailConfirmation = false,
    this.error,
  });

  const LinkResult.success() : this._(success: true);
  const LinkResult.needsConfirmation()
      : this._(success: false, requiresEmailConfirmation: true);
  const LinkResult.failure(String error) : this._(success: false, error: error);
}

// ── Service ────────────────────────────────────────────────────────

class PlayerService {
  final _supabase = SupabaseService.instance;

  // ── Profile ────────────────────────────────────────────────────

  Future<PlayerProfile?> getProfile() async {
    final playerId = _supabase.playerId;
    if (playerId == null) return null;

    try {
      final data = await _supabase.client
          .from('players')
          .select()
          .eq('id', playerId)
          .maybeSingle();

      return data == null ? null : PlayerProfile.fromJson(data);
    } catch (e) {
      debugPrint('PlayerService.getProfile error: $e');
      return null;
    }
  }

  Future<void> updateDisplayName(String name) async {
    final playerId = _supabase.playerId;
    if (playerId == null) return;

    await _supabase.client
        .from('players')
        .update({'display_name': name})
        .eq('id', playerId);
  }

  Future<PlayerProfile?> findByWallet(String walletAddress) async {
    try {
      final data = await _supabase.client
          .from('players')
          .select()
          .eq('wallet_address', walletAddress)
          .maybeSingle();

      return data == null ? null : PlayerProfile.fromJson(data);
    } catch (e) {
      debugPrint('PlayerService.findByWallet error: $e');
      return null;
    }
  }

  // ── Account linking ────────────────────────────────────────────

  /// Add email sign-in to a guest or wallet-auth account.
  ///
  /// The player_id never changes — this just adds email as an additional
  /// way to sign in. Supabase sends a confirmation email; the new sign-in
  /// won't be active until the link in that email is clicked.
  Future<LinkResult> linkEmailToPlayer(String email, String password) async {
    if (_supabase.isEmailUser) {
      return const LinkResult.failure(
        'This account already has email sign-in.',
      );
    }
    if (email.isEmpty || password.isEmpty) {
      return const LinkResult.failure('Email and password are required.');
    }
    if (password.length < 6) {
      return const LinkResult.failure(
        'Password must be at least 6 characters.',
      );
    }

    try {
      await _supabase.linkEmailToPlayer(email, password);
      return const LinkResult.needsConfirmation();
    } catch (e) {
      debugPrint('PlayerService.linkEmailToPlayer error: $e');
      return LinkResult.failure(_friendlyError(e));
    }
  }

  /// Add wallet sign-in to an email or guest account.
  ///
  /// The /link edge function creates a wallet Supabase auth user (if needed)
  /// and maps it to the current player_id in player_auth_accounts. After
  /// this, signing in with the wallet resolves to the same player.
  ///
  /// Also updates players.wallet_address for leaderboard display.
  Future<LinkResult> linkWalletToPlayer({
    required String walletAddress,
    required Uint8List signature,
    required Uint8List message,
  }) async {
    if (_supabase.isWalletUser) {
      return const LinkResult.failure(
        'This account already uses wallet sign-in.',
      );
    }

    try {
      await _supabase.linkWalletToPlayer(
        walletAddress: walletAddress,
        signature:     signature,
        message:       message,
      );
      return const LinkResult.success();
    } on WalletAlreadyLinkedException {
      return const LinkResult.failure(
        'This wallet is already linked to a different account.\n'
            'Sign in with that wallet to access it, or use a different wallet.',
      );
    } catch (e) {
      debugPrint('PlayerService.linkWalletToPlayer error: $e');
      return LinkResult.failure(_friendlyError(e));
    }
  }

  /// Upgrade a guest account to wallet sign-in.
  ///
  /// Shorthand for linkWalletToPlayer that also switches the session.
  /// The player_id is preserved — no game data is lost.
  Future<LinkResult> upgradeGuestToWallet({
    required String walletAddress,
    required Uint8List signature,
    required Uint8List message,
  }) async {
    if (!_supabase.isGuest) {
      return const LinkResult.failure(
        'Only guest accounts can be upgraded to wallet.',
      );
    }

    try {
      await _supabase.upgradeGuestToWallet(
        walletAddress: walletAddress,
        signature:     signature,
        message:       message,
      );
      return const LinkResult.success();
    } on WalletAlreadyLinkedException {
      return const LinkResult.failure(
        'This wallet already has a Diggle account.\n'
            'Sign in with that wallet instead, or connect a different wallet.',
      );
    } catch (e) {
      debugPrint('PlayerService.upgradeGuestToWallet error: $e');
      return LinkResult.failure(_friendlyError(e));
    }
  }

  /// Remove the wallet display address from the player profile.
  /// Does NOT remove the wallet sign-in capability from player_auth_accounts
  /// — the wallet can still be used to sign in.
  Future<LinkResult> unlinkWalletDisplay() async {
    try {
      await _supabase.unlinkWalletDisplay();
      return const LinkResult.success();
    } catch (e) {
      debugPrint('PlayerService.unlinkWalletDisplay error: $e');
      return LinkResult.failure(_friendlyError(e));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────

  String _friendlyError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (msg.contains('password')) {
      return 'Password must be at least 6 characters.';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return 'Network error — check your connection.';
    }
    if (msg.contains('rate limit')) {
      return 'Too many attempts — try again later.';
    }
    final str = e.toString();
    return str.length > 120 ? '${str.substring(0, 120)}...' : str;
  }
}