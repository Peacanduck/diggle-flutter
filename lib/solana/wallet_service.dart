/// wallet_service.dart
/// High-level wallet service using solana_mobile_client plugin.
///
/// This service wraps the solana_mobile_client plugin and provides:
/// - State management for wallet connection
/// - Connection status tracking
/// - Cluster switching (devnet/mainnet)
/// - Error handling with user-friendly messages
///
/// The wallet is completely optional - game is fully playable without it.
/// Future features could include:
/// - NFT cosmetics for the drill
/// - On-chain leaderboards
/// - Achievement NFTs

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

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

/// Supported Solana clusters
enum SolanaCluster {
  devnet('devnet', 'Devnet', 'https://api.devnet.solana.com', 'wss://api.devnet.solana.com'),
  mainnet('mainnet-beta', 'Mainnet', 'https://api.mainnet-beta.solana.com', 'wss://api.mainnet-beta.solana.com');

  final String value;
  final String displayName;
  final String rpcUrl;
  final String wsUrl;

  const SolanaCluster(this.value, this.displayName, this.rpcUrl, this.wsUrl);
}

/// High-level wallet service with state management
class WalletService extends ChangeNotifier {
  /// Current connection state
  WalletConnectionState _state = WalletConnectionState.disconnected;

  /// Connected wallet's public key (bytes)
  Uint8List? _publicKeyBytes;

  /// Auth token from wallet
  String? _authToken;

  /// Connected wallet app name
  String? _walletName;

  /// Last error message
  String? _errorMessage;

  /// Whether Solana Mobile is available on this device
  bool _isAvailable = false;

  /// Current cluster
  SolanaCluster _cluster = SolanaCluster.devnet;

  /// Solana client for RPC calls (optional, for future balance checks etc.)
  SolanaClient? _solanaClient;

  // ============================================================
  // GETTERS
  // ============================================================

  /// Current connection state
  WalletConnectionState get state => _state;

  /// Whether wallet is connected
  bool get isConnected => _state == WalletConnectionState.connected;

  /// Whether currently connecting
  bool get isConnecting => _state == WalletConnectionState.connecting;

  /// The connected public key as base58 string (null if not connected)
  String? get publicKey {
    if (_publicKeyBytes == null) return null;
    try {
      return Ed25519HDPublicKey(_publicKeyBytes!).toBase58();
    } catch (e) {
      return null;
    }
  }

  /// Shortened public key for display (first 4...last 4)
  String? get shortPublicKey {
    final pk = publicKey;
    if (pk == null || pk.length < 12) return pk;
    return '${pk.substring(0, 4)}...${pk.substring(pk.length - 4)}';
  }

  /// Connected wallet app name
  String? get walletName => _walletName;

  /// Last error message
  String? get errorMessage => _errorMessage;

  /// Whether Solana Mobile is available
  bool get isAvailable => _isAvailable;

  /// Current cluster
  SolanaCluster get cluster => _cluster;

  /// Whether on devnet
  bool get isDevnet => _cluster == SolanaCluster.devnet;

  /// Whether on mainnet
  bool get isMainnet => _cluster == SolanaCluster.mainnet;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initialize the service - check availability
  Future<void> initialize() async {
    try {
      // Check if any wallet apps are installed
      _isAvailable = await _checkWalletAvailability();

      // Initialize Solana client for future RPC calls
      _setupSolanaClient();

      debugPrint('WalletService initialized - available: $_isAvailable, cluster: ${_cluster.displayName}');
    } catch (e) {
      debugPrint('WalletService initialization error: $e');
      _isAvailable = false;
    }
    notifyListeners();
  }

