/// candy_machine_service.dart
/// Service for interacting with the Diggle NFT Candy Machine.
///
/// Architecture:
///   1. Calls the mint API to get an unsigned transaction
///   2. Signs via MWA (Mobile Wallet Adapter)
///   3. Sends to the Solana network
///   4. Detects NFT ownership via RPC (getTokenAccountsByOwner + metadata)
///
/// The mint API (Node.js) handles the complex Metaplex instruction building
/// using the official Umi SDK, while the Flutter app handles signing and sending.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
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

  OwnedDiggleNFT({
    required this.mintAddress,
    required this.tokenAccount,
    this.name,
    this.imageUri,
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

  /// Known collection mint for Diggle NFTs
  static const String collectionMint =
      '3FJkKz61tMRt3rDzGk1Xp6mTN8kGYXtwSTgYaYEmx5fG'; // 4eFNHpLUiVEAh2wi9K1YLUEeTdDYJgjiLhgEkxbw8upV devnet

  /// Metaplex Token Metadata program ID
  static const String _tokenMetadataProgram =
      'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s';

  // ============================================================
  // STATE
  // ============================================================

  MintStatus _mintStatus = MintStatus.idle;
  String? _error;
  String? _lastMintSignature;
  String? _lastMintedNFT;
  CandyMachineInfo? _info;
  OwnedDiggleNFT? _ownedNFT;
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
  bool get hasNFT => _ownedNFT != null;
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

  /// Base URL for the candy-machine edge function
  String get _functionUrl => '$_supabaseUrl/functions/v1/candy-machine';

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

  /// Full mint flow:
  /// 1. Call API to build unsigned transaction
  /// 2. Sign via MWA
  /// 3. Send to network
  /// 4. Return signature
  Future<String?> mint() async {
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

      // Step 1: Get unsigned transaction from API
      debugPrint('CandyMachine: Requesting unsigned mint tx...');
      final buildResponse = await http
          .post(
        Uri.parse('$_functionUrl/build-mint-tx'),
        headers: _headers,
        body: jsonEncode({'minter': minterPubkey}),
      )
          .timeout(const Duration(seconds: 15));

      if (buildResponse.statusCode != 200) {
        final errorBody = jsonDecode(buildResponse.body);
        _error = errorBody['error'] ?? 'Failed to build transaction';
        _mintStatus = MintStatus.error;
        notifyListeners();
        return null;
      }

      final buildData = jsonDecode(buildResponse.body) as Map<String, dynamic>;
      final base64Tx = buildData['transaction'] as String;
      final mintAddress = buildData['mint'] as String;

      debugPrint('CandyMachine: Got unsigned tx, NFT mint: $mintAddress');

      // Step 2: Decode the transaction
      final txBytes = base64Decode(base64Tx);

      // Step 3: Sign via MWA
      _mintStatus = MintStatus.awaitingSignature;
      notifyListeners();

      debugPrint('CandyMachine: Requesting MWA signature...');
      final signedBytes = await _wallet.signTransaction(Uint8List.fromList(txBytes));

      if (signedBytes == null) {
        _error = _wallet.errorMessage ?? 'Transaction signing was cancelled';
        _mintStatus = MintStatus.error;
        notifyListeners();
        return null;
      }

      // Step 4: Send the signed transaction
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

      // Step 5: Confirm
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

  /// Reset mint status back to idle
  void resetMintStatus() {
    _mintStatus = MintStatus.idle;
    _error = null;
    notifyListeners();
  }

  // ============================================================
  // NFT OWNERSHIP DETECTION
  // ============================================================

  /// Check if the connected wallet owns a Diggle NFT.
  /// Uses getTokenAccountsByOwner to find NFTs, then checks
  /// metadata for the correct collection.
  Future<bool> checkNFTOwnership() async {
    if (!_wallet.isConnected || _wallet.publicKey == null) {
      _ownedNFT = null;
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

      int nftCount = 0;

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

          // Extract mint address (first 32 bytes)
          final mintBytes = bytes.sublist(0, 32);
          final mintAddress = Ed25519HDPublicKey(mintBytes).toBase58();

          nftCount++;
          debugPrint('CandyMachine: Checking NFT mint: $mintAddress');

          // Check if this NFT belongs to our collection
          final result = await _isDiggleCollectionNFT(client, mintAddress);
          if (result.isMatch) {
            // Fetch the off-chain metadata JSON for the image
            String? imageUri;
            if (result.uri != null && result.uri!.isNotEmpty) {
              imageUri = await _fetchNFTImageUri(result.uri!);
            }

            _ownedNFT = OwnedDiggleNFT(
              mintAddress: mintAddress,
              tokenAccount: account.pubkey,
              name: result.name,
              imageUri: imageUri,
            );
            _isCheckingOwnership = false;
            notifyListeners();
            debugPrint('CandyMachine: ✅ Found Diggle NFT: $mintAddress (image: $imageUri)');
            return true;
          }
        } catch (e) {
          debugPrint('CandyMachine: Error parsing token account: $e');
          continue;
        }
      }

      debugPrint('CandyMachine: Scanned $nftCount NFTs, none matched collection $collectionMint');

      // No Diggle NFT found
      _ownedNFT = null;
      _isCheckingOwnership = false;
      notifyListeners();
      return false;

    } catch (e) {
      debugPrint('CandyMachine: Error checking NFT ownership: $e');
      _isCheckingOwnership = false;
      notifyListeners();
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
  Future<String?> _fetchNFTImageUri(String metadataUri) async {
    try {
      debugPrint('CandyMachine: Fetching off-chain metadata from: $metadataUri');
      final response = await http
          .get(Uri.parse(metadataUri))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final image = json['image'] as String?;
        debugPrint('CandyMachine: NFT image URI: $image');
        return image;
      } else {
        debugPrint('CandyMachine: Metadata fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('CandyMachine: Error fetching NFT metadata JSON: $e');
    }
    return null;
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
    await fetchMintInfo();
    if (_wallet.isConnected) {
      await checkNFTOwnership();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}