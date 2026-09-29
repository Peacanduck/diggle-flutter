/// review_prompt_service.dart
/// Persistence + reactive state + the dApp Store deep link for the in-game
/// review prompt.
///
/// Mirrors [VfxSettings]/[LocaleProvider]: a ChangeNotifier holding persisted
/// state, loaded once at startup and written through on change. The *when*
/// lives in `review_prompt_policy.dart` (pure, unit-tested). This class owns
/// storage, the safe-moment check, and the `url_launcher` hop to the listing.
///
/// **Not `in_app_review`.** Diggle ships through the Solana dApp Store, not
/// Google Play, so this is a plain external `url_launcher` link (plan §1).
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'review_prompt_policy.dart';

class ReviewPromptService extends ChangeNotifier {
  static const _prefKey = 'diggle_review_prompt_v1';

  /// The dApp Store listing deep link. Opens the listing page (there is no
  /// documented deep link straight to a review form — plan §1).
  static const String storeListingUrl =
      'solanadappstore://details?id=com.example.diggle';

  ReviewPromptState _state = const ReviewPromptState();
  String? _playerId;

  ReviewPromptState get state => _state;

  String _scoped() => '${_prefKey}_${_playerId ?? 'default'}';

  Future<void> load({String? playerId}) async {
    _playerId = playerId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scoped());
    if (raw != null) {
      _state = _decode(raw) ?? const ReviewPromptState();
    }
    notifyListeners();
  }

  /// Record a milestone. Banks a pending prompt the first time this trigger
  /// fires; a no-op afterwards, so a player who prestiges twenty times is
  /// asked once. Safe to call from any trigger site (plan §5).
  Future<void> recordMilestone(ReviewTrigger trigger) async {
    final next = _state.recordTrigger(trigger);
    if (identical(next, _state)) return; // already fired — nothing banked
    _state = next;
    await _persist();
    notifyListeners();
  }

  /// Call on entry to a safe moment (surfaced, shop opened, menu resumed).
  /// Returns whether the caller should show the sheet now; when it returns
  /// true it has already marked the session so no second prompt appears
  /// (at most one per session). The caller owns actually presenting the
  /// sheet (a game overlay in-game, a modal bottom sheet on the menu).
  bool checkAtSafeMoment() {
    final show = shouldShowPrompt(
      state: _state,
      now: DateTime.now(),
      atSafeMoment: true,
    );
    if (!show) return false;
    // shownThisSession is session-only — not persisted (see [_encode]).
    _state = _state.markShownThisSession();
    return true;
  }

  /// *Rate* — open the listing. Sets [hasRated] on a successful launch (not on
  /// return; we can't observe whether they submitted). On failure — no dApp
  /// Store app (sideloaded/emulator) — leaves the milestone banked so it
  /// retries next session, and returns false so the sheet can say so (§7).
  Future<bool> rate() async {
    bool launched = false;
    try {
      launched = await launchUrl(
        Uri.parse(storeListingUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('ReviewPromptService: launch failed: $e');
      launched = false;
    }
    if (launched) {
      _state = _state.markRated();
      await _persist();
      notifyListeners();
    }
    return launched;
  }

  /// *Not now* — clear the pending milestone; suppressed for 30 days.
  Future<void> dismiss() async {
    _state = _state.markDismissed(DateTime.now());
    await _persist();
    notifyListeners();
  }

  // ── Persistence ────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scoped(), _encode(_state));
  }

  /// [ReviewPromptState.shownThisSession] is session state and is deliberately
  /// not persisted — otherwise a dismissal-free quit would block next
  /// session's prompt forever.
  static String _encode(ReviewPromptState s) => jsonEncode({
        'hasRated': s.hasRated,
        'firedTriggers': s.firedTriggers.map((t) => t.name).toList(),
        'dismissedAt': s.dismissedAt?.toIso8601String(),
        'pending': s.pending,
      });

  static ReviewPromptState? _decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final fired = <ReviewTrigger>{};
      for (final name in (map['firedTriggers'] as List? ?? const [])) {
        for (final t in ReviewTrigger.values) {
          if (t.name == name) {
            fired.add(t);
            break;
          }
        }
      }
      final dismissedRaw = map['dismissedAt'] as String?;
      return ReviewPromptState(
        hasRated: map['hasRated'] as bool? ?? false,
        firedTriggers: fired,
        dismissedAt:
            dismissedRaw == null ? null : DateTime.tryParse(dismissedRaw),
        pending: map['pending'] as bool? ?? false,
      );
    } catch (_) {
      return null; // corrupt — start fresh
    }
  }
}
