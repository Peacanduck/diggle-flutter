/// vfx_settings.dart
/// Persists the player's visual-effect quality choice.
///
/// Mirrors [LocaleProvider]: a ChangeNotifier holding one preference, loaded
/// once at startup and written through on every change.
///
/// Usage:
///   `context.read<VfxSettings>().setQuality(VfxQuality.low)`
///
/// `GameScreen` applies the value to `DiggleGame.vfx` and keeps listening,
/// so a change made mid-session takes effect on the next emitted event.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/systems/vfx_queue.dart';

class VfxSettings extends ChangeNotifier {
  static const _prefKey = 'vfx_quality';

  VfxQuality _quality = VfxQuality.full;

  VfxQuality get quality => _quality;

  /// Initialize from the persisted preference. Call once at app startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored != null) {
      // Stored by NAME, not index — reordering the enum must not silently
      // change what an existing player's saved preference means.
      for (final value in VfxQuality.values) {
        if (value.name == stored) {
          _quality = value;
          break;
        }
      }
    }
    notifyListeners();
  }

  Future<void> setQuality(VfxQuality quality) async {
    if (quality == _quality) return;
    _quality = quality;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, quality.name);
  }
}
