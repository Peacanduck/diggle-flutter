import 'package:diggle/game/systems/quest_system.dart';
import 'package:diggle/solana/miners_pass_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MinersPassConfig.fromJson', () {
    test('active price', () {
      final config = MinersPassConfig.fromJson({
        'active': true,
        'amount': 100,
        'amountBase': '100000000',
        'decimals': 6,
      });
      expect(config.active, isTrue);
      expect(config.amount, 100.0);
    });

    test('inactive store', () {
      final config =
          MinersPassConfig.fromJson({'active': false, 'network': 'mainnet'});
      expect(config.active, isFalse);
    });

    test('a zero price is never a free pass', () {
      final config = MinersPassConfig.fromJson({'active': true, 'amount': 0});
      expect(config.active, isFalse);
    });

    test('missing fields fail closed', () {
      expect(MinersPassConfig.fromJson({}).active, isFalse);
    });
  });

  group('formatSkr', () {
    test('whole amounts have no decimals', () {
      expect(formatSkr(100), '100');
      expect(formatSkr(2.0), '2');
    });

    test('fractions keep up to two places, no trailing zeros', () {
      expect(formatSkr(12.5), '12.5');
      expect(formatSkr(0.25), '0.25');
      expect(formatSkr(1.10), '1.1');
    });
  });

  group('QuestSystem.activateMinersPassFor', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('activates for the current ISO week', () async {
      final quests = QuestSystem();
      final thisWeek = QuestSystem.isoWeekKey(DateTime.now().toUtc());
      await quests.activateMinersPassFor(thisWeek);
      expect(quests.minersPassActive, isTrue);
      expect(quests.weeklyRewardMultiplier, 2);
    });

    test('ignores a pass for another week', () async {
      final quests = QuestSystem();
      final lastWeek = QuestSystem.isoWeekKey(
          DateTime.now().toUtc().subtract(const Duration(days: 7)));
      await quests.activateMinersPassFor(lastWeek);
      expect(quests.minersPassActive, isFalse);
      expect(quests.weeklyRewardMultiplier, 1);
    });
  });

  group('QuestSystem.isoWeekKey matches Postgres IYYY-"W"IW', () {
    // Same dates as supabase/tests/store_tests.sql, so the client and
    // iso_week_key() agree on which week a paid pass belongs to.
    test('boundaries', () {
      expect(QuestSystem.isoWeekKey(DateTime.utc(2026, 9, 29, 12)), '2026-W40');
      expect(QuestSystem.isoWeekKey(DateTime.utc(2026, 12, 31, 12)), '2026-W53');
      expect(QuestSystem.isoWeekKey(DateTime.utc(2027, 1, 1, 12)), '2026-W53');
      expect(QuestSystem.isoWeekKey(DateTime.utc(2027, 1, 4)), '2027-W01');
      expect(QuestSystem.isoWeekKey(DateTime.utc(2027, 1, 4, 4, 30)), '2027-W01');
      expect(QuestSystem.isoWeekKey(DateTime.utc(2026, 1, 5, 12)), '2026-W02');
    });
  });
}
