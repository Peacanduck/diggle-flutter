/// wallet_service.dart
/// High-level wallet service using solana_mobile_client plugin.
///
/// This service wraps the solana_mobile_client plugin and provides:
/// - State management for wallet connection
/// - Connection status tracking
/// - Cluster switching (devnet/mainnet) — devnet only in debug builds
/// - Transaction signing and sending via MWA
/// - Error handling with user-friendly messages
///
/// The wallet is completely optional - game is fully playable without it.
///
/// NOTE: Devnet support varies by wallet. Phantom has good devnet support,
/// but some other wallets may not fully support devnet through MWA.

import 'dart:convert';
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
  devnet('devnet', 'Devnet', 'https://api.devnet.solana.com',
      'wss://api.devnet.solana.com'),
  mainnet('mainnet-beta', 'Mainnet', 'https://api.mainnet-beta.solana.com',
      'wss://api.mainnet-beta.solana.com');

  final String value;
  final String displayName;
  final String rpcUrl;
  final String wsUrl;

  const SolanaCluster(this.value, this.displayName, this.rpcUrl, this.wsUrl);
}

/// High-level wallet service with state management
class WalletService extends ChangeNotifier {
  // Mobile Wallet Adapter identity, sent on every authorize/reauthorize.
  // Wallets verify the app against the Digital Asset Links file on this
  // domain (/.well-known/assetlinks.json lists com.example.diggle and its
  // release signing key) and warn "identity could not be verified"
  // otherwise. They also look up the dApp's icon by domain, so Diggle has
  // its own host whose root, favicon.ico and page head are all Diggle's;
  // a path under the shared pydigital.xyz hub left wallets showing "?".
  // Only release-signed builds verify (a debug key isn't in the file).
  static final Uri _identityUri = Uri.parse('https://diggle.pydigital.xyz');
  static final Uri _iconUri = Uri.parse('diggle-icon.png');
  static const String _identityName = 'Diggle';

  /// Current connection state
  WalletConnectionState _state = WalletConnectionState.disconnected;

  /// Connected wallet's public key (bytes)
  Uint8List? _publicKeyBytes;

  /// Auth token from wallet (used for reauthorization in signing sessions)
  String? _authToken;

  /// Connected wallet app name
  String? _walletName;

  /// Last error message
  String? _errorMessage;

  /// Whether Solana Mobile is available on this device
  bool _isAvailable = false;

  /// Current cluster — defaults to mainnet in release, devnet in debug
  SolanaCluster _cluster = kDebugMode ? SolanaCluster.devnet : SolanaCluster.mainnet;

  /// Solana client for RPC calls
  SolanaClient? _solanaClient;

  // ============================================================
  // GETTERS
  // ============================================================

  WalletConnectionState get state => _state;
  bool get isConnected => _state == WalletConnectionState.connected;
  bool get isConnecting => _state == WalletConnectionState.connecting;

  String? get publicKey {
    if (_publicKeyBytes == null) return null;
    try {
      return Ed25519HDPublicKey(_publicKeyBytes!).toBase58();
    } catch (e) {
      return null;
    }
  }

  /// Get public key as Ed25519HDPublicKey (for transaction building)
  Ed25519HDPublicKey? get publicKeyObject {
    if (_publicKeyBytes == null) return null;
    try {
      return Ed25519HDPublicKey(_publicKeyBytes!);
    } catch (e) {
      return null;
    }
  }

  String? get shortPublicKey {
    final pk = publicKey;
    if (pk == null || pk.length < 12) return pk;
    return '${pk.substring(0, 4)}...${pk.substring(pk.length - 4)}';
  }

  String? get walletName => _walletName;
  String? get errorMessage => _errorMessage;
  bool get isAvailable => _isAvailable;
  SolanaCluster get cluster => _cluster;
  bool get isDevnet => _cluster == SolanaCluster.devnet;
  bool get isMainnet => _cluster == SolanaCluster.mainnet;

  /// Whether cluster switching is allowed (debug builds only)
  bool get canSwitchCluster => kDebugMode;

  /// Get the Solana RPC client (for direct RPC calls from other services)
  SolanaClient? get solanaClient => _solanaClient;

