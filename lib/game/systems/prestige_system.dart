/// prestige_system.dart
/// "Corporate Contracts" — the prestige/endgame loop.
///
/// Once a run hits the unlock bar (world floor or lifetime cash), the
/// player can sign a new contract: the world, cash, and ship upgrades
/// reset, but XP, points, NFTs, achievements, and the collection stay.
/// Each contract grants permanent perks and, from contract 2 onward,
/// "hardcore seams": richer ore and deadlier hazards via WorldConfig
/// multipliers.
///
/// Prestige is GLOBAL meta-progression (not per save slot) and persists
/// in SharedPreferences.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrestigeSystem extends ChangeNotifier {
  static const _prefsKey = 'diggle_prestige_level_v1';

  /// Unlock requirements (either one).
  static const int unlockDepth = 400;
  static const int unlockLifetimeCash = 500000;

  int _level = 0;
  bool _loaded = false;

  int get level => _level;
  bool get isLoaded => _loaded;

  // ── Perks ──────────────────────────────────────────────────────

  /// Permanent sell-price bonus: +5% per contract.
  double get sellMultiplier => 1.0 + 0.05 * _level;

  /// Starter cash for a fresh contract run.
  int get starterCash => 50 + 500 * _level;

  /// Ore spawn-weight multiplier for new worlds (hardcore seams).
  double get oreRichness => _level >= 2 ? 1.0 + 0.10 * (_level - 1) : 1.0;

  /// Hazard spawn-weight multiplier for new worlds (hardcore seams).
  double get hazardIntensity => _level >= 2 ? 1.0 + 0.15 * (_level - 1) : 1.0;

  /// Badge shown next to the player name.
  String get badge => _level <= 0 ? '' : '⭐' * _level.clamp(1, 5);

  // ── Eligibility ────────────────────────────────────────────────

  bool canPrestige({required int maxDepth, required int lifetimeCash}) {
    return maxDepth >= unlockDepth || lifetimeCash >= unlockLifetimeCash;
  }

  /// Sign the next contract. Caller is responsible for resetting the
  /// run (world/cash/upgrades) — this only advances the meta level.
  Future<void> prestige() async {
    _level += 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, _level);
    notifyListeners();
    debugPrint('PrestigeSystem: contract $_level signed');
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _level = prefs.getInt(_prefsKey) ?? 0;
    _loaded = true;
    notifyListeners();
  }
}
