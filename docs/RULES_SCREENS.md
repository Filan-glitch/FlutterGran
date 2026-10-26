# Rules section

The rules teach by showing: every rule with settings is a painted board you
flip between options on, every rule worth stopping on is a callout, and
every mode has a turn or two played out dart by dart. Copy is short and
structured - one sentence per option, not one paragraph per rule.

## Screens

- **`RulesScreen`** (`lib/app/screens/rules_screen.dart`) - the main menu's
  entry. Layout by device, via `isHeroDevice(context)` and `isDesktop`:
  - phone: a column of cards (glyph, name, tagline); a tap pushes
    `RulesDetailScreen`, the glyph flying into its header (`Hero`, tag
    `rulesGlyphTag`).
  - tablet: tall posters, all across when they fit and two rows when they
    do not, with the mode's numbers at the foot. Same tap, same flight.
    Five topics do not fit across a Tab S6 Lite, so it shows three over two.
  - desktop window with the hero treatment: master-detail - the cards as a
    rail, the selected mode's `RulesBody` in a pane beside it, switching in
    place. The rail scrolls once the cards outgrow a short window. Below `desktopHeroLayout` it falls back to the phone list.
- **`RulesDetailScreen(topic)`** - one mode's `RulesBody` under an `AppBar`.
  Pushed from the overview on phone/tablet and from each setup screen's
  `RulesButton`. `rulesContentWidth` widens its `CenteredContent` cap on hero
  devices so boards sit beside their options.

`RulesTopic` (`lib/app/rules_topic.dart`) is not `GameMode`: training has a
rules page but no engine. It carries the name (read from `gameModeRegistry`
for the playable modes), objective, tagline and facts (start scores, stops,
targets - read off the same domain constants the setup screens offer).

## Building blocks - `lib/app/widgets/rules/`

| Widget | Job |
| --- | --- |
| `RulesBody` | One topic's scrolling page. Sets things side by side once its own width passes 560 x text scale. |
| `RulesHero` | Glyph, name, objective, fact numerals. |
| `RuleExplorer<T>` | Options for one rule; tapping one relights the board. Stacked (`ChoiceRow` over the board) when narrow, board beside option tiles when wide. Keys `rule-explorer-<id>`, `rule-option-<id>-<value>`. |
| `RuleBoard` | Non-interactive `BoardWidget` lighting a `Set<Segment>` in `Palette.live` and dimming the rest (`BoardWidget.dimUnheated`); crossfades on change. |
| `RuleCallout` | Bust (doubleBed) or note (live) card with a numbered list. |
| `WorkedExample` | A turn as notation chips with the running figure under each and an outcome badge. |

`ModeGlyph` (`lib/app/widgets/mode_glyph.dart`) is shared with the
select-mode screen; a null topic is its "more modes coming" glyph.

## The rule this section must not break

**What a board lights comes from the engine's own predicates**, never a
hand-written list: `X01InRule.opens`, `X01OutRule.checksOut`,
`AtcStop.clears`. `test/app/rules_detail_screen_test.dart` asserts the lit
set equals the predicate's set for each option, so if a rule changes in the
domain, the picture changes with it. Worked examples are fixed data - check
them by hand if a rule they show changes.

## Tests

- `test/app/rules_screen_test.dart` - each device's overview layout, and an
  overflow sweep scrolling every page at phone, tablet and desktop sizes (the
  latter under `TargetPlatformVariant.only(TargetPlatform.windows)`),
  English and German.
- `test/app/rules_detail_screen_test.dart` - each topic's sections, explorer
  taps against the domain predicates, the match-format pips, Bulling's
  points table, Higher/Lower's out rules and worked examples.
