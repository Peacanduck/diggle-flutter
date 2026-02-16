/// premium_store_overlay.dart
/// Premium store UI for purchasing boosters and minting NFTs.
///
/// Three sections:
/// 1. Points Store - buy boosters with earned points (no wallet needed)
/// 2. Premium Store - buy boosters/points with SOL (wallet required, on-chain)
/// 3. NFT Collection - COMING SOON

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String? _message;
  bool _isSuccess = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.92),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsBar(),
            _buildActiveBoosts(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPointsStore(),
                  _buildPremiumStore(),
                  _buildNFTSection(),
                ],
              ),
            ),
            if (_message != null) _buildMessage(),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade900, Colors.indigo.shade900],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.purple.shade400, width: 2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: Colors.purple, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PREMIUM STORE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              // On-chain status indicator
              ListenableBuilder(
                listenable: widget.boostManager,
                builder: (context, _) {
                  final isOnChain = widget.boostManager.isStoreLoaded;
                  return Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOnChain ? Colors.green : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnChain ? 'On-chain prices loaded' : 'Using default prices',
                        style: TextStyle(
                          color: isOnChain
                              ? Colors.green.shade300
                              : Colors.orange.shade300,
                          fontSize: 10,
                        ),
                      ),
                      if (!isOnChain) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => widget.boostManager.refreshStoreConfig(),
                          child: Icon(
                            Icons.refresh,
                            color: Colors.orange.shade300,
                            size: 14,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => widget.game.overlays.remove('premiumStore'),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return ListenableBuilder(
      listenable: widget.xpSystem,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(
                icon: '⭐',
                label: 'Level',
                value: '${widget.xpSystem.level}',
                color: Colors.amber,
              ),
              _StatChip(
                icon: '✨',
                label: 'XP',
                value: '${widget.xpSystem.totalXP}',
                color: Colors.blue,
              ),
              _StatChip(
                icon: '💎',
                label: 'Points',
                value: '${widget.xpSystem.points}',
                color: Colors.purple,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveBoosts() {
    return ListenableBuilder(
      listenable: widget.boostManager,
      builder: (context, _) {
        final boosters = widget.boostManager.activeBoosters;
        if (boosters.isEmpty && !widget.boostManager.hasNFT) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade900.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade700),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'ACTIVE BOOSTS',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (widget.boostManager.hasNFT)
                    _BoostChip(
                      icon: '🏆',
                      label:
                      'NFT: ${widget.boostManager.nftCollection.xpMultiplier}x',
                      color: Colors.amber,
                      timeRemaining: 'Permanent',
                    ),
                  ...boosters.map((b) => _BoostChip(
                    icon: b.type.icon,
                    label:
                    '${b.type.displayName}: ${b.multiplierDisplay}',
                    color: b.onChainAddress != null
                        ? Colors.cyan
                        : Colors.green,
                    timeRemaining: b.timeRemainingDisplay,
                  )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.only(top: 4),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.purple,
        labelColor: Colors.purple,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(icon: Icon(Icons.diamond, size: 20), text: 'Points'),
          Tab(icon: Icon(Icons.currency_exchange, size: 20), text: 'SOL'),
          Tab(icon: Icon(Icons.collections, size: 20), text: 'NFT'),
        ],
      ),
    );
  }

  /// Points store - purchasable with earned points
  Widget _buildPointsStore() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: BoostManager.pointsStoreItems.length,
      itemBuilder: (context, index) {
        final item = BoostManager.pointsStoreItems[index];
        return _buildStoreItemCard(
          item: item,
          priceWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💎', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '${item.priceInPoints}',
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          canAfford: widget.xpSystem.canAffordPoints(item.priceInPoints),
          onPurchase: () {
            if (widget.boostManager.purchaseWithPoints(item)) {
              _showMessage('${item.name} activated!', true);
            } else {
              _showMessage('Not enough points!', false);
            }
          },
        );
      },
    );
  }

  /// Premium SOL store - on-chain purchases (only shows on-chain prices)
  Widget _buildPremiumStore() {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        if (!wallet.isConnected) {
          return _buildWalletPrompt();
        }

        return ListenableBuilder(
          listenable: widget.boostManager,
          builder: (context, _) {
            // Only show items when on-chain store config is loaded
            if (!widget.boostManager.isStoreLoaded) {
              return _buildStoreNotLoaded();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: BoostManager.premiumStoreItems.length,
              itemBuilder: (context, index) {
                final item = BoostManager.premiumStoreItems[index];
                final price =
                widget.boostManager.getPremiumItemPrice(item);

                return _buildStoreItemCard(
                  item: item,
                  priceWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png',
                        width: 18,
                        height: 18,
                        errorBuilder: (_, __, ___) => const Text('◎',
                            style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${price.toStringAsFixed(price < 0.01 ? 4 : 3)} SOL',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  canAfford: true,
                  isLoading: widget.boostManager.isLoading,
                  onPurchase: () async {
                    final sig =
                    await widget.boostManager.purchaseWithSOL(item);
                    if (sig != null) {
                      _showMessage(
                          '${item.name} purchased! TX: ${sig.substring(0, 8)}...',
                          true);
                    } else {
                      _showMessage(
                          widget.boostManager.error ?? 'Purchase failed',
                          false);
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// Shown when on-chain store config hasn't loaded yet
  Widget _buildStoreNotLoaded() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: Colors.orange.shade400,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Store Prices Unavailable',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load on-chain pricing.\nPlease check your connection and try again.',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => widget.boostManager.refreshStoreConfig(),
              icon: const Icon(Icons.refresh),
              label: const Text('RETRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NFT SECTION — CANDY MACHINE MINT
  // ============================================================

  Widget _buildNFTSection() {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        if (!wallet.isConnected) {
          return _buildWalletPrompt();
        }

        return ListenableBuilder(
          listenable: widget.candyMachineService,
          builder: (context, _) {
            final cms = widget.candyMachineService;

            // Already owns an NFT — show owned state
            if (cms.hasNFT) {
              return _buildNFTOwned(cms);
            }

            // Show mint UI
            return _buildNFTMint(cms);
          },
        );
      },
    );
  }

  /// Shows the mint interface when user doesn't own an NFT yet
  Widget _buildNFTMint(CandyMachineService cms) {
    final info = cms.info;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // NFT Preview
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.amber.shade900.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber.shade700.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text('💎', style: TextStyle(fontSize: 32)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.amber.shade300,
                Colors.amber.shade600,
                Colors.orange.shade700,
              ],
            ).createShader(bounds),
            child: const Text(
              'DIGGLE DIAMOND DRILL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Permanent boost NFT — one per player',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // Benefits
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                Text(
                  'HOLDER BENEFITS',
                  style: TextStyle(
                    color: Colors.amber.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                _buildBenefitRow('⚡', 'Permanent XP Boost', '+25% XP'),
                const SizedBox(height: 6),
                _buildBenefitRow('💎', 'Permanent Points Boost', '+25% Points'),
                const SizedBox(height: 6),
                _buildBenefitRow('🏆', 'Limited Supply',
                    info != null ? '${info.itemsRemaining}/${info.itemsAvailable}' : '...'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mint info / status
          if (cms.isLoadingInfo)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.amber,
              ),
            )
          else if (info == null)
            _buildMintInfoError(cms)
          else if (info.isSoldOut)
              _buildSoldOut()
            else if (!info.isMintLive)
                _buildMintNotLive(info)
              else
                _buildMintButton(cms, info),

          // Mint status feedback
          if (cms.mintStatus != MintStatus.idle)
            _buildMintStatusFeedback(cms),

          const SizedBox(height: 8),

          // Refresh button
          TextButton.icon(
            onPressed: cms.isLoadingInfo ? null : () {
              cms.fetchMintInfo();
              cms.checkNFTOwnership();
            },
            icon: Icon(Icons.refresh, size: 16,
                color: Colors.white.withOpacity(0.4)),
            label: Text('Refresh',
                style: TextStyle(color: Colors.white.withOpacity(0.4),
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMintButton(CandyMachineService cms, CandyMachineInfo info) {
    final isMinting = cms.isMinting;
    final price = info.mintPriceSol;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isMinting ? null : () => _handleMint(cms),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isMinting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💎', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              price != null
                  ? 'MINT — ${price.toStringAsFixed(price < 0.01 ? 4 : 2)} SOL'
                  : 'MINT NFT',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMint(CandyMachineService cms) async {
    final sig = await cms.mint();
    if (sig != null) {
      _showMessage('NFT Minted! 🎉', true);
    } else if (cms.error != null) {
      _showMessage(cms.error!, false);
    }
  }

  Widget _buildMintStatusFeedback(CandyMachineService cms) {
    String message;
    Color color;
    IconData icon;

    switch (cms.mintStatus) {
      case MintStatus.fetchingTransaction:
        message = 'Preparing transaction...';
        color = Colors.blue;
        icon = Icons.cloud_download;
        break;
      case MintStatus.awaitingSignature:
        message = 'Approve in your wallet app...';
        color = Colors.orange;
        icon = Icons.fingerprint;
        break;
      case MintStatus.sending:
        message = 'Sending transaction...';
        color = Colors.cyan;
        icon = Icons.send;
        break;
      case MintStatus.confirming:
        message = 'Confirming on-chain...';
        color = Colors.purple;
        icon = Icons.hourglass_top;
        break;
      case MintStatus.success:
        message = 'Minted successfully!';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case MintStatus.error:
        message = cms.error ?? 'Mint failed';
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (cms.mintStatus == MintStatus.error ||
                cms.mintStatus == MintStatus.success)
              GestureDetector(
                onTap: () => cms.resetMintStatus(),
                child: Icon(Icons.close, color: color, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  /// Shows the "already owned" state
  Widget _buildNFTOwned(CandyMachineService cms) {
    final nft = cms.ownedNFT;
    final imageUri = nft?.imageUri;
    final nftName = nft?.name ?? 'DIAMOND DRILL HOLDER';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // NFT image or fallback checkmark
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.shade400.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUri != null
                  ? Image.network(
                imageUri,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.green.shade900.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.green.shade900.withOpacity(0.3),
                    child: const Center(
                      child: Text('💎', style: TextStyle(fontSize: 40)),
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.green.shade900.withOpacity(0.3),
                child: const Center(
                  child: Text('💎', style: TextStyle(fontSize: 40)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            nftName.toUpperCase(),
            style: const TextStyle(
              color: Colors.green,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Your boosts are permanently active!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          // Active boosts
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  'ACTIVE BOOSTS',
                  style: TextStyle(
                    color: Colors.green.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBenefitRow('⚡', 'XP Boost', '+25% XP',
                    activeColor: Colors.green),
                const SizedBox(height: 8),
                _buildBenefitRow('💎', 'Points Boost', '+25% Points',
                    activeColor: Colors.green),
              ],
            ),
          ),

          if (cms.ownedNFT != null) ...[
            const SizedBox(height: 12),
            Text(
              'Mint: ${cms.ownedNFT!.mintAddress.substring(0, 8)}...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMintInfoError(CandyMachineService cms) {
    return Column(
      children: [
        Icon(Icons.cloud_off, color: Colors.orange.shade400, size: 36),
        const SizedBox(height: 8),
        Text(
          cms.error ?? 'Unable to load mint info',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            cms.fetchMintInfo();
            cms.checkNFTOwnership();
          },
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('RETRY'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSoldOut() {
    return Column(
      children: [
        Text(
          'SOLD OUT',
          style: TextStyle(
            color: Colors.red.shade400,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'All Diggle Diamond Drill NFTs have been minted!',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMintNotLive(CandyMachineInfo info) {
    return Column(
      children: [
        Icon(Icons.schedule, color: Colors.amber.shade400, size: 36),
        const SizedBox(height: 8),
        const Text(
          'MINT OPENS SOON',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          info.startDate != null
              ? 'Starts: ${_formatDate(info.startDate!)}'
              : 'Check back later!',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')} UTC';
  }

  Widget _buildBenefitRow(String icon, String title, String value,
      {Color? activeColor}) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(title,
            style: TextStyle(
                color: (activeColor ?? Colors.white).withOpacity(0.6),
                fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: activeColor ?? Colors.amber.shade400,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.purple,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Wallet Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect your Solana wallet to access premium items.\nAll purchases are on-chain transactions.',
              style: TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Consumer<WalletService>(
              builder: (context, wallet, _) {
                return ElevatedButton.icon(
                  onPressed:
                  wallet.isConnecting ? null : () => wallet.connect(),
                  icon: wallet.isConnecting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.account_balance_wallet),
                  label: Text(wallet.isConnecting
                      ? 'Connecting...'
                      : 'CONNECT WALLET'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreItemCard({
    required StoreItem item,
    required Widget priceWidget,
    required bool canAfford,
    required VoidCallback onPurchase,
    bool isLoading = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.requiresWallet
              ? Colors.cyan.shade800
              : Colors.grey.shade700,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.purple.shade900.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (item.requiresWallet) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.link, color: Colors.cyan.shade400, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          // Price + Buy
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              priceWidget,
              const SizedBox(height: 6),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed:
                  (canAfford && !isLoading) ? onPurchase : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('BUY'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _isSuccess
            ? Colors.green.shade900.withOpacity(0.8)
            : Colors.red.shade900.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _isSuccess ? Icons.check_circle : Icons.error,
            color: _isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _message!,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: ElevatedButton(
        onPressed: () => widget.game.overlays.remove('premiumStore'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text('CLOSE STORE'),
      ),
    );
  }

  void _showMessage(String message, bool success) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }
}

// ============================================================
// HELPER WIDGETS
// ============================================================

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        Text(label,
            style:
            TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _BoostChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final String timeRemaining;

  const _BoostChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Text(
            timeRemaining,
            style:
            TextStyle(color: color.withOpacity(0.7), fontSize: 10),
          ),
        ],
      ),
    );
  }
}