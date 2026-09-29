/// intro_coach_overlay.dart
/// The first-run coach-mark card + skip control.
///
/// A single dismissible card floating in the lower third, above the movement
/// controls and clear of the top fuel/hull gauges — the tip must never cover
/// the thing it is talking about. The game does NOT pause behind it: these
/// are coach marks, not modals (§7).
///
/// All sequencing lives in [IntroService]/`intro_policy.dart`; this widget
/// only renders whatever tip the service says is current and reports taps
/// back.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../game/diggle_game.dart';
import '../l10n/app_localizations.dart';
import '../services/intro_policy.dart';
import '../services/intro_service.dart';

class IntroCoachOverlay extends StatefulWidget {
  final DiggleGame game;

  const IntroCoachOverlay({super.key, required this.game});

  @override
  State<IntroCoachOverlay> createState() => _IntroCoachOverlayState();
}

class _IntroCoachOverlayState extends State<IntroCoachOverlay> {
  /// A tip dismisses itself after this long if the player doesn't tap it.
  static const _autoDismiss = Duration(seconds: 6);

  /// How long the post-skip confirmation lingers.
  static const _confirmLinger = Duration(milliseconds: 2500);

  IntroService? get _intro => widget.game.introService;

  IntroTip? _shownTip;
  Timer? _dismissTimer;
  Timer? _confirmTimer;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _intro?.addListener(_onIntroChanged);
    _shownTip = _intro?.currentTip;
    if (_shownTip != null) _restartDismissTimer();
  }

  @override
  void dispose() {
    _intro?.removeListener(_onIntroChanged);
    _dismissTimer?.cancel();
    _confirmTimer?.cancel();
    super.dispose();
  }

  void _onIntroChanged() {
    if (!mounted) return;
    final tip = _intro?.currentTip;
    if (tip != _shownTip) {
      _shownTip = tip;
      if (tip != null) _restartDismissTimer();
    }
    setState(() {});
  }

  void _restartDismissTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(_autoDismiss, () {
      _intro?.dismissCurrentTip();
    });
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    _intro?.dismissCurrentTip();
  }

  void _skip() {
    _dismissTimer?.cancel();
    _intro?.skip();
    setState(() => _showConfirm = true);
    _confirmTimer?.cancel();
    _confirmTimer = Timer(_confirmLinger, () {
      if (mounted) setState(() => _showConfirm = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tip = _intro?.currentTip;

    final Widget content;
    if (_showConfirm) {
      content = _ConfirmToast(text: l10n.introSkipConfirm);
    } else if (tip != null) {
      final copy = _copyFor(l10n, tip);
      content = _TipCard(
        key: ValueKey(tip),
        title: copy.$1,
        body: copy.$2,
        canSkip: _intro?.canSkip ?? false,
        skipLabel: l10n.introSkip,
        onTap: _dismiss,
        onSkip: _skip,
      );
    } else {
      content = const SizedBox.shrink();
    }

    // Lower third, above the controls (bottom:30, ~120px tall) and well clear
    // of the top gauges. Only the card catches taps; the rest of the screen
    // stays live so the player keeps playing.
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 170, left: 16, right: 16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: content,
          ),
        ),
      ),
    );
  }

  /// (title, body) for a tip, resolved live so a mid-session locale change is
  /// picked up.
  (String, String) _copyFor(AppLocalizations l10n, IntroTip tip) {
    switch (tip) {
      case IntroTip.movement:
        return (l10n.introTipMovementTitle, l10n.introTipMovementBody);
      case IntroTip.firstOre:
        return (l10n.introTipFirstOreTitle, l10n.introTipFirstOreBody);
      case IntroTip.cargoFull:
        return (l10n.introTipCargoFullTitle, l10n.introTipCargoFullBody);
      case IntroTip.lowFuel:
        return (l10n.introTipLowFuelTitle, l10n.introTipLowFuelBody);
      case IntroTip.fallDamage:
        return (l10n.introTipFallDamageTitle, l10n.introTipFallDamageBody);
    }
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String body;
  final bool canSkip;
  final String skipLabel;
  final VoidCallback onTap;
  final VoidCallback onSkip;

  const _TipCard({
    super.key,
    required this.title,
    required this.body,
    required this.canSkip,
    required this.skipLabel,
    required this.onTap,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xF21a1a2e),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber.shade600, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (canSkip)
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      skipLabel,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                // Subtle, wordless dismiss affordance — no English-only
                // string to leak past the localized copy. The card is
                // tappable and also auto-dismisses.
                Icon(Icons.touch_app,
                    color: Colors.white.withValues(alpha: 0.45), size: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmToast extends StatelessWidget {
  final String text;
  const _ConfirmToast({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
