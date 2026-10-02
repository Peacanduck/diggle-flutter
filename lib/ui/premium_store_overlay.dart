/// premium_store_overlay.dart
/// The in-run Premium Store (the Store building): the player's level / XP /
/// points bar over the shared Diggle Machine mint (NftMintPanel).
/// All user-facing strings localized via AppLocalizations.
///
/// The SOL and Points tabs (timed boosters, points packs) were removed
/// when the Diggle Mart program closed (2026-09-29).

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../game/diggle_game.dart';
import '../game/systems/xp_points_system.dart';
import '../game/systems/boost_manager.dart';
import '../solana/candy_machine_service.dart';
import 'nft_mint_panel.dart';

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

class _PremiumStoreOverlayState extends State<PremiumStoreOverlay> {
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
            Expanded(
              child: NftMintPanel(
                candyMachineService: widget.candyMachineService,
                onMinted: widget.boostManager.checkForNFT,
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
            onPressed: () => widget.game.closePremiumStore(),
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

  Widget _buildCloseButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: ElevatedButton.icon(
        onPressed: () => widget.game.closePremiumStore(),
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
}
