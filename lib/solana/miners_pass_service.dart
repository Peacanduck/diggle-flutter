/// miners_pass_service.dart
/// The weekly Miner's Pass, paid in SKR (the Seeker token).
///
/// There is NO on-chain program. The miners-pass edge function builds a
/// plain SPL transferChecked of SKR into the treasury wallet; the player
/// signs and sends it via MWA; the function then verifies the transfer
/// on-chain and records the pass against the player. See
/// supabase/edge/miners-pass/index.ts and
/// supabase/migrations/20260929_skr_miners_pass.sql.
///
/// Flow:
///   1. /build-tx → unsigned transaction + order id
///   2. WalletService.signAndSendTransaction → signature
///   3. persist {order, signature} — SKR has now left the wallet
///   4. poll /confirm until the server has verified it
///
/// If the app dies or verification times out after step 2, [restore]
/// finishes the job the next time the quest screen opens.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import 'wallet_service.dart';

enum PassPurchaseStatus {
  idle,
  preparing,
  awaitingSignature,
  verifying,
  success,
  error,
}

/// Why a purchase didn't go through, for the UI to localize.
enum PassPurchaseError {
  /// No price set, store inactive, or not signed in.
  unavailable,

  /// The wallet holds less SKR than the price ([MinersPassService.neededSkr]).
  insufficientSkr,

  /// Could not build, or the wallet rejected/failed to send — no SKR moved.
  failed,

  /// Sent, but the server could not verify it (yet). SKR may have moved;
  /// [MinersPassService.restore] retries.
  unconfirmed,
}

/// Price info from /config.
class MinersPassConfig {
  final bool active;

  /// Price in SKR (UI units, not base units).
  final double amount;

  const MinersPassConfig({required this.active, this.amount = 0});

  factory MinersPassConfig.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?)?.toDouble() ?? 0;
    return MinersPassConfig(
      // A zero price is a misconfiguration, never a free pass.
      active: json['active'] == true && amount > 0,
      amount: amount,
    );
  }

  static const inactive = MinersPassConfig(active: false);
}

