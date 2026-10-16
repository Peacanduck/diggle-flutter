/// candy_machine_service.dart
/// Service for interacting with the Diggle NFT Candy Machine.
///
/// Architecture:
///   1. Generates the NFT mint keypair on device and asks the candy-machine
///      edge function for an UNSIGNED, simulated mint transaction + its cost
///   2. The player reviews the cost; the wallet signs first via MWA
///   3. The mint keypair co-signs what the wallet returned (Phantom needs
///      the wallet to sign a multi-signer transaction first) and the app
///      sends it to the Solana network
///   4. Detects NFT ownership via RPC (getTokenAccountsByOwner + metadata)
///
/// The mint API (Node.js) handles the complex Metaplex instruction building
/// using the official Umi SDK, while the Flutter app handles signing and sending.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'tx_cosign.dart';
import 'wallet_service.dart';

/// Mint status for tracking the minting flow
enum MintStatus {
  idle,
  fetchingTransaction,
  awaitingSignature,
  sending,
  confirming,
  success,
  error,
}

/// Information about the candy machine state
class CandyMachineInfo {
  final String candyMachineId;
  final String collectionMint;
  final int itemsAvailable;
  final int itemsRedeemed;
  final int itemsRemaining;
  final String symbol;
  final double? mintPriceSol;
  final int? mintLimit;
  final DateTime? startDate;
  final bool hasGuard;
  final String? rpcUrl;
  final String? network;

  CandyMachineInfo({
    required this.candyMachineId,
    required this.collectionMint,
    required this.itemsAvailable,
    required this.itemsRedeemed,
    required this.itemsRemaining,
    required this.symbol,
    this.mintPriceSol,
    this.mintLimit,
    this.startDate,
    this.hasGuard = false,
    this.rpcUrl,
    this.network,
  });

  bool get isSoldOut => itemsRemaining <= 0;
  bool get isMintLive =>
      startDate == null || DateTime.now().isAfter(startDate!);

  factory CandyMachineInfo.fromJson(Map<String, dynamic> json) {
    final guard = json['guard'] as Map<String, dynamic>?;
    double? price;
    int? limit;
    DateTime? start;

    if (guard != null) {
      if (guard['hasSolPayment'] == true && guard['solPaymentLamports'] != null) {
        price = (guard['solPaymentLamports'] as num) / 1e9;
      }
      if (guard['hasMintLimit'] == true) {
        limit = guard['mintLimit'] as int?;
      }
      if (guard['hasStartDate'] == true && guard['startDate'] != null) {
        start = DateTime.tryParse(guard['startDate'].toString());
      }
    }

    return CandyMachineInfo(
      candyMachineId: json['candyMachine'] as String,
      collectionMint: json['collectionMint'] as String,
      itemsAvailable: json['itemsAvailable'] as int,
      itemsRedeemed: json['itemsRedeemed'] as int,
      itemsRemaining: json['itemsRemaining'] as int,
      symbol: json['symbol'] as String? ?? '',
      mintPriceSol: price,
      mintLimit: limit,
      startDate: start,
      hasGuard: guard != null,
      rpcUrl: json['rpcUrl'] as String?,
      network: json['network'] as String?,
    );
  }
}

/// Holds info about a user's owned Diggle NFT
class OwnedDiggleNFT {
  final String mintAddress;
  final String tokenAccount;
  final String? name;
  final String? imageUri;

  /// Off-chain metadata JSON URI (from on-chain metadata). Used by the
  /// gear system to parse trait attributes post-reveal.
  final String? metadataUri;

  OwnedDiggleNFT({
    required this.mintAddress,
    required this.tokenAccount,
    this.name,
    this.imageUri,
    this.metadataUri,
  });

  Map<String, dynamic> toJson() => {
        'mint': mintAddress,
        'ta': tokenAccount,
        'name': name,
        'img': imageUri,
        'meta': metadataUri,
      };

  static OwnedDiggleNFT? fromJson(Map<String, dynamic> json) {
    final mint = json['mint'] as String?;
    final ta = json['ta'] as String?;
    if (mint == null || ta == null) return null;
    return OwnedDiggleNFT(
      mintAddress: mint,
      tokenAccount: ta,
      name: json['name'] as String?,
      imageUri: json['img'] as String?,
      metadataUri: json['meta'] as String?,
    );
  }
}

/// What one mint costs, from the edge function's simulation of the exact
/// transaction the wallet will be asked to sign. Amounts in lamports.
class MintQuote {
  /// The guard's SOL payment, paid to [destination].
  final int priceLamports;

  /// Rent held in the new NFT's accounts (mint, token account, metadata,
  /// edition).
  final int rentLamports;

  /// Network and priority fees.
  final int feeLamports;
  final int totalLamports;

  /// Wallet that receives the price.
  final String destination;

  const MintQuote({
    required this.priceLamports,
    required this.rentLamports,
    required this.feeLamports,
    required this.totalLamports,
    required this.destination,
  });

  factory MintQuote.fromJson(Map<String, dynamic> json) {
    int lamports(String key) => (json[key] as num?)?.toInt() ?? 0;
    final price = lamports('priceLamports');
    final rent = lamports('rentLamports');
    final fee = lamports('feeLamports');
    return MintQuote(
      priceLamports: price,
      rentLamports: rent,
      feeLamports: fee,
      totalLamports: json['totalLamports'] == null
          ? price + rent + fee
          : lamports('totalLamports'),
      destination: json['destination'] as String? ?? '',
    );
  }
}

