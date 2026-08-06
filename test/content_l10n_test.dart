import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/game/systems/achievement_system.dart';
import 'package:diggle/game/systems/collection_system.dart';
import 'package:diggle/game/systems/item_system.dart';
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

    test('every ItemType has a localized name', () {
      final missing = [
        for (final t in ItemType.values)
          if (localizedItemName(l10n, t.name, _fallback) == _fallback) t.name
      ];
      expect(missing, isEmpty);
    });

    test('every TileType has a localized name', () {
      final missing = [
        for (final t in TileType.values)
          if (localizedTileName(l10n, t.name, _fallback) == _fallback) t.name
      ];
      expect(missing, isEmpty);
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
  });
}
