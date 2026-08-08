# Translations

**Done.** The 179 placeholder keys from the two l10n passes — UI chrome
(47) and the content catalogue (132) — are translated in `app_es`, `fr`,
`ja`, `ko`, `ru`, `zh`, plus the 7 item-description keys added while
fixing the extractor (see below), the 4 `biome*` keys, and the 5
`museum*Tab`/`leaderboard*Tab` keys. All seven locales carry the same 499
keys; nothing falls back at runtime.

The only values still identical to English are proper nouns and symbols
that should be: `appTitle`, `pyroLabs`, `version`, `nftTab`, `solTab`,
`devnet`, `mainnet`, `hp`, `xp`, `depthMeter`, `itemC4`, and the handful
of loanwords that genuinely coincide (`airdrop`/`menuHangar` in es+fr,
`itemDynamite`/`rarityRare`/`museumRecordsTab`/`leaderboardPointsTab` in
fr, `tileLava`/`biomePermafrost` in es).

## Two bugs fixed in the same pass

Both came from `tool/extract_content_catalogue.py`, so the corrections
are in the tool as well as in the seven arb files:

1. **Item keys held emoji.** The extractor scanned *every* `case X.y:
   return '…'` in `item_system.dart`, so `displayName`, `description` and
   `icon` all collapsed onto the same key and the icon won — the shop
   rendered "🧨" as the item's name, beside the icon. It now reads named
   getters only, `item*Desc` keys exist, and `localizedItemDescription`
   is wired into `shop_overlay`. `content_l10n_test.dart` pins item names
   to `displayName` so this cannot come back quietly.
2. **`achievementCash*Desc` shipped a visible backslash.** The Dart
   source escapes `\$`; arb has no dollar escape, so `clean()` now strips
   it. `"Earn \$1,000 lifetime"` → `"Earn $1,000 lifetime"`.

`gen_content_l10n.py` also carries `localizedRarity` now — it rewrites
`lib/ui/content_l10n.dart` wholesale, and a regen used to delete that
hand-written resolver.

## Conventions these translations follow

- **Placeholders survive verbatim.** `{count}`, `{cost}`, `{level}`,
  `{title}`; `prestigeDialogBody` keeps all five (`level`, `sellBonus`,
  `startCash`, `hardcore`, `badge`) and `prestigeHardcoreLine` keeps its
  trailing `\n`.
- **Currency position matches the locale's existing keys**: `${value}`
  prefix everywhere except fr, which suffixes (`{value}$`).
- **Thousands separators are localized** in the fixed-number strings:
  es `1.000`, fr/ru `1 000`, ja/ko/zh `1,000`.
- **Plural arms are per-locale.** ja/ko/zh use `other` alone, ru uses
  `one`/`few`/`other`, es/fr use `=1`/`other`.
- `Diggle` is the product name — never translated, including inside
  `titleDiggleLegend` and `achievementCash1m`.
- Emoji are part of the value; they stay in place.
- Level titles and achievement names are flavour, localized as ranks and
  jokes rather than literally. Achievement *descriptions* state the
  requirement plainly.
- Biome names are the canonical mid-sentence forms below, used inside
  `achievementDepth*Desc`. The `biome*` keys hold the same words cased
  for the museum header (see next section).

  | | Topsoil | Permafrost | Crystal Caverns | Magma Core |
  |---|---|---|---|---|
  | es | Capa Superficial | Permafrost | Cavernas de Cristal | Núcleo de Magma |
  | fr | Couche de Surface | Pergélisol | Cavernes de Cristal | Noyau de Magma |
  | ja | 表土層 | 永久凍土 | クリスタル洞窟 | マグマコア |
  | ko | 표토층 | 영구동토 | 수정 동굴 | 마그마 코어 |
  | ru | Верхний слой | Мерзлота | Кристальные пещеры | Магмовое ядро |
  | zh | 表土层 | 永久冻土 | 水晶洞窟 | 岩浆核心 |

## Casing lives in the arb, not in the widget

`biomeTopsoil`/`biomePermafrost`/`biomeCrystalCaverns`/`biomeMagmaCore`
store their values already upper-cased for Latin and Cyrillic and in
natural case for ja/ko/zh, and `collection_overlay.dart` renders them
as-is. It used to call `biomeName.toUpperCase()`, which is a no-op for
CJK and takes the choice away from the translator; the fallback argument
is still upper-cased so a biome with no key yet looks the same.

This matches every other heading key here — `museumTitle` is `"MUSEO"` /
`"МУЗЕЙ"` / `"博物館"`, not title case plus a `toUpperCase()`.

The same applies to the five tab labels: `museumArtifactsTab`,
`museumRecordsTab`, `leaderboardDepthTab`, `leaderboardPointsTab`,
`leaderboardWeeklyTab`. They are per-screen rather than shared, on
purpose:

- `museumRecordsTab` is **not** `achievementsTab` — that key is already
  the section heading *inside* the records tab, so sharing it would print
  the same word as the tab and again right under it.
- the `leaderboard*Tab` keys are **not** `pointsTab` / `points` /
  `statMaxDepth` — those are title-case labels on other screens (premium
  store tabs, stat cards), and since casing is per-value here one key
  cannot serve two tab bars with different looks.

`localizedBiomeName` is hand-maintained, because `Biome.name` /
`ArtifactDefinition.biomeName` are plain fields rather than catalogue
entries. It lives in `gen_content_l10n.py`'s tail block alongside
`localizedRarity` — putting it only in `content_l10n.dart` means the next
regen deletes it.

Reward `description` strings built in `lib/game/systems/` (e.g.
`'$biomeName collection complete!'`) are **not** UI — they are
points-ledger source labels and stay English.

## Tab labels have a width budget

The leaderboard's `TabBar` is fixed (not scrollable), so each of its three
labels gets roughly a third of the screen minus 32px of label padding —
about 88px at 360dp. A label with a space wraps to two lines and still
fits the 46px tab; `THIS WEEK` already does this in English. A single long
word has no break opportunity, so it is **clipped**, not wrapped.

That is why `leaderboardDepthTab` is metres rather than depth in es/fr/ru
(`METROS` / `MÈTRES` / `МЕТРЫ`): `PROFUNDIDAD` and `PROFONDEUR` are one
word and too wide. The rows under the tab read `N m`, so metres is what
the board ranks by. Swap in the literal word only if you also make the
`TabBar` scrollable.

The museum's two tabs have ~148px each and every locale fits on one line.

Note `flutter test` cannot measure this for you — the test environment
substitutes a fixed-width placeholder font, so a `TextPainter` there
reports roughly one em per glyph and overstates real Roboto widths by
~50%. Check tab labels on a device.

## Adding content later

New catalogue entries need keys or they silently render the English
fallback. The flow:

```bash
python tool/extract_content_catalogue.py
python tool/gen_content_l10n.py
flutter gen-l10n
```

The generator only *adds* missing keys, so it never clobbers a
translation — but it seeds new keys with English in every locale, which
is the placeholder state this file used to describe. `flutter test
test/content_l10n_test.dart` fails if a catalogue entry has no key.

Then confirm every locale still has the same key set — a typo'd key is
silently a *new* key, not an edit:

```bash
flutter analyze lib/
```
