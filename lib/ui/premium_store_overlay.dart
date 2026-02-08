/// premium_store_overlay.dart
/// Premium store UI for purchasing boosters and minting NFTs.
///
/// Three sections:
/// 1. Points Store - buy boosters with earned points (no wallet needed)
/// 2. Premium Store - buy boosters/points with SOL (wallet required, on-chain)
/// 3. NFT Collection - mint limited edition reward-boosting NFTs

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/diggle_game.dart';
import '../game/systems/xp_points_system.dart';
import '../game/systems/boost_manager.dart';
import '../solana/wallet_service.dart';

class PremiumStoreOverlay extends StatefulWidget {
  final DiggleGame game;
  final XPPointsSystem xpSystem;
  final BoostManager boostManager;

  const PremiumStoreOverlay({
    super.key,
    required this.game,
    required this.xpSystem,
    required this.boostManager,
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

  /// Premium SOL store - on-chain purchases
  Widget _buildPremiumStore() {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        if (!wallet.isConnected) {
          return _buildWalletPrompt();
        }

        return ListenableBuilder(
          listenable: widget.boostManager,
          builder: (context, _) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: BoostManager.premiumStoreItems.length,
              itemBuilder: (context, index) {
                final item = BoostManager.premiumStoreItems[index];
                // Use on-chain price if available, fallback to default
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
                  canAfford: true, // SOL balance check could be added
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

  /// NFT collection section
  Widget _buildNFTSection() {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        return ListenableBuilder(
          listenable: widget.boostManager,
          builder: (context, _) {
            final nft = widget.boostManager.nftCollection;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
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
                      border: Border.all(color: Colors.amber.shade700),
                    ),
                    child: Column(
                      children: [
                        // NFT Image placeholder
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.amber.shade600, width: 2),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('💎',
                                    style: TextStyle(fontSize: 48)),
                                SizedBox(height: 8),
                                Text(
                                  'Diamond Drill',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          nft.name,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Limited Edition Reward Booster',
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),

                        const SizedBox(height: 16),

                        // Benefits
                        _buildNFTBenefit(
                          '⚡',
                          'XP Boost',
                          '+${((nft.xpMultiplier - 1) * 100).toInt()}% XP permanently',
                        ),
                        _buildNFTBenefit(
                          '💎',
                          'Points Boost',
                          '+${((nft.pointsMultiplier - 1) * 100).toInt()}% points permanently',
                        ),
                        _buildNFTBenefit(
                          '🏆',
                          'Supply',
                          '${nft.currentSupply}/${nft.maxSupply} minted',
                        ),

                        const SizedBox(height: 16),

                        // NFT status
                        if (widget.boostManager.hasNFT)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                              Colors.green.shade900.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'NFT Detected! Boosts Active',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (!wallet.isConnected)
                          Column(
                            children: [
                              const Text(
                                'Connect your wallet to mint or detect existing NFTs',
                                style: TextStyle(color: Colors.white54),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => wallet.connect(),
                                icon: const Icon(
                                    Icons.account_balance_wallet),
                                label: const Text('CONNECT WALLET'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              if (nft.isSoldOut)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade900
                                        .withOpacity(0.5),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'SOLD OUT',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                              else ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed:
                                    widget.boostManager.isLoading
                                        ? null
                                        : () async {
                                      final mint =
                                      await widget
                                          .boostManager
                                          .mintNFT();
                                      if (mint != null) {
                                        _showMessage(
                                            'NFT Minted! 🎉 Mint: ${mint.substring(0, 8)}...',
                                            true);
                                      } else {
                                        _showMessage(
                                          widget.boostManager
                                              .error ??
                                              'Mint failed',
                                          false,
                                        );
                                      }
                                    },
                                    icon: widget
                                        .boostManager.isLoading
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                      CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                        : const Text('💎',
                                        style: TextStyle(
                                            fontSize: 20)),
                                    label: Text(
                                      'MINT FOR ${nft.mintPriceSOL} SOL',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Colors.amber.shade700,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () =>
                                      widget.boostManager.checkForNFT(),
                                  child: const Text(
                                    'Already own one? Tap to detect',
                                    style:
                                    TextStyle(color: Colors.white54),
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNFTBenefit(String icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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