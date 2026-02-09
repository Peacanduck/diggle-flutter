/// player_service.dart
/// Player profile CRUD, display name, wallet lookup.
///
/// Usage:
///   final service = PlayerService();
///   final profile = await service.getProfile();
///   await service.updateDisplayName('DrillMaster42');

import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// Player profile data model.
class PlayerProfile {
  final String id;
  final String? walletAddress;
  final String? deviceId;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastSeenAt;

  PlayerProfile({
    required this.id,
    this.walletAddress,
    this.deviceId,
    this.displayName,
    required this.createdAt,
    required this.lastSeenAt,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String,
      walletAddress: json['wallet_address'] as String?,
      deviceId: json['device_id'] as String?,
      displayName: json['display_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
    );
  }

  bool get hasWallet => walletAddress != null && walletAddress!.isNotEmpty;
}

class PlayerService {
  final _supabase = SupabaseService.instance;

  /// Fetch the current player's profile.
  Future<PlayerProfile?> getProfile() async {
    final playerId = _supabase.playerId;
    if (playerId == null) return null;

    try {
      final data = await _supabase.client
          .from('players')
          .select()
          .eq('id', playerId)
          .maybeSingle();

      if (data == null) return null;
      return PlayerProfile.fromJson(data);
    } catch (e) {
      debugPrint('PlayerService.getProfile error: $e');
      return null;
    }
  }

  /// Update the player's display name.
  Future<void> updateDisplayName(String name) async {
    final playerId = _supabase.playerId;
    if (playerId == null) return;

    await _supabase.client
        .from('players')
        .update({'display_name': name})
        .eq('id', playerId);

    debugPrint('PlayerService: display name updated to "$name"');
  }

  /// Lookup a player by wallet address (for leaderboards, etc.).
  Future<PlayerProfile?> findByWallet(String walletAddress) async {
    try {
      final data = await _supabase.client
          .from('players')
          .select()
          .eq('wallet_address', walletAddress)
          .maybeSingle();

      if (data == null) return null;
      return PlayerProfile.fromJson(data);
    } catch (e) {
      debugPrint('PlayerService.findByWallet error: $e');
      return null;
    }
  }
}