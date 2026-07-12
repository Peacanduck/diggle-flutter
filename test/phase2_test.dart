import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diggle/game/systems/prestige_system.dart';
import 'package:diggle/game/systems/quest_system.dart';
import 'package:diggle/game/world/world_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('isoWeekKey', () {
    test('known dates map to correct ISO weeks', () {
      // 2026-01-01 is a Thursday → week 1 of 2026
      expect(QuestSystem.isoWeekKey(DateTime.utc(2026, 1, 1)), '2026-W01');
      // 2024-12-30 (Monday) belongs to 2025-W01 per ISO 8601
      expect(QuestSystem.isoWeekKey(DateTime.utc(2024, 12, 30)), '2025-W01');
      // Mid-year sanity: 2026-07-05 is a Sunday → same week as 2026-06-29 (Monday)
      expect(
        QuestSystem.isoWeekKey(DateTime.utc(2026, 7, 5)),
        QuestSystem.isoWeekKey(DateTime.utc(2026, 6, 29)),
      );
      // Next Monday is a different week
      expect(
        QuestSystem.isoWeekKey(DateTime.utc(2026, 7, 5)),
        isNot(QuestSystem.isoWeekKey(DateTime.utc(2026, 7, 6))),
      );
    });

    test('same week key produces same world seed', () {
      final seedA = QuestSystem.isoWeekKey(DateTime.utc(2026, 7, 1)).hashCode &
          0x7FFFFFFF;
      final seedB = QuestSystem.isoWeekKey(DateTime.utc(2026, 7, 3)).hashCode &
          0x7FFFFFFF;
      expect(seedA, seedB);

      final worldA =
          WorldGenerator(config: WorldConfig(seed: seedA)).generate();
      final worldB =
          WorldGenerator(config: WorldConfig(seed: seedB)).generate();
      expect(worldA[30][200].type, worldB[30][200].type);
      expect(worldA[100][400].type, worldB[100][400].type);
    });
  });

  group('PrestigeSystem', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('perks scale with level and persist', () async {
      final prestige = PrestigeSystem();
      await prestige.initialize();
      expect(prestige.level, 0);
      expect(prestige.sellMultiplier, 1.0);
      expect(prestige.oreRichness, 1.0);

      await prestige.prestige();
      expect(prestige.level, 1);
      expect(prestige.sellMultiplier, closeTo(1.05, 0.001));
      expect(prestige.oreRichness, 1.0); // hardcore seams start at 2

      await prestige.prestige();
      expect(prestige.oreRichness, closeTo(1.10, 0.001));
      expect(prestige.hazardIntensity, closeTo(1.15, 0.001));

      final reloaded = PrestigeSystem();
      await reloaded.initialize();
      expect(reloaded.level, 2);
    });

    test('eligibility via depth OR lifetime cash', () {
      final prestige = PrestigeSystem();
      expect(prestige.canPrestige(maxDepth: 100, lifetimeCash: 1000), false);
      expect(prestige.canPrestige(maxDepth: 400, lifetimeCash: 0), true);
      expect(prestige.canPrestige(maxDepth: 0, lifetimeCash: 500000), true);
    });
  });
}
