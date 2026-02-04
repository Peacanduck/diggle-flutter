/// main_menu.dart
/// Main menu screen with wallet connection and game start options.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../solana/wallet_service.dart';

class MainMenu extends StatelessWidget {
  final VoidCallback onStartGame;

  const MainMenu({super.key, required this.onStartGame});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              const Spacer(flex: 1),

              // Game Title
              _buildTitle(),

              const Spacer(flex: 1),

              // Menu Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // Start Game Button
                    _MenuButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'START MINING',
                      color: Colors.green,
                      onPressed: onStartGame,
                    ),

                    const SizedBox(height: 16),

                    // Wallet Connection Section
                    _buildWalletSection(context),

                    const SizedBox(height: 16),

                    // Settings Button (placeholder)
                    _MenuButton(
                      icon: Icons.settings,
                      label: 'SETTINGS',
                      color: Colors.grey.shade700,
                      onPressed: () {
                        _showSettingsDialog(context);
                      },
                    ),

                    const SizedBox(height: 16),

                    // How to Play Button
                    _MenuButton(
                      icon: Icons.help_outline,
                      label: 'HOW TO PLAY',
                      color: Colors.blue.shade700,
                      onPressed: () {
                        _showHowToPlayDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Version info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'v1.0.0 • Built with Flutter & Flame',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Drill Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.brown.shade700,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.construction,
            size: 60,
            color: Colors.amber,
          ),
        ),

        const SizedBox(height: 24),

        // Title Text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.amber, Colors.orange, Colors.amber],
          ).createShader(bounds),
          child: const Text(
            'DIGGLE',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 8,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'MINE DEEP • SELL HIGH',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletSection(BuildContext context) {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: wallet.isConnected
                  ? Colors.green.shade700
                  : Colors.purple.shade700.withOpacity(0.5),
            ),
          ),
          child: Column(
            children: [
              // Cluster Selector
              _buildClusterSelector(context, wallet),

              const SizedBox(height: 12),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),

              // Wallet Connection Status
              if (wallet.isConnected)
                _buildConnectedState(wallet)
              else if (wallet.isConnecting)
                _buildConnectingState()
              else
                _buildDisconnectedState(context, wallet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClusterSelector(BuildContext context, WalletService wallet) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.language,
              color: Colors.white54,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'Network:',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 12),

            // Cluster Toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ClusterChip(
                    label: 'Devnet',
                    isSelected: wallet.isDevnet,
                    color: Colors.orange,
                    onTap: wallet.isConnecting
                        ? null
                        : () => wallet.setCluster(SolanaCluster.devnet),
                  ),
                  _ClusterChip(
                    label: 'Mainnet',
                    isSelected: wallet.isMainnet,
                    color: Colors.green,
                    onTap: wallet.isConnecting
                        ? null
                        : () => wallet.setCluster(SolanaCluster.mainnet),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Devnet note
        if (wallet.isDevnet && !wallet.isConnected)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '💡 Tip: Use Phantom for best devnet support',
              style: TextStyle(
                color: Colors.orange.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConnectedState(WalletService wallet) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'Connected to ${wallet.cluster.displayName}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          wallet.shortPublicKey ?? '',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => wallet.disconnect(),
            icon: const Icon(Icons.link_off, size: 18),
            label: const Text('DISCONNECT'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.purple,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Connecting to wallet...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedState(BuildContext context, WalletService wallet) {
    return Column(
      children: [
        if (wallet.errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    wallet.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
                GestureDetector(
                  onTap: () => wallet.clearError(),
                  child: const Icon(Icons.close, color: Colors.red, size: 18),
                ),
              ],
            ),
          ),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => wallet.connect(),
            icon: const Icon(Icons.account_balance_wallet, size: 20),
            label: Text(
              'CONNECT TO ${wallet.cluster.displayName.toUpperCase()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        if (!wallet.isAvailable)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No Solana wallet app detected',
              style: TextStyle(
                color: Colors.orange.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Settings coming soon!\n\n• Sound effects\n• Music volume\n• Haptic feedback',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'How to Play',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                '⛏️ Mining',
                'Use the arrow controls to move your drill. Dig through dirt and rock to find valuable ores.',
              ),
              _buildHelpSection(
                '⛽ Fuel',
                'Moving and digging consumes fuel. Return to the surface before running out!',
              ),
              _buildHelpSection(
                '🛡️ Hull',
                'Falling too far damages your hull. Watch your HP!',
              ),
              _buildHelpSection(
                '💰 Selling',
                'Return to the surface and visit the SHOP to sell your ore for cash.',
              ),
              _buildHelpSection(
                '🔧 Upgrades',
                'Use cash to upgrade your fuel tank, cargo bay, and hull armor.',
              ),
              _buildHelpSection(
                '⚠️ Hazards',
                'Watch out for lava (instant death) and gas pockets (damage)!',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Styled menu button widget
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}

/// Cluster selection chip widget
class _ClusterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;

  const _ClusterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}