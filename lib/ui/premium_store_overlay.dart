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
                  _buildNFTComingSoon(),
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
  // NFT SECTION — COMING SOON
  // ============================================================

  Widget _buildNFTComingSoon() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Diamond icon with glow effect
          Container(
            width: 120,
            height: 120,
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber.shade700.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text('💎', style: TextStyle(fontSize: 36)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Coming Soon title
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.amber.shade300,
                Colors.amber.shade600,
                Colors.orange.shade700,
              ],
            ).createShader(bounds),
            child: const Text(
              'COMING SOON',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Diggle Drill Machine NFT',
            style: TextStyle(
              color: Colors.amber.shade400,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Limited edition reward-boosting NFTs are on the way.\n'
                'Hold a Drill Machine NFT for permanent XP and Points multipliers!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Preview of benefits
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withOpacity(0.15),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'PLANNED BENEFITS',
                  style: TextStyle(
                    color: Colors.amber.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildComingSoonBenefit('⚡', 'Permanent XP Boost', '+25% XP'),
                const SizedBox(height: 8),
                _buildComingSoonBenefit('💎', 'Permanent Points Boost', '+25% Points'),
                const SizedBox(height: 8),
                _buildComingSoonBenefit('🏆', 'Limited Supply', '10,000 max'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Stay tuned for the mint announcement!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonBenefit(String icon, String title, String value) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(title,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Colors.amber.shade400,
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