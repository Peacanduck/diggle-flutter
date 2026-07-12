/// gear_system.dart
/// NFT gear utility: a Diggle Machine NFT becomes equippable in-game gear.
///
/// Each NFT carries 5 trait slots matching the ship's upgrade systems
/// (Hull / Thruster / Fuel Tank / Drill / Cargo Hold), each in one of
/// 5 rarities. Equipping the NFT applies convenience-power bonuses via
/// small additive setGearBonus() hooks on the existing systems — never
/// in weekly challenge mode (the pay-to-win firewall).
///
/// Pre-reveal (hiddenSettings), NFTs are "sealed crates": no traits in
/// metadata yet, so they keep the flat BoostManager multiplier and show
/// as sealed in the hangar. This module degrades gracefully to that.

import 'dart:convert';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GearRarity { common, uncommon, rare, epic, legendary }

extension GearRarityX on GearRarity {
  String get displayName {
    switch (this) {
      case GearRarity.common:
        return 'Common';
      case GearRarity.uncommon:
        return 'Uncommon';
      case GearRarity.rare:
        return 'Rare';
      case GearRarity.epic:
        return 'Epic';
      case GearRarity.legendary:
        return 'Legendary';
    }
  }

  static GearRarity? parse(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'common':
        return GearRarity.common;
      case 'uncommon':
        return GearRarity.uncommon;
      case 'rare':
        return GearRarity.rare;
      case 'epic':
        return GearRarity.epic;
      case 'legendary':
        return GearRarity.legendary;
      default:
        return null;
    }
  }
}

enum GearSlot { hull, thruster, fuelTank, drill, cargoHold }

extension GearSlotX on GearSlot {
  /// trait_type string in the NFT metadata.
  String get traitType {
    switch (this) {
      case GearSlot.hull:
        return 'Hull';
      case GearSlot.thruster:
        return 'Thruster';
      case GearSlot.fuelTank:
        return 'Fuel Tank';
      case GearSlot.drill:
        return 'Drill';
      case GearSlot.cargoHold:
        return 'Cargo Hold';
    }
  }
}

/// Fallback: part name → rarity, for metadata missing the explicit
/// "<Slot> Rarity" attributes. Mirrors the DiggleAssets trait matrix.
const Map<String, GearRarity> _partNameRarity = {
  // Hull (two Common variants per slot — 50/25/15/8/2 curve)
  'standard prospector': GearRarity.common,
  'rusty hauler': GearRarity.common,
  'armored vanguard': GearRarity.uncommon,
  'cyber scarab': GearRarity.rare,
  'golden behemoth': GearRarity.epic,
  'ghost stealth': GearRarity.legendary,
  // Thruster
  'ion drive': GearRarity.common,
  'turbo fan': GearRarity.common,
  'chemical burner': GearRarity.uncommon,
  'plasma jet': GearRarity.rare,
  'gravity well': GearRarity.epic,
  'quantum glitch': GearRarity.legendary,
  // Fuel Tank
  'diesel canister': GearRarity.common,
  'oil drum': GearRarity.common,
  'hydrogen cell': GearRarity.uncommon,
  'nuclear battery': GearRarity.rare,
  'dark matter vial': GearRarity.epic,
  'miniature star': GearRarity.legendary,
  // Drill
  'steel augur': GearRarity.common,
  'iron pike': GearRarity.common,
  'tungsten breaker': GearRarity.uncommon,
  'laser bore': GearRarity.rare,
  'sonic pulverizer': GearRarity.epic,
  'diamond omni-drill': GearRarity.legendary,
  // Cargo Hold
  'standard bin': GearRarity.common,
  'scrap basket': GearRarity.common,
  'reinforced crate': GearRarity.uncommon,
  'ore net': GearRarity.rare,
  'cryo pod': GearRarity.epic,
  'dimensional vault': GearRarity.legendary,
};

/// One slot of an NFT's gear.
class GearTrait {
  final GearSlot slot;
  final String partName;
  final GearRarity rarity;

  const GearTrait({
    required this.slot,
    required this.partName,
    required this.rarity,
  });

  Map<String, dynamic> toJson() => {
        'slot': slot.name,
        'part': partName,
        'rarity': rarity.name,
      };

