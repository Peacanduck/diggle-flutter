/// intro_service.dart
/// Persistence + reactive state for the first-run coach marks.
///
/// Mirrors [VfxSettings]: a ChangeNotifier holding one persisted preference,
/// loaded once at startup and written through on every change. Player-scoped
/// the way [StreakSystem] scopes its keys, so a second account on the same
/// device gets its own intro.
///
/// The *when* lives in `intro_policy.dart` (pure, unit-tested). This class
/// owns storage, the currently-visible tip, and the game-facing hooks the
/// drill and game call. It never decides sequencing itself — it always asks
/// [nextTip].
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'intro_policy.dart';

class IntroService extends ChangeNotifier {
  static const _prefKey = 'diggle_intro_state_v1';

  IntroState _state = const IntroState();
  IntroTip? _currentTip;
  String? _playerId;

  /// Armed for the current session's first-run game. Set by [arm]; the intro
  /// produces no tips until it is armed, so a player who only browses the
  /// store never spends their intro (§8: first *new game*, not first launch).
  bool _armed = false;

  /// Whether the card now up is the first one shown this session — the skip
  /// control appears only there (§7).
  bool _showingFirstCard = true;

  /// The tip whose card should be on screen, or null.
  IntroTip? get currentTip => _currentTip;

  /// Whether the visible card should offer *Skip tips*.
  bool get canSkip => _currentTip != null && _showingFirstCard;

  /// Live while the intro can still produce tips.
  bool get isActive => _armed && !_state.skipped && !_state.completed;

  String _scoped() => '${_prefKey}_${_playerId ?? 'default'}';

  /// Load persisted state. [playerHasHistory] grandfathers existing players
  /// out: a veteran (prior saves) meeting this feature for the first time —
  /// no stored state — is marked completed so they never get coach marks
  /// (§10). A brand-new player has no history and no stored state, so the
  /// intro stays available.
  Future<void> load({
    String? playerId,
    required bool playerHasHistory,
  }) async {
    _playerId = playerId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scoped());
    if (raw != null) {
      _state = _decode(raw) ?? const IntroState();
    } else if (playerHasHistory) {
      _state = const IntroState(completed: true);
      await _persist(); // make the grandfather decision stick
    } else {
      _state = const IntroState();
    }
    notifyListeners();
  }

  /// Arm for a first-run new game. No-op once the intro is skipped or
  /// completed, so this can be called unconditionally on every new game.
  void arm() {
    if (_state.skipped || _state.completed) return;
    _armed = true;
    _showingFirstCard = true;
  }

  /// Drive from the game loop with live readings. Shows the next eligible
  /// tip, if any. Momentary events (first ore, fall damage) are pushed via
  /// [notifyFirstOre] / [notifyFallDamage]; standing conditions (idle, cargo,
  /// fuel) come through here every frame.
  void evaluate({
    required bool atSurface,
    required double cargoFraction,
    required double fuelFraction,
    required double secondsSinceInput,
    bool justMinedFirstOre = false,
    bool justTookFallDamage = false,
  }) {
    if (!isActive) return;
    if (_currentTip != null) return; // one card at a time

    final tip = nextTip(
      state: _state,
      atSurface: atSurface,
      cargoFraction: cargoFraction,
      fuelFraction: fuelFraction,
      justMinedFirstOre: justMinedFirstOre,
      justTookFallDamage: justTookFallDamage,
      secondsSinceInput: secondsSinceInput,
    );
    if (tip != null) {
      _currentTip = tip;
      _state = _state.markTipVisible();
      notifyListeners();
    }
  }

  /// The player provided directional input. Consumes the movement tip so a
  /// player who drilled immediately never gets it, and clears its card if it
  /// happened to be up.
  void onPlayerInput() {
    if (!isActive) return;
    if (_state.shown.contains(IntroTip.movement)) return;
    _state = _state.markInputReceived();
    if (_currentTip == IntroTip.movement) _currentTip = null;
    _persist();
    notifyListeners();
  }

  /// Dismiss the visible tip (tap-anywhere or timeout). Marks it shown.
  void dismissCurrentTip() {
    final tip = _currentTip;
    if (tip == null) return;
    _currentTip = null;
    _showingFirstCard = false;
    _state = _state.markShown(tip);
    _persist();
    notifyListeners();
  }

  /// *Skip tips* — no tip ever shows again for this player.
  void skip() {
    _currentTip = null;
    _state = _state.markSkipped();
    _persist();
    notifyListeners();
  }

  // ── Persistence ────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scoped(), _encode(_state));
  }

  /// Only the durable fields persist. A card being up ([tipVisible]) and the
  /// live [currentTip] are session state and must not survive a restart.
  static String _encode(IntroState s) => jsonEncode({
        'skipped': s.skipped,
        'completed': s.completed,
        'shown': s.shown.map((t) => t.name).toList(),
      });

  static IntroState? _decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final shown = <IntroTip>{};
      for (final name in (map['shown'] as List? ?? const [])) {
        for (final tip in IntroTip.values) {
          if (tip.name == name) {
            shown.add(tip);
            break;
          }
        }
      }
      return IntroState(
        skipped: map['skipped'] as bool? ?? false,
        completed: map['completed'] as bool? ?? false,
        shown: shown,
      );
    } catch (_) {
      return null; // corrupt — fall back to a fresh state
    }
  }
}
