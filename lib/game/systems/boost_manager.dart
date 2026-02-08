/// boost_manager.dart
/// Manages active boosts from on-chain purchases and NFT holdings.
///
/// Responsibilities:
/// - Fetches store config and active boosters from on-chain accounts
/// - Builds and sends purchase transactions via MWA
/// - Detects NFTs in connected wallet for permanent boosts
/// - Manages timed boost expiry
/// - Syncs boost multipliers to XPPointsSystem

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import './xp_points_system.dart';
import '../../solana/wallet_service.dart';
import '../../solana/diggle_mart_client.dart';

/// Types of boosters available
enum BoosterType {
  xpBoost(0, 'XP Boost', '⚡', 'Increases XP earned'),
  pointsBoost(1, 'Points Boost', '💎', 'Increases points earned'),
  comboBoost(2, 'Combo Boost', '🔥', 'Increases both XP and points');

  final int value;
  final String displayName;
  final String icon;
  final String description;

  const BoosterType(this.value, this.displayName, this.icon, this.description);

  static BoosterType fromValue(int v) {
    return BoosterType.values.firstWhere(
          (t) => t.value == v,
      orElse: () => BoosterType.xpBoost,
    );
  }
}

/// Represents an active or purchasable booster
class Booster {
  final BoosterType type;
  final double multiplier; // e.g., 1.5 = 50% boost
  final Duration duration; // Duration.zero = permanent (NFT)
  final DateTime? expiresAt;
  final bool isActive;
  final bool isFromNFT;
  final String? onChainAddress; // PDA of booster account

  Booster({
    required this.type,
    required this.multiplier,
    required this.duration,
    this.expiresAt,
    this.isActive = false,
    this.isFromNFT = false,
    this.onChainAddress,
  });

  bool get isExpired {
    if (isFromNFT) return false;
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt!);
  }

  Duration get timeRemaining {
    if (isFromNFT || expiresAt == null) return Duration.zero;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get timeRemainingDisplay {
    if (isFromNFT) return 'Permanent';
    final rem = timeRemaining;
    if (rem == Duration.zero) return 'Expired';
    if (rem.inHours > 0) return '${rem.inHours}h ${rem.inMinutes % 60}m';
    if (rem.inMinutes > 0) return '${rem.inMinutes}m';
    return '${rem.inSeconds}s';
  }

  String get multiplierDisplay => '${multiplier}x';

  /// Create a Booster from on-chain data
  factory Booster.fromOnChain(OnChainBooster onChain) {
    final type = BoosterType.fromValue(onChain.boosterType);
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      onChain.expiresAt * 1000,
    );
    final purchasedAt = DateTime.fromMillisecondsSinceEpoch(
      onChain.purchasedAt * 1000,
    );

    return Booster(
      type: type,
      multiplier: onChain.multiplierDouble,
      duration: expiresAt.difference(purchasedAt),
      expiresAt: expiresAt,
      isActive: onChain.isActive && !onChain.isExpired,
      onChainAddress: onChain.address,
    );
  }
}

/// Store items available for purchase
class StoreItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BoosterType boosterType;
  final double multiplier;
  final Duration duration;
  final int priceInPoints; // 0 if SOL-only
  final double priceInSOL; // 0 if points-only
  final bool requiresWallet;

  /// For on-chain purchase: booster type as u8
  final int? onChainBoosterType;

  /// For on-chain purchase: duration in seconds
  final int? onChainDurationSeconds;

  /// For on-chain purchase: points pack type (0=small, 1=large)
  final int? onChainPackType;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.boosterType,
    required this.multiplier,
    required this.duration,
    this.priceInPoints = 0,
    this.priceInSOL = 0,
    this.requiresWallet = false,
    this.onChainBoosterType,
    this.onChainDurationSeconds,
    this.onChainPackType,
  });
}

/// NFT collection info for reward-boosting NFTs
class NFTCollectionInfo {
  final String name;
  final double xpMultiplier;
  final double pointsMultiplier;
  final int maxSupply;
  final double mintPriceSOL;
  // Fetched from chain
  final int currentSupply;
  final bool isActive;
  final String? collectionMint;

  const NFTCollectionInfo({
    required this.name,
    required this.xpMultiplier,
    required this.pointsMultiplier,
    required this.maxSupply,
    required this.mintPriceSOL,
    this.currentSupply = 0,
    this.isActive = false,
    this.collectionMint,
  });