  static GearTrait? fromJson(Map<String, dynamic> json) {
    final slot =
        GearSlot.values.where((s) => s.name == json['slot']).firstOrNull;
    final rarity = GearRarity.values
        .where((r) => r.name == json['rarity'])
        .firstOrNull;
    if (slot == null || rarity == null) return null;
    return GearTrait(
      slot: slot,
      partName: json['part'] as String? ?? '',
      rarity: rarity,
    );
  }
}

/// Parsed traits of one Diggle Machine NFT.
class DiggleNFTTraits {
  final String mintAddress;
  final String? name;
  final Map<GearSlot, GearTrait> traits;

  const DiggleNFTTraits({
    required this.mintAddress,
    this.name,
    required this.traits,
  });

  bool get isComplete => traits.length == GearSlot.values.length;

  /// Parse from off-chain metadata JSON (attributes array).
  /// Returns null if no gear traits found (unrevealed / placeholder).
  static DiggleNFTTraits? fromMetadataJson(
      String mintAddress, Map<String, dynamic> json) {
    final attributes = json['attributes'];
    if (attributes is! List) return null;

    // Collect trait_type → value
    final values = <String, String>{};
    for (final attr in attributes) {
      if (attr is! Map) continue;
      final type = attr['trait_type']?.toString();
      final value = attr['value']?.toString();
      if (type != null && value != null) values[type] = value;
    }

    final traits = <GearSlot, GearTrait>{};
    for (final slot in GearSlot.values) {
      final partName = values[slot.traitType];
      if (partName == null) continue;
      // Prefer the explicit "<Slot> Rarity" attribute, fall back to
      // the part-name table.
      final rarity = GearRarityX.parse(values['${slot.traitType} Rarity']) ??
          _partNameRarity[partName.toLowerCase().trim()];
      if (rarity == null) continue;
      traits[slot] = GearTrait(slot: slot, partName: partName, rarity: rarity);
    }

    if (traits.isEmpty) return null;
    return DiggleNFTTraits(
      mintAddress: mintAddress,
      name: json['name']?.toString(),
      traits: traits,
    );
  }

  Map<String, dynamic> toJson() => {
        'mint': mintAddress,
        'name': name,
        'traits': traits.values.map((t) => t.toJson()).toList(),
      };

  static DiggleNFTTraits? fromJson(Map<String, dynamic> json) {
    final mint = json['mint'] as String?;
    if (mint == null) return null;
    final traits = <GearSlot, GearTrait>{};
    for (final t in (json['traits'] as List? ?? [])) {
      final trait = GearTrait.fromJson(t as Map<String, dynamic>);
      if (trait != null) traits[trait.slot] = trait;
    }
    return DiggleNFTTraits(
      mintAddress: mint,
      name: json['name'] as String?,
      traits: traits,
    );
  }
}

/// Stat bonuses per rarity per slot (convenience power, not score).
class GearBonusTable {
  /// Drill: dig-speed bonus (fraction). Legendary also digs hardness 4.
  static const Map<GearRarity, double> drillSpeed = {
    GearRarity.common: 0.03,
    GearRarity.uncommon: 0.06,
    GearRarity.rare: 0.10,
    GearRarity.epic: 0.16,
    GearRarity.legendary: 0.25,
  };

  /// Hull: bonus max HP. Legendary also halves gas damage.
  static const Map<GearRarity, double> hullHP = {
    GearRarity.common: 5,
    GearRarity.uncommon: 10,
    GearRarity.rare: 18,
    GearRarity.epic: 28,
    GearRarity.legendary: 40,
  };

  /// Thruster: move/fly speed bonus. Legendary adds +1 safe fall tile.
  static const Map<GearRarity, double> thrusterSpeed = {
    GearRarity.common: 0.03,
    GearRarity.uncommon: 0.06,
    GearRarity.rare: 0.10,
    GearRarity.epic: 0.15,
    GearRarity.legendary: 0.22,
  };

  /// Fuel tank: capacity bonus. Legendary refuels 10% cheaper.
  static const Map<GearRarity, double> fuelCapacity = {
    GearRarity.common: 0.05,
    GearRarity.uncommon: 0.08,
    GearRarity.rare: 0.12,
    GearRarity.epic: 0.18,
    GearRarity.legendary: 0.25,
  };

