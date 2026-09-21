# Rules screens: overview vs detail

Written 2026-09-13, as a handoff note for a session restart — the split
below is implemented, tested, and green, but **not yet committed**.

## What changed

One `RulesScreen` used to show all 4 modes' rules back-to-back and was
pushed unmodified from the main menu and from every setup screen's info
icon. Split into two:

- **`lib/app/screens/rules_screen.dart`** — now the main-menu entry point,
  an overview/picker: one row per mode, icon + one-line tagline, nothing
  else. Tapping a row drills into that mode's detail. Name/type kept as
  `RulesScreen` deliberately, so `main_menu_screen.dart`'s import and push
  site needed no change.
- **`lib/app/screens/rules_detail_screen.dart`** (new) — `RulesDetailScreen
  ({required RulesTopic topic})`, the full rules text for exactly one mode.
  Reached two ways: a setup screen's `RulesButton` (already knows its own
  mode), and a tap on an overview row. Same screen, same content, just two
  entry points.
- **`lib/app/rules_topic.dart`** (new) — `enum RulesTopic { x01,
  aroundTheClock, bulling, training }` plus an extension mapping each value
  to an icon, a title, and a one-line overview tagline. Deliberately not
  `domain/game_mode.dart`'s `GameMode`: that enum is switched over
  exhaustively assuming an engine/resumable-leg/stats-calculator exist
  (`select_game_mode_screen.dart`, `main_menu_screen.dart`), and training
  has none of those. `RulesTopic` also carries `IconData`, so it belongs in
  `lib/app/`, not `lib/domain/` (which must stay Flutter-free).
- **`lib/app/widgets/rules_button.dart`** — now takes `required
  RulesTopic topic` and pushes `RulesDetailScreen(topic: topic)`. All 4
  setup screens updated to pass their own topic
  (`x01_setup_screen.dart` → `RulesTopic.x01`, etc).
- **8 new l10n keys** in `app_en.arb`/`app_de.arb` (4 detail-screen titles
  `rules<Mode>Title`, 4 overview taglines `rules<Mode>Overview`), generated
  into `app_localizations*.dart` via `flutter gen-l10n`. No existing key
  renamed — the original `rules<Mode><Section>` body-copy keys are unchanged
  and now consumed only by `rules_detail_screen.dart`.

## Verified

`flutter analyze` clean. `flutter test` (568 tests) and
`dart test test/domain test/data` (269 tests) all pass, including new/
updated coverage:
- `test/app/rules_screen_test.dart` — overview shows taglines only (asserts
  old detail copy is `findsNothing`), tap navigates to the right
  `RulesDetailScreen`.
- `test/app/rules_detail_screen_test.dart` (new) — one test per
  `RulesTopic`, each asserting its own copy shows and every other mode's
  distinguishing text does not.
- `test/app/x01_setup_screen_test.dart` and
  `test/app/training_setup_screen_test.dart` — rules icon opens
  `RulesDetailScreen` scoped to that screen's own topic.

## Known gap — not done

**No widget test file exists for `AtcSetupScreen` or `BullingSetupScreen`**
(none existed before this change either — only `atc_controller_test.dart`/
`bulling_controller_test.dart`, which don't pump the setup screen). So their
`RulesButton(topic: RulesTopic.aroundTheClock/.bulling)` wiring is
type-checked and analyzed but not exercised by a widget test the way X01's
and Training's now are. Building `atc_setup_screen_test.dart` and
`bulling_setup_screen_test.dart` from scratch (harness: `FakeBoardSource` +
`AppDatabase` like `x01_setup_screen_test.dart`, or the simpler
`training_setup_screen_test.dart` shape if no persistence is involved) is
the natural next step, but was out of scope for this pass since it's new
test infrastructure, not a regression risk from this change.

## Still to do before this is “finished”

- **Commit.** Working tree has the full diff staged nowhere yet:
  `lib/app/rules_topic.dart`, `lib/app/screens/rules_detail_screen.dart`,
  and `test/app/rules_detail_screen_test.dart` are untracked; the setup
  screens, `rules_screen.dart`, `rules_button.dart`, both `.arb` files, both
  generated `app_localizations_*.dart`, and 3 test files are modified.
  One commit is fine — l10n regeneration is small and mechanical enough not
  to need its own.
- Run `graphify update .` after committing (per this repo's `CLAUDE.md`)
  and commit that diff separately, `chore: update graphify knowledge graph`.
- Optional: fill the ATC/Bulling setup-screen test gap above.