  int get remainingSupply => maxSupply - currentSupply;
  bool get isSoldOut => currentSupply >= maxSupply;
}

/// Manages all boosts and store interactions
class BoostManager extends ChangeNotifier {
  final XPPointsSystem xpSystem;
  final WalletService walletService;

  /// Diggle Mart on-chain client
  DiggleMartClient? _martClient;

  /// Active boosters (from chain + local points purchases)
  final List<Booster> _activeBoosters = [];

  /// Whether NFT boost is detected
  bool _hasNFT = false;

  /// NFT metadata if detected
  String? _nftName;
  String? _nftImageUri;

  /// On-chain store data
  OnChainStore? _storeData;

  /// NFT collection data from chain
  OnChainNftCollection? _nftCollectionData;

  /// Expiry check timer
  Timer? _expiryTimer;

  /// Loading state
  bool _isLoading = false;
  String? _error;

  // ============================================================
  // STORE CATALOG
  // ============================================================

  /// Available store items (points-based, no wallet needed)
  static const List<StoreItem> pointsStoreItems = [
    StoreItem(
      id: 'xp_boost_small',
      name: 'XP Boost (30min)',
      description: '1.5x XP for 30 minutes',
      icon: '⚡',
      boosterType: BoosterType.xpBoost,
      multiplier: 1.5,
      duration: Duration(minutes: 30),
      priceInPoints: 50,
    ),
    StoreItem(
      id: 'xp_boost_medium',
      name: 'XP Boost (2hr)',
      description: '1.5x XP for 2 hours',
      icon: '⚡',
      boosterType: BoosterType.xpBoost,
      multiplier: 1.5,
      duration: Duration(hours: 2),
      priceInPoints: 150,
    ),
    StoreItem(
      id: 'points_boost_small',
      name: 'Points Boost (30min)',
      description: '2x points for 30 minutes',
      icon: '💎',
      boosterType: BoosterType.pointsBoost,
      multiplier: 2.0,
      duration: Duration(minutes: 30),
      priceInPoints: 75,
    ),
    StoreItem(
      id: 'combo_boost',
      name: 'Combo Boost (1hr)',
      description: '1.5x XP + 1.5x points for 1 hour',
      icon: '🔥',
      boosterType: BoosterType.comboBoost,
      multiplier: 1.5,
      duration: Duration(hours: 1),
      priceInPoints: 200,
    ),
  ];

  /// Premium store items (SOL-based, requires wallet + on-chain tx)
  /// Prices here are defaults; actual prices come from on-chain store config
  static const List<StoreItem> premiumStoreItems = [
    StoreItem(
      id: 'xp_boost_mega',
      name: 'Mega XP Boost (24hr)',
      description: '2x XP for 24 hours (on-chain)',
      icon: '🌟',
      boosterType: BoosterType.xpBoost,
      multiplier: 2.0,
      duration: Duration(hours: 24),
      priceInSOL: 0.01,
      requiresWallet: true,
      onChainBoosterType: 0, // XP boost
      onChainDurationSeconds: 86400, // 24 hours
    ),
    StoreItem(
      id: 'combo_boost_mega',
      name: 'Mega Combo Boost (24hr)',
      description: '2x XP + 2x points for 24 hours (on-chain)',
      icon: '💥',
      boosterType: BoosterType.comboBoost,
      multiplier: 2.0,
      duration: Duration(hours: 24),
      priceInSOL: 0.02,
      requiresWallet: true,
      onChainBoosterType: 2, // Combo boost
      onChainDurationSeconds: 86400,
    ),
    StoreItem(
      id: 'points_pack_500',
      name: '500 Points Pack',
      description: 'Instantly receive 500 points (on-chain)',
      icon: '💰',
      boosterType: BoosterType.pointsBoost,
      multiplier: 1.0,
      duration: Duration.zero,
      priceInSOL: 0.005,
      requiresWallet: true,
      onChainPackType: 0, // Small pack
    ),
    StoreItem(
      id: 'points_pack_2000',
      name: '2000 Points Pack',
      description: 'Instantly receive 2000 points (on-chain)',
      icon: '💰',
      boosterType: BoosterType.pointsBoost,
      multiplier: 1.0,
      duration: Duration.zero,
      priceInSOL: 0.015,
      requiresWallet: true,
      onChainPackType: 1, // Large pack
    ),
  ];

