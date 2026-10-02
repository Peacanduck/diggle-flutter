/// boost_manager.dart
/// Manages the permanent holder boosts: Diggle NFT and Seeker Genesis Token.
///
/// Responsibilities:
/// - Delegates NFT detection to CandyMachineService (Metaplex Candy Machine)
/// - Keeps collection info (supply, mint price) in sync with the candy machine
/// - Syncs holder multipliers to XPPointsSystem
///
/// Timed boosters (points- and SOL-bought) were removed when the Diggle
/// Mart program closed (2026-09-29).

import 'package:flutter/foundation.dart';
import './xp_points_system.dart';
import '../../solana/wallet_service.dart';
import '../../solana/candy_machine_service.dart';

/// NFT collection info for reward-boosting NFTs
class NFTCollectionInfo {
  final String name;
  final double xpMultiplier;
  final double pointsMultiplier;
  final int maxSupply;
  final double mintPriceSOL;
  final String? imageUrl;
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
    this.imageUrl,
    this.currentSupply = 0,
    this.isActive = false,
    this.collectionMint,
  });

  int get remainingSupply => maxSupply - currentSupply;
  bool get isSoldOut => currentSupply >= maxSupply;

  /// The collection as known before the candy machine reports in: the
  /// fixed holder multipliers plus fallback supply and price.
  static const NFTCollectionInfo defaults = NFTCollectionInfo(
    name: 'Diggle Diamond Drill',
    xpMultiplier: 1.25,
    pointsMultiplier: 1.25,
    maxSupply: 10000,
    mintPriceSOL: 0.1,
    imageUrl: 'https://gateway.irys.xyz/nrUUILfhG4NHoDG1e2c-Xky4veoRJEY2KgP24Cp_AAU?ext=png',
  );
}

/// Manages holder boosts (NFT + Seeker Genesis Token)
class BoostManager extends ChangeNotifier {
  final XPPointsSystem xpSystem;
  final WalletService walletService;
  final CandyMachineService candyMachineService;

  /// NFT collection info - defaults, updated from candy machine service
  NFTCollectionInfo _nftCollection = NFTCollectionInfo.defaults;

  NFTCollectionInfo get nftCollection => _nftCollection;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  BoostManager({
    required this.xpSystem,
    required this.walletService,
    required this.candyMachineService,
  }) {
    // Listen for wallet changes
    walletService.addListener(_onWalletChanged);

    // Listen for candy machine service changes (NFT ownership updates)
    candyMachineService.addListener(_onCandyMachineChanged);

    // Initialize candy machine AFTER the current build frame completes
    // to avoid notifyListeners() during widget build
    Future.microtask(() => candyMachineService.initialize());
  }

  @override
  void dispose() {
    walletService.removeListener(_onWalletChanged);
    candyMachineService.removeListener(_onCandyMachineChanged);
    super.dispose();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  /// NFT ownership is now delegated to CandyMachineService
  bool get hasNFT => candyMachineService.hasNFT;

  String? get nftName => hasNFT ? _nftCollection.name : null;
  String? get nftImageUri => null; // Could be fetched from metadata URI

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
        imageUrl: _nftCollection.imageUrl,
        currentSupply: cmInfo.itemsRedeemed,
        isActive: cmInfo.isMintLive && !cmInfo.isSoldOut,
        collectionMint: candyMachineService.collectionMint,
      );
    }

    _syncMultipliers();
    notifyListeners();
  }

  // ============================================================
  // INTERNAL
  // ============================================================

  void _onWalletChanged() {
    if (walletService.isConnected) {
      // NFT check is handled by CandyMachineService listening to wallet
      candyMachineService.initialize();
    }
    _syncMultipliers();
    notifyListeners();
  }

  /// Seeker Genesis Token holder bonus (verified Solana Mobile device).
  static const double genesisTokenBonus = 1.05;

  bool get hasGenesisToken => candyMachineService.hasGenesisToken;

  /// Sync holder multipliers (Diggle NFT × Seeker Genesis Token) to the
  /// XP system.
  void _syncMultipliers() {
    double nftXP = hasNFT ? _nftCollection.xpMultiplier : 1.0;
    double nftPoints = hasNFT ? _nftCollection.pointsMultiplier : 1.0;
    if (hasGenesisToken) {
      nftXP *= genesisTokenBonus;
      nftPoints *= genesisTokenBonus;
    }
    xpSystem.setNFTXPMultiplier(nftXP);
    xpSystem.setNFTPointsMultiplier(nftPoints);
  }
}