  /// Get the auth token (needed by other services for MWA reauth)
  String? get authToken => _authToken;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initialize() async {
    try {
      _isAvailable = await _checkWalletAvailability();
      _setupSolanaClient();
      debugPrint(
          'WalletService initialized - available: $_isAvailable, '
              'cluster: ${_cluster.displayName}, '
              'debug: $kDebugMode');
    } catch (e) {
      debugPrint('WalletService initialization error: $e');
      _isAvailable = false;
    }
    notifyListeners();
  }

  Future<bool> _checkWalletAvailability() async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  void _setupSolanaClient() {
    _solanaClient = SolanaClient(
      rpcUrl: Uri.parse(_cluster.rpcUrl),
      websocketUrl: Uri.parse(_cluster.wsUrl),
    );
  }

  // ============================================================
  // CLUSTER MANAGEMENT
  // ============================================================

  Future<void> setCluster(SolanaCluster cluster) async {
    // In release builds, only allow mainnet
    if (!kDebugMode && cluster == SolanaCluster.devnet) {
      debugPrint('WalletService: devnet not available in release builds');
      return;
    }
    if (_cluster == cluster) return;
    if (isConnected) {
      await disconnect();
    }
    _cluster = cluster;
    _setupSolanaClient();
    debugPrint('Cluster switched to: ${_cluster.displayName}');
    notifyListeners();
  }

  Future<void> toggleCluster() async {
    // Only allow toggling in debug builds
    if (!kDebugMode) {
      debugPrint('WalletService: cluster toggle disabled in release builds');
      return;
    }
    if (_cluster == SolanaCluster.devnet) {
      await setCluster(SolanaCluster.mainnet);
    } else {
      await setCluster(SolanaCluster.devnet);
    }
  }

  // ============================================================
  // CONNECTION MANAGEMENT
  // ============================================================