  /// Cargo: bonus slots. Legendary sells 5% higher.
  static const Map<GearRarity, int> cargoSlots = {
    GearRarity.common: 2,
    GearRarity.uncommon: 4,
    GearRarity.rare: 7,
    GearRarity.epic: 10,
    GearRarity.legendary: 15,
  };
}

/// Manages the equipped NFT and its parsed traits.
/// DiggleGame reads this to apply setGearBonus() to each system.
class GearSystem extends ChangeNotifier {
  static const _equippedKey = 'diggle_gear_equipped_v1';
  static const _traitsCachePrefix = 'diggle_gear_traits_v1';

  DiggleNFTTraits? _equipped;

  DiggleNFTTraits? get equipped => _equipped;
  bool get hasGearEquipped => _equipped != null;

  /// Fired when gear changes so the game can re-apply bonuses.
  void Function()? onGearChanged;

  GearTrait? traitFor(GearSlot slot) => _equipped?.traits[slot];

  bool isLegendary(GearSlot slot) =>
      traitFor(slot)?.rarity == GearRarity.legendary;

  // ── Computed bonuses (0 / neutral when nothing equipped) ──────

  double get drillSpeedBonus =>
      GearBonusTable.drillSpeed[traitFor(GearSlot.drill)?.rarity] ?? 0;
  bool get drillHardnessOverride => isLegendary(GearSlot.drill);

  double get hullHPBonus =>
      GearBonusTable.hullHP[traitFor(GearSlot.hull)?.rarity] ?? 0;
  bool get gasResist => isLegendary(GearSlot.hull);

  double get thrusterSpeedBonus =>
      GearBonusTable.thrusterSpeed[traitFor(GearSlot.thruster)?.rarity] ?? 0;
  int get bonusSafeFallTiles => isLegendary(GearSlot.thruster) ? 1 : 0;

  double get fuelCapacityBonus =>
      GearBonusTable.fuelCapacity[traitFor(GearSlot.fuelTank)?.rarity] ?? 0;
  double get refuelDiscount => isLegendary(GearSlot.fuelTank) ? 0.10 : 0;

  int get cargoSlotBonus =>
      GearBonusTable.cargoSlots[traitFor(GearSlot.cargoHold)?.rarity] ?? 0;
  double get sellBonus => isLegendary(GearSlot.cargoHold) ? 0.05 : 0;

  /// Subtle sprite tint by hull rarity (modulate blend — near-white
  /// with a hue cast). Null = no tint (nothing equipped / common hull).
  Color? get equippedTint {
    final rarity = traitFor(GearSlot.hull)?.rarity;
    switch (rarity) {
      case GearRarity.uncommon:
        return const Color(0xFFD8FFD8); // green cast
      case GearRarity.rare:
        return const Color(0xFFCCF2FF); // cyan cast
      case GearRarity.epic:
        return const Color(0xFFFFEBC2); // gold cast
      case GearRarity.legendary:
        return const Color(0xFFE3CCFF); // violet cast
      case GearRarity.common:
      case null:
        return null;
    }
  }

  // ── Equip / unequip ────────────────────────────────────────────

  Future<void> equip(DiggleNFTTraits traits) async {
    _equipped = traits;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_equippedKey, jsonEncode(traits.toJson()));
    onGearChanged?.call();
    notifyListeners();
  }

  Future<void> unequip() async {
    _equipped = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_equippedKey);
    onGearChanged?.call();
    notifyListeners();
  }

  // ── Trait caching (per mint) ───────────────────────────────────

  Future<void> cacheTraits(DiggleNFTTraits traits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_traitsCachePrefix}_${traits.mintAddress}',
      jsonEncode(traits.toJson()),
    );
  }

  Future<DiggleNFTTraits?> cachedTraits(String mintAddress) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_traitsCachePrefix}_$mintAddress');
    if (raw == null) return null;
    try {
      return DiggleNFTTraits.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_equippedKey);
    if (raw != null) {
      try {
        _equipped =
            DiggleNFTTraits.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('GearSystem: failed to restore equipped gear: $e');
      }
    }
    notifyListeners();
  }
}
