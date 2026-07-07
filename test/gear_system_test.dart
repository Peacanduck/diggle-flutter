import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diggle/game/systems/gear_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  // Mirrors DiggleAssets/metadata/sample_legendary.json
  final legendaryJson = {
    'name': 'Diggle Machine #5',
    'symbol': 'DIGM',
    'attributes': [
      {'trait_type': 'Background', 'value': 'Crystal Cavern'},
      {'trait_type': 'Hull', 'value': 'Ghost Stealth'},
      {'trait_type': 'Thruster', 'value': 'Quantum Glitch'},
      {'trait_type': 'Fuel Tank', 'value': 'Miniature Star'},
      {'trait_type': 'Drill', 'value': 'Diamond Omni-Drill'},
      {'trait_type': 'Cargo Hold', 'value': 'Dimensional Vault'},
      {'trait_type': 'Hull Rarity', 'value': 'Legendary'},
      {'trait_type': 'Thruster Rarity', 'value': 'Legendary'},
      {'trait_type': 'Fuel Tank Rarity', 'value': 'Legendary'},
      {'trait_type': 'Drill Rarity', 'value': 'Legendary'},
      {'trait_type': 'Cargo Hold Rarity', 'value': 'Legendary'},
      {'trait_type': 'Rarity Score', 'value': 800},
    ],
  };

  group('DiggleNFTTraits.fromMetadataJson', () {
    test('parses full legendary metadata', () {
      final traits =
          DiggleNFTTraits.fromMetadataJson('MintAddr111', legendaryJson);
      expect(traits, isNotNull);
      expect(traits!.isComplete, true);
      expect(traits.traits[GearSlot.hull]!.partName, 'Ghost Stealth');
      expect(traits.traits[GearSlot.drill]!.rarity, GearRarity.legendary);
    });

    test('falls back to part-name rarity table without Rarity attributes',
        () {
      final json = {
        'name': 'Diggle Machine #7',
        'attributes': [
          {'trait_type': 'Hull', 'value': 'Cyber Scarab'},
          {'trait_type': 'Drill', 'value': 'Steel Augur'},
        ],
      };
      final traits = DiggleNFTTraits.fromMetadataJson('Mint2', json);
      expect(traits!.traits[GearSlot.hull]!.rarity, GearRarity.rare);
      expect(traits.traits[GearSlot.drill]!.rarity, GearRarity.common);
      expect(traits.isComplete, false);
    });

    test('returns null for unrevealed/placeholder metadata', () {
      final placeholder = {
        'name': 'Diggle Machine',
        'attributes': [
          {'trait_type': 'Status', 'value': 'Unrevealed'},
        ],
      };
      expect(DiggleNFTTraits.fromMetadataJson('Mint3', placeholder), isNull);
      expect(DiggleNFTTraits.fromMetadataJson('Mint4', {'name': 'x'}), isNull);
    });
  });

  group('GearSystem bonuses', () {
    test('legendary loadout yields max bonuses', () async {
      final gear = GearSystem();
      final traits =
          DiggleNFTTraits.fromMetadataJson('Mint1', legendaryJson)!;
      await gear.equip(traits);

      expect(gear.drillSpeedBonus, 0.25);
      expect(gear.drillHardnessOverride, true);
      expect(gear.hullHPBonus, 40);
      expect(gear.gasResist, true);
      expect(gear.thrusterSpeedBonus, 0.22);
      expect(gear.bonusSafeFallTiles, 1);
      expect(gear.fuelCapacityBonus, 0.25);
      expect(gear.refuelDiscount, 0.10);
      expect(gear.cargoSlotBonus, 15);
      expect(gear.sellBonus, 0.05);
      expect(gear.equippedTint, isNotNull);
    });

    test('nothing equipped yields neutral bonuses', () {
      final gear = GearSystem();
      expect(gear.drillSpeedBonus, 0);
      expect(gear.drillHardnessOverride, false);
      expect(gear.hullHPBonus, 0);
      expect(gear.cargoSlotBonus, 0);
      expect(gear.equippedTint, isNull);
    });

    test('equipped gear persists across restarts', () async {
      final gear = GearSystem();
      await gear.equip(
          DiggleNFTTraits.fromMetadataJson('MintPersist', legendaryJson)!);

      final reloaded = GearSystem();
      await reloaded.initialize();
      expect(reloaded.equipped?.mintAddress, 'MintPersist');
      expect(reloaded.drillSpeedBonus, 0.25);

      await reloaded.unequip();
      final reloaded2 = GearSystem();
      await reloaded2.initialize();
      expect(reloaded2.equipped, isNull);
    });
  });
}
