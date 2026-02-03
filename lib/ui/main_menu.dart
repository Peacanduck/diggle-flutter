/// main_menu.dart
/// Main menu screen with play button and wallet connection

import 'package:flutter/material.dart';
import '../solana/wallet_service.dart';

class MainMenu extends StatefulWidget {
  final VoidCallback onPlay;
  final WalletService walletService;

  const MainMenu({
    super.key,
    required this.onPlay,
    required this.walletService,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            _buildTitle(),
            const Spacer(flex: 2),
            _buildMenuButtons(),
            const Spacer(flex: 1),
            _buildWalletSection(),
            const SizedBox(height: 16),
            _buildFooter(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Animated Drill Icon
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade600, Colors.blue.shade900],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.hardware, size: 55, color: Colors.white.withOpacity(0.9)),
                Positioned(
                  bottom: 8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Title
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.amber.shade300, Colors.orange, Colors.deepOrange],
          ).createShader(bounds),
          child: const Text(
            'DIGGLE',
            style: TextStyle(
              fontSize: 58,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'DRILL DEEP  •  COLLECT ORE  •  SURVIVE',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Play Button
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: widget.onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.green.withOpacity(0.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 32),
                  SizedBox(width: 8),
                  Text(
                    'START MINING',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Premium Shop Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _showPremiumShop(context),
              icon: const Icon(Icons.diamond, size: 22),
              label: const Text(
                'PREMIUM SHOP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber,
                side: BorderSide(color: Colors.amber.shade600, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection() {
    return ListenableBuilder(
      listenable: widget.walletService,
      builder: (context, _) {
        final wallet = widget.walletService;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: wallet.isConnected
                  ? Colors.green.withOpacity(0.5)
                  : Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9945FF), Color(0xFF14F195)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('◎', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    wallet.isConnected ? 'WALLET CONNECTED' : 'SOLANA WALLET',
                    style: TextStyle(
                      color: wallet.isConnected ? Colors.green : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Network toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNetworkButton('Devnet', !wallet.isMainnet, () => wallet.setMainnet(false)),
                  const SizedBox(width: 8),
                  _buildNetworkButton('Mainnet', wallet.isMainnet, () => wallet.setMainnet(true)),
                ],
              ),
              const SizedBox(height: 14),

              if (wallet.isConnected) ...[
                // Connected state
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    wallet.shortAddress,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${wallet.solBalance.toStringAsFixed(4)} SOL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!wallet.isMainnet)
                      TextButton.icon(
                        onPressed: () => wallet.requestAirdrop(),
                        icon: const Icon(Icons.water_drop, size: 16),
                        label: const Text('Airdrop'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.cyan,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => wallet.refreshBalance(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white54,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => wallet.disconnect(),
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Disconnect'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ] else if (wallet.isConnecting) ...[
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple),
                    ),
                    SizedBox(width: 12),
                    Text('Connecting...', style: TextStyle(color: Colors.white54)),
                  ],
                ),
                const SizedBox(height: 10),
              ] else ...[
                // Disconnected state
                if (wallet.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            wallet.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 11),
                          ),
                        ),
                        IconButton(
                          onPressed: () => wallet.clearError(),
                          icon: const Icon(Icons.close, size: 16),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
                ElevatedButton.icon(
                  onPressed: () => wallet.connect(),
                  icon: const Icon(Icons.account_balance_wallet, size: 20),
                  label: const Text('CONNECT WALLET'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9945FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect to buy premium items with SOL',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNetworkButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.purple.shade200 : Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Powered by ',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF9945FF), Color(0xFF14F195)],
              ).createShader(bounds),
              child: const Text(
                'Solana',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'v1.0.0',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
        ),
      ],
    );
  }

  void _showPremiumShop(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PremiumShopSheet(walletService: widget.walletService),
    );
  }
}

/// Premium shop bottom sheet for SOL purchases
class PremiumShopSheet extends StatelessWidget {
  final WalletService walletService;