  /// Check if wallet is available by attempting to query
  Future<bool> _checkWalletAvailability() async {
    try {
      // On Android, we assume available and let connection fail gracefully
      // The actual check happens when we try to connect
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Setup Solana RPC client
  void _setupSolanaClient() {
    _solanaClient = SolanaClient(
      rpcUrl: Uri.parse(_cluster.rpcUrl),
      websocketUrl: Uri.parse(_cluster.wsUrl),
    );
  }

  // ============================================================
  // CLUSTER MANAGEMENT
  // ============================================================

  /// Switch cluster - disconnects wallet if connected
  Future<void> setCluster(SolanaCluster cluster) async {
    if (_cluster == cluster) return;

    // Disconnect if connected since auth token is cluster-specific
    if (isConnected) {
      await disconnect();
    }

    _cluster = cluster;
    _setupSolanaClient();

    debugPrint('Cluster switched to: ${_cluster.displayName}');
    notifyListeners();
  }

  /// Toggle between devnet and mainnet
  Future<void> toggleCluster() async {
    if (_cluster == SolanaCluster.devnet) {
      await setCluster(SolanaCluster.mainnet);
    } else {
      await setCluster(SolanaCluster.devnet);
    }
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

    _state = WalletConnectionState.connecting;
    _errorMessage = null;
    notifyListeners();

    LocalAssociationScenario? session;

    try {
      debugPrint('Creating LocalAssociationScenario...');

      // Create a new session
      session = await LocalAssociationScenario.create();

      debugPrint('Session created, starting activity and session concurrently...');

      // IMPORTANT: Don't await startActivityForResult before start()
      // They need to run concurrently - startActivityForResult opens the wallet,
      // and start() establishes the connection
      // ignore: unawaited_futures
      session.startActivityForResult(null);

      // Start the session to get the client
      // This will wait for the wallet to respond
      final client = await session.start();

      debugPrint('Client obtained, authorizing on ${_cluster.displayName}...');

      // Authorize with the wallet
      final result = await client.authorize(
        identityUri: Uri.parse('https://diggle.app'),
        iconUri: Uri.parse('favicon.ico'),
        identityName: 'Diggle',
        cluster: _cluster.value,
      );

      debugPrint('Authorization result: $result');

      if (result != null) {
        _publicKeyBytes = result.publicKey;
        _authToken = result.authToken;
        _walletName = 'Solana Wallet';
        _state = WalletConnectionState.connected;
        _isAvailable = true;

        debugPrint('Wallet connected on ${_cluster.displayName}: $shortPublicKey');
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Authorization was cancelled';
        _state = WalletConnectionState.error;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Wallet connection error: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorMessage = _getUserFriendlyError(e);
      _state = WalletConnectionState.error;
      notifyListeners();
      return false;
    } finally {
      // Always close the session
      if (session != null) {
        try {
          debugPrint('Closing session...');
          await session.close();
          debugPrint('Session closed');
        } catch (e) {
          debugPrint('Error closing session: $e');
        }
      }
    }
  }

  /// Disconnect from the current wallet
  Future<void> disconnect() async {
    if (_state == WalletConnectionState.disconnected) {
      return;
    }

    LocalAssociationScenario? session;

    try {
      if (_authToken != null) {
        debugPrint('Deauthorizing wallet...');

        // Create session to deauthorize
        session = await LocalAssociationScenario.create();

        // Start activity without awaiting, then start session
        // ignore: unawaited_futures
        session.startActivityForResult(null);
        final client = await session.start();

        await client.deauthorize(authToken: _authToken!);

        debugPrint('Wallet deauthorized');
      }
    } catch (e) {
      debugPrint('Disconnect error (ignored): $e');
    } finally {
      if (session != null) {
        try {
          await session.close();
        } catch (e) {
          debugPrint('Error closing session: $e');
        }
      }
    }

    _publicKeyBytes = null;
    _authToken = null;
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

  /// Convert exception to user-friendly message
  String _getUserFriendlyError(dynamic e) {
    final message = e.toString().toLowerCase();

    if (message.contains('cancelled') || message.contains('canceled')) {
      return 'Connection was cancelled';
    }
    if (message.contains('no wallet') || message.contains('not found')) {
      return 'No Solana wallet app found. Please install Phantom, Solflare, or another Solana wallet.';
    }
    if (message.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }
    if (message.contains('denied') || message.contains('rejected')) {
      return 'Authorization was denied';
    }
    if (message.contains('activity')) {
      return 'Could not open wallet app. Please make sure a Solana wallet is installed.';
    }
    if (message.contains('already') && message.contains('started')) {
      return 'Connection already in progress. Please try again.';
    }

    // Default message
    return 'Failed to connect: ${e.toString().length > 100 ? '${e.toString().substring(0, 100)}...' : e.toString()}';
  }

  // ============================================================
  // BALANCE & AIRDROP (for future use)
  // ============================================================

  /// Get SOL balance
  Future<double?> getBalance() async {
    if (!isConnected || _publicKeyBytes == null || _solanaClient == null) {
      return null;
    }

    try {
      final pubKey = Ed25519HDPublicKey(_publicKeyBytes!);
      final balance = await _solanaClient!.rpcClient.getBalance(pubKey.toBase58());
      // Convert lamports to SOL
      return balance.value / 1000000000;
    } catch (e) {
      debugPrint('Error getting balance: $e');
      return null;
    }
  }

  /// Request airdrop (devnet only)
  Future<bool> requestAirdrop({int lamports = 1000000000}) async {
    if (!isConnected || _publicKeyBytes == null || _solanaClient == null) {
      return false;
    }
    if (_cluster != SolanaCluster.devnet) {
      debugPrint('Airdrop only available on devnet');
      return false;
    }

    try {
      await _solanaClient!.requestAirdrop(
        address: Ed25519HDPublicKey(_publicKeyBytes!),
        lamports: lamports,
      );
      return true;
    } catch (e) {
      debugPrint('Airdrop error: $e');
      return false;
    }
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'WalletService(state: $_state, pubkey: $shortPublicKey, cluster: ${_cluster.displayName})';
  }
}

/*/// wallet_service.dart
/// High-level wallet service using solana_mobile_client plugin.
///
/// This service wraps the solana_mobile_client plugin and provides:
/// - State management for wallet connection
/// - Connection status tracking
/// - Error handling with user-friendly messages
///
/// The wallet is completely optional - game is fully playable without it.
/// Future features could include:
/// - NFT cosmetics for the drill
/// - On-chain leaderboards
/// - Achievement NFTs

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

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

  /// Connected wallet's public key (bytes)
  Uint8List? _publicKeyBytes;

  /// Auth token from wallet
  String? _authToken;

  /// Connected wallet app name
  String? _walletName;

  /// Last error message
  String? _errorMessage;

  /// Whether Solana Mobile is available on this device
  bool _isAvailable = false;

  /// Current cluster (testnet or mainnet-beta)
  String _cluster = 'mainnet-beta';

  /// Solana client for RPC calls (optional, for future balance checks etc.)
  SolanaClient? _solanaClient;

  // ============================================================
  // GETTERS
  // ============================================================

  /// Current connection state
  WalletConnectionState get state => _state;

  /// Whether wallet is connected
  bool get isConnected => _state == WalletConnectionState.connected;

  /// Whether currently connecting
  bool get isConnecting => _state == WalletConnectionState.connecting;

  /// The connected public key as base58 string (null if not connected)
  String? get publicKey {
    if (_publicKeyBytes == null) return null;
    try {
      return Ed25519HDPublicKey(_publicKeyBytes!).toBase58();
    } catch (e) {
      return null;
    }
  }

  /// Shortened public key for display (first 4...last 4)
  String? get shortPublicKey {
    final pk = publicKey;
    if (pk == null || pk.length < 12) return pk;
    return '${pk.substring(0, 4)}...${pk.substring(pk.length - 4)}';
  }

  /// Connected wallet app name
  String? get walletName => _walletName;

  /// Last error message
  String? get errorMessage => _errorMessage;

  /// Whether Solana Mobile is available
  bool get isAvailable => _isAvailable;

  /// Current cluster
  String get cluster => _cluster;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Initialize the service - check availability
  Future<void> initialize() async {
    try {
      // Check if any wallet apps are installed
      _isAvailable = await _checkWalletAvailability();

      // Initialize Solana client for future RPC calls
      _setupSolanaClient();

      debugPrint('WalletService initialized - available: $_isAvailable');
    } catch (e) {
      debugPrint('WalletService initialization error: $e');
      _isAvailable = false;
    }
    notifyListeners();
  }

  /// Check if wallet is available by attempting to query
  Future<bool> _checkWalletAvailability() async {
    try {
      // On Android, we assume available and let connection fail gracefully
      // The actual check happens when we try to connect
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Setup Solana RPC client
  void _setupSolanaClient() {
    _solanaClient = SolanaClient(
      rpcUrl: Uri.parse(_cluster == 'mainnet-beta'
          ? 'https://api.mainnet-beta.solana.com'
          : 'https://api.testnet.solana.com'),
      websocketUrl: Uri.parse(_cluster == 'mainnet-beta'
          ? 'wss://api.mainnet-beta.solana.com'
          : 'wss://api.testnet.solana.com'),
    );
  }

  /// Switch cluster
  void setCluster(String cluster) {
    if (cluster != 'mainnet-beta' && cluster != 'testnet') return;
    _cluster = cluster;
    _setupSolanaClient();
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

    _state = WalletConnectionState.connecting;
    _errorMessage = null;
    notifyListeners();

    LocalAssociationScenario? session;

    try {
      debugPrint('Creating LocalAssociationScenario...');

      // Create a new session
      session = await LocalAssociationScenario.create();

      debugPrint('Session created, starting activity and session concurrently...');

      // IMPORTANT: Don't await startActivityForResult before start()
      // They need to run concurrently - startActivityForResult opens the wallet,
      // and start() establishes the connection
      // ignore: unawaited_futures
      session.startActivityForResult(null);

      // Start the session to get the client
      // This will wait for the wallet to respond
      final client = await session.start();

      debugPrint('Client obtained, authorizing...');

      // Authorize with the wallet
      final result = await client.authorize(
        identityUri: Uri.parse('https://diggle.app'),
        iconUri: Uri.parse('favicon.ico'),
        identityName: 'Diggle',
        cluster: _cluster,
      );

      debugPrint('Authorization result: $result');

      if (result != null) {
        _publicKeyBytes = result.publicKey;
        _authToken = result.authToken;
        _walletName = 'Solana Wallet';
        _state = WalletConnectionState.connected;
        _isAvailable = true;

        debugPrint('Wallet connected: $shortPublicKey');
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Authorization was cancelled';
        _state = WalletConnectionState.error;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Wallet connection error: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorMessage = _getUserFriendlyError(e);
      _state = WalletConnectionState.error;
      notifyListeners();
      return false;
    } finally {
      // Always close the session
      if (session != null) {
        try {
          debugPrint('Closing session...');
          await session.close();
          debugPrint('Session closed');
        } catch (e) {
          debugPrint('Error closing session: $e');
        }
      }
    }
  }

  /// Disconnect from the current wallet
  Future<void> disconnect() async {
    if (_state == WalletConnectionState.disconnected) {
      return;
    }

    LocalAssociationScenario? session;

    try {
      if (_authToken != null) {
        debugPrint('Deauthorizing wallet...');

        // Create session to deauthorize
        session = await LocalAssociationScenario.create();

        // Start activity without awaiting, then start session
        // ignore: unawaited_futures
        session.startActivityForResult(null);
        final client = await session.start();

        await client.deauthorize(authToken: _authToken!);

        debugPrint('Wallet deauthorized');
      }
    } catch (e) {
      debugPrint('Disconnect error (ignored): $e');
    } finally {
      if (session != null) {
        try {
          await session.close();
        } catch (e) {
          debugPrint('Error closing session: $e');
        }
      }
    }

    _publicKeyBytes = null;
    _authToken = null;
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

  /// Convert exception to user-friendly message
  String _getUserFriendlyError(dynamic e) {
    final message = e.toString().toLowerCase();

    if (message.contains('cancelled') || message.contains('canceled')) {
      return 'Connection was cancelled';
    }
    if (message.contains('no wallet') || message.contains('not found')) {
      return 'No Solana wallet app found. Please install Phantom, Solflare, or another Solana wallet.';
    }
    if (message.contains('timeout')) {
      return 'Connection timed out. Please try again.';
    }
    if (message.contains('denied') || message.contains('rejected')) {
      return 'Authorization was denied';
    }
    if (message.contains('activity')) {
      return 'Could not open wallet app. Please make sure a Solana wallet is installed.';
    }
    if (message.contains('already') && message.contains('started')) {
      return 'Connection already in progress. Please try again.';
    }

    // Default message
    return 'Failed to connect: ${e.toString().length > 100 ? '${e.toString().substring(0, 100)}...' : e.toString()}';
  }

  // ============================================================
  // FUTURE FEATURES (Stubbed)
  // ============================================================

  /// Get SOL balance (for future use)
  Future<double?> getBalance() async {
    if (!isConnected || _publicKeyBytes == null || _solanaClient == null) {
      return null;
    }

    try {
      final pubKey = Ed25519HDPublicKey(_publicKeyBytes!);
      final balance = await _solanaClient!.rpcClient.getBalance(pubKey.toBase58());
      // Convert lamports to SOL
      return balance.value / 1000000000;
    } catch (e) {
      debugPrint('Error getting balance: $e');
      return null;
    }
  }

  /// Request airdrop (testnet only, for future use)
  Future<bool> requestAirdrop({int lamports = 1000000000}) async {
    if (!isConnected || _publicKeyBytes == null || _solanaClient == null) {
      return false;
    }
    if (_cluster != 'testnet') {
      debugPrint('Airdrop only available on testnet');
      return false;
    }

    try {
      await _solanaClient!.requestAirdrop(
        address: Ed25519HDPublicKey(_publicKeyBytes!),
        lamports: lamports,
      );
      return true;
    } catch (e) {
      debugPrint('Airdrop error: $e');
      return false;
    }
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'WalletService(state: $_state, pubkey: $shortPublicKey, cluster: $_cluster)';
  }
}*/