  Future<bool> connect() async {
    if (_state == WalletConnectionState.connecting) {
      return false;
    }

    _state = WalletConnectionState.connecting;
    _errorMessage = null;
    notifyListeners();

    LocalAssociationScenario? session;

    try {
      debugPrint('Creating LocalAssociationScenario...');
      session = await LocalAssociationScenario.create();

      debugPrint(
          'Session created, starting activity and session concurrently...');
      // ignore: unawaited_futures
      session.startActivityForResult(null);
      final client = await session.start();

      debugPrint('Client obtained, authorizing on ${_cluster.displayName}...');

      final result = await client.authorize(
        identityUri: _identityUri,
        iconUri: _iconUri,
        identityName: _identityName,
        cluster: _cluster.value,
      );

      debugPrint('Authorization result: $result');

      if (result != null) {
        _publicKeyBytes = result.publicKey;
        _authToken = result.authToken;
        _walletName = 'Solana Wallet';
        _state = WalletConnectionState.connected;
        _isAvailable = true;

        debugPrint(
            'Wallet connected on ${_cluster.displayName}: $shortPublicKey');
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

  Future<void> disconnect() async {
    if (_state == WalletConnectionState.disconnected) {
      return;
    }

    debugPrint('Disconnecting wallet (clearing local state)...');
    _publicKeyBytes = null;
    _authToken = null;
    _walletName = null;
    _errorMessage = null;
    _state = WalletConnectionState.disconnected;
    debugPrint('Wallet disconnected');
    notifyListeners();
  }

  Future<void> disconnectAndDeauthorize() async {
    if (_state == WalletConnectionState.disconnected) {
      return;
    }

    LocalAssociationScenario? session;

    try {
      if (_authToken != null) {
        debugPrint('Deauthorizing wallet...');
        session = await LocalAssociationScenario.create();
        // ignore: unawaited_futures
        session.startActivityForResult(null);
        final client = await session.start();
        await client.deauthorize(authToken: _authToken!);
        debugPrint('Wallet deauthorized');
      }
    } catch (e) {
      debugPrint('Deauthorize error (ignored): $e');
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

  void clearError() {
    if (_state == WalletConnectionState.error) {
      _errorMessage = null;
      _state = WalletConnectionState.disconnected;
      notifyListeners();
    }
  }

  // ============================================================
  // TRANSACTION SIGNING & SENDING
  // ============================================================

  /// Have the wallet sign AND submit a single-signer transaction (MWA
  /// `sign_and_send_transactions`), for example the Miner's Pass SKR
  /// transfer built by the miners-pass edge function.
  ///
  /// Letting the wallet send is what Phantom expects: it simulates the
  /// transaction, may add its own guard instructions (Lighthouse) before
  /// submitting, and the app-switch network drop no longer matters. So the
  /// transaction that lands can differ from [serializedTransaction] —
  /// verify payments by their instructions, never by byte equality.
  ///
  /// Not for transactions that need another signer after the wallet (the
  /// wallet would submit before that signature exists): use
  /// [signTransaction] for those.
  ///
  /// Wallets that can only sign get the old path: sign via MWA, then
  /// submit via RPC with retries.
  ///
  /// Returns the transaction signature (base58) on success, null on failure.
  /// Sets [errorMessage] on failure.
  Future<String?> signAndSendTransaction(
      Uint8List serializedTransaction) async {
    if (!isConnected || _authToken == null) {
      _errorMessage = 'Wallet not connected';
      notifyListeners();
      return null;
    }

    LocalAssociationScenario? session;
    Uint8List? signedForRpc;

    try {
      debugPrint('Opening MWA session for sign-and-send...');
      session = await LocalAssociationScenario.create();

      // ignore: unawaited_futures
      session.startActivityForResult(null);
      final client = await session.start();

      if (!await _reauthorize(client)) return null;

      GetCapabilitiesResult? capabilities;
      try {
        capabilities = await client.getCapabilities();
      } catch (e) {
        debugPrint('get_capabilities failed ($e); assuming sign-and-send');
      }

      if (capabilities?.supportsSignAndSendTransactions ?? true) {
        debugPrint('Wallet sign-and-send (${serializedTransaction.length} bytes)...');
        final result = await client.signAndSendTransactions(
          transactions: [serializedTransaction],
        );
        if (result.signatures.isNotEmpty) {
          final signature = _bytesToBase58(result.signatures.first);
          debugPrint('Wallet submitted transaction: $signature');
          return signature;
        }
        _errorMessage = 'Transaction was cancelled or could not be sent';
        notifyListeners();
        return null;
      }

      debugPrint('Wallet cannot sign-and-send; signing for RPC submission...');
      final result = await client.signTransactions(
        transactions: [serializedTransaction],
      );
      if (result.signedPayloads.isEmpty) {
        _errorMessage = 'Transaction signing was cancelled';
        notifyListeners();
        return null;
      }
      signedForRpc = Uint8List.fromList(result.signedPayloads.first);
    } catch (e, stackTrace) {
      debugPrint('Sign-and-send error: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorMessage = _getTransactionError(e);
      notifyListeners();
      return null;
    } finally {
      if (session != null) {
        try {
          await session.close();
        } catch (e) {
          debugPrint('Error closing MWA session: $e');
        }
      }
    }

    return _submitViaRpc(signedForRpc);
  }

  /// Submit a fully signed transaction via RPC.
  ///
  /// Includes retry logic because Android may temporarily lose network
  /// connectivity when switching back from the wallet app.
  Future<String?> _submitViaRpc(Uint8List signedTxBytes) async {
    final encodedTx = base64Encode(signedTxBytes);
    const maxRetries = 3;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (attempt > 1) {
          debugPrint('Retry $attempt/$maxRetries - waiting for network...');
          await Future.delayed(Duration(seconds: attempt));
        }
        debugPrint('Submitting signed transaction via RPC (${signedTxBytes.length} bytes)...');
        final signatureBase58 = await _solanaClient!.rpcClient.sendTransaction(
          encodedTx,
          preflightCommitment: Commitment.confirmed,
        );
        debugPrint('Transaction submitted! Signature: $signatureBase58');
        return signatureBase58;
      } catch (e) {
        debugPrint('RPC sendTransaction error (attempt $attempt): $e');
        final isNetworkError = e.toString().contains('SocketException') ||
            e.toString().contains('host lookup') ||
            e.toString().contains('Connection refused') ||
            e.toString().contains('Network is unreachable');

        if (!isNetworkError || attempt == maxRetries) {
          debugPrint('Signed tx first 4 bytes: ${signedTxBytes.take(4).toList()}');
          debugPrint('Signed tx length: ${signedTxBytes.length}');
          _errorMessage = isNetworkError
              ? 'Network unavailable after wallet switch. Please try again.'
              : 'Failed to submit transaction: ${e.toString()}';
          notifyListeners();
          return null;
        }
      }
    }
    return null;
  }

  /// Sign a transaction without sending, for multi-signer flows like NFT
  /// minting.
  ///
  /// Pass the transaction with NO signatures yet and add the others to the
  /// result: Phantom has to sign first to simulate a multi-signer
  /// transaction and add its guard instructions, and otherwise warns that
  /// the app "could be malicious". The wallet may change the message, so
  /// later signers must sign the message in the returned bytes.
  ///
  /// Returns the signed transaction bytes, or null on failure.
  Future<Uint8List?> signTransaction(Uint8List serializedTransaction) async {
    if (!isConnected || _authToken == null) {
      _errorMessage = 'Wallet not connected';
      notifyListeners();
      return null;
    }

    LocalAssociationScenario? session;

    try {
      debugPrint('Opening MWA session for transaction signing...');
      session = await LocalAssociationScenario.create();

      // ignore: unawaited_futures
      session.startActivityForResult(null);
      final client = await session.start();

      if (!await _reauthorize(client)) return null;

      // Sign only (don't send)
      debugPrint('Signing transaction (${serializedTransaction.length} bytes)...');
      debugPrint('First 8 bytes: ${serializedTransaction.take(8).toList()}');
      final result = await client.signTransactions(
        transactions: [serializedTransaction],
      );

      if (result.signedPayloads.isNotEmpty) {
        debugPrint('Transaction signed successfully');
        return Uint8List.fromList(result.signedPayloads.first);
      }

      _errorMessage = 'Transaction signing was cancelled';
      notifyListeners();
      return null;
    } catch (e, stackTrace) {
      debugPrint('Transaction signing error: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorMessage = _getTransactionError(e);
      notifyListeners();
      return null;
    } finally {
      if (session != null) {
        try {
          await session.close();
        } catch (e) {
          debugPrint('Error closing MWA session: $e');
        }
      }
    }
  }

  /// Reauthorize this session with the stored auth token, falling back to
  /// a fresh authorize. Returns false (with [errorMessage] set) if the
  /// wallet refused both.
  Future<bool> _reauthorize(MobileWalletAdapterClient client) async {
    debugPrint('Reauthorizing...');
    final reauth = await client.reauthorize(
      identityUri: _identityUri,
      iconUri: _iconUri,
      identityName: _identityName,
      authToken: _authToken!,
    );

    if (reauth != null) {
      _authToken = reauth.authToken;
      return true;
    }

    final freshAuth = await client.authorize(
      identityUri: _identityUri,
      iconUri: _iconUri,
      identityName: _identityName,
      cluster: _cluster.value,
    );
    if (freshAuth == null) {
      _errorMessage = 'Authorization failed';
      notifyListeners();
      return false;
    }
    _publicKeyBytes = freshAuth.publicKey;
    _authToken = freshAuth.authToken;
    return true;
  }

  // ============================================================
  // MESSAGE SIGNING (for Sign In With Solana)
  // ============================================================

  /// Sign a message (arbitrary bytes) via MWA.
  ///
  /// Used for wallet-based authentication (Sign In With Solana).
  /// The wallet app will show the message and ask the user to approve.
  ///
  /// [messageBytes] - the raw message bytes to sign
  ///
  /// Returns the 64-byte ed25519 signature, or null on failure.
  Future<Uint8List?> signMessage(Uint8List messageBytes) async {
    if (!isConnected || _authToken == null) {
      _errorMessage = 'Wallet not connected';
      notifyListeners();
      return null;
    }

    LocalAssociationScenario? session;

    try {
      debugPrint('Opening MWA session for message signing...');
      session = await LocalAssociationScenario.create();

      // ignore: unawaited_futures
      session.startActivityForResult(null);
      final client = await session.start();

      if (!await _reauthorize(client)) return null;

      // Sign the message
      debugPrint('Signing message (${messageBytes.length} bytes)...');
      final result = await client.signMessages(
        messages: [messageBytes],
        addresses: [_publicKeyBytes!],
      );

      if (result != null && result.signedMessages.isNotEmpty) {
        final signedMessage = result.signedMessages.first;
        if (signedMessage.signatures.isNotEmpty) {
          final signature = Uint8List.fromList(signedMessage.signatures.first);
          debugPrint('Message signed successfully (${signature.length} bytes)');
          return signature;
        }
      }

      _errorMessage = 'Message signing was cancelled';
      notifyListeners();
      return null;
    } catch (e, stackTrace) {
      debugPrint('Message signing error: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorMessage = _getTransactionError(e);
      notifyListeners();
      return null;
    } finally {
      if (session != null) {
        try {
          await session.close();
        } catch (e) {
          debugPrint('Error closing MWA session: $e');
        }
      }
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

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
    if (message.contains('cluster') || message.contains('network')) {
      return 'Network not supported by this wallet. Try Phantom for devnet support.';
    }

    return 'Failed to connect: ${e.toString().length > 100 ? '${e.toString().substring(0, 100)}...' : e.toString()}';
  }

  /// Transaction-specific error messages
  String _getTransactionError(dynamic e) {
    final message = e.toString().toLowerCase();

    if (message.contains('cancelled') || message.contains('canceled')) {
      return 'Transaction was cancelled by user';
    }
    if (message.contains('insufficient') || message.contains('not enough')) {
      return 'Insufficient SOL balance for this transaction';
    }
    if (message.contains('rejected') || message.contains('denied')) {
      return 'Transaction was rejected';
    }
    if (message.contains('timeout')) {
      return 'Transaction timed out. Please try again.';
    }
    if (message.contains('blockhash')) {
      return 'Transaction expired. Please try again.';
    }
    if (message.contains('reauthorize') || message.contains('auth')) {
      return 'Wallet session expired. Please reconnect.';
    }

    return 'Transaction failed: ${e.toString().length > 100 ? '${e.toString().substring(0, 100)}...' : e.toString()}';
  }

  // ============================================================
  // BALANCE & AIRDROP
  // ============================================================

  Future<double?> getBalance() async {
    if (!isConnected || _publicKeyBytes == null || _solanaClient == null) {
      return null;
    }

    try {
      final pubKey = Ed25519HDPublicKey(_publicKeyBytes!);
      final balance =
      await _solanaClient!.rpcClient.getBalance(pubKey.toBase58());
      return balance.value / 1000000000;
    } catch (e) {
      debugPrint('Error getting balance: $e');
      return null;
    }
  }

  Future<bool> requestAirdrop({int lamports = 1000000000}) async {
    if (!isConnected || _publicKeyBytes == null || _solanaClient == null) {
      return false;
    }
    if (_cluster != SolanaCluster.devnet) {
      debugPrint('Airdrop only available on devnet');
      return false;
    }
    // Extra guard: only allow in debug builds
    if (!kDebugMode) {
      debugPrint('Airdrop disabled in release builds');
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
  // BASE58 HELPER
  // ============================================================

  /// Convert raw signature bytes to base58 string
  String _bytesToBase58(Uint8List bytes) {
    const alphabet =
        '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

    if (bytes.isEmpty) return '';

    var value = BigInt.zero;
    for (final byte in bytes) {
      value = (value << 8) | BigInt.from(byte);
    }

    final result = StringBuffer();
    while (value > BigInt.zero) {
      final remainder = (value % BigInt.from(58)).toInt();
      value = value ~/ BigInt.from(58);
      result.write(alphabet[remainder]);
    }

    for (final byte in bytes) {
      if (byte == 0) {
        result.write(alphabet[0]);
      } else {
        break;
      }
    }

    return result.toString().split('').reversed.join();
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'WalletService(state: $_state, pubkey: $shortPublicKey, cluster: ${_cluster.displayName})';
  }
}