  const PremiumShopSheet({super.key, required this.walletService});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1a)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.diamond, color: Colors.amber, size: 28),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREMIUM SHOP',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Pay with SOL',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          // Wallet status bar
          ListenableBuilder(
            listenable: walletService,
            builder: (context, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: walletService.isConnected
                      ? Colors.green.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: walletService.isConnected
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      walletService.isConnected ? Icons.check_circle : Icons.warning,
                      color: walletService.isConnected ? Colors.green : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            walletService.isConnected
                                ? 'Balance: ${walletService.solBalance.toStringAsFixed(4)} SOL'
                                : 'Connect wallet to purchase',
                            style: TextStyle(
                              color: walletService.isConnected ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (walletService.isConnected)
                            Text(
                              walletService.isMainnet ? 'Mainnet' : 'Devnet (Test Mode)',
                              style: TextStyle(
                                color: walletService.isMainnet ? Colors.green.shade300 : Colors.cyan,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!walletService.isConnected)
                      TextButton(
                        onPressed: () => walletService.connect(),
                        child: const Text('Connect'),
                      )
                    else if (!walletService.isMainnet)
                      TextButton(
                        onPressed: () => walletService.requestAirdrop(),
                        child: const Text('Get Test SOL', style: TextStyle(color: Colors.cyan)),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Items list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildSectionHeader('STARTER PACKS'),
                _PremiumItem(
                  icon: '🎁',
                  title: 'Starter Pack',
                  description: '500 Bonus Cash + 3 Space Rifts',
                  priceSol: 0.01,
                  walletService: walletService,
                ),
                _PremiumItem(
                  icon: '🚀',
                  title: 'Booster Pack',
                  description: '1500 Cash + 5 Backup Fuel + 5 Repair Bots',
                  priceSol: 0.025,
                  walletService: walletService,
                ),
                _PremiumItem(
                  icon: '💎',
                  title: 'Mega Pack',
                  description: 'All upgrades maxed + 10 of each item + 5000 Cash',
                  priceSol: 0.1,
                  walletService: walletService,
                  isFeatured: true,
                ),

                const SizedBox(height: 16),
                _buildSectionHeader('CONSUMABLES'),
                _PremiumItem(
                  icon: '💥',
                  title: 'Explosives Bundle',
                  description: '10 Dynamite + 5 C4',
                  priceSol: 0.015,
                  walletService: walletService,
                ),
                _PremiumItem(
                  icon: '🆘',
                  title: 'Emergency Kit',
                  description: '5 Backup Fuel + 5 Repair Bots + 3 Space Rifts',
                  priceSol: 0.02,
                  walletService: walletService,
                ),

                const SizedBox(height: 16),
                _buildSectionHeader('PREMIUM PASS'),
                _PremiumItem(
                  icon: '👑',
                  title: 'VIP Pass (30 Days)',
                  description: '2x Ore Value • 50% Less Fuel Use • Exclusive Gold Drill',
                  priceSol: 0.2,
                  walletService: walletService,
                  isFeatured: true,
                  isSubscription: true,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _PremiumItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final double priceSol;
  final WalletService walletService;
  final bool isFeatured;
  final bool isSubscription;

  const _PremiumItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.priceSol,
    required this.walletService,
    this.isFeatured = false,
    this.isSubscription = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isFeatured
            ? LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.15),
            Colors.orange.withOpacity(0.1),
          ],
        )
            : null,
        color: isFeatured ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFeatured
              ? Colors.amber.withOpacity(0.4)
              : Colors.white.withOpacity(0.1),
          width: isFeatured ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isFeatured ? Colors.amber : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isSubscription) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Price button
          ListenableBuilder(
            listenable: walletService,
            builder: (context, _) {
              final canBuy = walletService.isConnected &&
                  walletService.solBalance >= priceSol;
              return ElevatedButton(
                onPressed: canBuy ? () => _handlePurchase(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canBuy ? Colors.green.shade600 : Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$priceSol',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Text('SOL', style: TextStyle(fontSize: 9)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handlePurchase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Purchase', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buy "$title" for $priceSol SOL?',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Transaction will be sent to your wallet for approval',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Process purchase through wallet service
      final success = await walletService.purchaseItem(title, priceSol);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '✓ Purchased $title!'
                : '✗ Purchase failed. Please try again.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}