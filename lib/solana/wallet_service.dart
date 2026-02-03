/// wallet_service.dart
/// Solana wallet integration using solana_mobile_client plugin.
///
/// API pattern:
/// 1. scenario = await LocalAssociationScenario.create()
/// 2. client = await scenario.start()  // start() returns the client!
/// 3. result = await client.authorize(...)
/// 4. await scenario.close()  // ALWAYS close!

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wallet connection state
enum WalletState {
  disconnected,
  connecting,
  connected,
  error,
}

/// Service for Solana wallet operations
class WalletService extends ChangeNotifier {
  WalletState _state = WalletState.disconnected;
  String? _errorMessage;

  // Stored wallet state (persisted)
  String? _authToken;
  String? _publicKey;
  String? _walletName;
  Uri? _walletUriBase;

  // Balance (fetched from RPC)
  double _solBalance = 0.0;

  // Network configuration
  bool _isMainnet = false;

  // Availability flag
  bool _isAvailable = false;

  // RPC endpoints
  static const String _devnetRpc = 'https://api.devnet.solana.com';
  static const String _mainnetRpc = 'https://api.mainnet-beta.solana.com';

  // Treasury wallet for receiving payments (REPLACE WITH YOUR WALLET)
  static const String treasuryWallet = 'EZ2k7zj48yq4rr5ui5EVPMZeZWJXkFp214jTTxbbThim';

  // App identity
  static const String _appName = 'Diggle';
  static const String _appUri = 'https://diggle.app';

  // Storage keys
  static const String _keyAuthToken = 'wallet_auth_token';
  static const String _keyPublicKey = 'wallet_public_key';
  static const String _keyWalletName = 'wallet_name';
  static const String _keyWalletUri = 'wallet_uri_base';
  static const String _keyIsMainnet = 'wallet_is_mainnet';

  // ============================================================
  // GETTERS
  // ============================================================

  WalletState get state => _state;
  bool get isConnected => _state == WalletState.connected && _authToken != null;
  bool get isConnecting => _state == WalletState.connecting;
  String? get publicKey => _publicKey;
  String? get walletName => _walletName;
  double get solBalance => _solBalance;
  String? get errorMessage => _errorMessage;
  bool get isMainnet => _isMainnet;
  bool get isAvailable => _isAvailable;
  String? get walletAddress => _publicKey;

  String get shortAddress {
    if (_publicKey == null || _publicKey!.length < 12) return _publicKey ?? '';
    return '${_publicKey!.substring(0, 6)}...${_publicKey!.substring(_publicKey!.length - 4)}';
  }

  String? get shortPublicKey => _publicKey != null ? shortAddress : null;

  String get _rpcUrl => _isMainnet ? _mainnetRpc : _devnetRpc;
  String get cluster => _isMainnet ? 'mainnet-beta' : 'devnet';

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initialize() async {
    try {
      _isAvailable = await _checkWalletAvailable();

      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(_keyAuthToken);
      _publicKey = prefs.getString(_keyPublicKey);
      _walletName = prefs.getString(_keyWalletName);
      _isMainnet = prefs.getBool(_keyIsMainnet) ?? false;

      final uriString = prefs.getString(_keyWalletUri);
      if (uriString != null) {
        _walletUriBase = Uri.tryParse(uriString);
      }

      if (_authToken != null && _publicKey != null) {
        _state = WalletState.connected;
        await _fetchBalance();
      }

      debugPrint('WalletService initialized: $this');
    } catch (e) {
      debugPrint('WalletService init error: $e');
    }
    notifyListeners();
  }

