import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import 'package:diggle/ui/streak_glyph.dart';

void main() {
  group('StreakStage.forStreak', () {
    const jackpot = 7; // default ladder length

    test('early days are an ember', () {
      expect(StreakStage.forStreak(0, jackpot), StreakStage.ember);
      expect(StreakStage.forStreak(1, jackpot), StreakStage.ember);
      expect(StreakStage.forStreak(3, jackpot), StreakStage.ember);
    });

    test('mid streak is burning', () {
      expect(StreakStage.forStreak(4, jackpot), StreakStage.burning);
      expect(StreakStage.forStreak(6, jackpot), StreakStage.burning);
    });

    test('the jackpot rung and beyond is a blaze', () {
      expect(StreakStage.forStreak(7, jackpot), StreakStage.blaze);
      expect(StreakStage.forStreak(8, jackpot), StreakStage.blaze);
      expect(StreakStage.forStreak(365, jackpot), StreakStage.blaze);
    });

    test('thresholds follow a server-tuned ladder length', () {
      // A 10-rung ladder moves the boundaries with it.
      expect(StreakStage.forStreak(4, 10), StreakStage.ember);
      expect(StreakStage.forStreak(5, 10), StreakStage.burning);
      expect(StreakStage.forStreak(9, 10), StreakStage.burning);
      expect(StreakStage.forStreak(10, 10), StreakStage.blaze);
    });

    test('a degenerate ladder length does not throw', () {
      expect(StreakStage.forStreak(5, 0), StreakStage.ember);
      expect(StreakStage.forStreak(5, -1), StreakStage.ember);
    });
  });

  group('asset wiring', () {
    test('the generated animation is on disk', () {
      expect(File(StreakGlyph.assetKey).existsSync(), true,
          reason: '${StreakGlyph.assetKey} missing — run '
              'python tool/gen_streak_glyph.py');
    });

    test('the asset is declared in pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('assets/animations/'),
          reason: 'undeclared assets are absent at runtime');
    });
  });

  group('generated animation parses as real Lottie', () {
    // The whole point of the pure-Dart renderer: the composition can be
    // parsed here, so a malformed hand-authored animation fails in CI
    // instead of rendering as a blank box on a device.
    late LottieComposition composition;

    setUpAll(() async {
      final bytes = File(StreakGlyph.assetKey).readAsBytesSync();
      composition = await LottieComposition.fromBytes(bytes);
    });

    test('has the timeline the stages assume', () {
      expect(composition.startFrame, 0);
      // The parser trims a hundredth of a frame off the out point, so
      // this lands at 89.99 rather than a clean 90.
      expect(composition.endFrame, closeTo(90, 0.05));
      expect(composition.frameRate, 30);
      expect(composition.duration.inMilliseconds, closeTo(3000, 5));
    });

    test('has one layer per stage, and they actually drew', () {
      // A composition that parsed but produced no drawable content is
      // the exact failure that looks like "nothing is showing".
      expect(composition.layers.length, StreakStage.values.length);
      for (final layer in composition.layers) {
        expect(layer.shapes, isNotEmpty,
            reason: 'layer ${layer.name} has no shapes to draw');
      }
    });

    test('every stage segment lies inside the timeline', () {
      final lastFrame = composition.endFrame.ceil();
      for (final stage in StreakStage.values) {
        expect(stage.segment.first,
            greaterThanOrEqualTo(composition.startFrame.floor()));
        expect(stage.segment.last, lessThanOrEqualTo(lastFrame));
      }
      // Stages tile the timeline end to end, with no gap or overlap.
      final stages = StreakStage.values;
      for (var i = 1; i < stages.length; i++) {
        expect(stages[i].segment.first, stages[i - 1].segment.last);
      }
      expect(stages.first.segment.first, composition.startFrame.floor());
      expect(stages.last.segment.last, lastFrame);
    });
  });

  group('StreakGlyph widget', () {
    testWidgets('renders the animation once the composition loads',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StreakGlyph(streak: 7)),
      ));
      // Let the asset load and the controller start.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(LottieBuilder), findsOneWidget);
      await tester.pumpWidget(const SizedBox()); // stop the repeat
    });

    testWidgets('falls back to the stage emoji when disabled',
        (tester) async {
      StreakGlyph.debugDisableAnimation = true;
      addTearDown(() => StreakGlyph.debugDisableAnimation = false);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StreakGlyph(streak: 7)),
      ));
      await tester.pump();

      expect(find.text('🔥'), findsOneWidget);
      expect(find.byType(LottieBuilder), findsNothing);
    });

    testWidgets('the looping range follows a ladder that changed length',
        (tester) async {
      // Streak 5 of 7 rungs is mid-ladder; the same streak against a
      // 5-rung ladder is the jackpot. The playing range must follow,
      // even though the streak itself never changed.
      expect(StreakStage.forStreak(5, 7), StreakStage.burning);
      expect(StreakStage.forStreak(5, 5), StreakStage.blaze);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StreakGlyph(streak: 5, ladderLength: 7)),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final state = tester.state<StreakGlyphState>(find.byType(StreakGlyph));
      expect(state.playingStage, StreakStage.burning,
          reason: 'composition should have loaded and started a range');

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StreakGlyph(streak: 5, ladderLength: 5)),
      ));
      await tester.pump();

      expect(state.playingStage, StreakStage.blaze,
          reason: 'ladder shrank, so this streak is now the jackpot');

      await tester.pumpWidget(const SizedBox()); // stop the repeat
    });

    testWidgets('an early streak falls back to the calendar emoji',
        (tester) async {
      StreakGlyph.debugDisableAnimation = true;
      addTearDown(() => StreakGlyph.debugDisableAnimation = false);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: StreakGlyph(streak: 2)),
      ));
      await tester.pump();

      expect(find.text('📅'), findsOneWidget);
    });
  });
}

