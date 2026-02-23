/// premium_store_overlay.dart
/// Premium store overlay for points/SOL/NFT purchases.
/// All user-facing strings localized via AppLocalizations.
///
/// BoostManager API used:
///   - BoostManager.pointsStoreItems (static)  — points catalog
///   - BoostManager.premiumStoreItems (static)  — SOL catalog
///   - boostManager.refreshStoreConfig()        — load on-chain prices
///   - boostManager.isStoreLoaded               — prices available?
///   - boostManager.activeBoosters              — active boost list
///   - boostManager.purchaseWithPoints(item)     — buy with points
///   - boostManager.purchaseWithSOL(item)        — buy with SOL
///   - boostManager.getPremiumItemPrice(item)    — on-chain price
///   - boostManager.checkForNFT()               — refresh NFT ownership
///   - boostManager.hasNFT                      — NFT ownership flag
///   - boostManager.nftCollection               — NFTCollectionInfo
///
/// CandyMachineService API used:
///   - candyMachineService.info                 — CandyMachineInfo?
///     .itemsAvailable, .itemsRedeemed, .mintPriceSol, .isMintLive, .isSoldOut
///   - candyMachineService.hasNFT               — bool
///   - candyMachineService.isMinting            — bool
///   - candyMachineService.mintStatus           — MintStatus?
///   - candyMachineService.mint()               — Future<String?>
///
/// Booster model:
///   .type.displayName, .type.icon, .multiplier, .isFromNFT, .timeRemaining

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../game/diggle_game.dart';
import '../game/systems/xp_points_system.dart';
import '../game/systems/boost_manager.dart';
import '../solana/wallet_service.dart';
import '../solana/candy_machine_service.dart';

class PremiumStoreOverlay extends StatefulWidget {
  final DiggleGame game;
  final XPPointsSystem xpSystem;
  final BoostManager boostManager;
  final CandyMachineService candyMachineService;

  const PremiumStoreOverlay({
    super.key,
    required this.game,
    required this.xpSystem,
    required this.boostManager,
    required this.candyMachineService,
  });

  @override
  State<PremiumStoreOverlay> createState() => _PremiumStoreOverlayState();
}

