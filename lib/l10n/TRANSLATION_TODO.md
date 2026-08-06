# Translation TODO

47 keys were added for the v2 screens (Museum, Achievements, Leaderboard,
Hangar, Quests) plus the prestige dialog and level titles. Every locale
already **has** these keys so nothing falls back at runtime — but in
`app_es/fr/ja/ko/ru/zh.arb` the values are still the **English text**,
sitting there as placeholders for a translator.

Everything else in those files is genuinely translated. These 47 are the
outstanding work:

```
menuWeeklyChallenge      menuLeaderboard          menuHangar
museumTitle              achievementsTab
leaderboardHeading       leaderboardEmpty
hangarHeading            hangarMachineCount       hangarSeekerVerified
hangarSeekerBlurb        hangarSealedCrate        hangarSealedBlurb
hangarEquipped
quantity                 airdrop
questsWeeklyTab          questsWeeklyInfo         questsNotEnoughPoints
questJoinDiscordServer   questCheckingMembership  questVerifyMembership
questDiscordHint         questPostOnX             questTweetHint
questDiscordUnavailable  questDiscordOpenFailed   questDiscordVerified
questDiscordVerifyFailed
signNewContract          corporateContract        prestigeDialogBody
prestigeHardcoreLine     notYet                   signContract
recoveryFailedPoints     emergencyRecoveryCost    emergencyRecoveryNeed
keepsCargo
titleUnlocked            titleProspector          titleExcavator
titleDemolitionist       titleDeepMiner           titleVoidwalker
titleCoreBreaker         titleDiggleLegend
```

## Notes for whoever translates these

- **Placeholders must survive.** `{count}`, `{cost}`, `{level}`,
  `{title}` etc. are substituted at runtime — keep them verbatim, and
  keep `prestigeDialogBody`'s five (`level`, `sellBonus`, `startCash`,
  `hardcore`, `badge`).
- `prestigeHardcoreLine` is a single bullet spliced into
  `prestigeDialogBody` as `{hardcore}`; it must keep its trailing `\n`.
- **Do not translate** `Diggle` (`appTitle`) — it is the product name.
- Emoji in values (`🏆`, `🛠️`, `⭐`, `✅`) are part of the string; keep
  them where they are.
- Level titles are player ranks, not UI chrome; localize them as flavour
  names rather than literally.

## How to verify after editing

```bash
flutter gen-l10n
```

Then confirm every locale still has the same key set — a typo'd key is
silently a *new* key, not an edit:

```bash
flutter analyze lib/
```
