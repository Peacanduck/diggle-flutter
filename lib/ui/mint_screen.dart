/// mint_screen.dart
/// Buy a Diggle Machine outside a run — reached from the main menu and the
/// Hangar's "no machine" state. The same NftMintPanel as the Store
/// building, so the two can never drift apart.
library;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../solana/candy_machine_service.dart';
import 'nft_mint_panel.dart';

class MintScreen extends StatefulWidget {
  final CandyMachineService candyMachineService;

  const MintScreen({super.key, required this.candyMachineService});

  @override
  State<MintScreen> createState() => _MintScreenState();
}

class _MintScreenState extends State<MintScreen> {
  @override
  void initState() {
    super.initState();
    // In a run, BoostManager initializes the candy machine. Out here there
    // is no BoostManager, so load supply/price ourselves — after this
    // frame, since initialize() notifies listeners.
    if (widget.candyMachineService.info == null) {
      Future.microtask(() => widget.candyMachineService.initialize());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text(AppLocalizations.of(context)!.diggleDrillMachine,
            style: const TextStyle(letterSpacing: 2, fontSize: 18)),
      ),
      body: SafeArea(
        child: NftMintPanel(
          candyMachineService: widget.candyMachineService,
          onMinted: () async {
            await widget.candyMachineService.checkNFTOwnership();
          },
        ),
      ),
    );
  }
}
