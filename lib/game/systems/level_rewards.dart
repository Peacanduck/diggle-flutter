/// level_rewards.dart
/// Rewards granted on level-up, beyond the base bonus points.
///
/// Replaces the old "levels only give points" design: key levels grant
/// consumable items and titles so the 25-level ladder has landmarks.
/// DiggleGame applies item grants via ItemSystem when XPPointsSystem
/// fires its onLevelUp callback.

import 'item_system.dart';

/// Stable ids for level titles. The display name is localized at
/// render time (see LevelTitles in the UI layer) so the id can be
/// stored and compared without depending on the active locale.
class LevelTitles {
  static const prospector = 'prospector';
  static const excavator = 'excavator';
  static const demolitionist = 'demolitionist';
  static const deepMiner = 'deepMiner';
  static const voidwalker = 'voidwalker';
  static const coreBreaker = 'coreBreaker';
  static const diggleLegend = 'diggleLegend';
}

class LevelReward {
  final Map<ItemType, int> items;

  /// A [LevelTitles] id, not display text.
  final String? title;

  const LevelReward({this.items = const {}, this.title});

  bool get isEmpty => items.isEmpty && title == null;
}

class LevelRewardTable {
  static const Map<int, LevelReward> rewards = {
    2: LevelReward(items: {ItemType.backupFuel: 1}),
    3: LevelReward(items: {ItemType.repairBot: 1}),
    5: LevelReward(items: {ItemType.dynamite: 2}, title: LevelTitles.prospector),
    7: LevelReward(items: {ItemType.backupFuel: 2, ItemType.repairBot: 1}),
    9: LevelReward(items: {ItemType.dynamite: 3}),
    10: LevelReward(items: {ItemType.repairBot: 2}, title: LevelTitles.excavator),
    12: LevelReward(items: {ItemType.c4: 1}, title: LevelTitles.demolitionist),
    14: LevelReward(items: {ItemType.dynamite: 3, ItemType.repairBot: 2}),
    15: LevelReward(items: {ItemType.c4: 2}, title: LevelTitles.deepMiner),
    17: LevelReward(items: {ItemType.backupFuel: 3, ItemType.c4: 1}),
    18: LevelReward(items: {ItemType.spaceRift: 1}, title: LevelTitles.voidwalker),
    20: LevelReward(
        items: {ItemType.c4: 3, ItemType.spaceRift: 1}, title: LevelTitles.coreBreaker),
    22: LevelReward(items: {ItemType.spaceRift: 1, ItemType.c4: 2}),
    25: LevelReward(
        items: {ItemType.spaceRift: 2, ItemType.c4: 5},
        title: LevelTitles.diggleLegend),
  };

  static LevelReward? forLevel(int level) => rewards[level];

}
