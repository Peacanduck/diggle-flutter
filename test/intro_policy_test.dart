import 'package:flutter_test/flutter_test.dart';

import 'package:diggle/services/intro_policy.dart';

/// Readings for a fresh surface start with nothing happening — the "quiet"
/// baseline each test perturbs one axis of.
IntroTip? _next(
  IntroState state, {
  bool atSurface = true,
  double cargoFraction = 0.0,
  double fuelFraction = 1.0,
  bool justMinedFirstOre = false,
  bool justTookFallDamage = false,
  double secondsSinceInput = 0.0,
}) {
  return nextTip(
    state: state,
    atSurface: atSurface,
    cargoFraction: cargoFraction,
    fuelFraction: fuelFraction,
    justMinedFirstOre: justMinedFirstOre,
    justTookFallDamage: justTookFallDamage,
    secondsSinceInput: secondsSinceInput,
  );
}

void main() {
  group('nextTip — terminal states', () {
    test('a skipped intro never shows anything', () {
      const state = IntroState(skipped: true);
      expect(_next(state, secondsSinceInput: 10), isNull);
      expect(_next(state, justMinedFirstOre: true), isNull);
      expect(_next(state, justTookFallDamage: true), isNull);
    });

    test('a completed intro never shows anything', () {
      const state = IntroState(completed: true);
      expect(_next(state, secondsSinceInput: 10), isNull);
      expect(_next(state, justTookFallDamage: true), isNull);
    });

    test('a visible tip blocks a second one (never stack two cards)', () {
      const state = IntroState(tipVisible: true);
      // Two triggers are live at once; neither may return while a card is up.
      expect(
        _next(state, justTookFallDamage: true, justMinedFirstOre: true),
        isNull,
      );
    });
  });

  group('nextTip — the movement tip', () {
    test('below the idle threshold nothing fires', () {
      expect(_next(const IntroState(), secondsSinceInput: 1.49), isNull);
    });

    test('at the idle threshold the movement tip fires', () {
      expect(
        _next(const IntroState(), secondsSinceInput: kMovementIdleSeconds),
        IntroTip.movement,
      );
    });

    test('the movement tip only fires at the surface', () {
      expect(
        _next(const IntroState(), atSurface: false, secondsSinceInput: 5),
        isNull,
      );
    });

    test('a movement tip already shown never returns again', () {
      const state = IntroState(shown: {IntroTip.movement});
      expect(_next(state, secondsSinceInput: 5), isNull);
    });
  });

  group('nextTip — first ore', () {
    test('mining the first ore fires the cargo tip', () {
      expect(
        _next(const IntroState(), justMinedFirstOre: true),
        IntroTip.firstOre,
      );
    });

    test('does not re-fire once shown', () {
      const state = IntroState(shown: {IntroTip.firstOre});
      expect(_next(state, justMinedFirstOre: true), isNull);
    });
  });

  group('nextTip — cargo full', () {
    test('80% cargo below the surface fires', () {
      expect(
        _next(const IntroState(), atSurface: false, cargoFraction: 0.8),
        IntroTip.cargoFull,
      );
    });

    test('does NOT fire at the surface — selling is available there', () {
      expect(
        _next(const IntroState(), atSurface: true, cargoFraction: 0.95),
        isNull,
      );
    });

    test('below the threshold does not fire', () {
      expect(
        _next(const IntroState(), atSurface: false, cargoFraction: 0.79),
        isNull,
      );
    });
  });

  group('nextTip — low fuel', () {
    test('under 40% fuel below the surface fires', () {
      expect(
        _next(const IntroState(), atSurface: false, fuelFraction: 0.39),
        IntroTip.lowFuel,
      );
    });

    test('does not fire at the surface (refuelling happens there)', () {
      expect(
        _next(const IntroState(), atSurface: true, fuelFraction: 0.1),
        isNull,
      );
    });

    test('low fuel wins over full cargo when both are live', () {
      expect(
        _next(const IntroState(),
            atSurface: false, fuelFraction: 0.1, cargoFraction: 0.95),
        IntroTip.lowFuel,
      );
    });
  });

  group('nextTip — fall damage is event-ordered, not sequence-locked', () {
    test('fires on fall damage even though no earlier tip has shown', () {
      expect(
        _next(const IntroState(), justTookFallDamage: true),
        IntroTip.fallDamage,
      );
    });

    test('wins over a simultaneous first-ore event', () {
      expect(
        _next(const IntroState(),
            justTookFallDamage: true, justMinedFirstOre: true),
        IntroTip.fallDamage,
      );
    });

    test('does not re-fire once shown', () {
      const state = IntroState(shown: {IntroTip.fallDamage});
      expect(_next(state, justTookFallDamage: true), isNull);
    });
  });

  group('IntroState reducers', () {
    test('markShown adds the tip and lowers tipVisible', () {
      final s = const IntroState(tipVisible: true).markShown(IntroTip.firstOre);
      expect(s.shown, contains(IntroTip.firstOre));
      expect(s.tipVisible, isFalse);
      expect(s.completed, isFalse);
    });

    test('showing all five tips sets completed', () {
      var s = const IntroState();
      for (final tip in IntroTip.values) {
        expect(s.completed, isFalse);
        s = s.markShown(tip);
      }
      expect(s.completed, isTrue);
      expect(s.shown.length, IntroTip.values.length);
    });

    test('markInputReceived consumes the movement tip so it never renders', () {
      final s = const IntroState().markInputReceived();
      expect(s.shown, contains(IntroTip.movement));
      // Even after the idle threshold, a player who already gave input gets
      // no movement tip.
      expect(_next(s, secondsSinceInput: 10), isNull);
    });

    test('markInputReceived is a no-op once movement is shown', () {
      const s = IntroState(shown: {IntroTip.movement, IntroTip.firstOre});
      final after = s.markInputReceived();
      expect(after.shown, s.shown);
    });

    test('markSkipped sets skipped and lowers tipVisible', () {
      final s = const IntroState(tipVisible: true).markSkipped();
      expect(s.skipped, isTrue);
      expect(s.tipVisible, isFalse);
    });
  });

  group('a plausible first run, event by event', () {
    test('idle → drill → ore → deep → low fuel, tips fire in real order', () {
      var s = const IntroState();

      // Sits still at the surface: movement tip becomes eligible, then shows.
      expect(_next(s, secondsSinceInput: 2), IntroTip.movement);
      s = s.markTipVisible();
      expect(_next(s, secondsSinceInput: 2), isNull); // card is up
      s = s.markShown(IntroTip.movement);

      // Mines first ore.
      expect(_next(s, justMinedFirstOre: true), IntroTip.firstOre);
      s = s.markShown(IntroTip.firstOre);

      // Digs deep, cargo fills.
      expect(_next(s, atSurface: false, cargoFraction: 0.85),
          IntroTip.cargoFull);
      s = s.markShown(IntroTip.cargoFull);

      // Fuel runs low on the way back.
      expect(_next(s, atSurface: false, fuelFraction: 0.2), IntroTip.lowFuel);
      s = s.markShown(IntroTip.lowFuel);

      // Later run: takes a bad fall.
      expect(_next(s, justTookFallDamage: true), IntroTip.fallDamage);
      s = s.markShown(IntroTip.fallDamage);

      expect(s.completed, isTrue);
      expect(_next(s, justTookFallDamage: true), isNull);
    });
  });
}
