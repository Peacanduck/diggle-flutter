/// hangar_screen.dart
/// The Hangar: view, verify, and equip your Diggle Machine NFT as gear.
///
/// - Wallet not connected → connect prompt
/// - NFT owned but unrevealed (no trait attributes yet) → "sealed
///   crate" card keeping the flat XP/points boost
/// - Revealed → trait cards with rarity colors + equip/unequip
///
/// Trait parsing uses CandyMachineService.fetchOffchainMetadata and
/// caches per mint via GearSystem.

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../game/systems/gear_sprites.dart';
import '../game/systems/gear_system.dart';
import '../solana/candy_machine_service.dart';
import '../solana/wallet_service.dart';

class HangarScreen extends StatefulWidget {
  final GearSystem gearSystem;
  final CandyMachineService candyMachineService;
  final WalletService walletService;
  final VoidCallback onBack;

  const HangarScreen({
    super.key,
    required this.gearSystem,
    required this.candyMachineService,
    required this.walletService,
    required this.onBack,
  });

  @override
  State<HangarScreen> createState() => _HangarScreenState();
}

class _HangarScreenState extends State<HangarScreen> {
  bool _loading = false;    // blocking spinner (no cache to show)
  bool _refreshing = false; // background rescan in progress
  List<({OwnedDiggleNFT nft, DiggleNFTTraits? traits})> _machines = [];

