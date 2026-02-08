/// boost_manager.dart
/// Manages active boosts from on-chain purchases and NFT holdings.
///
/// Responsibilities:
/// - Fetches active boosters from on-chain accounts
/// - Detects NFTs in connected wallet for permanent boosts
/// - Manages timed boost expiry
/// - Syncs boost multipliers to XPPointsSystem
///
/// On-chain booster account structure (from Anchor program):
/// {
///   owner: Pubkey,
///   booster_type: u8,      // 0=XP, 1=Points, 2=Both
///   multiplier: u16,       // e.g., 200 = 2.0x
///   expires_at: i64,       // Unix timestamp (0 = permanent/NFT)
///   is_active: bool,
/// }

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:solana/solana.dart';
import '../systems/xp_points_system.dart';
import '../../solana/wallet_service.dart';

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
    if (isFromNFT) return false; // NFT boosts never expire
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
  });
}

/// NFT collection info for reward-boosting NFTs
class NFTCollectionInfo {
  final String collectionMint;
  final String name;
  final double xpMultiplier;
  final double pointsMultiplier;
  final int maxSupply;
  final double mintPriceSOL;

  const NFTCollectionInfo({
    required this.collectionMint,
    required this.name,
    required this.xpMultiplier,
    required this.pointsMultiplier,
    required this.maxSupply,
    required this.mintPriceSOL,
  });
}

/// Manages all boosts and store interactions
class BoostManager extends ChangeNotifier {
  final XPPointsSystem xpSystem;
  final WalletService walletService;

  /// Active boosters
  final List<Booster> _activeBoosters = [];

  /// Whether NFT boost is detected
  bool _hasNFT = false;

  /// NFT metadata if detected
  String? _nftName;
  String? _nftImageUri;

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

  /// Premium store items (SOL-based, requires wallet)
  static const List<StoreItem> premiumStoreItems = [
    StoreItem(
      id: 'xp_boost_mega',
      name: 'Mega XP Boost (24hr)',
      description: '2x XP for 24 hours',
      icon: '🌟',
      boosterType: BoosterType.xpBoost,
      multiplier: 2.0,
      duration: Duration(hours: 24),
      priceInSOL: 0.01,
      requiresWallet: true,
    ),
    StoreItem(
      id: 'combo_boost_mega',
      name: 'Mega Combo Boost (24hr)',
      description: '2x XP + 2x points for 24 hours',
      icon: '💥',
      boosterType: BoosterType.comboBoost,
      multiplier: 2.0,
      duration: Duration(hours: 24),
      priceInSOL: 0.02,
      requiresWallet: true,
    ),
    StoreItem(
      id: 'points_pack_500',
      name: '500 Points Pack',
      description: 'Instantly receive 500 points',
      icon: '💰',
      boosterType: BoosterType.pointsBoost,
      multiplier: 1.0,
      duration: Duration.zero,
      priceInSOL: 0.005,
      requiresWallet: true,
    ),
    StoreItem(
      id: 'points_pack_2000',
      name: '2000 Points Pack',
      description: 'Instantly receive 2000 points (20% bonus)',
      icon: '💰',
      boosterType: BoosterType.pointsBoost,
      multiplier: 1.0,
      duration: Duration.zero,
      priceInSOL: 0.015,
      requiresWallet: true,
    ),
  ];

  /// Limited edition NFT info
  /// Update collectionMint after deploying your NFT collection
  static const NFTCollectionInfo nftCollection = NFTCollectionInfo(
    collectionMint: 'YOUR_COLLECTION_MINT_ADDRESS_HERE',
    name: 'Diggle Diamond Drill',
    xpMultiplier: 1.25,
    pointsMultiplier: 1.25,
    maxSupply: 1000,
    mintPriceSOL: 0.1,
  );

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  BoostManager({
    required this.xpSystem,
    required this.walletService,
  }) {
    // Start expiry check timer
    _expiryTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => _checkExpiredBoosters(),
    );

    // Listen for wallet changes to re-check NFT
    walletService.addListener(_onWalletChanged);
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    walletService.removeListener(_onWalletChanged);
    super.dispose();
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

  /// Total active XP multiplier
  double get totalXPMultiplier {
    double mult = 1.0;
    for (final b in activeBoosters) {
      if (b.type == BoosterType.xpBoost || b.type == BoosterType.comboBoost) {
        mult *= b.multiplier;
      }
    }
    if (_hasNFT) mult *= nftCollection.xpMultiplier;
    return mult;
  }

  /// Total active points multiplier
  double get totalPointsMultiplier {
    double mult = 1.0;
    for (final b in activeBoosters) {
      if (b.type == BoosterType.pointsBoost ||
          b.type == BoosterType.comboBoost) {
        mult *= b.multiplier;
      }
    }
    if (_hasNFT) mult *= nftCollection.pointsMultiplier;
    return mult;
  }

