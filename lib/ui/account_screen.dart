/// account_screen.dart
/// Account management screen. All strings localized via AppLocalizations.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../solana/wallet_service.dart';
import '../services/stats_service.dart';
import '../services/player_service.dart';
import '../services/supabase_service.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onSignOut;

  const AccountScreen({super.key, required this.onBack, this.onSignOut});

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
    setState(() => _editingName = false);
    await _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final supabase = SupabaseService.instance;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildProfileSection(l10n),
                      const SizedBox(height: 16),
                      if (supabase.isGuest) ...[
                        _buildWalletAdapterSection(l10n, isGuestMode: true),
                      ] else ...[
                        _buildSignInMethodsSection(l10n),
                        const SizedBox(height: 16),
                        _buildWalletAdapterSection(l10n, isGuestMode: false),
                      ],
                      const SizedBox(height: 16),
                      _buildStatsSection(l10n),
                      const SizedBox(height: 24),
                      _buildSignOutSection(l10n),
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

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
              Text(l10n.accountTitle,
                  style: TextStyle(
                      color: Colors.purple.shade300,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3)),
              Text(l10n.accountSubtitle,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(AppLocalizations l10n) {
    final supabase = SupabaseService.instance;

    return _SectionCard(
      icon: Icons.person,
      iconColor: Colors.amber,
      title: l10n.playerProfile,
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
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.amber.shade900.withOpacity(0.3),
              shape: BoxShape.circle,
              border:
              Border.all(color: Colors.amber.shade700, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.construction,
                  color: Colors.amber, size: 36),
            ),
          ),
          const SizedBox(height: 10),
          _AuthBadge(method: supabase.authMethod),
          const SizedBox(height: 10),
          if (supabase.isEmailUser &&
              supabase.userEmail != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email_outlined,
                    color: Colors.white.withOpacity(0.4), size: 14),
                const SizedBox(width: 6),
                Text(supabase.userEmail!,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_editingName) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: l10n.enterDisplayName,
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
                        borderSide:
                        BorderSide(color: Colors.amber.shade900),
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
                    _profile?.displayName ?? l10n.anonymousMiner,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit,
                      color: Colors.white.withOpacity(0.4), size: 16),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (_profile != null)
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: _profile!.id));
                _showSnack(l10n.playerIdCopied);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tag,
                      color: Colors.white.withOpacity(0.3),
                      size: 14),
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
                      color: Colors.white.withOpacity(0.2),
                      size: 12),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            _profile != null
                ? l10n.memberSince(
                _formatJoinDate(_profile!.createdAt))
                : l10n.playingOffline,
            style: TextStyle(
                color: Colors.white.withOpacity(0.3), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInMethodsSection(AppLocalizations l10n) {
    final supabase = SupabaseService.instance;

    return _SectionCard(
      icon: Icons.security,
      iconColor: Colors.teal,
      title: l10n.signInMethods,
      subtitle: l10n.signInMethodsSubtitle,
      child: Column(
        children: [
          if (supabase.isEmailUser) ...[
            _MethodRow(
              icon: Icons.email_outlined,
              color: Colors.blue,
              label: l10n.emailLabel,
              detail: supabase.userEmail ?? '',
              status: MethodStatus.active,
              primaryLabel: l10n.primary,
              linkedLabel: l10n.linked,
            ),
          ] else if (supabase.linkedEmail != null) ...[
            _MethodRow(
              icon: Icons.email_outlined,
              color: Colors.blue,
              label: l10n.emailSignIn,
              detail: supabase.linkedEmail!,
              status: MethodStatus.linked,
              primaryLabel: l10n.primary,
              linkedLabel: l10n.linked,
            ),
          ] else ...[
            _MethodRow(
              icon: Icons.email_outlined,
              color: Colors.blue,
              label: l10n.emailSignIn,
              detail: l10n.addEmailAlt,
              status: MethodStatus.notLinked,
              onAdd: () => _showAddEmailSheet(),
              addLabel: l10n.add,
              primaryLabel: l10n.primary,
              linkedLabel: l10n.linked,
            ),
          ],
          const Divider(color: Colors.white10, height: 24),
          if (supabase.isWalletUser) ...[
            _MethodRow(
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.purple,
              label: l10n.solanaWallet,
              detail: _shortAddress(supabase.walletAddress),
              status: MethodStatus.active,
              primaryLabel: l10n.primary,
              linkedLabel: l10n.linked,
              onCopy: supabase.walletAddress != null
                  ? () {
                Clipboard.setData(
                    ClipboardData(text: supabase.walletAddress!));
                _showSnack(l10n.addressCopied);
              }
                  : null,
            ),
          ] else if (supabase.linkedWallet != null) ...[
            _MethodRow(
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.purple,
              label: l10n.linkedWallet,
              detail: _shortAddress(supabase.linkedWallet),
              status: MethodStatus.linked,
              primaryLabel: l10n.primary,
              linkedLabel: l10n.linked,
              onCopy: () {
                Clipboard.setData(
                    ClipboardData(text: supabase.linkedWallet!));
                _showSnack(l10n.addressCopied);
              },
              onRemove: () => _confirmUnlinkWallet(),
            ),
          ] else ...[
            _MethodRow(
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.purple,
              label: l10n.solanaWallet,
              detail: l10n.linkForStore,
              status: MethodStatus.notLinked,
              onAdd: () => _linkWalletForEmailAccount(),
              addLabel: l10n.add,
              primaryLabel: l10n.primary,
              linkedLabel: l10n.linked,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAddEmailSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final playerService = context.read<PlayerService>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EmailLinkSheet(
        title: l10n.addEmailSignIn,
        subtitle: l10n.addEmailSubtitle,
        submitLabel: l10n.addEmail,
        onSubmit: (email, password) =>
            playerService.linkEmailToPlayer(email, password),
        onSuccess: (result) {
          if (result.requiresEmailConfirmation) {
            _showSnack(l10n.checkEmailLink, color: Colors.amber);
          } else {
            _showSnack(l10n.emailSignInAdded);
            setState(() {});
          }
        },
      ),
    );
  }

  Future<void> _linkWalletForEmailAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final wallet = context.read<WalletService>();
    final playerService = context.read<PlayerService>();

    try {
      if (!wallet.isConnected) {
        final connected = await wallet.connect();
        if (!connected) {
          _showSnack(l10n.walletConnectionCancelled, color: Colors.orange);
          return;
        }
      }

      final pubkey = wallet.publicKey;
      if (pubkey == null) {
        _showSnack(l10n.couldNotGetWalletAddress, color: Colors.red);
        return;
      }

      final message =
      await SupabaseService.instance.getWalletSignInMessage(pubkey);
      final signed = await wallet.signMessage(message);
      if (signed == null) {
        _showSnack(l10n.signingCancelled, color: Colors.orange);
        return;
      }

      final result = await playerService.linkWalletToPlayer(
        walletAddress: pubkey,
        signature: signed,
        message: message,
      );

      if (!mounted) return;

      if (result.success) {
        _showSnack(l10n.walletLinked);
        setState(() {});
        await _loadProfile();
      } else {
        _showSnack(result.error ?? l10n.walletLinkFailed, color: Colors.red);
      }
    } catch (e) {
      if (mounted) _showSnack(l10n.errorPrefix(e.toString()), color: Colors.red);
    }
  }

  Future<void> _confirmUnlinkWallet() async {
    final l10n = AppLocalizations.of(context)!;
    final playerService = context.read<PlayerService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(l10n.unlinkWalletTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(l10n.unlinkWalletMessage,
            style: TextStyle(color: Colors.white.withOpacity(0.7))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.unlink,
                  style: TextStyle(color: Colors.red.shade300))),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await playerService.unlinkWalletDisplay();
    if (!mounted) return;

    if (result.success) {
      _showSnack(l10n.walletUnlinked);
      setState(() {});
      await _loadProfile();
    } else {
      _showSnack(result.error ?? l10n.unlinkFailed, color: Colors.red);
    }
  }

  Widget _buildWalletAdapterSection(AppLocalizations l10n,
      {required bool isGuestMode}) {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        final subtitle = isGuestMode
            ? l10n.walletAdapterGuestSubtitle
            : SupabaseService.instance.isWalletUser
            ? l10n.walletAdapterReconnectSubtitle
            : l10n.walletAdapterConnectSubtitle;

        return _SectionCard(
          icon: Icons.account_balance_wallet,
          iconColor: Colors.purple,
          title: l10n.walletAdapter,
          subtitle: subtitle,
          child: Column(
            children: [
              if (wallet.canSwitchCluster) ...[
                _buildClusterSelector(l10n, wallet),
                const Divider(color: Colors.white12, height: 24),
              ] else ...[
                _buildNetworkRow(l10n),
                const Divider(color: Colors.white12, height: 24),
              ],
              if (wallet.isConnected)
                _buildAdapterConnected(l10n, wallet)
              else if (wallet.isConnecting)
                _buildAdapterConnecting(l10n)
              else
                _buildAdapterDisconnected(l10n, wallet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNetworkRow(AppLocalizations l10n) {
    return Row(
      children: [
        Icon(Icons.language, color: Colors.white.withOpacity(0.4), size: 18),
        const SizedBox(width: 8),
        Text(l10n.network,
            style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 13)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(l10n.mainnet,
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildClusterSelector(AppLocalizations l10n, WalletService wallet) {
    return Row(
      children: [
        Icon(Icons.language, color: Colors.white.withOpacity(0.4), size: 18),
        const SizedBox(width: 8),
        Text(l10n.network,
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
                label: l10n.devnet,
                isSelected: wallet.isDevnet,
                color: Colors.orange,
                onTap: wallet.isConnecting
                    ? null
                    : () => wallet.setCluster(SolanaCluster.devnet),
              ),
              _ClusterChip(
                label: l10n.mainnet,
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

  Widget _buildAdapterConnected(AppLocalizations l10n, WalletService wallet) {
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
                  Text(l10n.connected(wallet.cluster.displayName),
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (wallet.publicKey != null) {
                    Clipboard.setData(
                        ClipboardData(text: wallet.publicKey!));
                    _showSnack(l10n.addressCopied);
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
                        child: Text(wallet.publicKey ?? '',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontFamily: 'monospace',
                                fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Icon(Icons.copy,
                          color: Colors.white.withOpacity(0.3), size: 14),
                    ],
                  ),
                ),
              ),
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
                          Text(l10n.loadingBalance,
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
                        Text('${balance.toStringAsFixed(4)} SOL',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        if (kDebugMode && wallet.isDevnet) ...[
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final ok = await wallet.requestAirdrop();
                              if (mounted) {
                                _showSnack(ok
                                    ? l10n.airdropRequested
                                    : l10n.airdropFailed);
                                setState(() {});
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
        const SizedBox(height: 8),
        if (SupabaseService.instance.isWalletUser)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l10n.disconnectNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 11)),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => wallet.disconnect(),
            icon: const Icon(Icons.link_off, size: 16),
            label: Text(l10n.disconnectAdapter),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade300,
              side: BorderSide(color: Colors.red.shade800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdapterConnecting(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          Text(l10n.connecting,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildAdapterDisconnected(
      AppLocalizations l10n, WalletService wallet) {
    return Column(
      children: [
        if (wallet.errorMessage != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(wallet.errorMessage!,
                      style:
                      const TextStyle(color: Colors.red, fontSize: 11)),
                ),
                GestureDetector(
                  onTap: () => wallet.clearError(),
                  child:
                  const Icon(Icons.close, color: Colors.red, size: 16),
                ),
              ],
            ),
          ),
        ],
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => wallet.connect(),
            icon: const Icon(Icons.account_balance_wallet, size: 20),
            label: Text(l10n.connectWallet,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (kDebugMode && wallet.isDevnet)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.phantomTip,
                style: TextStyle(
                    color: Colors.orange.withOpacity(0.6), fontSize: 11)),
          ),
      ],
    );
  }

  Widget _buildStatsSection(AppLocalizations l10n) {
    final stats = context.read<StatsService>().stats;

    return _SectionCard(
      icon: Icons.bar_chart,
      iconColor: Colors.cyan,
      title: l10n.lifetimeStats,
      child: Column(
        children: [
          Row(children: [
            Expanded(child: _StatTile(
                icon: '⭐', label: l10n.statLevel, value: '${stats.level}')),
            Expanded(child: _StatTile(
                icon: '✨', label: l10n.statTotalXp,
                value: _formatNumber(stats.totalXpEarned))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _StatTile(
                icon: '💎', label: l10n.statPoints,
                value: _formatNumber(stats.points))),
            Expanded(child: _StatTile(
                icon: '⛏️', label: l10n.statOresMined,
                value: _formatNumber(stats.totalOresMined))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _StatTile(
                icon: '📏', label: l10n.statMaxDepth,
                value: '${stats.maxDepthReached}m')),
            Expanded(child: _StatTile(
                icon: '⏱️', label: l10n.statPlayTime,
                value: _formatPlaytime(stats.totalPlayTimeSeconds))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _StatTile(
                icon: '💰', label: l10n.statPointsEarned,
                value: _formatNumber(stats.totalPointsEarned))),
            Expanded(child: _StatTile(
                icon: '🛒', label: l10n.statPointsSpent,
                value: _formatNumber(stats.totalPointsSpent))),
          ]),
        ],
      ),
    );
  }

  Widget _buildSignOutSection(AppLocalizations l10n) {
    final supabase = SupabaseService.instance;
    final authLabel = switch (supabase.authMethod) {
      AuthMethod.email  => l10n.signedInEmail,
      AuthMethod.wallet => l10n.signedInWallet,
      AuthMethod.guest  => l10n.playingAsGuest,
      AuthMethod.none   => '',
    };

    return Column(
      children: [
        if (authLabel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(authLabel,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 12)),
          ),
        if (widget.onSignOut != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _confirmSignOut,
              icon: const Icon(Icons.logout, size: 18),
              label: Text(l10n.signOut),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade300,
                side: BorderSide(
                    color: Colors.red.shade300.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmSignOut() async {
    final l10n = AppLocalizations.of(context)!;
    final supabase = SupabaseService.instance;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(l10n.signOut,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          supabase.isGuest ? l10n.guestSignOutWarning : l10n.signOutConfirm,
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.signOut,
                  style: TextStyle(color: Colors.red.shade300))),
        ],
      ),
    );

    if (confirmed == true && widget.onSignOut != null) {
      widget.onSignOut!();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────

  void _showSnack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: color != null
              ? const TextStyle(color: Colors.white)
              : null),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
    ));
  }

  String _shortAddress(String? address) {
    if (address == null || address.length < 12) return address ?? '';
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatJoinDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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

// ── Reusable widgets (unchanged logic, kept for completeness) ────

class _AuthBadge extends StatelessWidget {
  final AuthMethod method;
  const _AuthBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, icon, color) = switch (method) {
      AuthMethod.email  => (l10n.emailAccount, Icons.email_outlined, Colors.blue.shade400),
      AuthMethod.wallet => (l10n.walletAccount, Icons.account_balance_wallet_outlined, Colors.purple.shade400),
      AuthMethod.guest  => (l10n.guestLocalOnly, Icons.person_outline, Colors.orange.shade400),
      AuthMethod.none   => (l10n.offline, Icons.cloud_off, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

enum MethodStatus { active, linked, notLinked }

class _MethodRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String detail;
  final MethodStatus status;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onCopy;
  final String? addLabel;
  final String primaryLabel;
  final String linkedLabel;

  const _MethodRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.detail,
    required this.status,
    this.onAdd,
    this.onRemove,
    this.onCopy,
    this.addLabel,
    required this.primaryLabel,
    required this.linkedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isActive    = status == MethodStatus.active;
    final isLinked    = status == MethodStatus.linked;
    final isNotLinked = status == MethodStatus.notLinked;

    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: isNotLinked ? Colors.white.withOpacity(0.05) : color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: isNotLinked ? Colors.white38 : color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(label, style: TextStyle(
                    color: isNotLinked ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.w600, fontSize: 14)),
                if (isActive) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(primaryLabel,
                        style: const TextStyle(color: Colors.green, fontSize: 9,
                            fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ] else if (isLinked) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(linkedLabel,
                        style: TextStyle(color: color, fontSize: 9,
                            fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(detail,
                  style: TextStyle(
                      color: Colors.white.withOpacity(isNotLinked ? 0.3 : 0.5),
                      fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (isNotLinked && onAdd != null)
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: Text(addLabel ?? 'Add',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          )
        else if ((isLinked || isActive) && onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: Icon(Icons.copy, color: Colors.white.withOpacity(0.3), size: 16),
          ),
        if (isLinked && onRemove != null)
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.link_off,
                color: Colors.red.shade300.withOpacity(0.7), size: 16),
          ),
      ],
    );
  }
}

// ── Email Link Sheet ──────────────────────────────────────────────

class _EmailLinkSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String submitLabel;
  final Future<LinkResult> Function(String email, String password) onSubmit;
  final void Function(LinkResult result) onSuccess;

  const _EmailLinkSheet({
    required this.title,
    required this.subtitle,
    required this.submitLabel,
    required this.onSubmit,
    required this.onSuccess,
  });

  @override
  State<_EmailLinkSheet> createState() => _EmailLinkSheetState();
}

class _EmailLinkSheetState extends State<_EmailLinkSheet> {
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final email   = _emailCtrl.text.trim();
    final pass    = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = l10n.pleaseFillAllFields);
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = l10n.passwordTooShort);
      return;
    }
    if (pass != confirm) {
      setState(() => _error = l10n.passwordsNoMatch);
      return;
    }

    setState(() { _loading = true; _error = null; });
    final result = await widget.onSubmit(email, pass);
    if (!mounted) return;

    if (result.success || result.requiresEmailConfirmation) {
      Navigator.pop(context);
      widget.onSuccess(result);
    } else {
      setState(() { _loading = false; _error = result.error; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.subtitle,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            const SizedBox(height: 20),
            _sheetField(_emailCtrl, l10n.emailAddress, Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _sheetField(_passCtrl, l10n.passwordMinChars, Icons.lock_outlined,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white30, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )),
            const SizedBox(height: 12),
            _sheetField(_confirmCtrl, l10n.confirmPassword, Icons.lock_outlined,
                obscure: true),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Icon(Icons.error_outline, color: Colors.red.shade300, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_error!,
                      style: TextStyle(color: Colors.red.shade300, fontSize: 13))),
                ]),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563eb),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.submitLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String hint, IconData icon,
      {bool obscure = false, TextInputType keyboardType = TextInputType.text, Widget? suffix}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563eb))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── Section Card / Stat Tile / Cluster Chip (shared) ─────────────

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
        border: Border.all(color: iconColor.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: iconColor, fontSize: 13,
                fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ]),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 11)),
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
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 10)),
            Text(value, style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        )),
      ]),
    );
  }
}

class _ClusterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;
  const _ClusterChip({
    required this.label, required this.isSelected,
    required this.color, this.onTap,
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
        child: Text(label, style: TextStyle(
          color: isSelected ? Colors.white : Colors.white54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        )),
      ),
    );
  }
}