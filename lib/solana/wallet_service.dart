/// wallet_service.dart
/// High-level wallet service for Solana Mobile integration.
/// 
/// This service wraps the platform channel and provides:
/// - State management for wallet connection
/// - Automatic reconnection handling
/// - Connection status tracking
/// - Error handling with user-friendly messages
/// 
/// The wallet is completely optional - game is fully playable without it.
/// Future features could include:
/// - NFT cosmetics for the drill
/// - On-chain leaderboards
/// - Achievement NFTs

import 'package:flutter/foundation.dart';
import 'wallet_channel.dart';

/// Wallet connection state
enum WalletConnectionState {
  /// No wallet connected, not attempting connection
  disconnected,
  
  /// Currently attempting to connect
  connecting,
  
  /// Successfully connected to wallet
  connected,
  
  /// Connection failed
  error,
}

/// High-level wallet service with state management
class WalletService extends ChangeNotifier {
  /// Current connection state
  WalletConnectionState _state = WalletConnectionState.disconnected;

  /// Connected wallet's public key (base58)
  String? _publicKey;

  /// Connected wallet app name
  String? _walletName;

  /// Last error message
  String? _errorMessage;

  /// Whether Solana Mobile is available on this device
  bool _isAvailable = false;

  // ============================================================
  // GETTERS
  // ============================================================

  /// Current connection state
  WalletConnectionState get state => _state;

  /// Whether wallet is connected
  bool get isConnected => _state == WalletConnectionState.connected;

  /// Whether currently connecting
  bool get isConnecting => _state == WalletConnectionState.connecting;

  /// The connected public key (null if not connected)
  String? get publicKey => _publicKey;

  /// Shortened public key for display (first 4...last 4)
  String? get shortPublicKey {
    if (_publicKey == null || _publicKey!.length < 12) return _publicKey;
    return '${_publicKey!.substring(0, 4)}...${_publicKey!.substring(_publicKey!.length - 4)}';
  }

  /// Connected wallet app name
  String? get walletName => _walletName;

  /// Last error message
  String? get errorMessage => _errorMessage;

  /// Whether Solana Mobile is available
  bool get isAvailable => _isAvailable;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initialize the service - check availability
  Future<void> initialize() async {
    try {
      _isAvailable = await WalletChannel.isAvailable();
      
      // Check for existing connection
      if (_isAvailable) {
        final existingKey = await WalletChannel.getPublicKey();
        if (existingKey != null) {
          _publicKey = existingKey;
          _walletName = await WalletChannel.getWalletName();
          _state = WalletConnectionState.connected;
        }
      }
    } catch (e) {
      debugPrint('WalletService initialization error: $e');
      _isAvailable = false;
    }
    notifyListeners();
  }

  // ============================================================
  // CONNECTION MANAGEMENT
  // ============================================================

  /// Connect to a Solana wallet
  /// 
  /// Opens the wallet app for authorization.
  /// Returns true on success, false on failure.
  Future<bool> connect() async {
    if (_state == WalletConnectionState.connecting) {
      return false; // Already connecting
    }

    if (!_isAvailable) {
      _errorMessage = 'No Solana wallet app installed';
      _state = WalletConnectionState.error;
      notifyListeners();
      return false;
    }

    _state = WalletConnectionState.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      _publicKey = await WalletChannel.connect();
      _walletName = await WalletChannel.getWalletName();
      _state = WalletConnectionState.connected;
      notifyListeners();
      return true;
    } on WalletException catch (e) {
      _errorMessage = _getUserFriendlyError(e);
      _state = WalletConnectionState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Connection failed: $e';
      _state = WalletConnectionState.error;
      notifyListeners();
      return false;
    }
  }

  /// Disconnect from the current wallet
  Future<void> disconnect() async {
    if (_state == WalletConnectionState.disconnected) {
      return;
    }

    try {
      await WalletChannel.disconnect();
    } catch (e) {
      debugPrint('Disconnect error (ignored): $e');
    }

    _publicKey = null;
    _walletName = null;
    _errorMessage = null;
    _state = WalletConnectionState.disconnected;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    if (_state == WalletConnectionState.error) {
      _errorMessage = null;
      _state = WalletConnectionState.disconnected;
      notifyListeners();
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  /// Convert WalletException to user-friendly message
  String _getUserFriendlyError(WalletException e) {
    switch (e.code) {
      case 'NOT_AUTHORIZED':
        return 'Wallet authorization was denied';
      case 'NOT_SIGNED':
        return 'Transaction signing was cancelled';
      case 'NO_WALLET':
        return 'No Solana wallet app found';
      case 'TIMEOUT':
        return 'Wallet connection timed out';
      default:
        return e.message;
    }
  }

  // ============================================================
  // FUTURE FEATURES (Stubbed)
  // ============================================================

  /// Sign a transaction (NOT IMPLEMENTED)
  /// Reserved for future NFT minting, etc.
  Future<String?> signTransaction(String transactionBase64) async {
    if (!isConnected) return null;
    // TODO: Implement when needed
    throw UnimplementedError('Transaction signing not available in MVP');
  }

  /// Get SOL balance (NOT IMPLEMENTED)
  /// Would need RPC connection to Solana network
  Future<double?> getBalance() async {
    if (!isConnected) return null;
    // TODO: Implement with Solana RPC
    throw UnimplementedError('Balance check not available in MVP');
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'WalletService(state: $_state, pubkey: $shortPublicKey)';
  }
}