/// Format an SKR amount for a button: "100", "12.5", "0.25".
String formatSkr(double amount) {
  if (amount == amount.roundToDouble()) return amount.toStringAsFixed(0);
  return amount
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Payment sent but not yet verified, persisted across app restarts.
class _PendingOrder {
  final String orderId;
  final String signature;
  final String network;
  final String? playerId;
  final int savedAt;

  _PendingOrder({
    required this.orderId,
    required this.signature,
    required this.network,
    required this.playerId,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'signature': signature,
        'network': network,
        'playerId': playerId,
        'savedAt': savedAt,
      };

  static _PendingOrder? fromJson(Map<String, dynamic> json) {
    final orderId = json['orderId'];
    final signature = json['signature'];
    final network = json['network'];
    if (orderId is! String || signature is! String || network is! String) {
      return null;
    }
    return _PendingOrder(
      orderId: orderId,
      signature: signature,
      network: network,
      playerId: json['playerId'] as String?,
      savedAt: json['savedAt'] as int? ?? 0,
    );
  }
}

class MinersPassService extends ChangeNotifier {
  final WalletService _wallet;

  MinersPassService({required WalletService wallet}) : _wallet = wallet;

  static const String _pendingKey = 'miners_pass_pending_order_v1';
  static const Duration _pollInterval = Duration(seconds: 2);
  static const int _pollAttempts = 30;

  /// A transaction whose blockhash has long expired can never land, so a
  /// pending order older than this that still isn't visible is dropped.
  static const Duration _pendingTtl = Duration(hours: 1);

  MinersPassConfig? _config;
  PassPurchaseStatus _status = PassPurchaseStatus.idle;
  PassPurchaseError? _error;
  double? _neededSkr;

  MinersPassConfig? get config => _config;
  PassPurchaseStatus get status => _status;
  PassPurchaseError? get error => _error;

  /// SKR needed, set with [PassPurchaseError.insufficientSkr].
  double? get neededSkr => _neededSkr;

  bool get isBusy =>
      _status == PassPurchaseStatus.preparing ||
      _status == PassPurchaseStatus.awaitingSignature ||
      _status == PassPurchaseStatus.verifying;

  /// Signed in and a price is active — the pass can be offered.
  bool get isAvailable => _hasSession && (_config?.active ?? false);

  bool get _hasSession {
    final supabase = SupabaseService.instance;
    return supabase.isInitialized &&
        supabase.client.auth.currentSession != null;
  }

  String get _network => _wallet.isDevnet ? 'devnet' : 'mainnet';

  /// Devnet wallets use the separate devnet function (dummy SKR mint),
  /// mirroring candy-machine / candy-machine-devnet.
  String get _function =>
      _wallet.isDevnet ? 'miners-pass-devnet' : 'miners-pass';

  Future<Map<String, dynamic>> _call(
    String route, [
    Map<String, dynamic> body = const {},
  ]) async {
    final response = await SupabaseService.instance.client.functions
        .invoke('$_function/$route', body: body);
    final data = response.data;
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// The `error` code from a non-2xx edge function response, if any.
  static String? _errorCode(FunctionException e) {
    final details = e.details;
    return details is Map ? details['error'] as String? : null;
  }

  // ============================================================
  // CONFIG
  // ============================================================

  /// Load the current price. Inactive when signed out or on any error.
  Future<void> fetchConfig() async {
    if (!_hasSession) {
      _config = MinersPassConfig.inactive;
      notifyListeners();
      return;
    }
    try {
      _config = MinersPassConfig.fromJson(await _call('config'));
    } catch (e) {
      debugPrint('MinersPass: config fetch failed: $e');
      _config = MinersPassConfig.inactive;
    }
    notifyListeners();
  }

  // ============================================================
  // PURCHASE
  // ============================================================

  /// Buy this week's pass. Returns the ISO week key the server granted,
  /// or null with [error] set.
  Future<String?> purchase() async {
    if (isBusy) return null;
    final buyer = _wallet.publicKey;
    if (!_wallet.isConnected || buyer == null || !_hasSession) {
      return _fail(PassPurchaseError.unavailable);
    }

    _error = null;
    _neededSkr = null;
    _setStatus(PassPurchaseStatus.preparing);

    // 1. Server builds the SKR transfer (and refuses up front if the
    //    wallet can't cover it or the pass is already active).
    final String orderId;
    final Uint8List txBytes;
    try {
      final built = await _call('build-tx', {'buyer': buyer});
      orderId = built['orderId'] as String;
      txBytes = base64Decode(built['transaction'] as String);
    } on FunctionException catch (e) {
      switch (_errorCode(e)) {
        case 'insufficient_skr':
          final details = e.details as Map;
          _neededSkr = (details['needed'] as num?)?.toDouble();
          return _fail(PassPurchaseError.insufficientSkr);
        case 'already_active':
          final weekKey = (e.details as Map)['weekKey'] as String?;
          _setStatus(PassPurchaseStatus.success);
          return weekKey;
        case 'unavailable':
          _config = MinersPassConfig.inactive;
          return _fail(PassPurchaseError.unavailable);
        default:
          debugPrint('MinersPass: build failed (${e.status}): ${e.details}');
          return _fail(PassPurchaseError.failed);
      }
    } catch (e) {
      debugPrint('MinersPass: build failed: $e');
      return _fail(PassPurchaseError.failed);
    }

    // 2. Sign + send via MWA (retries across the app-switch network drop).
    _setStatus(PassPurchaseStatus.awaitingSignature);
    final signature = await _wallet.signAndSendTransaction(txBytes);
    if (signature == null) {
      debugPrint('MinersPass: not sent: ${_wallet.errorMessage}');
      return _fail(PassPurchaseError.failed);
    }

    // 3. SKR is on its way — remember the order before anything else can
    //    go wrong, so restore() can finish verification later.
    await _savePending(_PendingOrder(
      orderId: orderId,
      signature: signature,
      network: _network,
      playerId: SupabaseService.instance.playerId,
      savedAt: DateTime.now().millisecondsSinceEpoch,
    ));

    // 4. Server verifies the transfer on-chain and records the pass.
    _setStatus(PassPurchaseStatus.verifying);
    final weekKey = await _confirm(orderId, signature, attempts: _pollAttempts);
    if (weekKey == null) return _fail(PassPurchaseError.unconfirmed);

    _setStatus(PassPurchaseStatus.success);
    return weekKey;
  }

  /// Poll /confirm. Returns the week key once paid; null when the order
  /// failed, was rejected, or is still unverified after [attempts].
  /// The persisted pending order is cleared only on a final answer.
  Future<String?> _confirm(
    String orderId,
    String signature, {
    required int attempts,
  }) async {
    for (var i = 0; i < attempts; i++) {
      if (i > 0) await Future.delayed(_pollInterval);
      try {
        final result = await _call('confirm', {
          'orderId': orderId,
          'signature': signature,
        });
        switch (result['status']) {
          case 'paid':
            await _clearPending();
            return result['weekKey'] as String?;
          case 'failed':
            await _clearPending();
            return null;
        }
        // 'pending': not visible on-chain yet — keep polling.
      } on FunctionException catch (e) {
        if (e.status >= 400 && e.status < 500) {
          // Final: the transaction does not pay this order, or the order
          // is unknown to this player.
          debugPrint('MinersPass: confirm rejected (${e.status}): ${e.details}');
          await _clearPending();
          return null;
        }
        debugPrint('MinersPass: confirm error (${e.status}), retrying');
      } catch (e) {
        debugPrint('MinersPass: confirm error: $e, retrying');
      }
    }
    return null;
  }

  // ============================================================
  // RESTORE
  // ============================================================

  /// Finish any payment interrupted after sending, then ask the server
  /// whether this player's pass is active this week (covers reinstalls
  /// and other devices). Returns the active week key, or null.
  Future<String?> restore() async {
    if (!_hasSession) return null;

    final pending = await _loadPending();
    if (pending != null &&
        pending.network == _network &&
        pending.playerId == SupabaseService.instance.playerId) {
      final weekKey =
          await _confirm(pending.orderId, pending.signature, attempts: 1);
      if (weekKey != null) return weekKey;
      final age = DateTime.now().millisecondsSinceEpoch - pending.savedAt;
      if (age > _pendingTtl.inMilliseconds) await _clearPending();
    }

    try {
      final status = await _call('status');
      return status['active'] == true ? status['weekKey'] as String? : null;
    } catch (e) {
      debugPrint('MinersPass: status check failed: $e');
      return null;
    }
  }

  // ============================================================
  // INTERNAL
  // ============================================================

  String? _fail(PassPurchaseError error) {
    _error = error;
    _setStatus(PassPurchaseStatus.error);
    return null;
  }

  void _setStatus(PassPurchaseStatus status) {
    _status = status;
    notifyListeners();
  }

  Future<void> _savePending(_PendingOrder order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingKey, jsonEncode(order.toJson()));
    } catch (e) {
      debugPrint('MinersPass: failed to persist pending order: $e');
    }
  }

  Future<_PendingOrder?> _loadPending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendingKey);
      if (raw == null) return null;
      return _PendingOrder.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('MinersPass: failed to load pending order: $e');
      return null;
    }
  }

  Future<void> _clearPending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingKey);
    } catch (_) {}
  }
}