  // ============================================================
  // POINTS-BASED PURCHASES (offline, no wallet needed)
  // ============================================================

  /// Purchase a booster with points
  bool purchaseWithPoints(StoreItem item) {
    if (item.priceInPoints <= 0) return false;
    if (!xpSystem.canAffordPoints(item.priceInPoints)) return false;

    // Special case: points pack (just add points)
    if (item.id.startsWith('points_pack')) {
      // Not applicable for points-bought items
      return false;
    }

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
  // SOL-BASED PURCHASES (requires wallet + on-chain tx)
  // ============================================================

  /// Purchase a premium booster with SOL
  /// Returns transaction signature on success, null on failure
  Future<String?> purchaseWithSOL(StoreItem item) async {
    if (!item.requiresWallet) return null;
    if (!walletService.isConnected) {
      _error = 'Wallet not connected';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ============================================================
      // ON-CHAIN TRANSACTION
      // ============================================================
      // This is where you'd build and send the Anchor instruction:
      //
      // 1. Build the PurchaseBooster instruction
      // 2. Sign via MWA (Mobile Wallet Adapter)
      // 3. Send and confirm transaction
      //
      // For now, we simulate the purchase. Replace with actual
      // Anchor client calls when your program is deployed.
      //
      // Example flow:
      //
      // final instruction = await _buildPurchaseInstruction(item);
      // final signature = await _signAndSend(instruction);
      // if (signature != null) {
      //   // Fetch the created booster account
      //   final boosterAccount = await _fetchBoosterAccount(signature);
      //   _activeBoosters.add(boosterAccount);
      // }

      // Special case: points pack
      if (item.id.startsWith('points_pack')) {
        final pointsAmount = int.tryParse(
            item.id.replaceAll('points_pack_', '')) ?? 0;
        xpSystem.addPoints(pointsAmount);

        _isLoading = false;
        notifyListeners();
        return 'simulated_tx_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Timed booster
      final booster = Booster(
        type: item.boosterType,
        multiplier: item.multiplier,
        duration: item.duration,
        expiresAt: DateTime.now().add(item.duration),
        isActive: true,
      );

      _activeBoosters.add(booster);
      _syncMultipliers();

      _isLoading = false;
      notifyListeners();
      return 'simulated_tx_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      _error = 'Purchase failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ============================================================
  // NFT DETECTION
  // ============================================================

  /// Check connected wallet for Diggle NFT
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
      // ============================================================
      // NFT DETECTION LOGIC
      // ============================================================
      // When deployed, this would:
      // 1. Fetch all token accounts for the connected wallet
      // 2. Filter for NFTs (amount=1, decimals=0)
      // 3. Fetch metadata for each NFT
      // 4. Check if any belong to your collection (by collection mint)
      //
      // Using Metaplex:
      //
      // final pubkey = walletService.publicKey;
      // final tokenAccounts = await solanaClient.rpcClient
      //     .getTokenAccountsByOwner(pubkey, ...);
      //
      // for (final account in tokenAccounts) {
      //   final metadata = await fetchMetadata(account.mint);
      //   if (metadata.collection?.key == nftCollection.collectionMint) {
      //     _hasNFT = true;
      //     _nftName = metadata.name;
      //     _nftImageUri = metadata.uri;
      //     break;
      //   }
      // }

      // For now, NFT detection is disabled until collection is deployed
      _hasNFT = false;

      _syncMultipliers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('NFT check error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mint a limited edition NFT
  /// Returns mint address on success
  Future<String?> mintNFT() async {
    if (!walletService.isConnected) {
      _error = 'Wallet not connected';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ============================================================
      // NFT MINTING
      // ============================================================
      // When deployed, this would:
      // 1. Call your Anchor program's mint_nft instruction
      // 2. The program checks supply < maxSupply
      // 3. Creates the NFT via CPI to Metaplex Token Metadata
      // 4. Transfers SOL mint price to treasury
      // 5. Returns the new mint address
      //
      // final instruction = await _buildMintNFTInstruction();
      // final signature = await _signAndSend(instruction);
      // final mintAddress = await _extractMintFromTx(signature);
      //
      // _hasNFT = true;
      // _nftName = nftCollection.name;
      // _syncMultipliers();

      _error = 'NFT collection not yet deployed. Coming soon!';
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
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
    if (walletService.isConnected) {
      checkForNFT();
    } else {
      _hasNFT = false;
      _nftName = null;
      _nftImageUri = null;
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
      xpSystem.setNFTXPMultiplier(nftCollection.xpMultiplier);
      xpSystem.setNFTPointsMultiplier(nftCollection.pointsMultiplier);
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