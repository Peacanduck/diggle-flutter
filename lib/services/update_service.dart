/// update_service.dart
/// Checks for app updates against Supabase remote config.
///
/// Flow:
///   1. App launches → [checkForUpdate()] fetches `app_version` from app_config
///   2. Compares local [appVersion] against remote `latest_version` / `min_version`
///   3. Returns [UpdateStatus] indicating no update, optional, or forced
///   4. UI shows appropriate dialog with dApp Store deep link
///
/// Supabase table: `app_config` (key='app_version')
///   {
///     "latest_version": "0.2.0",
///     "min_version": "0.1.0",
///     "force_update": false,
///     "update_message": "...",
///     "force_message": "...",
///     "dapp_store_id": "com.example.diggle"
///   }
///
/// Dependencies: package_info_plus, url_launcher

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════════
// Models
// ═══════════════════════════════════════════════════════════════════

enum UpdateAction {
  /// App is up to date
  none,

  /// Newer version available but current still supported (dismissible)
  optional,

  /// Current version below min_version or force flag set (blocking)
  forced,
}

class UpdateStatus {
  final UpdateAction action;
  final String currentVersion;
  final String latestVersion;
  final String? message;
  final String? dappStoreId;

  const UpdateStatus({
    required this.action,
    required this.currentVersion,
    required this.latestVersion,
    this.message,
    this.dappStoreId,
  });

  /// Deep link URI to the Solana dApp Store listing page
  Uri? get dappStoreUri {
    if (dappStoreId == null || dappStoreId!.isEmpty) return null;
    return Uri.parse('solanadappstore://details?id=$dappStoreId');
  }

  bool get needsUpdate => action != UpdateAction.none;
  bool get isForced => action == UpdateAction.forced;
}

// ═══════════════════════════════════════════════════════════════════
// Service
// ═══════════════════════════════════════════════════════════════════

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  /// Cached status from last check
  UpdateStatus? _lastStatus;
  UpdateStatus? get lastStatus => _lastStatus;

  /// Check remote config and compare versions.
  /// Safe to call on every app launch — fails silently on network error.
  Future<UpdateStatus> checkForUpdate() async {
    try {
      // Get current app version from package info
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "0.1.0"

      // Fetch remote config from Supabase (public read, no auth needed)
      final response = await SupabaseService.instance.client
          .from('app_config')
          .select('value')
          .eq('key', 'app_version')
          .maybeSingle();

      if (response == null || response['value'] == null) {
        debugPrint('UpdateService: no app_version config found');
        _lastStatus = UpdateStatus(
          action: UpdateAction.none,
          currentVersion: currentVersion,
          latestVersion: currentVersion,
        );
        return _lastStatus!;
      }

      final config = response['value'] as Map<String, dynamic>;
      final latestVersion = config['latest_version'] as String? ?? currentVersion;
      final minVersion = config['min_version'] as String? ?? '0.0.0';
      final forceUpdate = config['force_update'] as bool? ?? false;
      final updateMessage = config['update_message'] as String?;
      final forceMessage = config['force_message'] as String?;
      final dappStoreId = config['dapp_store_id'] as String?;

      // Determine action
      UpdateAction action;
      String? message;

      if (forceUpdate || _isVersionBelow(currentVersion, minVersion)) {
        action = UpdateAction.forced;
        message = forceMessage ?? updateMessage;
      } else if (_isVersionBelow(currentVersion, latestVersion)) {
        action = UpdateAction.optional;
        message = updateMessage;
      } else {
        action = UpdateAction.none;
      }

      _lastStatus = UpdateStatus(
        action: action,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        message: message,
        dappStoreId: dappStoreId,
      );

      debugPrint(
        'UpdateService: current=$currentVersion latest=$latestVersion '
            'min=$minVersion action=${action.name}',
      );

      return _lastStatus!;
    } catch (e) {
      debugPrint('UpdateService: check failed (non-blocking): $e');

      // Fail open — don't block the app if version check fails
      String currentVersion;
      try {
        final info = await PackageInfo.fromPlatform();
        currentVersion = info.version;
      } catch (_) {
        currentVersion = '0.0.0';
      }

      _lastStatus = UpdateStatus(
        action: UpdateAction.none,
        currentVersion: currentVersion,
        latestVersion: currentVersion,
      );
      return _lastStatus!;
    }
  }

  /// Open the Solana dApp Store listing page for this app.
  /// Falls back gracefully if the deep link can't be launched.
  Future<bool> openDappStore({String? packageId}) async {
    final id = packageId ??
        _lastStatus?.dappStoreId ??
        'com.example.diggle';

    final uri = Uri.parse('solanadappstore://details?id=$id');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint('UpdateService: could not launch $uri');
      }
      return launched;
    } catch (e) {
      debugPrint('UpdateService: launch error: $e');
      return false;
    }
  }

  // ── Semver comparison ────────────────────────────────────────

  /// Returns true if [current] is strictly below [target].
  /// Supports standard semver: major.minor.patch
  bool _isVersionBelow(String current, String target) {
    final c = _parseVersion(current);
    final t = _parseVersion(target);

    if (c[0] != t[0]) return c[0] < t[0]; // major
    if (c[1] != t[1]) return c[1] < t[1]; // minor
    return c[2] < t[2];                     // patch
  }

  /// Parse "1.2.3" → [1, 2, 3]. Handles missing segments gracefully.
  List<int> _parseVersion(String version) {
    // Strip leading 'v' if present (e.g. "v0.1.0")
    final clean = version.startsWith('v') ? version.substring(1) : version;

    // Strip pre-release suffix (e.g. "0.1.0-alpha" → "0.1.0")
    final base = clean.split('-').first;

    final parts = base.split('.').map((s) => int.tryParse(s) ?? 0).toList();

    while (parts.length < 3) {
      parts.add(0);
    }

    return parts.sublist(0, 3);
  }
}