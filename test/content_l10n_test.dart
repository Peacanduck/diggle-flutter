import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/game/systems/achievement_system.dart';
import 'package:diggle/game/systems/collection_system.dart';
import 'package:diggle/game/systems/item_system.dart';
import 'package:diggle/game/world/biome.dart';
import 'package:diggle/game/world/tile.dart';
import 'package:diggle/l10n/app_localizations.dart';
import 'package:diggle/l10n/app_localizations_en.dart';
import 'package:diggle/ui/content_l10n.dart';

/// Sentinel that can never be a real translation, so a resolver falling
/// through to its fallback is unmistakable.
const _fallback = '!!UNRESOLVED!!';

void main() {
  final AppLocalizations l10n = AppLocalizationsEn();

  // The resolvers deliberately fall back to the definition's English for
  // unknown ids, which keeps the UI working but hides missing keys. These
  // tests are what stops content added later from silently shipping
  // untranslatable — the fallback should never be the thing on screen.
  group('every catalogue entry resolves to a key', () {
    test('artifacts have a localized name and description', () {
      final missing = <String>[];
      for (final a in CollectionSystem.catalog) {
        if (localizedArtifactName(l10n, a.id, _fallback) == _fallback) {
          missing.add('${a.id} (name)');
        }
        if (localizedArtifactDescription(l10n, a.id, _fallback) == _fallback) {
          missing.add('${a.id} (description)');
        }
      }
      expect(missing, isEmpty,
          reason: 'add keys and re-run python tool/gen_content_l10n.py');
    });

    test('achievements have a localized name and description', () {
      final missing = <String>[];
      for (final a in AchievementSystem.catalog) {
        if (localizedAchievementName(l10n, a.id, _fallback) == _fallback) {
          missing.add('${a.id} (name)');
        }
        if (localizedAchievementDescription(l10n, a.id, _fallback) ==
            _fallback) {
          missing.add('${a.id} (description)');
        }
      }
      expect(missing, isEmpty,
          reason: 'add keys and re-run python tool/gen_content_l10n.py');
    });

    test('every ItemType has a localized name and description', () {
      final missing = <String>[];
      for (final t in ItemType.values) {
        if (localizedItemName(l10n, t.name, _fallback) == _fallback) {
          missing.add('${t.name} (name)');
        }
        if (localizedItemDescription(l10n, t.name, _fallback) == _fallback) {
          missing.add('${t.name} (description)');
        }
      }
      expect(missing, isEmpty);
    });

    // The item keys were once generated off the icon getter as well as
    // displayName, and the emoji won: every item rendered as its icon.
    test('item names are the display name, not the icon', () {
      for (final t in ItemType.values) {
        expect(localizedItemName(l10n, t.name, _fallback), t.displayName,
            reason: '${t.name} should resolve to its English displayName');
        expect(localizedItemDescription(l10n, t.name, _fallback),
            t.description);
      }
    });

    test('every TileType has a localized name', () {
      final missing = [
        for (final t in TileType.values)
          if (localizedTileName(l10n, t.name, _fallback) == _fallback) t.name
      ];
      expect(missing, isEmpty);
    });

    // The museum groups artifacts by Biome.strata and labels each group
    // with the biome name, so both sources have to resolve: a stratum
    // with no key loses its header, and an artifact filed under a biome
    // that no stratum names would never be shown at all.
    test('every stratum has a localized biome name', () {
      final missing = [
        for (final b in Biome.strata)
          if (localizedBiomeName(l10n, b.name, _fallback) == _fallback) b.name
      ];
      expect(missing, isEmpty);
    });

    test("every artifact's biome has a localized name", () {
      final biomes = CollectionSystem.catalog.map((a) => a.biomeName).toSet();
      final missing = [
        for (final name in biomes)
          if (localizedBiomeName(l10n, name, _fallback) == _fallback) name
      ];
      expect(missing, isEmpty);
      expect(biomes, everyElement(isIn(Biome.strata.map((b) => b.name))),
          reason: 'an artifact filed under an unknown biome is unreachable');
    });
  });

  group('resolver behaviour', () {
    test('an unknown id falls back rather than throwing', () {
      expect(localizedArtifactName(l10n, 'no_such_artifact', 'Mystery Rock'),
          'Mystery Rock');
      expect(localizedItemName(l10n, 'no_such_item', 'Thing'), 'Thing');
    });

    test('a known id returns the catalogue text, not the fallback', () {
      final artifact = CollectionSystem.catalog.first;
      expect(localizedArtifactName(l10n, artifact.id, _fallback),
          artifact.name);
    });

    test('rarity names resolve, unknown ones fall back', () {
      expect(localizedRarity(l10n, 'legendary', _fallback), 'Legendary');
      expect(localizedRarity(l10n, 'mythic', 'Mythic'), 'Mythic');
    });

    // The header renders the value as-is rather than upper-casing it, so
    // the casing has to come from the arb.
    test('biome names carry their display casing, unknown ones fall back', () {
      expect(localizedBiomeName(l10n, 'Magma Core', _fallback), 'MAGMA CORE');
      expect(localizedBiomeName(l10n, 'The Hollow', 'THE HOLLOW'),
          'THE HOLLOW');
    });
  });
}
