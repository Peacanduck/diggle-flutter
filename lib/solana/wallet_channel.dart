/// wallet_channel.dart
/// Platform channel interface for Solana Mobile Wallet Adapter.
/// 
/// This file provides the Flutter side of the platform channel bridge
/// to native Kotlin code that handles Solana wallet operations.
/// 
/// Platform channels allow Flutter to call native Android code and
/// receive responses asynchronously.
/// 
/// Reference implementation from:
/// https://github.com/brij-digital/espresso-cash-public/tree/master/packages/solana_mobile_client/example

import 'package:flutter/services.dart';

/// Exception thrown when wallet operations fail
class WalletException implements Exception {
  final String message;
  final String? code;

  WalletException(this.message, {this.code});

  @override
  String toString() => 'WalletException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Low-level platform channel interface for wallet operations
class WalletChannel {
  /// Method channel name - must match native side
  static const String _channelName = 'com.plebsolutions.diggle/wallet';

  /// The method channel for communicating with native code
  static const MethodChannel _channel = MethodChannel(_channelName);

  /// Connect to a wallet app
  /// 
  /// Launches the wallet app's authorization flow.
  /// Returns the authorized public key as base58 string on success.
  /// Throws [WalletException] on failure.
  static Future<String> connect() async {
    try {
      final result = await _channel.invokeMethod<String>('connect');
      if (result == null) {
        throw WalletException('No public key returned');
      }
      return result;
    } on PlatformException catch (e) {
      throw WalletException(
        e.message ?? 'Failed to connect wallet',
        code: e.code,
      );
    }
  }

  /// Disconnect from the current wallet session
  /// 
  /// Clears the current authorization.
  /// Returns true on success.
  static Future<bool> disconnect() async {
    try {
      final result = await _channel.invokeMethod<bool>('disconnect');
      return result ?? false;
    } on PlatformException catch (e) {
      throw WalletException(
        e.message ?? 'Failed to disconnect wallet',
        code: e.code,
      );
    }
  }

  /// Get the currently connected public key
  /// 
  /// Returns null if no wallet is connected.
  /// Returns the public key as base58 string if connected.
  static Future<String?> getPublicKey() async {
    try {
      final result = await _channel.invokeMethod<String>('getPublicKey');
      return result;
    } on PlatformException catch (e) {
      throw WalletException(
        e.message ?? 'Failed to get public key',
        code: e.code,
      );
    }
  }

  /// Check if Solana Mobile Wallet Adapter is available
  /// 
  /// Returns true if at least one compatible wallet app is installed.
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      // If method fails, assume not available
      return false;
    }
  }

  /// Get the name of the connected wallet app
  /// 
  /// Returns null if no wallet is connected or name is unavailable.
  static Future<String?> getWalletName() async {
    try {
      final result = await _channel.invokeMethod<String>('getWalletName');
      return result;
    } on PlatformException catch (e) {
      return null;
    }
  }

  // ============================================================
  // FUTURE TRANSACTION METHODS (Stubbed for MVP)
  // ============================================================

  /// Sign a transaction (NOT IMPLEMENTED IN MVP)
  /// 
  /// This would sign a transaction without submitting it.
  /// Reserved for future implementation.
  static Future<String> signTransaction(String transactionBase64) async {
    throw WalletException('signTransaction not implemented in MVP');
  }

  /// Sign and send a transaction (NOT IMPLEMENTED IN MVP)
  /// 
  /// This would sign and submit a transaction to the network.
  /// Reserved for future implementation.
  static Future<String> signAndSendTransaction(String transactionBase64) async {
    throw WalletException('signAndSendTransaction not implemented in MVP');
  }

  /// Sign a message (NOT IMPLEMENTED IN MVP)
  /// 
  /// This would sign an arbitrary message for verification.
  /// Reserved for future implementation.
  static Future<String> signMessage(String message) async {
    throw WalletException('signMessage not implemented in MVP');
  }
}