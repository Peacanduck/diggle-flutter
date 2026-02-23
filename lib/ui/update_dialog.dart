/// update_dialog.dart
/// Displays an update prompt to the user.
///
/// Two modes:
///   - **Optional**: Dismissible dialog, "Later" button available
///   - **Forced**: Blocks the app, no dismiss — user must update
///
/// The "Update" button opens the Solana dApp Store via deep link:
///   solanadappstore://details?id=com.pyrolabs.diggle
///
/// Usage from navigator/main:
///   final status = await UpdateService.instance.checkForUpdate();
///   if (status.needsUpdate && mounted) {
///     UpdateDialog.show(context, status);
///   }

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/update_service.dart';

class UpdateDialog {
  UpdateDialog._();

  /// Show the update dialog. Returns when dismissed (optional) or never (forced).
  static Future<void> show(BuildContext context, UpdateStatus status) {
    if (status.isForced) {
      return _showForcedDialog(context, status);
    } else {
      return _showOptionalDialog(context, status);
    }
  }

  // ── Optional (dismissible) ─────────────────────────────────────

  static Future<void> _showOptionalDialog(
      BuildContext context, UpdateStatus status) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🔄', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.updateAvailableTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (status.message != null)
              Text(
                status.message!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _versionLabel(
                    l10n.currentVersionLabel,
                    status.currentVersion,
                    Colors.white54,
                  ),
                  const Icon(Icons.arrow_forward,
                      color: Colors.white24, size: 16),
                  _versionLabel(
                    l10n.latestVersionLabel,
                    status.latestVersion,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.updateLater,
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              UpdateService.instance.openDappStore(
                packageId: status.dappStoreId,
              );
            },
            icon: const Icon(Icons.system_update, size: 18),
            label: Text(l10n.updateNow),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Forced (blocking) ──────────────────────────────────────────

  static Future<void> _showForcedDialog(
      BuildContext context, UpdateStatus status) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.updateRequiredTitle,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.message ??
                    l10n.updateRequiredMessage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _versionLabel(
                      l10n.currentVersionLabel,
                      status.currentVersion,
                      Colors.red.shade300,
                    ),
                    const Icon(Icons.arrow_forward,
                        color: Colors.white24, size: 16),
                    _versionLabel(
                      l10n.requiredVersionLabel,
                      status.latestVersion,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  UpdateService.instance.openDappStore(
                    packageId: status.dappStoreId,
                  );
                },
                icon: const Icon(Icons.system_update, size: 20),
                label: Text(
                  l10n.updateNow,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared ─────────────────────────────────────────────────────

  static Widget _versionLabel(String label, String version, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          'v$version',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}