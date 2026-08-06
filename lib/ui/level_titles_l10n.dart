/// level_titles_l10n.dart
/// Maps the stable [LevelTitles] ids stored in LevelRewardTable to their
/// localized display names.
///
/// The ids live in the game layer (which has no BuildContext); the
/// mapping lives here so a saved or compared title never depends on the
/// active locale.

import '../game/systems/level_rewards.dart';
import '../l10n/app_localizations.dart';

String localizedLevelTitle(AppLocalizations l10n, String titleId) {
  switch (titleId) {
    case LevelTitles.prospector:
      return l10n.titleProspector;
    case LevelTitles.excavator:
      return l10n.titleExcavator;
    case LevelTitles.demolitionist:
      return l10n.titleDemolitionist;
    case LevelTitles.deepMiner:
      return l10n.titleDeepMiner;
    case LevelTitles.voidwalker:
      return l10n.titleVoidwalker;
    case LevelTitles.coreBreaker:
      return l10n.titleCoreBreaker;
    case LevelTitles.diggleLegend:
      return l10n.titleDiggleLegend;
  }
  // Unknown id (e.g. a save from a newer build) — show it verbatim
  // rather than dropping the announcement.
  return titleId;
}