  /// Cache older than this triggers a background rescan on open.
  static const _staleAfter = Duration(minutes: 10);

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Cache-first load: show the last scan instantly, then refresh from
  /// the chain in the background (or on demand via the refresh button).
  Future<void> _load({bool force = false}) async {
    final service = widget.candyMachineService;
    if (!widget.walletService.isConnected) {
      if (mounted) setState(() {});
      return;
    }

    try {
      // Phase 1 — instant: serve cached ownership if we have it.
      bool haveSomething = service.ownedNFTs.isNotEmpty;
      if (!haveSomething) {
        haveSomething = await service.loadCachedOwnership();
      }
      if (haveSomething) {
        await _rebuildMachines(traitsFromCacheOnly: true);
      } else {
        // Nothing cached — this is a genuine first load.
        if (mounted) setState(() => _loading = true);
      }

      // Phase 2 — background: rescan if forced, empty, or stale.
      final last = service.lastScanAt;
      final stale = last == null ||
          DateTime.now().difference(last) > _staleAfter;
      if (force || !haveSomething || stale) {
        if (mounted) setState(() => _refreshing = true);
        await service.checkNFTOwnership();
        await service.checkGenesisTokenOwnership();
        await _rebuildMachines();
      }
    } catch (e) {
      debugPrint('Hangar: load failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  /// Build the machine list from the service's current NFTs.
  /// With [traitsFromCacheOnly], no network is touched (instant path).
  Future<void> _rebuildMachines({bool traitsFromCacheOnly = false}) async {
    final service = widget.candyMachineService;
    final machines = <({OwnedDiggleNFT nft, DiggleNFTTraits? traits})>[];
    for (final nft in service.ownedNFTs) {
      DiggleNFTTraits? traits =
          await widget.gearSystem.cachedTraits(nft.mintAddress);
      if (traits == null &&
          !traitsFromCacheOnly &&
          nft.metadataUri != null) {
        final json = await service.fetchOffchainMetadata(nft.metadataUri!);
        if (json != null) {
          traits = DiggleNFTTraits.fromMetadataJson(nft.mintAddress, json);
          if (traits != null) {
            await widget.gearSystem.cacheTraits(traits);
          }
        }
      }
      machines.add((nft: nft, traits: traits));
    }

    if (!mounted) return;
    setState(() {
      _machines = machines;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.black45,
        leading: IconButton(
            onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
        title: Text(AppLocalizations.of(context)!.hangarHeading,
            style: const TextStyle(letterSpacing: 2, fontSize: 18)),
        actions: [
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.amber),
                ),
              ),
            )
          else
            IconButton(
                onPressed: () => _load(force: true),
                icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!widget.walletService.isConnected) {
      return _buildMessage(
        '🔌',
        'Connect your wallet to hangar your Diggle Machine.',
      );
    }
    if (_machines.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.candyMachineService.hasGenesisToken)
            _buildGenesisBadge(),
          SizedBox(
            height: 400,
            child: _buildMessage(
              '🪐',
              'No Diggle Machine found in this wallet.\n'
              'Mint one in the Premium Store to unlock gear bonuses!',
            ),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.candyMachineService.hasGenesisToken) _buildGenesisBadge(),
        if (_machines.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              AppLocalizations.of(context)!
                  .hangarMachineCount(_machines.length),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        for (final machine in _machines) ...[
          _buildNFTHeader(machine.nft),
          const SizedBox(height: 12),
          if (machine.traits == null)
            _buildSealedCrate()
          else
            _buildTraitList(machine.traits!),
          const SizedBox(height: 28),
        ],
      ],
    );
  }

  /// Seeker Genesis Token holder badge — verified Solana Mobile device.
  Widget _buildGenesisBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade900, Colors.indigo.shade900],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.tealAccent.shade700),
      ),
      child: Row(
        children: [
          const Text('📱', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.hangarSeekerVerified,
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.hangarSeekerBlurb,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String emoji, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildNFTHeader(OwnedDiggleNFT nft) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: nft.imageUri != null
              ? Image.network(
                  nft.imageUri!,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageFallback(),
                )
              : _imageFallback(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nft.name ?? 'Diggle Machine',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${nft.mintAddress.substring(0, 8)}…',
                style:
                    const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imageFallback() => Container(
        width: 84,
        height: 84,
        color: Colors.indigo.shade900,
        child: const Center(child: Text('⛏️', style: TextStyle(fontSize: 32))),
      );

  Widget _buildSealedCrate() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.brown.shade900.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.brown.shade600),
      ),
      child: Column(
        children: [
          const Text('📦', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.hangarSealedCrate,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.hangarSealedBlurb,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitList(DiggleNFTTraits traits) {
    final isEquipped =
        widget.gearSystem.equipped?.mintAddress == traits.mintAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final slot in GearSlot.values)
          if (traits.traits[slot] != null)
            _buildTraitCard(traits.traits[slot]!),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            if (isEquipped) {
              await widget.gearSystem.unequip();
            } else {
              await widget.gearSystem.equip(traits);
            }
            if (mounted) setState(() {});
          },
          icon: Icon(isEquipped ? Icons.remove_circle : Icons.build),
          label: Text(isEquipped ? 'UNEQUIP' : 'EQUIP THIS MACHINE'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isEquipped ? Colors.grey.shade800 : Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        if (isEquipped)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              AppLocalizations.of(context)!.hangarEquipped,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTraitCard(GearTrait trait) {
    final color = _rarityColor(trait.rarity);
    final bonusText = _bonusText(trait);
    final previewAsset = GearSpriteSheet.previewAsset(trait.partName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          if (previewAsset != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset(
                previewAsset,
                width: 56,
                height: 56,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trait.slot.traitType.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 1.5),
                ),
                Text(
                  trait.partName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(bonusText,
                    style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color),
            ),
            child: Text(
              trait.rarity.displayName.toUpperCase(),
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _rarityColor(GearRarity rarity) {
    switch (rarity) {
      case GearRarity.common:
        return Colors.grey.shade400;
      case GearRarity.uncommon:
        return Colors.green.shade400;
      case GearRarity.rare:
        return Colors.cyan.shade300;
      case GearRarity.epic:
        return Colors.amber.shade400;
      case GearRarity.legendary:
        return Colors.purple.shade300;
    }
  }

  String _bonusText(GearTrait trait) {
    final rarity = trait.rarity;
    switch (trait.slot) {
      case GearSlot.drill:
        final pct = (GearBonusTable.drillSpeed[rarity]! * 100).round();
        return rarity == GearRarity.legendary
            ? '+$pct% dig speed • digs any hardness'
            : '+$pct% dig speed';
      case GearSlot.hull:
        final hp = GearBonusTable.hullHP[rarity]!.round();
        return rarity == GearRarity.legendary
            ? '+$hp max HP • −50% gas damage'
            : '+$hp max HP';
      case GearSlot.thruster:
        final pct = (GearBonusTable.thrusterSpeed[rarity]! * 100).round();
        return rarity == GearRarity.legendary
            ? '+$pct% speed • +1 safe fall tile'
            : '+$pct% move & fly speed';
      case GearSlot.fuelTank:
        final pct = (GearBonusTable.fuelCapacity[rarity]! * 100).round();
        return rarity == GearRarity.legendary
            ? '+$pct% fuel capacity • −10% refuel cost'
            : '+$pct% fuel capacity';
      case GearSlot.cargoHold:
        final slots = GearBonusTable.cargoSlots[rarity]!;
        return rarity == GearRarity.legendary
            ? '+$slots cargo slots • +5% sell price'
            : '+$slots cargo slots';
    }
  }
}
