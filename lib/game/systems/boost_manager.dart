/// boost_manager.dart
/// Manages active boosts from on-chain purchases and NFT holdings.
///
/// Responsibilities:
/// - Fetches store config and active boosters from on-chain accounts
/// - Builds and sends purchase transactions via MWA
/// - Delegates NFT detection to CandyMachineService (Metaplex Candy Machine)
/// - Manages timed boost expiry
/// - Syncs boost multipliers to XPPointsSystem
/// - Logs purchases to Supabase via XPStatsBridge

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import '../../services/xp_stats_bridge.dart';
import './xp_points_system.dart';
import '../../solana/wallet_service.dart';
import '../../solana/diggle_mart_client.dart';
import '../../solana/candy_machine_service.dart';

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
  final CandyMachineService candyMachineService;

  /// Optional bridge for Supabase persistence.
  /// Set after construction via [attachStatsBridge].
  XPStatsBridge? _statsBridge;

  /// Diggle Mart on-chain client
  DiggleMartClient? _martClient;

  /// Active boosters (from chain + local points purchases)
  final List<Booster> _activeBoosters = [];

  /// On-chain store data
  OnChainStore? _storeData;

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

  /// NFT collection info - defaults, updated from candy machine service
  NFTCollectionInfo _nftCollection = const NFTCollectionInfo(
    name: 'Diggle Diamond Drill',
    xpMultiplier: 1.25,
    pointsMultiplier: 1.25,
    maxSupply: 10000,
    mintPriceSOL: 0.1,
  );

  NFTCollectionInfo get nftCollection => _nftCollection;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  BoostManager({
    required this.xpSystem,
    required this.walletService,
    required this.candyMachineService,
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

    // Listen for candy machine service changes (NFT ownership updates)
    candyMachineService.addListener(_onCandyMachineChanged);

    // Fetch store config on init
    _fetchStoreConfig();

    // Initialize candy machine AFTER the current build frame completes
    // to avoid notifyListeners() during widget build
    Future.microtask(() => candyMachineService.initialize());
  }

  /// Attach the Supabase stats bridge for persistence.
  /// Call this after constructing BoostManager in your Provider setup.
  void attachStatsBridge(XPStatsBridge bridge) {
    _statsBridge = bridge;
    debugPrint('BoostManager: stats bridge attached');
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    walletService.removeListener(_onWalletChanged);
    candyMachineService.removeListener(_onCandyMachineChanged);
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

  /// NFT ownership is now delegated to CandyMachineService
  bool get hasNFT => candyMachineService.hasNFT;

  String? get nftName => hasNFT ? _nftCollection.name : null;
  String? get nftImageUri => null; // Could be fetched from metadata URI
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
    if (hasNFT) mult *= _nftCollection.xpMultiplier;
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
    if (hasNFT) mult *= _nftCollection.pointsMultiplier;
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

  /// Fetch store config from on-chain
  Future<void> _fetchStoreConfig({bool silent = false}) async {
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
        if(!silent) notifyListeners();
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

  // ============================================================
  // POINTS-BASED PURCHASES (offline, no wallet needed)
  // ============================================================

  bool purchaseWithPoints(StoreItem item) {
    if (item.priceInPoints <= 0) return false;
    if (!xpSystem.canAffordPoints(item.priceInPoints)) return false;
    if (item.id.startsWith('points_pack')) return false;

    // Use bridge if available for ledger tracking, otherwise direct
    if (_statsBridge != null) {
      final success = _statsBridge!.spendPoints(
        item.priceInPoints,
        itemName: item.name,
      );
      if (!success) return false;
    } else {
      xpSystem.spendPoints(item.priceInPoints);
    }

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
      await _fetchStoreConfig(silent: true);

      Uint8List txBytes;
      bool isPointsPack = item.onChainPackType != null;

      if (isPointsPack) {
        debugPrint(
            'Building purchasePointsPack tx (packType: ${item.onChainPackType})...');

        txBytes = await _martClient!.buildPurchasePointsPackTx(
          buyer: buyerPubkey,
          packType: item.onChainPackType!,
        );
      } else if (item.onChainBoosterType != null &&
          item.onChainDurationSeconds != null) {
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

      // Apply the effects locally + log to Supabase
      if (isPointsPack) {
        final config = _storeData?.config;
        int pointsAmount;
        if (item.onChainPackType == 0) {
          pointsAmount = config?.pointsPackSmallAmount ?? 500;
        } else {
          pointsAmount = config?.pointsPackLargeAmount ?? 2000;
        }
        if (_statsBridge != null) {
          _statsBridge!.awardPackPurchase(
            pointsAmount,
            item.onChainPackType!,
            signature,
          );
        } else {
          xpSystem.addPoints(pointsAmount);
        }
        debugPrint('Awarded $pointsAmount points from pack purchase');
      } else {
        final booster = Booster(
          type: item.boosterType,
          multiplier: item.multiplier,
          duration: item.duration,
          expiresAt: DateTime.now().add(item.duration),
          isActive: true,
          onChainAddress: signature,
        );
        _activeBoosters.add(booster);
        _syncMultipliers();

        _statsBridge?.logBoosterPurchase(
          boosterType: item.onChainBoosterType!,
          durationSeconds: item.onChainDurationSeconds!,
          priceSOL: getPremiumItemPrice(item),
          txSignature: signature,
        );

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
  // NFT DETECTION — Delegated to CandyMachineService
  // ============================================================

  /// Check connected wallet for Diggle NFT.
  /// Delegates to CandyMachineService which handles Metaplex metadata parsing.
  Future<void> checkForNFT() async {
    if (!walletService.isConnected) {
      _syncMultipliers();
      notifyListeners();
      return;
    }

    await candyMachineService.checkNFTOwnership();
    // _onCandyMachineChanged will fire and sync multipliers
  }

  /// Called when CandyMachineService notifies (NFT ownership change, mint status, etc.)
  void _onCandyMachineChanged() {
    // Update NFT collection info from candy machine mint info if available
    final cmInfo = candyMachineService.info;
    if (cmInfo != null) {
      _nftCollection = NFTCollectionInfo(
        name: _nftCollection.name,
        xpMultiplier: _nftCollection.xpMultiplier,
        pointsMultiplier: _nftCollection.pointsMultiplier,
        maxSupply: cmInfo.itemsAvailable,
        mintPriceSOL: cmInfo.mintPriceSol ?? _nftCollection.mintPriceSOL,
        currentSupply: cmInfo.itemsRedeemed,
        isActive: cmInfo.isMintLive && !cmInfo.isSoldOut,
        collectionMint: CandyMachineService.collectionMint,
      );
    }

    _syncMultipliers();
    notifyListeners();
  }

  // ============================================================
  // INTERNAL
  // ============================================================

  void _onWalletChanged() {
    // Re-initialize mart client with potentially new RPC endpoint
    _initMartClient();
    _fetchStoreConfig();

    if (walletService.isConnected) {
      fetchOnChainBoosters();
      // NFT check is handled by CandyMachineService listening to wallet
      candyMachineService.initialize();
    } else {
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

  /// Sync multipliers from active boosters + NFT to XP system
  void _syncMultipliers() {
    xpSystem.setXPBoost(totalXPMultiplier);
    xpSystem.setPointsBoost(totalPointsMultiplier);

    if (hasNFT) {
      xpSystem.setNFTXPMultiplier(_nftCollection.xpMultiplier);
      xpSystem.setNFTPointsMultiplier(_nftCollection.pointsMultiplier);
    } else {
      xpSystem.setNFTXPMultiplier(1.0);
      xpSystem.setNFTPointsMultiplier(1.0);
    }
  }

  void reset() {
    _activeBoosters.clear();
    _error = null;
    _syncMultipliers();
    notifyListeners();
  }
}