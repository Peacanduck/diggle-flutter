/// account_screen.dart
/// Account management screen.
///
/// Layout adapts to the user's auth state:
///
///   Guest  → Profile + "SAVE YOUR ACCOUNT" upgrade section (email or wallet)
///            + Wallet adapter panel (for store transactions in current session)
///
///   Email  → Profile + "SIGN-IN METHODS" section showing:
///              ✓ Email (primary, always shown)
///              + Link Wallet (if no wallet linked yet)
///              ✓ Wallet linked (address + unlink option, if wallet linked)
///            + Wallet adapter panel (connect for transactions)
///
///   Wallet → Profile + "SIGN-IN METHODS" section showing:
///              ✓ Wallet (primary, address shown)
///              ✓ Email linked (shown if email was added)
///              + Add Email (if no email added yet)
///            + Wallet adapter panel (reconnect if adapter dropped)
///
/// Sign-in methods read from supabase.linkedEmail / supabase.linkedWallet
/// so both sessions see the complete picture regardless of which method
/// is currently active.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildProfileSection(),
                      const SizedBox(height: 16),

                      if (supabase.isGuest) ...[
                       // _buildGuestUpgradeSection(),
                       // const SizedBox(height: 16),
                        _buildWalletAdapterSection(isGuestMode: true),
                      ] else ...[
                        _buildSignInMethodsSection(),
                        const SizedBox(height: 16),
                        _buildWalletAdapterSection(isGuestMode: false),
                      ],

                      const SizedBox(height: 16),
                      _buildStatsSection(),
                      const SizedBox(height: 24),
                      _buildSignOutSection(),
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

  // ── Header ─────────────────────────────────────────────────────

  Widget _buildHeader() {
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
                'Profile, sign-in methods & stats',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Profile Section ────────────────────────────────────────────

  Widget _buildProfileSection() {
    final supabase = SupabaseService.instance;

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
          // Avatar
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

          // Auth badge
          _AuthBadge(method: supabase.authMethod),
          const SizedBox(height: 10),

          // Show email in profile for email-auth users
          if (supabase.isEmailUser && supabase.userEmail != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email_outlined,
                    color: Colors.white.withOpacity(0.4), size: 14),
                const SizedBox(width: 6),
                Text(
                  supabase.userEmail!,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

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
                    _profile?.displayName ?? 'Anonymous Miner',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit,
                      color: Colors.white.withOpacity(0.4),
                      size: 16),
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
                _showSnack('Player ID copied');
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
                color: Colors.white.withOpacity(0.3), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Sign-In Methods Section ────────────────────────────────────
  // Reads from supabase.linkedEmail / supabase.linkedWallet so both
  // email and wallet sessions see the full picture.

  Widget _buildSignInMethodsSection() {
    final supabase = SupabaseService.instance;

    return _SectionCard(
      icon: Icons.security,
      iconColor: Colors.teal,
      title: 'SIGN-IN METHODS',
      subtitle: 'How you can access your account',
      child: Column(
        children: [
          // ── Email row ──────────────────────────────────────────
          if (supabase.isEmailUser) ...[
            // Primary auth method
            _MethodRow(
              icon: Icons.email_outlined,
              color: Colors.blue,
              label: 'Email',
              detail: supabase.userEmail ?? '',
              status: MethodStatus.active,
            ),
          ] else if (supabase.linkedEmail != null) ...[
            // Wallet user who added email as alternative
            _MethodRow(
              icon: Icons.email_outlined,
              color: Colors.blue,
              label: 'Email sign-in',
              detail: supabase.linkedEmail!,
              status: MethodStatus.linked,
            ),
          ] else ...[
            // Wallet user — no email added yet
            _MethodRow(
              icon: Icons.email_outlined,
              color: Colors.blue,
              label: 'Email sign-in',
              detail: 'Add email as an alternative way to sign in',
              status: MethodStatus.notLinked,
              onAdd: () => _showAddEmailSheet(),
            ),
          ],

          const Divider(color: Colors.white10, height: 24),

          // ── Wallet row ─────────────────────────────────────────
          if (supabase.isWalletUser) ...[
            // Primary auth method
            _MethodRow(
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.purple,
              label: 'Solana Wallet',
              detail: _shortAddress(supabase.walletAddress),
              status: MethodStatus.active,
              onCopy: supabase.walletAddress != null
                  ? () {
                Clipboard.setData(
                    ClipboardData(text: supabase.walletAddress!));
                _showSnack('Wallet address copied');
              }
                  : null,
            ),
          ] else if (supabase.linkedWallet != null) ...[
            // Email user with linked wallet sign-in
            _MethodRow(
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.purple,
              label: 'Linked Wallet',
              detail: _shortAddress(supabase.linkedWallet),
              status: MethodStatus.linked,
              onCopy: () {
                Clipboard.setData(
                    ClipboardData(text: supabase.linkedWallet!));
                _showSnack('Wallet address copied');
              },
              onRemove: () => _confirmUnlinkWallet(),
            ),
          ] else ...[
            // Email user — no wallet linked yet
            _MethodRow(
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.purple,
              label: 'Solana Wallet',
              detail: 'Link for store purchases & NFTs',
              status: MethodStatus.notLinked,
              onAdd: () => _linkWalletForEmailAccount(),
            ),
          ],
        ],
      ),
    );
  }

  // Add email to wallet account
  Future<void> _showAddEmailSheet() async {
    final playerService = context.read<PlayerService>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EmailLinkSheet(
        title: 'Add Email Sign-In',
        subtitle:
        'Your wallet remains your primary sign-in. Email is an alternative.',
        submitLabel: 'ADD EMAIL',
        onSubmit: (email, password) =>
            playerService.linkEmailToPlayer(email, password),
        onSuccess: (result) {
          if (result.requiresEmailConfirmation) {
            _showSnack('Check your email to confirm the link!',
                color: Colors.amber);
          } else {
            _showSnack('Email sign-in added!');
            setState(() {});
          }
        },
      ),
    );
  }

  // Link wallet for email-auth users
  Future<void> _linkWalletForEmailAccount() async {
    final wallet = context.read<WalletService>();
    final playerService = context.read<PlayerService>();

    try {
      if (!wallet.isConnected) {
        final connected = await wallet.connect();
        if (!connected) {
          _showSnack('Wallet connection cancelled', color: Colors.orange);
          return;
        }
      }

      final pubkey = wallet.publicKey;
      if (pubkey == null) {
        _showSnack('Could not get wallet address', color: Colors.red);
        return;
      }

      final message =
      await SupabaseService.instance.getWalletSignInMessage(pubkey);
      final signed = await wallet.signMessage(message);
      if (signed == null) {
        _showSnack('Signing was cancelled', color: Colors.orange);
        return;
      }

      final result = await playerService.linkWalletToPlayer(
        walletAddress: pubkey,
        signature: signed,
        message: message,
      );

      if (!mounted) return;

      if (result.success) {
        _showSnack('Wallet linked! You can now sign in with it.');
        setState(() {}); // refresh methods section
        await _loadProfile();
      } else {
        _showSnack(result.error ?? 'Wallet link failed', color: Colors.red);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', color: Colors.red);
    }
  }

  Future<void> _confirmUnlinkWallet() async {
    final playerService = context.read<PlayerService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Unlink Wallet',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Your wallet will be removed from your account. '
              'You can link a different wallet afterwards.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Unlink',
                  style: TextStyle(color: Colors.red.shade300))),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await playerService.unlinkWalletDisplay();
    if (!mounted) return;

    if (result.success) {
      _showSnack('Wallet unlinked');
      setState(() {});
      await _loadProfile();
    } else {
      _showSnack(result.error ?? 'Failed to unlink wallet', color: Colors.red);
    }
  }

  // ── Guest Upgrade Section ──────────────────────────────────────