/// A mint built and simulated by the edge function, waiting for the
/// player to approve its [quote].
class PreparedMint {
  /// Unsigned: the wallet signs first, then [mintKey].
  final Uint8List transaction;

  /// The new NFT's mint keypair, generated on this device.
  final Ed25519HDKeyPair mintKey;
  final MintQuote quote;
  final DateTime builtAt;

  const PreparedMint({
    required this.transaction,
    required this.mintKey,
    required this.quote,
    required this.builtAt,
  });
}

/// Service for Candy Machine minting and NFT detection
class CandyMachineService extends ChangeNotifier {
  final WalletService _wallet;

  /// Supabase project URL — the edge function is at
  /// {supabaseUrl}/functions/v1/candy-machine/{route}
  String _supabaseUrl;
  String _supabaseAnonKey;

  /// Get the SolanaClient from the wallet service (cluster-aware).
  /// Falls back to creating one from the wallet service's current cluster.
  SolanaClient get _solanaClient {
    final client = _wallet.solanaClient;
    if (client != null) return client;
    // Should never happen if wallet service is initialized
    throw StateError('SolanaClient not available — WalletService not initialized');
  }

  /// Known collection mints for Diggle NFTs (per cluster)
  static const String mainnetCollectionMint =
      '3FJkKz61tMRt3rDzGk1Xp6mTN8kGYXtwSTgYaYEmx5fG';
  static const String devnetCollectionMint =
      '4eFNHpLUiVEAh2wi9K1YLUEeTdDYJgjiLhgEkxbw8upV';

  /// Collection mint for the wallet's current cluster.
  String get collectionMint =>
      _wallet.isDevnet ? devnetCollectionMint : mainnetCollectionMint;

  /// Metaplex Token Metadata program ID
  static const String _tokenMetadataProgram =
      'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s';

  // ── Seeker Genesis Token (Token-2022) ──────────────────────────
  // Per Solana Mobile docs: verify (1) mint authority, (2) metadata
  // pointer, (3) token group member — all three must match.
  static const String _token2022Program =
      'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb';
  static const String _sgtMintAuthority =
      'GT2zuHVaZQYZSyQMgJPLzvkmyztfyXg2NJunqFp4p3A4';
  static const String _sgtMetadataAddress =
      'GT22s89nU4iWFkNXj1Bw6uYhJJWDRPpShHt4Bk8f99Te';
  // Metadata and group address are intentionally the same account.
  static const String _sgtGroupAddress =
      'GT22s89nU4iWFkNXj1Bw6uYhJJWDRPpShHt4Bk8f99Te';

  // ============================================================
  // STATE
  // ============================================================

  MintStatus _mintStatus = MintStatus.idle;
  String? _error;
  String? _lastMintSignature;
  String? _lastMintedNFT;
  CandyMachineInfo? _info;
  OwnedDiggleNFT? _ownedNFT;
  final List<OwnedDiggleNFT> _ownedNFTs = [];
  bool _isLoadingInfo = false;
  bool _isCheckingOwnership = false;

  // ============================================================
  // GETTERS
  // ============================================================

  MintStatus get mintStatus => _mintStatus;
  String? get error => _error;
  String? get lastMintSignature => _lastMintSignature;
  String? get lastMintedNFT => _lastMintedNFT;
  CandyMachineInfo? get info => _info;
  OwnedDiggleNFT? get ownedNFT => _ownedNFT;

  /// All Diggle NFTs in the connected wallet (a holder can own several).
  List<OwnedDiggleNFT> get ownedNFTs => List.unmodifiable(_ownedNFTs);
  bool get hasNFT => _ownedNFT != null;

  /// Whether the wallet holds a verified Seeker Genesis Token
  /// (Solana Mobile device NFT — grants a small holder perk).
  bool get hasGenesisToken => _hasGenesisToken;
  bool _hasGenesisToken = false;

  /// When the last successful ownership scan completed (null = never).
  DateTime? get lastScanAt => _lastScanAt;
  DateTime? _lastScanAt;

  // ── Ownership cache (per wallet + cluster) ─────────────────────
  // The full scan is expensive (one RPC round-trip per token account),
  // so results persist across sessions: the Hangar shows cached
  // machines instantly and refreshes in the background.

  String get _cacheKey =>
      'diggle_nft_cache_v1_${_wallet.isDevnet ? 'devnet' : 'mainnet'}'
      '_${_wallet.publicKey ?? 'none'}';

  String get _negativeCacheKey =>
      'diggle_non_diggle_mints_v1_${_wallet.isDevnet ? 'devnet' : 'mainnet'}';

