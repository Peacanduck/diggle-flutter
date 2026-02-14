/// account_screen.dart
/// Account management screen showing:
/// - Player profile (display name, ID)
/// - Wallet connection with cluster selector (debug only)
/// - Lifetime stats summary
/// - Points balance and ledger preview

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../solana/wallet_service.dart';
import '../services/stats_service.dart';
import '../services/player_service.dart';
import '../services/game_lifecycle_manager.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AccountScreen({super.key, required this.onBack});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  PlayerProfile? _profile;
  bool _loadingProfile = true;
  bool _editingName = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final playerService = context.read<PlayerService>();
    final profile = await playerService.getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _loadingProfile = false;
        if (profile?.displayName != null) {
          _nameController.text = profile!.displayName!;
        }
      });
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final playerService = context.read<PlayerService>();
    await playerService.updateDisplayName(name);
    setState(() {
      _editingName = false;
    });
    await _loadProfile();
  }

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
              // Header
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white70, size: 28),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCOUNT',
                          style: TextStyle(
                            color: Colors.purple.shade300,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        Text(
                          'Manage your profile, wallet, and stats',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildProfileSection(),
                      const SizedBox(height: 16),
                      _buildWalletSection(),
                      const SizedBox(height: 16),
                      _buildStatsSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Profile Section ────────────────────────────────────────────

  Widget _buildProfileSection() {
    return _SectionCard(
      icon: Icons.person,
      iconColor: Colors.amber,
      title: 'PLAYER PROFILE',
      child: _loadingProfile
          ? const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.amber),
        ),
      )
          : Column(
        children: [
          // Avatar / Player icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.amber.shade900.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber.shade700, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.construction,
                  color: Colors.amber, size: 36),
            ),
          ),
          const SizedBox(height: 12),

          // Display name
          if (_editingName) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter display name',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: Colors.amber.shade700),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Colors.amber.shade900),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: Colors.amber.shade400),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    maxLength: 20,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9_ ]')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _saveName,
                  icon: const Icon(Icons.check_circle,
                      color: Colors.green, size: 28),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _editingName = false),
                  icon: Icon(Icons.cancel,
                      color: Colors.red.shade300, size: 28),
                ),
              ],
            ),
          ] else ...[
            GestureDetector(
              onTap: () => setState(() => _editingName = true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _profile?.displayName ?? 'Anonymous Miner',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit,
                      color: Colors.white.withOpacity(0.4), size: 16),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Player ID
          if (_profile != null)
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: _profile!.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Player ID copied'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tag,
                      color: Colors.white.withOpacity(0.3), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${_profile!.id.substring(0, 8)}...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.copy,
                      color: Colors.white.withOpacity(0.2), size: 12),
                ],
              ),
            ),

          const SizedBox(height: 4),
          Text(
            _profile != null
                ? 'Member since ${_formatJoinDate(_profile!.createdAt)}'
                : 'Playing offline',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ── Wallet Section ─────────────────────────────────────────────

  Widget _buildWalletSection() {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        return _SectionCard(
          icon: Icons.account_balance_wallet,
          iconColor: Colors.purple,
          title: 'SOLANA WALLET',
          subtitle:
          'Connect for premium store, NFTs',
          child: Column(
            children: [
              // Cluster selector — only visible in debug builds
              if (wallet.canSwitchCluster) ...[
                _buildClusterSelector(wallet),
                const Divider(color: Colors.white12, height: 24),
              ],

              // Network indicator for release builds (always mainnet)
              if (!wallet.canSwitchCluster) ...[
                Row(
                  children: [
                    Icon(Icons.language, color: Colors.white.withOpacity(0.4), size: 18),
                    const SizedBox(width: 8),
                    Text('Network',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 13)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Mainnet',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),
              ],

              // Connection state
              if (wallet.isConnected)
                _buildConnectedWallet(wallet)
              else if (wallet.isConnecting)
                _buildConnectingWallet()
              else
                _buildDisconnectedWallet(wallet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClusterSelector(WalletService wallet) {
    return Row(
      children: [
        Icon(Icons.language, color: Colors.white.withOpacity(0.4), size: 18),
        const SizedBox(width: 8),
        Text('Network',
            style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 13)),
        const Spacer(),
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
    );
  }

  Widget _buildConnectedWallet(WalletService wallet) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade900.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade800),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Connected to ${wallet.cluster.displayName}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Full address with copy
              GestureDetector(
                onTap: () {
                  if (wallet.publicKey != null) {
                    Clipboard.setData(
                        ClipboardData(text: wallet.publicKey!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Wallet address copied'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          wallet.publicKey ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.copy,
                          color: Colors.white.withOpacity(0.3), size: 14),
                    ],
                  ),
                ),
              ),
              // Balance display
              FutureBuilder<double?>(
                future: wallet.getBalance(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Loading balance...',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 11)),
                        ],
                      ),
                    );
                  }
                  final balance = snap.data;
                  if (balance == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Text('◎',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${balance.toStringAsFixed(4)} SOL',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        // Airdrop button — only in debug on devnet
                        if (kDebugMode && wallet.isDevnet) ...[
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final ok = await wallet.requestAirdrop();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok
                                        ? 'Airdrop requested!'
                                        : 'Airdrop failed'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                setState(() {}); // refresh balance
                              }
                            },
                            icon: const Icon(Icons.air, size: 14),
                            label: const Text('Airdrop',
                                style: TextStyle(fontSize: 11)),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => wallet.disconnect(),
            icon: const Icon(Icons.link_off, size: 16),
            label: const Text('DISCONNECT'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade300,
              side: BorderSide(color: Colors.red.shade800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectingWallet() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child:
            CircularProgressIndicator(strokeWidth: 2, color: Colors.purple),
          ),
          SizedBox(width: 12),
          Text('Connecting to wallet...',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDisconnectedWallet(WalletService wallet) {
    return Column(
      children: [
        if (wallet.errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(wallet.errorMessage!,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 11)),
                ),
                GestureDetector(
                  onTap: () => wallet.clearError(),
                  child: const Icon(Icons.close,
                      color: Colors.red, size: 16),
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
              'CONNECT WALLET',
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

        // Devnet hint — only in debug
        if (kDebugMode && wallet.isDevnet)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '💡 Use Phantom wallet for best devnet support',
              style: TextStyle(
                color: Colors.orange.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  // ── Stats Section ──────────────────────────────────────────────

  Widget _buildStatsSection() {
    final stats = context.read<StatsService>().stats;

    return _SectionCard(
      icon: Icons.bar_chart,
      iconColor: Colors.cyan,
      title: 'LIFETIME STATS',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      icon: '⭐',
                      label: 'Level',
                      value: '${stats.level}')),
              Expanded(
                  child: _StatTile(
                      icon: '✨',
                      label: 'Total XP',
                      value: _formatNumber(stats.totalXpEarned))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      icon: '💎',
                      label: 'Points',
                      value: _formatNumber(stats.points))),
              Expanded(
                  child: _StatTile(
                      icon: '⛏️',
                      label: 'Ores Mined',
                      value: _formatNumber(stats.totalOresMined))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      icon: '📏',
                      label: 'Max Depth',
                      value: '${stats.maxDepthReached}m')),
              Expanded(
                  child: _StatTile(
                      icon: '⏱️',
                      label: 'Play Time',
                      value: _formatPlaytime(stats.totalPlayTimeSeconds))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      icon: '💰',
                      label: 'Points Earned',
                      value: _formatNumber(stats.totalPointsEarned))),
              Expanded(
                  child: _StatTile(
                      icon: '🛒',
                      label: 'Points Spent',
                      value: _formatNumber(stats.totalPointsSpent))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  String _formatJoinDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatPlaytime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    return '${h}h ${m % 60}m';
  }

  String _formatNumber(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }
}

// ── Reusable Widgets ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 10)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}