  /// NFT collection info - defaults, updated from chain
  NFTCollectionInfo _nftCollection = const NFTCollectionInfo(
    name: 'Diggle Diamond Drill',
    xpMultiplier: 1.25,
    pointsMultiplier: 1.25,
    maxSupply: 1000,
    mintPriceSOL: 0.1,
  );

  NFTCollectionInfo get nftCollection => _nftCollection;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  BoostManager({
    required this.xpSystem,
    required this.walletService,
  }) {
    // Initialize the on-chain client if wallet service has a Solana client
    _initMartClient();

    // Start expiry check timer
    _expiryTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => _checkExpiredBoosters(),
    );

    // Listen for wallet changes
    walletService.addListener(_onWalletChanged);

    // Fetch store config on init
    _fetchStoreConfig();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    walletService.removeListener(_onWalletChanged);
    super.dispose();
  }

  /// Initialize the DiggleMartClient with the current RPC client
  void _initMartClient() {
    final solanaClient = walletService.solanaClient;
    if (solanaClient != null) {
      _martClient = DiggleMartClient(rpcClient: solanaClient);
    }
  }

  // ============================================================
  // GETTERS
  // ============================================================

  List<Booster> get activeBoosters =>
      _activeBoosters.where((b) => !b.isExpired).toList();

  bool get hasNFT => _hasNFT;
  String? get nftName => _nftName;
  String? get nftImageUri => _nftImageUri;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OnChainStore? get storeData => _storeData;
  bool get isStoreLoaded => _storeData != null;

  /// Manually refresh store config from on-chain
  Future<void> refreshStoreConfig() async {
    await _fetchStoreConfig();
  }

  double get totalXPMultiplier {
    double mult = 1.0;
    for (final b in activeBoosters) {
      if (b.type == BoosterType.xpBoost || b.type == BoosterType.comboBoost) {
        mult *= b.multiplier;
      }
    }
    if (_hasNFT) mult *= _nftCollection.xpMultiplier;
    return mult;
  }

  double get totalPointsMultiplier {
    double mult = 1.0;
    for (final b in activeBoosters) {
      if (b.type == BoosterType.pointsBoost ||
          b.type == BoosterType.comboBoost) {
        mult *= b.multiplier;
      }
    }
    if (_hasNFT) mult *= _nftCollection.pointsMultiplier;
    return mult;
  }

  /// Get the on-chain price for a premium store item (in SOL)
  /// Falls back to the hardcoded default if store not loaded
  double getPremiumItemPrice(StoreItem item) {
    if (_storeData == null) return item.priceInSOL;

    final config = _storeData!.config;

    // Points packs
    if (item.onChainPackType != null) {
      if (item.onChainPackType == 0) {
        return config.pointsPackSmallPriceSOL;
      } else {
        return config.pointsPackLargePriceSOL;
      }
    }

    // Boosters: price = pricePerHour * (durationSeconds / 3600)
    if (item.onChainBoosterType != null &&
        item.onChainDurationSeconds != null) {
      final hours = item.onChainDurationSeconds! / 3600.0;
      switch (item.onChainBoosterType) {
        case 0:
          return config.xpBoostPriceSOLPerHour * hours;
        case 1:
          return config.pointsBoostPriceSOLPerHour * hours;
        case 2:
          return config.comboBoostPriceSOLPerHour * hours;
      }
    }

    return item.priceInSOL;
  }

  // ============================================================
  // FETCH ON-CHAIN DATA
  // ============================================================