  Future<bool> _checkWalletAvailable() async {
    try {
      final scenario = await LocalAssociationScenario.create();
      await scenario.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_authToken != null) {
        await prefs.setString(_keyAuthToken, _authToken!);
      } else {
        await prefs.remove(_keyAuthToken);
      }
      if (_publicKey != null) {
        await prefs.setString(_keyPublicKey, _publicKey!);
      } else {
        await prefs.remove(_keyPublicKey);
      }
      if (_walletName != null) {
        await prefs.setString(_keyWalletName, _walletName!);
      } else {
        await prefs.remove(_keyWalletName);
      }
      if (_walletUriBase != null) {
        await prefs.setString(_keyWalletUri, _walletUriBase.toString());
      } else {
        await prefs.remove(_keyWalletUri);
      }
      await prefs.setBool(_keyIsMainnet, _isMainnet);
    } catch (e) {
      debugPrint('Error saving state: $e');
    }
  }

  Future<void> _clearState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAuthToken);
      await prefs.remove(_keyPublicKey);
      await prefs.remove(_keyWalletName);
      await prefs.remove(_keyWalletUri);
    } catch (e) {
      debugPrint('Error clearing state: $e');
    }
  }

  // ============================================================
  // NETWORK
  // ============================================================

  void setMainnet(bool mainnet) {
    _isMainnet = mainnet;
    _saveState();
    if (isConnected) {
      _fetchBalance();
    }
    notifyListeners();
  }

  // ============================================================
  // CONNECTION
  // ============================================================

  Future<bool> connect() async {
    if (_state == WalletState.connecting) return false;

    _state = WalletState.connecting;
    _errorMessage = null;
    notifyListeners();

    LocalAssociationScenario? scenario;

    try {
      // Create scenario
      scenario = await LocalAssociationScenario.create();

      // start() returns the MobileWalletAdapterClient
      final client = await scenario.start();

      // Authorize
      final result = await client.authorize(
        identityUri: Uri.parse(_appUri),
        identityName: _appName,
        cluster: cluster,
      );

      // ALWAYS close
      await scenario.close();
      scenario = null;

      if (result != null && result.accountLabel != null) {
        _authToken = result.authToken;
        _publicKey = result.publicKey as String?;
        _walletName = result.accountLabel ?? 'Wallet';
        _walletUriBase = result.walletUriBase;
        _state = WalletState.connected;

        await _saveState();
        await _fetchBalance();

        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Authorization denied';
        _state = WalletState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (scenario != null) {
        try { await scenario.close(); } catch (_) {}
      }
      _errorMessage = 'Connection failed: $e';
      _state = WalletState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    if (!isConnected || _authToken == null) {
      _resetState();
      return;
    }

    LocalAssociationScenario? scenario;

    try {
      scenario = await LocalAssociationScenario.create();
      final client = await scenario.start();
      await client.deauthorize(authToken: _authToken!);
    } catch (e) {
      debugPrint('Deauthorize error: $e');
    } finally {
      if (scenario != null) {
        try { await scenario.close(); } catch (_) {}
      }
    }

    _resetState();
  }

  void _resetState() {
    _authToken = null;
    _publicKey = null;
    _walletName = null;
    _walletUriBase = null;
    _solBalance = 0.0;
    _errorMessage = null;
    _state = WalletState.disconnected;
    _clearState();
    notifyListeners();
  }

  void clearError() {
    if (_state == WalletState.error) {
      _errorMessage = null;
      _state = WalletState.disconnected;
      notifyListeners();
    }
  }

  // ============================================================
  // BALANCE
  // ============================================================

  Future<void> _fetchBalance() async {
    if (_publicKey == null) return;

    try {
      final client = RpcClient(_rpcUrl);
      final balance = await client.getBalance(_publicKey!);
      _solBalance = balance.value / lamportsPerSol;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching balance: $e');
      _solBalance = 0.0;
    }
  }

  Future<void> refreshBalance() async {
    await _fetchBalance();
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Future<bool> purchaseItem(String itemName, double priceSol) async {
    if (!isConnected || _publicKey == null || _authToken == null) {
      _errorMessage = 'Wallet not connected';
      notifyListeners();
      return false;
    }

    if (_solBalance < priceSol) {
      _errorMessage = 'Insufficient balance';
      notifyListeners();
      return false;
    }

    LocalAssociationScenario? scenario;

    try {
      final rpcClient = RpcClient(_rpcUrl);
      final recentBlockhash = await rpcClient.getLatestBlockhash();

      final fromPubkey = Ed25519HDPublicKey.fromBase58(_publicKey!);
      final toPubkey = Ed25519HDPublicKey.fromBase58(treasuryWallet);
      final lamports = (priceSol * lamportsPerSol).toInt();

      final transferInstruction = SystemInstruction.transfer(
        fundingAccount: fromPubkey,
        recipientAccount: toPubkey,
        lamports: lamports,
      );

      final message = Message.only(transferInstruction);
      final compiledMessage = message.compile(
        recentBlockhash: recentBlockhash.value.blockhash,
        feePayer: fromPubkey,
      );

      final txBytes = compiledMessage.toByteArray();

      // Start wallet session
      scenario = await LocalAssociationScenario.create();
      final client = await scenario.start();

      // Reauthorize
      final reauth = await client.reauthorize(
        identityUri: Uri.parse(_appUri),
        identityName: _appName,
        authToken: _authToken!,
      );

      if (reauth == null) {
        await scenario.close();
        scenario = null;
        _errorMessage = 'Reauthorization failed';
        _resetState();
        return false;
      }

      _authToken = reauth.authToken;
      await _saveState();

      // Sign and send
      final signatures = await client.signAndSendTransactions(
        transactions: [Uint8List.fromList(txBytes as List<int>)],
      );

      await scenario.close();
      scenario = null;

      if (signatures.signatures.isNotEmpty) {
        debugPrint('Transaction sent!');
        await Future.delayed(const Duration(seconds: 2));
        await _fetchBalance();
        return true;
      } else {
        _errorMessage = 'Transaction rejected';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Transaction failed: $e';
      notifyListeners();
      return false;
    } finally {
      if (scenario != null) {
        try { await scenario.close(); } catch (_) {}
      }
    }
  }

  Future<bool> requestAirdrop({double amount = 1.0}) async {
    if (!isConnected || _publicKey == null) return false;
    if (_isMainnet) {
      _errorMessage = 'Airdrop only on devnet';
      notifyListeners();
      return false;
    }

    try {
      final client = RpcClient(_rpcUrl);
      final lamports = (amount * lamportsPerSol).toInt();

      await client.requestAirdrop(
        _publicKey!,
        lamports,
        commitment: Commitment.confirmed,
      );

      await Future.delayed(const Duration(seconds: 2));
      await _fetchBalance();
      return true;
    } catch (e) {
      _errorMessage = 'Airdrop failed: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  String toString() => 'WalletService($_state, $shortAddress, $_solBalance SOL)';
}