/*
  Widget _buildGuestUpgradeSection() {
    return _SectionCard(
      icon: Icons.upgrade,
      iconColor: Colors.orange,
      title: 'SAVE YOUR ACCOUNT',
      subtitle:
      'Guest progress is only on this device. Upgrade to keep it forever.',
      child: Column(
        children: [
          _UpgradeButton(
            icon: Icons.email_outlined,
            label: 'Upgrade with Email',
            subtitle: 'Sign in on any device with email & password',
            color: const Color(0xFF2563eb),
            onTap: () => _showGuestEmailUpgradeSheet(),
          ),
          const SizedBox(height: 10),
          _UpgradeButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Upgrade with Wallet',
            subtitle: 'Your wallet becomes your persistent identity',
            color: Colors.purple,
            onTap: () => _upgradeGuestToWallet(),
          ),
        ],
      ),
    );
  }

  Future<void> _showGuestEmailUpgradeSheet() async {
    final playerService = context.read<PlayerService>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EmailLinkSheet(
        title: 'Save with Email',
        subtitle: 'Your current progress will be saved to this account.',
        submitLabel: 'SAVE ACCOUNT',
        onSubmit: (email, password) =>
            playerService.linkEmailToPlayer(email, password),
        onSuccess: (result) {
          if (result.requiresEmailConfirmation) {
            _showSnack('Check your email to confirm your account!',
                color: Colors.amber);
          } else {
            _showSnack('Account saved! You can now sign in with email.');
            setState(() {});
          }
        },
      ),
    );
  }

  Future<void> _upgradeGuestToWallet() async {
    final wallet = context.read<WalletService>();
    final playerService = context.read<PlayerService>();

    try {
      if (!wallet.isConnected) {
        final connected = await wallet.connect();
        if (!connected) {
          _showSnack('Wallet connection cancelled', color: Colors.orange);
          return;
        }
      }

      final pubkey = wallet.publicKey;
      if (pubkey == null) {
        _showSnack('Could not get wallet address', color: Colors.red);
        return;
      }

      final message =
      await SupabaseService.instance.getWalletSignInMessage(pubkey);
      final signed = await wallet.signMessage(message);
      if (signed == null) {
        _showSnack('Signing was cancelled', color: Colors.orange);
        return;
      }

      final result = await playerService.upgradeGuestToWallet(
        walletAddress: pubkey,
        signature: signed,
        message: message,
      );

      if (!mounted) return;

      if (result.success) {
        _showSnack('Account saved! Sign in with your wallet next time.');
        setState(() {});
        await _loadProfile();
      } else {
        _showSnack(result.error ?? 'Upgrade failed', color: Colors.red);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', color: Colors.red);
    }
  }
*/
  // ── Wallet Adapter Section ─────────────────────────────────────

  Widget _buildWalletAdapterSection({required bool isGuestMode}) {
    return Consumer<WalletService>(
      builder: (context, wallet, _) {
        final subtitle = isGuestMode
            ? 'Connect for store purchases this session'
            : SupabaseService.instance.isWalletUser
            ? 'Reconnect to sign transactions'
            : 'Connect to use the store';

        return _SectionCard(
          icon: Icons.account_balance_wallet,
          iconColor: Colors.purple,
          title: 'WALLET ADAPTER',
          subtitle: subtitle,
          child: Column(
            children: [
              if (wallet.canSwitchCluster) ...[
                _buildClusterSelector(wallet),
                const Divider(color: Colors.white12, height: 24),
              ] else ...[
                _buildNetworkRow(),
                const Divider(color: Colors.white12, height: 24),
              ],

              if (wallet.isConnected)
                _buildAdapterConnected(wallet)
              else if (wallet.isConnecting)
                _buildAdapterConnecting()
              else
                _buildAdapterDisconnected(wallet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNetworkRow() {
    return Row(
      children: [
        Icon(Icons.language, color: Colors.white.withOpacity(0.4), size: 18),
        const SizedBox(width: 8),
        Text('Network',
            style:
            TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
        const Spacer(),
        _NetworkBadge(label: 'Mainnet', color: Colors.green),
      ],
    );
  }

  Widget _buildClusterSelector(WalletService wallet) {
    return Row(
      children: [
        Icon(Icons.language, color: Colors.white.withOpacity(0.4), size: 18),
        const SizedBox(width: 8),
        Text('Network',
            style:
            TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
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

  Widget _buildAdapterConnected(WalletService wallet) {
    final supabase = SupabaseService.instance;

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
                    'Connected — ${wallet.cluster.displayName}',
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (wallet.publicKey != null) {
                    Clipboard.setData(
                        ClipboardData(text: wallet.publicKey!));
                    _showSnack('Address copied');
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
                        if (kDebugMode && wallet.isDevnet) ...[
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final ok = await wallet.requestAirdrop();
                              if (mounted) {
                                _showSnack(ok
                                    ? 'Airdrop requested!'
                                    : 'Airdrop failed');
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
        if (supabase.isWalletUser)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Disconnecting ends the adapter session only. '
                  'Your account stays linked — reconnect at any time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 11),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => wallet.disconnect(),
            icon: const Icon(Icons.link_off, size: 16),
            label: const Text('DISCONNECT ADAPTER'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade300,
              side: BorderSide(color: Colors.red.shade800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdapterConnecting() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.purple),
          ),
          SizedBox(width: 12),
          Text('Connecting...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildAdapterDisconnected(WalletService wallet) {
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
            label: const Text('CONNECT WALLET',
                style: TextStyle(
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
            child: Text(
              '💡 Use Phantom wallet for best devnet support',
              style: TextStyle(
                  color: Colors.orange.withOpacity(0.6), fontSize: 11),
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
                      icon: '⭐', label: 'Level', value: '${stats.level}')),
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

  // ── Sign Out Section ───────────────────────────────────────────

  Widget _buildSignOutSection() {
    final supabase = SupabaseService.instance;
    final authLabel = switch (supabase.authMethod) {
      AuthMethod.email  => 'Signed in with email',
      AuthMethod.wallet => 'Signed in with wallet',
      AuthMethod.guest  => 'Playing as guest',
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
              label: const Text('Sign Out'),
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
    final supabase = SupabaseService.instance;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Sign Out',
            style: TextStyle(color: Colors.white)),
        content: Text(
          supabase.isGuest
              ? 'Guest progress is only on this device. Signing out will '
              'remove access to your current saves. Are you sure?'
              : 'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Sign Out',
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

// ── Auth Badge ────────────────────────────────────────────────────

class _AuthBadge extends StatelessWidget {
  final AuthMethod method;
  const _AuthBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (method) {
      AuthMethod.email => (
      'Email Account',
      Icons.email_outlined,
      Colors.blue.shade400
      ),
      AuthMethod.wallet => (
      'Wallet Account',
      Icons.account_balance_wallet_outlined,
      Colors.purple.shade400
      ),
      AuthMethod.guest => (
      'Guest — progress is local only',
      Icons.person_outline,
      Colors.orange.shade400
      ),
      AuthMethod.none => ('Offline', Icons.cloud_off, Colors.grey),
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
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Method Row ────────────────────────────────────────────────────

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

  const _MethodRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.detail,
    required this.status,
    this.onAdd,
    this.onRemove,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isActive   = status == MethodStatus.active;
    final isLinked   = status == MethodStatus.linked;
    final isNotLinked = status == MethodStatus.notLinked;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isNotLinked
                ? Colors.white.withOpacity(0.05)
                : color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              size: 18,
              color: isNotLinked ? Colors.white38 : color),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label,
                      style: TextStyle(
                        color:
                        isNotLinked ? Colors.white38 : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      )),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('PRIMARY',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    ),
                  ] else if (isLinked) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('LINKED',
                          style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(detail,
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(isNotLinked ? 0.3 : 0.5),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),

        if (isNotLinked && onAdd != null)
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text('Add',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          )
        else if ((isLinked || isActive) && onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: Icon(Icons.copy,
                color: Colors.white.withOpacity(0.3), size: 16),
            tooltip: 'Copy address',
          ),

        if (isLinked && onRemove != null)
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.link_off,
                color: Colors.red.shade300.withOpacity(0.7), size: 16),
            tooltip: 'Unlink',
          ),
      ],
    );
  }
}

// ── Email Link Sheet ──────────────────────────────────────────────
// Self-contained StatefulWidget — owns and disposes its own controllers.

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
    final email   = _emailCtrl.text.trim();
    final pass    = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error   = null;
    });

    final result = await widget.onSubmit(email, pass);

    if (!mounted) return;

    if (result.success || result.requiresEmailConfirmation) {
      Navigator.pop(context);
      widget.onSuccess(result);
    } else {
      setState(() {
        _loading = false;
        _error   = result.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.subtitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 12)),
            const SizedBox(height: 20),
            _SheetTextField(
              controller: _emailCtrl,
              hint: 'Email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _SheetTextField(
              controller: _passCtrl,
              hint: 'Password (min 6 characters)',
              icon: Icons.lock_outlined,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white30,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 12),
            _SheetTextField(
              controller: _confirmCtrl,
              hint: 'Confirm password',
              icon: Icons.lock_outlined,
              obscure: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: _error!),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : Text(widget.submitLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guest Upgrade Button ──────────────────────────────────────────

class _UpgradeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _UpgradeButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: color.withOpacity(0.6), size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Shared Small Widgets ──────────────────────────────────────────

class _NetworkBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _NetworkBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffix;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon,
            color: Colors.white.withOpacity(0.3), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563eb)),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style:
                TextStyle(color: Colors.red.shade300, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

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
        border:
        Border.all(color: iconColor.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  )),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11)),
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

  const _StatTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10)),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight:
            isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}