// Update premium store item prices from on-chain config
  // (StoreItem is const, so we just use getPremiumItemPrice() for display)
  /// Fetch store config from on-chain
  Future<void> _fetchStoreConfig() async {
    _initMartClient();
    if (_martClient == null) {
      debugPrint('Cannot fetch store config: mart client not initialized (solanaClient null?)');
      return;
    }

    try {
      _storeData = await _martClient!.fetchStore();
      if (_storeData != null) {
        debugPrint(
            'Store config loaded: active=${_storeData!.config.isActive}, '
                'totalSold=${_storeData!.totalBoostersSold}');
        notifyListeners();
      } else {
        debugPrint('Store account returned null - has the store been initialized on-chain?');

      }
    } catch (e) {
      debugPrint('Failed to fetch store config: $e');
    }
  }

  /// Fetch active boosters for the connected wallet
  Future<void> fetchOnChainBoosters() async {
    if (_martClient == null || !walletService.isConnected) return;

    final pubkey = walletService.publicKey;
    if (pubkey == null) return;

    try {
      debugPrint('Fetching on-chain boosters for $pubkey...');
      final onChainBoosters =
      await _martClient!.fetchActiveBoosters(pubkey);

      // Remove existing on-chain boosters and replace with fresh data
      _activeBoosters
          .removeWhere((b) => b.onChainAddress != null && !b.isFromNFT);

      for (final onChain in onChainBoosters) {
        _activeBoosters.add(Booster.fromOnChain(onChain));
      }

      debugPrint(
          'Found ${onChainBoosters.length} active on-chain boosters');

      _syncMultipliers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching on-chain boosters: $e');
    }
  }

  /// Fetch NFT collection info from chain
  Future<void> fetchNftCollectionInfo() async {
    if (_martClient == null) return;

    try {
      _nftCollectionData = await _martClient!.fetchNftCollection();
      if (_nftCollectionData != null) {
        _nftCollection = NFTCollectionInfo(
          name: _nftCollectionData!.name,
          xpMultiplier: _nftCollection.xpMultiplier,
          pointsMultiplier: _nftCollection.pointsMultiplier,
          maxSupply: _nftCollectionData!.maxSupply,
          mintPriceSOL: _nftCollectionData!.mintPriceSOL,
          currentSupply: _nftCollectionData!.currentSupply,
          isActive: _nftCollectionData!.isActive,
          collectionMint: _nftCollectionData!.collectionMint,
        );
        debugPrint('NFT collection loaded: ${_nftCollection.name}, '
            'supply: ${_nftCollection.currentSupply}/${_nftCollection.maxSupply}');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch NFT collection: $e');
    }
  }

  // ============================================================
  // POINTS-BASED PURCHASES (offline, no wallet needed)
  // ============================================================

  bool purchaseWithPoints(StoreItem item) {
    if (item.priceInPoints <= 0) return false;
    if (!xpSystem.canAffordPoints(item.priceInPoints)) return false;
    if (item.id.startsWith('points_pack')) return false;

    xpSystem.spendPoints(item.priceInPoints);

    final booster = Booster(
      type: item.boosterType,
      multiplier: item.multiplier,
      duration: item.duration,
      expiresAt: DateTime.now().add(item.duration),
      isActive: true,
    );

    _activeBoosters.add(booster);
    _syncMultipliers();
    notifyListeners();
    return true;
  }

  // ============================================================
  // SOL-BASED PURCHASES (on-chain via MWA)
  // ============================================================

  /// Purchase a premium booster with SOL via on-chain transaction.
  ///
  /// Builds the transaction, sends to wallet for signing via MWA,
  /// then confirms on-chain.
  ///
  /// Returns transaction signature on success, null on failure.
  Future<String?> purchaseWithSOL(StoreItem item) async {
    if (!item.requiresWallet) return null;
    if (!walletService.isConnected) {
      _error = 'Wallet not connected';
      notifyListeners();
      return null;
    }

    final buyerPubkey = walletService.publicKeyObject;
    if (buyerPubkey == null) {
      _error = 'Invalid wallet public key';
      notifyListeners();
      return null;
    }

    _initMartClient();
    if (_martClient == null) {
      _error = 'RPC client not available';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Refresh store data to get current totalBoostersSold for PDA derivation
      await _fetchStoreConfig();

      Uint8List txBytes;
      bool isPointsPack = item.onChainPackType != null;

      if (isPointsPack) {
        // ============================================================
        // POINTS PACK PURCHASE
        // ============================================================
        debugPrint(
            'Building purchasePointsPack tx (packType: ${item.onChainPackType})...');

        txBytes = await _martClient!.buildPurchasePointsPackTx(
          buyer: buyerPubkey,
          packType: item.onChainPackType!,
        );
      } else if (item.onChainBoosterType != null &&
          item.onChainDurationSeconds != null) {
        // ============================================================
        // BOOSTER PURCHASE
        // ============================================================
        debugPrint(
            'Building purchaseBooster tx (type: ${item.onChainBoosterType}, '
                'duration: ${item.onChainDurationSeconds}s, '
                'totalSold: ${_storeData?.totalBoostersSold ?? 0})...');

        txBytes = await _martClient!.buildPurchaseBoosterTx(
          buyer: buyerPubkey,
          boosterType: item.onChainBoosterType!,
          durationSeconds: item.onChainDurationSeconds!,
          totalBoostersSold: _storeData?.totalBoostersSold ?? 0,
        );
      } else {
        _error = 'Invalid store item configuration';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Send to wallet for signing and submission
      debugPrint('Sending transaction to wallet for approval...');
      final signature =
      await walletService.signAndSendTransaction(txBytes);

      if (signature == null) {
        _error = walletService.errorMessage ?? 'Transaction failed';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      debugPrint('Transaction submitted: $signature');

      // Confirm the transaction
      debugPrint('Confirming transaction...');
      final confirmed = await _martClient!.confirmTransaction(signature);

      if (!confirmed) {
        _error = 'Transaction failed to confirm. Check your wallet for details.';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      debugPrint('Transaction confirmed!');

      // Apply the effects locally
      if (isPointsPack) {
        // Award points locally
        final config = _storeData?.config;
        int pointsAmount;
        if (item.onChainPackType == 0) {
          pointsAmount = config?.pointsPackSmallAmount ?? 500;
        } else {
          pointsAmount = config?.pointsPackLargeAmount ?? 2000;
        }
        xpSystem.addPoints(pointsAmount);
        debugPrint('Awarded $pointsAmount points from pack purchase');
      } else {
        // Add the booster locally (also fetch from chain to get exact data)
        final booster = Booster(
          type: item.boosterType,
          multiplier: item.multiplier,
          duration: item.duration,
          expiresAt: DateTime.now().add(item.duration),
          isActive: true,
          onChainAddress: signature, // Use signature as temp identifier
        );
        _activeBoosters.add(booster);
        _syncMultipliers();

        // Fetch fresh data from chain in the background
        Future.delayed(const Duration(seconds: 2), () {
          fetchOnChainBoosters();
        });
      }

      _isLoading = false;
      notifyListeners();
      return signature;
    } catch (e) {
      debugPrint('Purchase error: $e');
      _error = 'Purchase failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ============================================================
  // NFT DETECTION
  // ============================================================

  /// Check connected wallet for Diggle NFT by looking at token accounts
  Future<void> checkForNFT() async {
    if (!walletService.isConnected) {
      _hasNFT = false;
      _syncMultipliers();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch NFT collection info from chain first
      await fetchNftCollectionInfo();

      final collectionMint = _nftCollectionData?.collectionMint;
      if (collectionMint == null ||
          collectionMint == 'YOUR_COLLECTION_MINT_ADDRESS_HERE') {
        debugPrint('NFT collection not yet deployed');
        _hasNFT = false;
        _isLoading = false;
        _syncMultipliers();
        notifyListeners();
        return;
      }

      // Check if wallet holds any tokens from this collection
      // This requires checking token accounts with Metaplex metadata
      final pubkey = walletService.publicKey;
      final solanaClient = walletService.solanaClient;

      if (pubkey == null || solanaClient == null) {
        _hasNFT = false;
        _isLoading = false;
        _syncMultipliers();
        notifyListeners();
        return;
      }

      // Fetch token accounts for this wallet
      // Look for NFTs (amount=1, decimals=0) whose collection matches
      try {
         final tokenAccounts =
       await solanaClient.rpcClient.getTokenAccountsByOwner(
          pubkey,
          TokenAccountsFilter.byProgramId(tokenProgramId),
          encoding: Encoding.jsonParsed,
        );

        // For each token with amount=1, check if it's from our collection
        // In a full implementation, you'd fetch Metaplex metadata for each mint
        // and check the collection field. For now, we do a basic check.
        for (final account in tokenAccounts.value) {
          try {
            final parsed = account.account.data;
           if (parsed is ParsedAccountData) {
             final parsedData = parsed.parsed as Map<String, dynamic>;
              final info = parsedData['info'] as Map<String, dynamic>?;
              if (info != null) {
                final tokenAmount = info['tokenAmount'];
                if (tokenAmount != null &&
                    tokenAmount['decimals'] == 0 &&
                    tokenAmount['uiAmount'] == 1) {
                  // This is an NFT. In production, verify collection via Metaplex.
                  // For now, we log it for debugging.
                  debugPrint(
                      'Found potential NFT: ${info['mint']}');
                }
              }
            }
    } catch (e) {
            // Skip malformed accounts
          }
        }

        // Until full Metaplex integration, NFT detection relies on
        // the collection being properly set up and verified
        _hasNFT = false; // Will be true once collection is deployed and verified
      } catch (e) {
        debugPrint('Error scanning token accounts: $e');
        _hasNFT = false;
      }

      _syncMultipliers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('NFT check error: $e');
      _hasNFT = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mint a limited edition NFT from the on-chain collection
  Future<String?> mintNFT() async {
    if (!walletService.isConnected) {
      _error = 'Wallet not connected';
      notifyListeners();
      return null;
    }

    final minterPubkey = walletService.publicKeyObject;
    if (minterPubkey == null) {
      _error = 'Invalid wallet public key';
      notifyListeners();
      return null;
    }

    _initMartClient();
    if (_martClient == null) {
      _error = 'RPC client not available';
      notifyListeners();
      return null;
    }

    // Check if collection is deployed and active
    await fetchNftCollectionInfo();
    if (_nftCollectionData == null || !_nftCollectionData!.isActive) {
      _error = 'NFT collection not yet deployed or inactive. Coming soon!';
      _isLoading = false;
      notifyListeners();
      return null;
    }

    if (_nftCollectionData!.isSoldOut) {
      _error = 'NFT collection is sold out!';
      _isLoading = false;
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For NFT minting, we need a new mint keypair.
      // The mint account must be created in the same transaction.
      // This requires the client to generate a keypair, pre-sign with it,
      // then have the wallet sign as the minter.
      //
      // NOTE: This is a simplified flow. A production implementation
      // would need to:
      // 1. Generate a mint keypair
      // 2. Build create_account + initialize_mint instructions
      // 3. Append the mint_nft instruction
      // 4. Partially sign with the mint keypair
      // 5. Send to MWA for wallet signature
      //
      // For now, we build the mint_nft instruction assuming the mint
      // is created by the Anchor program (if your program handles it).

      // Generate a temporary mint keypair
      final mintKeypair = await Ed25519HDKeyPair.random();
      final nftMintPubkey = mintKeypair.publicKey;

      debugPrint('Building mintNft tx (mint: ${nftMintPubkey.toBase58()})...');

      final txBytes = await _martClient!.buildMintNftTx(
        minter: minterPubkey,
        nftMintPubkey: nftMintPubkey,
      );

      // Send to wallet for signing
      debugPrint('Sending mint transaction to wallet...');
      final signature =
      await walletService.signAndSendTransaction(txBytes);

      if (signature == null) {
        _error = walletService.errorMessage ?? 'Mint transaction failed';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Confirm
      final confirmed = await _martClient!.confirmTransaction(signature);
      if (!confirmed) {
        _error = 'Mint transaction failed to confirm';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // NFT minted successfully!
      _hasNFT = true;
      _nftName = _nftCollection.name;
      _syncMultipliers();

      _isLoading = false;
      notifyListeners();
      return nftMintPubkey.toBase58();
    } catch (e) {
      debugPrint('NFT mint error: $e');
      _error = 'Mint failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ============================================================
  // INTERNAL
  // ============================================================

  void _onWalletChanged() {
    // Re-initialize mart client with potentially new RPC endpoint
    _initMartClient();

    if (walletService.isConnected) {
      // Fetch data when wallet connects
     // _fetchStoreConfig();
      fetchOnChainBoosters();
      checkForNFT();
    } else {
      _hasNFT = false;
      _nftName = null;
      _nftImageUri = null;
      // Remove on-chain boosters, keep local ones
      _activeBoosters.removeWhere((b) => b.onChainAddress != null);
      _syncMultipliers();
      notifyListeners();
    }
  }

  void _checkExpiredBoosters() {
    final hadActive = _activeBoosters.any((b) => !b.isExpired);
    _activeBoosters.removeWhere((b) => b.isExpired && !b.isFromNFT);
    final hasActive = _activeBoosters.any((b) => !b.isExpired);

    if (hadActive != hasActive) {
      _syncMultipliers();
      notifyListeners();
    }
  }

  /// Sync multipliers from active boosters to XP system
  void _syncMultipliers() {
    xpSystem.setXPBoost(totalXPMultiplier);
    xpSystem.setPointsBoost(totalPointsMultiplier);

    if (_hasNFT) {
      xpSystem.setNFTXPMultiplier(_nftCollection.xpMultiplier);
      xpSystem.setNFTPointsMultiplier(_nftCollection.pointsMultiplier);
    } else {
      xpSystem.setNFTXPMultiplier(1.0);
      xpSystem.setNFTPointsMultiplier(1.0);
    }
  }

  void reset() {
    _activeBoosters.clear();
    _hasNFT = false;
    _nftName = null;
    _nftImageUri = null;
    _error = null;
    _syncMultipliers();
    notifyListeners();
  }
}