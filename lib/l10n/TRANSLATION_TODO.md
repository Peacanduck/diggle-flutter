# Translation TODO

179 keys were added in two passes — **UI chrome** (47) and the **content
catalogue** (132). Every locale already **has** these keys so nothing
falls back at runtime, but in `app_es/fr/ja/ko/ru/zh.arb` the values are
still the **English text**, sitting there as placeholders for a
translator.

Everything else in those files is genuinely translated.

## Pass 2 — content catalogue (132 keys)

Generated, so they are listed by prefix rather than one by one:

| Prefix | Count | What |
|---|---|---|
| `artifact*` | 40 | 20 museum artifacts, name + description |
| `achievement*` | 54 | 27 achievements, name + description |
| `item*` | 21 | consumables and their shop descriptions |
| `tile*` | 20 | ore and terrain names |
| `rarity*` | 5 | Common … Legendary |
| `questUseExplosives*`, `questFindArtifact*`, `questOpenCrate*` | 6 | v2 quests |

These are **game content**, so translate for flavour, not literally —
artifact names and descriptions are meant to have character.

Do **not** rename the keys: they are generated from content ids by
`tool/gen_content_l10n.py`, and `test/content_l10n_test.dart` fails if a
catalogue entry loses its key.

## Pass 1 — UI chrome (47 keys)

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