class _PremiumStoreOverlayState extends State<PremiumStoreOverlay>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _statusMessage;
  bool _loadingPrices = true;
  bool _pricesAvailable = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPrices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    setState(() => _loadingPrices = true);
    try {
      await widget.boostManager.refreshStoreConfig();
      setState(() {
        _pricesAvailable = widget.boostManager.isStoreLoaded;
        _loadingPrices = false;
      });
      if (_pricesAvailable) {
        _showStatus(AppLocalizations.of(context)!.onChainLoaded);
      } else {
        _showStatus(AppLocalizations.of(context)!.usingDefaultPrices);
      }
    } catch (e) {
      setState(() {
        _pricesAvailable = false;
        _loadingPrices = false;
      });
      _showStatus(AppLocalizations.of(context)!.usingDefaultPrices);
    }
  }

  void _showStatus(String msg) {
    setState(() => _statusMessage = msg);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _statusMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.black.withOpacity(0.92),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            _buildPlayerBar(l10n),
            _buildActiveBoosts(l10n),
            _buildTabBar(l10n),
            Expanded(
              child: _loadingPrices
                  ? const Center(
                  child: CircularProgressIndicator(color: Colors.purple))
                  : TabBarView(
                controller: _tabController,
                children: [
                  _buildPointsTab(l10n),
                  _buildSolTab(l10n),
                  _buildNFTTab(l10n),
                ],
              ),
            ),
            if (_statusMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade900.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.purple, size: 16),
                    const SizedBox(width: 8),
                    Text(_statusMessage!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            _buildCloseButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.purple.shade900,
          Colors.deepPurple.shade800,
        ]),
        border: Border(
            bottom: BorderSide(color: Colors.purple.shade400, width: 2)),
      ),
      child: Row(
        children: [
          const Text('💎', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l10n.premiumStore,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
          ),
          IconButton(
            onPressed: () => widget.game.overlays.remove('premiumStore'),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBar(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.xpSystem,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCol(
                  '⭐', l10n.level, '${widget.xpSystem.level}', Colors.amber),
              _buildStatCol(
                  '✨', l10n.xp, '${widget.xpSystem.totalXP}', Colors.blue),
              _buildStatCol('💎', l10n.points, '${widget.xpSystem.points}',
                  Colors.purple),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCol(
      String icon, String label, String value, Color color) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActiveBoosts(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: widget.boostManager,
      builder: (context, _) {
        final boosts = widget.boostManager.activeBoosters;
        if (boosts.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.shade900.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade700.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(l10n.activeBoosts,
                      style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: boosts.map((b) {
                  return Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: b.isFromNFT
                          ? Colors.amber.shade900.withOpacity(0.5)
                          : Colors.purple.shade900.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(b.type.icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(b.type.displayName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                        const SizedBox(width: 4),
                        if (b.isFromNFT)
                          Text('∞',
                              style: TextStyle(
                                  color: Colors.amber.shade300, fontSize: 12))
                        else
                          Text(_formatDuration(b.timeRemaining),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.grey.shade900,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.purple,
        labelColor: Colors.purple,
        unselectedLabelColor: Colors.white54,
        tabs: [
          Tab(icon: Icon(Icons.diamond, size: 20),
              text: l10n.pointsTab),
          Tab(icon: Icon(Icons.currency_exchange, size: 20),
              text: l10n.solTab),
          Tab(icon: Icon(Icons.collections, size: 20),
              text: l10n.nftTab),
        ],
      ),
    );
  }

  // ── Points Tab ─────────────────────────────────────────────────

  Widget _buildPointsTab(AppLocalizations l10n) {
    final items = BoostManager.pointsStoreItems;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final canBuy = widget.xpSystem.points >= item.priceInPoints;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: canBuy
                    ? Colors.purple.withOpacity(0.5)
                    : Colors.grey.shade800),
          ),
          child: Row(
            children: [
              Text(item.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(item.description,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: canBuy ? () => _buyWithPoints(item) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade800,
                ),
                child: Column(
                  children: [
                    Text('💎 ${item.priceInPoints}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(l10n.buy,
                        style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── SOL Tab ────────────────────────────────────────────────────

  Widget _buildSolTab(AppLocalizations l10n) {
    final wallet = context.watch<WalletService>();

    if (!wallet.isConnected) {
      return _buildWalletRequired(l10n);
    }

    if (!_pricesAvailable && !widget.boostManager.isStoreLoaded) {
      return _buildPricesUnavailable(l10n);
    }

    final items = BoostManager.premiumStoreItems;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final price = widget.boostManager.getPremiumItemPrice(item);
        final isPointsPack = item.onChainPackType != null;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Text(item.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(item.description,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    if (isPointsPack)
                      Text(l10n.permanent,
                          style: const TextStyle(
                              color: Colors.amber, fontSize: 10)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: widget.boostManager.isLoading
                    ? null
                    : () => _buyWithSOL(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade800,
                ),
                child: widget.boostManager.isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png',
                          width: 14,
                          height: 14,
                          errorBuilder: (_, __, ___) => const Text('◎',
                              style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 4),
                        Text(price.toStringAsFixed(3),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    Text(l10n.buy,
                        style: const TextStyle(fontSize: 10)),
                  ],
                ),

              ),
            ],
          ),
        );
      },
    );
  }

  // ── NFT Tab ────────────────────────────────────────────────────

  Widget _buildNFTTab(AppLocalizations l10n) {
    final wallet = context.watch<WalletService>();

    if (!wallet.isConnected) {
      return _buildWalletRequired(l10n);
    }

    return ListenableBuilder(
      listenable: widget.candyMachineService,
      builder: (context, _) {
        final cmInfo = widget.candyMachineService.info;
        final nftCol = widget.boostManager.nftCollection;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // NFT preview card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.shade900.withOpacity(0.3),
                      Colors.purple.shade900.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border:
                  Border.all(color: Colors.amber.shade700.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Text('⛏️', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    Text(l10n.diggleDrillMachine,
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text(l10n.permanentBoostNft,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12)),
                    const SizedBox(height: 16),

                    // Benefits
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(l10n.holderBenefits,
                              style: TextStyle(
                                  color: Colors.amber.shade300,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                          const SizedBox(height: 8),
                          _buildBenefitRow('⚡', l10n.permanentXpBoost,
                              '+${((nftCol.xpMultiplier - 1) * 100).toInt()}% XP'),
                          _buildBenefitRow('💎', l10n.permanentPointsBoost,
                              '+${((nftCol.pointsMultiplier - 1) * 100).toInt()}% Points'),
                          _buildBenefitRow(
                            '🏆',
                            l10n.limitedSupply,
                            '${cmInfo?.itemsRedeemed ?? nftCol.currentSupply}'
                                '/${cmInfo?.itemsAvailable ?? nftCol.maxSupply}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mint status / action
              if (cmInfo?.isSoldOut == true || nftCol.isSoldOut)
                _buildMintStatus(
                    l10n.soldOut, l10n.allNftsMinted, Colors.red)
              else if (cmInfo != null && !cmInfo.isMintLive)
                _buildMintStatus(
                    l10n.mintOpensSoon, l10n.checkBackLater, Colors.orange)
              else if (widget.candyMachineService.hasNFT)
                  _buildMintStatus(
                      l10n.nftMinted, l10n.boostsActive, Colors.green)
                else
                  _buildMintButton(l10n),

              if (widget.candyMachineService.mintStatus != MintStatus.idle) ...[
                const SizedBox(height: 12),
                _buildMintProgress(
                    l10n, widget.candyMachineService.mintStatus),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMintStatus(String title, String subtitle, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  color: color.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMintButton(AppLocalizations l10n) {
    final cmInfo = widget.candyMachineService.info;
    final nftCol = widget.boostManager.nftCollection;
    final mintPrice = cmInfo?.mintPriceSol ?? nftCol.mintPriceSOL;
    final isMinting = widget.candyMachineService.isMinting;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isMinting ? null : () => _mintNFT(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          foregroundColor: Colors.black,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isMinting
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.black),
        )
            : Text(
          l10n.mintCost(mintPrice.toStringAsFixed(3)),
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildMintProgress(AppLocalizations l10n, MintStatus status) {
    final (label, color) = switch (status) {
      MintStatus.idle                => ('', Colors.transparent), // Added safe fallback
      MintStatus.fetchingTransaction => (l10n.mintStatusPreparing, Colors.white70),
      MintStatus.awaitingSignature   => (l10n.mintStatusApprove, Colors.amber),
      MintStatus.sending             => (l10n.mintStatusSending, Colors.blue),
      MintStatus.confirming          => (l10n.mintStatusConfirming, Colors.purple),
      MintStatus.success             => (l10n.mintStatusSuccess, Colors.green),
      MintStatus.error               => (l10n.mintStatusError, Colors.red),
    };

    if (status == MintStatus.idle) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (status != MintStatus.success && status != MintStatus.error)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: color),
            )
          else
            Icon(
                status == MintStatus.success
                    ? Icons.check_circle
                    : Icons.error,
                color: color,
                size: 16),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildWalletRequired(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: Colors.purple, size: 48),
            const SizedBox(height: 16),
            Text(l10n.walletRequired,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.walletRequiredMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<WalletService>().connect(),
              icon: const Icon(Icons.account_balance_wallet),
              label: Text(l10n.connectWallet),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricesUnavailable(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            Text(l10n.storePricesUnavailable,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.storePricesUnavailableMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPrices,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: ElevatedButton.icon(
        onPressed: () => widget.game.overlays.remove('premiumStore'),
        icon: const Icon(Icons.close),
        label: Text(l10n.closeStore),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────

  Future<void> _buyWithPoints(StoreItem item) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = widget.boostManager.purchaseWithPoints(item);
      if (success) {
        _showStatus(l10n.activated(item.name));
      } else {
        _showStatus(l10n.notEnoughPoints);
      }
    } catch (e) {
      _showStatus(l10n.purchaseFailed);
    }
  }

  Future<void> _buyWithSOL(StoreItem item) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final tx = await widget.boostManager.purchaseWithSOL(item);
      if (tx != null) {
        _showStatus(l10n.purchasedTx(item.name, tx.substring(0, 8)));
      } else {
        // Check if BoostManager set an error message
        final err = widget.boostManager.error;
        _showStatus(err ?? l10n.purchaseFailed);
      }
    } catch (e) {
      _showStatus(l10n.purchaseFailed);
    }
  }

  Future<void> _mintNFT() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await widget.candyMachineService.mint();
      if (result != null) {
        // Refresh NFT ownership status in BoostManager
        await widget.boostManager.checkForNFT();
        _showStatus(l10n.nftMinted);
      }
    } catch (e) {
      _showStatus(l10n.purchaseFailed);
    }
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return '${d.inSeconds}s';
  }
}