  /// Load the last scan result from disk. Returns true if a cache
  /// existed for this wallet. Instant — no network.
  Future<bool> loadCachedOwnership() async {
    if (_wallet.publicKey == null) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return false;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final nfts = <OwnedDiggleNFT>[];
      for (final item in (data['nfts'] as List? ?? [])) {
        final nft = OwnedDiggleNFT.fromJson(item as Map<String, dynamic>);
        if (nft != null) nfts.add(nft);
      }
      _ownedNFTs
        ..clear()
        ..addAll(nfts);
      _ownedNFT = nfts.isNotEmpty ? nfts.first : null;
      _hasGenesisToken = data['genesis'] as bool? ?? false;
      final ts = data['ts'] as int?;
      _lastScanAt = ts != null
          ? DateTime.fromMillisecondsSinceEpoch(ts)
          : null;
      notifyListeners();
      debugPrint('CandyMachine: loaded cache (${nfts.length} NFTs, '
          'genesis: $_hasGenesisToken, scanned: $_lastScanAt)');
      return true;
    } catch (e) {
      debugPrint('CandyMachine: cache load failed: $e');
      return false;
    }
  }

  Future<void> _saveOwnershipCache() async {
    if (_wallet.publicKey == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode({
          'ts': DateTime.now().millisecondsSinceEpoch,
          'nfts': _ownedNFTs.map((n) => n.toJson()).toList(),
          'genesis': _hasGenesisToken,
        }),
      );
    } catch (e) {
      debugPrint('CandyMachine: cache save failed: $e');
    }
  }

  /// Mints already checked and known NOT to be Diggle NFTs — skipped on
  /// re-scans so repeat scans only pay for new tokens.
  Future<Set<String>> _loadNegativeMintCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_negativeCacheKey) ?? []).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveNegativeMintCache(Set<String> mints) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Bound the cache so it can't grow without limit
      final list = mints.take(800).toList();
      await prefs.setStringList(_negativeCacheKey, list);
    } catch (_) {}
  }
  bool get isLoadingInfo => _isLoadingInfo;
  bool get isCheckingOwnership => _isCheckingOwnership;
  bool get isMinting => _mintStatus != MintStatus.idle &&
      _mintStatus != MintStatus.success &&
      _mintStatus != MintStatus.error;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  CandyMachineService({
    required WalletService wallet,
    required String supabaseUrl,
    required String supabaseAnonKey,
  })  : _wallet = wallet,
        _supabaseUrl = supabaseUrl,
        _supabaseAnonKey = supabaseAnonKey;

  /// Base URL for the candy-machine edge function.
  /// Devnet wallets route to the separate candy-machine-devnet function
  /// so testing never touches the mainnet function serving live users.
  String get _functionUrl => _wallet.isDevnet
      ? '$_supabaseUrl/functions/v1/candy-machine-devnet'
      : '$_supabaseUrl/functions/v1/candy-machine';

  /// Standard headers for Supabase edge function calls
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_supabaseAnonKey',
  };

  // ============================================================
  // FETCH CANDY MACHINE INFO
  // ============================================================

  /// Fetch current candy machine state (items remaining, price, etc.)
  Future<CandyMachineInfo?> fetchMintInfo() async {
    _isLoadingInfo = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http
          .get(
        Uri.parse('$_functionUrl/mint-info'),
        headers: _headers,
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _info = CandyMachineInfo.fromJson(data);

        // Warn if the edge function is on a different network than the wallet
        final edgeNetwork = _info!.network;
        final walletIsDevnet = _wallet.isDevnet;
        if (edgeNetwork != null) {
          final edgeIsDevnet = edgeNetwork == 'devnet';
          if (edgeIsDevnet != walletIsDevnet) {
            debugPrint(
                '⚠️ CandyMachine: NETWORK MISMATCH — '
                    'edge function is on $edgeNetwork but wallet is on '
                    '${_wallet.cluster.displayName}. Minting will fail!'
            );
          }
        }

        _isLoadingInfo = false;
        notifyListeners();
        return _info;
      } else {
        _error = 'Failed to fetch mint info: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Unable to reach mint server: ${e.toString().length > 80 ? '${e.toString().substring(0, 80)}...' : e}';
      debugPrint('CandyMachine fetchMintInfo error: $e');
    }

    _isLoadingInfo = false;
    notifyListeners();
    return null;
  }

  // ============================================================
  // MINT NFT
  // ============================================================

  /// A built transaction older than this is rebuilt before signing, so a
  /// review left open never hands the wallet an expired blockhash.
  static const Duration _quoteMaxAge = Duration(seconds: 30);

  /// Step 1 of a mint: build and simulate it, and price it.
  ///
  /// The app generates the NFT mint keypair, so the edge function returns
  /// the transaction with no signatures: the wallet signs first and the
  /// mint key after ([confirmMint]), the order Phantom needs. The function
  /// simulates before answering, so a mint the guard would refuse (limit,
  /// sold out, not enough SOL, bot tax) comes back as [error] here and the
  /// wallet never opens.
  ///
  /// Returns null with [error] set on failure.
  Future<PreparedMint?> prepareMint() async {
    if (!_wallet.isConnected) {
      _error = 'Wallet not connected';
      notifyListeners();
      return null;
    }

    final minterPubkey = _wallet.publicKey;
    if (minterPubkey == null) {
      _error = 'No public key available';
      notifyListeners();
      return null;
    }

    _mintStatus = MintStatus.fetchingTransaction;
    _error = null;
    _lastMintSignature = null;
    _lastMintedNFT = null;
    notifyListeners();

    try {
      // Ensure we have mint info (also syncs RPC URL from edge function)
      if (_info == null) {
        await fetchMintInfo();
      }

      final mintKey = await Ed25519HDKeyPair.random();
      final prepared = await _buildMint(minterPubkey, mintKey);
      if (prepared == null) {
        _mintStatus = MintStatus.error;
        notifyListeners();
        return null;
      }

      _mintStatus = MintStatus.idle;
      notifyListeners();
      return prepared;
    } catch (e, stack) {
      debugPrint('CandyMachine prepareMint error: $e');
      debugPrint('Stack: $stack');
      _error = 'Mint failed: ${e.toString().length > 100 ? '${e.toString().substring(0, 100)}...' : e}';
      _mintStatus = MintStatus.error;
      notifyListeners();
      return null;
    }
  }

  /// Ask the edge function for an unsigned, simulated mint transaction
  /// for [mintKey]. Null with [_error] set when it refuses.
  Future<PreparedMint?> _buildMint(
      String minterPubkey, Ed25519HDKeyPair mintKey) async {
    debugPrint('CandyMachine: Requesting unsigned mint tx...');
    final buildResponse = await http
        .post(
      Uri.parse('$_functionUrl/build-mint-tx'),
      headers: _headers,
      body: jsonEncode({'minter': minterPubkey, 'nftMint': mintKey.address}),
    )
        .timeout(const Duration(seconds: 20));

    final body = jsonDecode(buildResponse.body);
    if (buildResponse.statusCode != 200) {
      final map = body is Map<String, dynamic> ? body : const <String, dynamic>{};
      _error = map['error'] == 'simulation_failed'
          ? _simulationFailureMessage(map['reason'] as String?)
          : (map['error'] as String? ?? 'Failed to build transaction');
      debugPrint('CandyMachine: build refused: ${buildResponse.body}');
      return null;
    }

    final data = body as Map<String, dynamic>;
    final mintAddress = data['mint'] as String;
    if (mintAddress != mintKey.address) {
      _error = 'Mint server returned a different NFT address';
      return null;
    }
    final quote = data['quote'];
    if (quote is! Map<String, dynamic>) {
      // An old edge function that doesn't simulate: never sign blind.
      _error = 'Mint server is out of date. Please try again later.';
      return null;
    }

    debugPrint('CandyMachine: Got unsigned tx, NFT mint: $mintAddress');
    return PreparedMint(
      transaction: base64Decode(data['transaction'] as String),
      mintKey: mintKey,
      quote: MintQuote.fromJson(quote),
      builtAt: DateTime.now(),
    );
  }

  /// Why the edge function's simulation refused the mint. The wallet was
  /// never opened, so nothing was charged.
  static String _simulationFailureMessage(String? reason) {
    const nothingSigned = 'Your wallet wasn\'t asked to sign anything.';
    return switch (reason) {
      'insufficient_sol' =>
        'Not enough SOL for the price, rent and network fee. $nothingSigned',
      'mint_limit' => 'This wallet has reached its mint limit. $nothingSigned',
      'sold_out' => 'Sold out — every machine has been claimed. $nothingSigned',
      'not_started' => 'Minting is not open right now. $nothingSigned',
      'bot_tax' =>
        'The candy machine would reject this mint and charge its bot tax, '
            'so it was stopped before signing. $nothingSigned',
      _ => 'This mint would fail on-chain. $nothingSigned',
    };
  }

  /// Step 2 of a mint, after the player approved the quote:
  /// 1. Rebuild if the quote is stale (blockhash)
  /// 2. The wallet signs first (MWA sign-only)
  /// 3. The app adds the NFT mint key's signature to what the wallet returned
  /// 4. Send to the network and confirm
  ///
  /// Returns the signature, or null with [error] set.
  Future<String?> confirmMint(PreparedMint prepared) async {
    final minterPubkey = _wallet.publicKey;
    if (!_wallet.isConnected || minterPubkey == null) {
      _error = 'Wallet not connected';
      _mintStatus = MintStatus.error;
      notifyListeners();
      return null;
    }

    _error = null;
    _lastMintSignature = null;
    _lastMintedNFT = null;

    try {
      var current = prepared;
      if (DateTime.now().difference(prepared.builtAt) > _quoteMaxAge) {
        _mintStatus = MintStatus.fetchingTransaction;
        notifyListeners();
        final rebuilt = await _buildMint(minterPubkey, prepared.mintKey);
        if (rebuilt == null) {
          _mintStatus = MintStatus.error;
          notifyListeners();
          return null;
        }
        current = rebuilt;
      }
      final mintAddress = current.mintKey.address;

      // Sign via MWA — the wallet signs first.
      _mintStatus = MintStatus.awaitingSignature;
      notifyListeners();

      debugPrint('CandyMachine: Requesting MWA signature...');
      final walletSigned = await _wallet.signTransaction(current.transaction);

      if (walletSigned == null) {
        _error = _wallet.errorMessage ?? 'Transaction signing was cancelled';
        _mintStatus = MintStatus.error;
        notifyListeners();
        return null;
      }

      // Now the NFT mint key signs the message the wallet returned.
      final signedBytes = await cosignTransaction(walletSigned, current.mintKey);

      // Send the signed transaction
      // After MWA app switch, Android may need a moment to restore network
      _mintStatus = MintStatus.sending;
      notifyListeners();

      debugPrint('CandyMachine: Sending signed transaction...');
      final encodedTx = base64Encode(signedBytes);
      String? signature;
      const maxRetries = 4;

      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          if (attempt > 1) {
            debugPrint('CandyMachine: Retry $attempt/$maxRetries — waiting for network...');
            await Future.delayed(Duration(seconds: attempt));
          }
          signature = await _solanaClient.rpcClient.sendTransaction(
            encodedTx,
            preflightCommitment: Commitment.confirmed,
          );
          break; // Success
        } catch (e) {
          debugPrint('CandyMachine: sendTransaction error (attempt $attempt): $e');
          final isNetworkError = e.toString().contains('SocketException') ||
              e.toString().contains('host lookup') ||
              e.toString().contains('Connection refused') ||
              e.toString().contains('Network is unreachable');

          if (!isNetworkError || attempt == maxRetries) {
            _error = isNetworkError
                ? 'Network unavailable after wallet switch. Please try again.'
                : 'Failed to submit transaction: $e';
            _mintStatus = MintStatus.error;
            notifyListeners();
            return null;
          }
        }
      }

      debugPrint('CandyMachine: Transaction sent! Sig: $signature');

      // Confirm
      _mintStatus = MintStatus.confirming;
      notifyListeners();

      // Wait for confirmation (simple polling)
      bool confirmed = false;
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(seconds: 2));
        try {
          final status = await _solanaClient.rpcClient.getSignatureStatuses(
            [signature!],
          );
          if (status.value.isNotEmpty && status.value.first != null) {
            final confirmationStatus = status.value.first!.confirmationStatus;
            if (confirmationStatus == Commitment.confirmed ||
                confirmationStatus == Commitment.finalized) {
              confirmed = true;
              break;
            }
            if (status.value.first!.err != null) {
              _error = 'Transaction failed on-chain';
              _mintStatus = MintStatus.error;
              notifyListeners();
              return null;
            }
          }
        } catch (e) {
          debugPrint('CandyMachine: Confirmation poll error: $e');
        }
      }

      if (!confirmed) {
        // Transaction may still confirm — give user the signature
        debugPrint('CandyMachine: Confirmation timeout, but tx may still land');
      }

      _lastMintSignature = signature;
      _lastMintedNFT = mintAddress;
      _mintStatus = MintStatus.success;
      notifyListeners();

      // Refresh ownership in background (delay for RPC to catch up + network recovery)
      Future.delayed(const Duration(seconds: 5), () => checkNFTOwnership());

      return signature;

    } catch (e, stack) {
      debugPrint('CandyMachine mint error: $e');
      debugPrint('Stack: $stack');
      _error = 'Mint failed: ${e.toString().length > 100 ? '${e.toString().substring(0, 100)}...' : e}';
      _mintStatus = MintStatus.error;
      notifyListeners();
      return null;
    }
  }

  /// Prepare and confirm in one go, for the later mints of a batch whose
  /// first quote the player already reviewed (every mint costs the same,
  /// and each one is still simulated before its wallet prompt).
  Future<String?> mint() async {
    final prepared = await prepareMint();
    if (prepared == null) return null;
    return confirmMint(prepared);
  }

  /// Reset mint status back to idle
  void resetMintStatus() {
    _mintStatus = MintStatus.idle;
    _error = null;
    notifyListeners();
  }

  // ============================================================
  // NFT OWNERSHIP DETECTION
  // ============================================================

  /// Check if the connected wallet owns Diggle NFTs.
  /// Uses getTokenAccountsByOwner to find NFTs, then checks
  /// metadata for the correct collection. Collects ALL matches
  /// (a wallet can hold several Diggle Machines).
  Future<bool> checkNFTOwnership() async {
    if (!_wallet.isConnected || _wallet.publicKey == null) {
      _ownedNFT = null;
      _ownedNFTs.clear();
      notifyListeners();
      return false;
    }

    _isCheckingOwnership = true;
    notifyListeners();

    try {
      final client = _solanaClient;
      final ownerPubkey = _wallet.publicKey!;
      debugPrint('CandyMachine: Checking NFT ownership for $ownerPubkey');

      // Retry logic — Android network can be flaky after MWA app switch
      late final dynamic tokenAccounts;
      const maxRetries = 3;
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          if (attempt > 1) {
            debugPrint('CandyMachine: NFT check retry $attempt/$maxRetries...');
            await Future.delayed(Duration(seconds: attempt * 2));
          }
          tokenAccounts = await client.rpcClient.getTokenAccountsByOwner(
            ownerPubkey,
            TokenAccountsFilter.byProgramId(
              'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
            ),
            encoding: Encoding.base64,
            commitment: Commitment.confirmed,
          );
          break; // Success
        } catch (e) {
          final isNetworkError = e.toString().contains('SocketException') ||
              e.toString().contains('host lookup') ||
              e.toString().contains('Connection refused');
          if (!isNetworkError || attempt == maxRetries) rethrow;
        }
      }

      debugPrint('CandyMachine: Found ${tokenAccounts.value.length} token accounts');

      // ── Phase 1: collect candidate NFT mints (local parse, no RPC) ──
      final candidates = <({String mint, String tokenAccount})>[];
      for (final account in tokenAccounts.value) {
        try {
          final data = account.account.data;
          if (data is! BinaryAccountData) continue;

          final bytes = Uint8List.fromList(data.data);
          // SPL Token account layout (165 bytes):
          //   mint:     32 bytes (offset 0)
          //   owner:    32 bytes (offset 32)
          //   amount:   8 bytes  (offset 64, u64 LE)
          if (bytes.length < 72) continue;

          // Read amount as u64 LE
          int amount = 0;
          for (int i = 0; i < 8; i++) {
            amount |= bytes[64 + i] << (i * 8);
          }

          // NFTs: amount == 1
          if (amount != 1) continue;

          final mintAddress =
              Ed25519HDPublicKey(bytes.sublist(0, 32)).toBase58();
          candidates.add((mint: mintAddress, tokenAccount: account.pubkey));
        } catch (e) {
          debugPrint('CandyMachine: Error parsing token account: $e');
        }
      }

      // ── Phase 2: skip mints already known not to be Diggle NFTs ──
      final negative = await _loadNegativeMintCache();
      final toCheck =
          candidates.where((c) => !negative.contains(c.mint)).toList();
      debugPrint('CandyMachine: ${candidates.length} NFT candidates, '
          '${toCheck.length} need metadata checks '
          '(${candidates.length - toCheck.length} skipped via cache)');

      // ── Phase 3: check metadata in parallel chunks ──
      final found = <OwnedDiggleNFT>[];
      const chunkSize = 8;
      for (int i = 0; i < toCheck.length; i += chunkSize) {
        final chunk = toCheck.skip(i).take(chunkSize).toList();
        final results = await Future.wait(chunk.map((c) async {
          try {
            final result = await _isDiggleCollectionNFT(client, c.mint);
            return (candidate: c, result: result);
          } catch (e) {
            debugPrint('CandyMachine: metadata check failed ${c.mint}: $e');
            return (
              candidate: c,
              result: (isMatch: false, name: null, uri: null)
            );
          }
        }));

        for (final r in results) {
          if (r.result.isMatch) {
            // Fetch the off-chain metadata JSON for the image
            String? imageUri;
            final uri = r.result.uri;
            if (uri != null && uri.isNotEmpty) {
              imageUri = await _fetchNFTImageUri(uri);
            }
            found.add(OwnedDiggleNFT(
              mintAddress: r.candidate.mint,
              tokenAccount: r.candidate.tokenAccount,
              name: r.result.name,
              imageUri: imageUri,
              metadataUri: uri,
            ));
            debugPrint('CandyMachine: ✅ Found Diggle NFT: '
                '${r.candidate.mint} (image: $imageUri)');
          } else {
            negative.add(r.candidate.mint);
          }
        }
      }
      await _saveNegativeMintCache(negative);

      _ownedNFTs
        ..clear()
        ..addAll(found);
      _ownedNFT = found.isNotEmpty ? found.first : null;
      _lastScanAt = DateTime.now();
      _isCheckingOwnership = false;
      await _saveOwnershipCache();
      notifyListeners();

      if (found.isEmpty) {
        debugPrint('CandyMachine: Scanned ${candidates.length} NFTs, '
            'none matched collection $collectionMint');
        return false;
      }
      debugPrint('CandyMachine: ${found.length} Diggle NFT(s) in wallet');
      return true;

    } catch (e) {
      debugPrint('CandyMachine: Error checking NFT ownership: $e');
      _isCheckingOwnership = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // SEEKER GENESIS TOKEN (Token-2022)
  // ============================================================

  /// Check whether the connected wallet holds a verified Seeker Genesis
  /// Token. Per Solana Mobile docs, an SGT is a Token-2022 mint where:
  ///   1. mint authority == SGT mint authority
  ///   2. metadata pointer -> SGT metadata address (authority matches)
  ///   3. token group member -> SGT group address
  Future<bool> checkGenesisTokenOwnership() async {
    if (!_wallet.isConnected || _wallet.publicKey == null) {
      _hasGenesisToken = false;
      notifyListeners();
      return false;
    }

    try {
      final client = _solanaClient;

      final tokenAccounts = await client.rpcClient.getTokenAccountsByOwner(
        _wallet.publicKey!,
        TokenAccountsFilter.byProgramId(_token2022Program),
        encoding: Encoding.base64,
        commitment: Commitment.confirmed,
      );

      // Collect held Token-2022 mints (amount == 1)
      final mints = <String>[];
      for (final account in tokenAccounts.value) {
        final data = account.account.data;
        if (data is! BinaryAccountData) continue;
        final bytes = Uint8List.fromList(data.data);
        if (bytes.length < 72) continue;
        int amount = 0;
        for (int i = 0; i < 8; i++) {
          amount |= bytes[64 + i] << (i * 8);
        }
        if (amount != 1) continue;
        mints.add(Ed25519HDPublicKey(bytes.sublist(0, 32)).toBase58());
      }
      debugPrint('CandyMachine: ${mints.length} Token-2022 NFT(s) to '
          'check for SGT');

      bool foundSGT = false;
      for (final mint in mints) {
        final info = await client.rpcClient.getAccountInfo(
          mint,
          encoding: Encoding.base64,
          commitment: Commitment.confirmed,
        );
        final data = info.value?.data;
        if (data is! BinaryAccountData) continue;
        if (_isSeekerGenesisMint(Uint8List.fromList(data.data))) {
          debugPrint('CandyMachine: ✅ Verified Seeker Genesis Token: $mint');
          foundSGT = true;
          break;
        }
      }

      _hasGenesisToken = foundSGT;
      await _saveOwnershipCache();
      notifyListeners();
      return foundSGT;
    } catch (e) {
      debugPrint('CandyMachine: SGT check failed: $e');
      // Keep the previous (possibly cached) value on transient failure
      return _hasGenesisToken;
    }
  }

  /// Parse a Token-2022 mint account and verify the three SGT properties.
  ///
  /// Token-2022 mint layout: 82-byte base mint, zero-padded to 165, then
  /// 1 account-type byte (1 = Mint), then TLV extension entries:
  /// [u16 type][u16 length][value...].
  bool _isSeekerGenesisMint(Uint8List bytes) {
    try {
      if (bytes.length < 82) return false;

      // (1) Mint authority: COption<Pubkey> at offset 0 (u32 tag + 32B)
      final hasAuthority = bytes[0] == 1;
      if (!hasAuthority) return false;
      final authority =
          Ed25519HDPublicKey(bytes.sublist(4, 36)).toBase58();
      if (authority != _sgtMintAuthority) return false;

      // Extensions require padded layout + account type byte
      if (bytes.length < 166) return false;
      if (bytes[165] != 1) return false; // AccountType.mint

      bool metadataOk = false;
      bool groupOk = false;

      int offset = 166;
      while (offset + 4 <= bytes.length) {
        final type = bytes[offset] | (bytes[offset + 1] << 8);
        final length = bytes[offset + 2] | (bytes[offset + 3] << 8);
        final valueStart = offset + 4;
        if (valueStart + length > bytes.length) break;

        if (type == 18 && length >= 64) {
          // MetadataPointer: authority(32) + metadata_address(32)
          final ptrAuthority = Ed25519HDPublicKey(
              bytes.sublist(valueStart, valueStart + 32)).toBase58();
          final metadataAddr = Ed25519HDPublicKey(
              bytes.sublist(valueStart + 32, valueStart + 64)).toBase58();
          metadataOk = ptrAuthority == _sgtMintAuthority &&
              metadataAddr == _sgtMetadataAddress;
        } else if (type == 23 && length >= 64) {
          // TokenGroupMember: mint(32) + group(32) + member_number(u64)
          final group = Ed25519HDPublicKey(
              bytes.sublist(valueStart + 32, valueStart + 64)).toBase58();
          groupOk = group == _sgtGroupAddress;
        }

        offset = valueStart + length;
        if (length == 0) break; // malformed TLV guard
      }

      return metadataOk && groupOk;
    } catch (e) {
      debugPrint('CandyMachine: SGT mint parse error: $e');
      return false;
    }
  }

  /// Check if an NFT mint belongs to the Diggle collection
  /// by reading its on-chain metadata and checking the collection field.
  /// Returns name and URI if it matches.
  Future<({bool isMatch, String? name, String? uri})> _isDiggleCollectionNFT(
      SolanaClient client,
      String mintAddress,
      ) async {
    const noMatch = (isMatch: false, name: null, uri: null);
    try {
      // Derive the metadata PDA
      final metadataProgramKey =
      Ed25519HDPublicKey.fromBase58(_tokenMetadataProgram);
      final mintKey = Ed25519HDPublicKey.fromBase58(mintAddress);

      final seeds = [
        'metadata'.codeUnits,
        metadataProgramKey.bytes,
        mintKey.bytes,
      ];

      final result = await Ed25519HDPublicKey.findProgramAddress(
        seeds: seeds.map((s) => Uint8List.fromList(s)).toList(),
        programId: metadataProgramKey,
      );

      String metadataPdaBase58;
      if (result is Ed25519HDPublicKey) {
        metadataPdaBase58 = result.toBase58();
      } else {
        try {
          metadataPdaBase58 = (result as dynamic).toBase58();
        } catch (_) {
          try {
            metadataPdaBase58 = (result as dynamic).pubkey.toBase58();
          } catch (_) {
            try {
              metadataPdaBase58 = (result as dynamic).key.toBase58();
            } catch (e) {
              debugPrint('CandyMachine: Cannot extract PDA address from result type: ${result.runtimeType}');
              return noMatch;
            }
          }
        }
      }

      debugPrint('CandyMachine: Metadata PDA for $mintAddress: $metadataPdaBase58');

      final accountInfo = await client.rpcClient.getAccountInfo(
        metadataPdaBase58,
        encoding: Encoding.base64,
        commitment: Commitment.confirmed,
      );

      if (accountInfo.value == null || accountInfo.value!.data == null) {
        debugPrint('CandyMachine: No metadata account found for $mintAddress');
        return noMatch;
      }

      debugPrint('CandyMachine: Metadata account found, owner: ${accountInfo.value!.owner}');

      final data = accountInfo.value!.data;
      if (data is BinaryAccountData) {
        final bytes = Uint8List.fromList(data.data);
        debugPrint('CandyMachine: Metadata size: ${bytes.length} bytes');
        return _parseCollectionFromMetadata(bytes, collectionMint);
      } else {
        debugPrint('CandyMachine: Unexpected data type: ${data.runtimeType}');
      }

      return noMatch;
    } catch (e, stack) {
      debugPrint('CandyMachine: Error checking collection for $mintAddress: $e');
      debugPrint('CandyMachine: Stack: $stack');
      return noMatch;
    }
  }

  /// Result of parsing collection metadata
  /// Contains the collection match status plus name and URI if found.
  /// Parse Metaplex metadata bytes to check collection and extract name/uri.
  ///
  /// Metadata V1 layout (simplified):
  ///   - key (1 byte)
  ///   - update_authority (32 bytes)
  ///   - mint (32 bytes)
  ///   - name (4 + len bytes, borsh string)
  ///   - symbol (4 + len bytes, borsh string)
  ///   - uri (4 + len bytes, borsh string)
  ///   - seller_fee_basis_points (2 bytes)
  ///   - creators (optional: 1 bool + 4 len + entries)
  ///   - primary_sale_happened (1 byte)
  ///   - is_mutable (1 byte)
  ///   - edition_nonce (optional: 1 bool + 1 byte)
  ///   - token_standard (optional: 1 bool + 1 byte)
  ///   - collection (optional: 1 bool + 1 verified + 32 key)
  ({bool isMatch, String? name, String? uri}) _parseCollectionFromMetadata(
      Uint8List bytes,
      String expectedCollection,
      ) {
    try {
      int offset = 0;

      // key (1)
      offset += 1;
      // update_authority (32)
      offset += 32;
      // mint (32)
      offset += 32;

      // name (borsh string: 4 byte len + data)
      if (offset + 4 > bytes.length) return (isMatch: false, name: null, uri: null);
      final nameLen = _readU32LE(bytes, offset);
      offset += 4;
      final name = String.fromCharCodes(bytes.sublist(offset, offset + nameLen))
          .replaceAll('\x00', '')
          .trim();
      offset += nameLen;

      // symbol
      if (offset + 4 > bytes.length) return (isMatch: false, name: name, uri: null);
      final symbolLen = _readU32LE(bytes, offset);
      offset += 4 + symbolLen;

      // uri
      if (offset + 4 > bytes.length) return (isMatch: false, name: name, uri: null);
      final uriLen = _readU32LE(bytes, offset);
      offset += 4;
      final uri = String.fromCharCodes(bytes.sublist(offset, offset + uriLen))
          .replaceAll('\x00', '')
          .trim();
      offset += uriLen;

      debugPrint('CandyMachine: Parsed metadata — name: "$name", uri: "$uri"');

      // seller_fee_basis_points (2)
      offset += 2;

      // creators (Option<Vec<Creator>>)
      if (offset >= bytes.length) return (isMatch: false, name: name, uri: uri);
      final hasCreators = bytes[offset] == 1;
      offset += 1;
      if (hasCreators) {
        if (offset + 4 > bytes.length) return (isMatch: false, name: name, uri: uri);
        final numCreators = _readU32LE(bytes, offset);
        offset += 4;
        // Each creator: 32 (address) + 1 (verified) + 1 (share) = 34
        offset += numCreators * 34;
      }

      // primary_sale_happened (1)
      offset += 1;

      // is_mutable (1)
      offset += 1;

      // edition_nonce (Option<u8>)
      if (offset >= bytes.length) return (isMatch: false, name: name, uri: uri);
      final hasEditionNonce = bytes[offset] == 1;
      offset += 1;
      if (hasEditionNonce) offset += 1;

      // token_standard (Option<u8>)
      if (offset >= bytes.length) return (isMatch: false, name: name, uri: uri);
      final hasTokenStandard = bytes[offset] == 1;
      offset += 1;
      if (hasTokenStandard) offset += 1;

      // collection (Option<Collection>)
      // Collection = { verified: bool(1), key: Pubkey(32) }
      if (offset >= bytes.length) return (isMatch: false, name: name, uri: uri);
      final hasCollection = bytes[offset] == 1;
      offset += 1;

      if (!hasCollection) return (isMatch: false, name: name, uri: uri);
      if (offset + 33 > bytes.length) return (isMatch: false, name: name, uri: uri);

      final verified = bytes[offset] == 1;
      offset += 1;

      // Read collection pubkey (32 bytes)
      final collectionKeyBytes = bytes.sublist(offset, offset + 32);
      final collectionKeyBase58 =
      Ed25519HDPublicKey(collectionKeyBytes).toBase58();

      debugPrint(
        'CandyMachine: Collection key=$collectionKeyBase58, '
            'verified=$verified, expected=$expectedCollection',
      );

      final isMatch = collectionKeyBase58 == expectedCollection && verified;
      return (isMatch: isMatch, name: name, uri: uri);
    } catch (e) {
      debugPrint('CandyMachine: Metadata parse error: $e');
      return (isMatch: false, name: null, uri: null);
    }
  }

  /// Fetch the image URI from the NFT's off-chain metadata JSON.
  /// The on-chain metadata URI points to a JSON file (e.g. on Arweave/IPFS)
  /// that contains an "image" field with the actual image URL.
  /// Fetch and decode the off-chain metadata JSON for an NFT.
  /// Public so the gear system can parse trait attributes post-reveal.
  Future<Map<String, dynamic>?> fetchOffchainMetadata(
      String metadataUri) async {
    try {
      debugPrint('CandyMachine: Fetching off-chain metadata from: $metadataUri');
      final response = await http
          .get(Uri.parse(metadataUri))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      debugPrint('CandyMachine: Metadata fetch failed: ${response.statusCode}');
    } catch (e) {
      debugPrint('CandyMachine: Error fetching NFT metadata JSON: $e');
    }
    return null;
  }

  Future<String?> _fetchNFTImageUri(String metadataUri) async {
    final json = await fetchOffchainMetadata(metadataUri);
    final image = json?['image'] as String?;
    debugPrint('CandyMachine: NFT image URI: $image');
    return image;
  }

  int _readU32LE(Uint8List bytes, int offset) {
    return bytes[offset] |
    (bytes[offset + 1] << 8) |
    (bytes[offset + 2] << 16) |
    (bytes[offset + 3] << 24);
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  /// Initialize: fetch mint info and check NFT ownership
  Future<void> initialize() async {
    // Cache first so holder boosts (NFT + Seeker Genesis) apply from
    // cold start without waiting on a wallet scan.
    await loadCachedOwnership();
    await fetchMintInfo();
    if (_wallet.isConnected) {
      await checkNFTOwnership();
      await checkGenesisTokenOwnership();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}