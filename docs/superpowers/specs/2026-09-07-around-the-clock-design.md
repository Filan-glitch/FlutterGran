# Around the Clock — design

Status: approved, ready for planning.

## Summary

A second game mode. Every player has a private track of 22 stops — the
numbers 1 through 20, in order, then the outer bull, then the bullseye —
and must hit each stop before advancing to the next. First to complete the
bullseye wins the leg. Three variants govern which ring counts as a hit on
a numbered wedge:

- **Any part** — inner single, outer single, double, or triple all count.
- **Masters** — double or triple only; a single does not advance.
- **Doubles only** — double only.

The two bull stops are unaffected by variant: each is a single physical
ring (outer bull has no double/triple ring to restrict; the bullseye *is*
the inner-bull ring), so any hit on the correct bull ring advances that
stop regardless of variant.

v1 is single-leg only — no best-of-N match wrapping, matching x01's
`MatchConfig`. Match support can be added later the same way it was added
to x01, without reshaping the engine.

## Rules, precisely

- A turn is 3 darts, same as x01 (`dartsPerTurn`, reused as-is).
- A dart advances a player's track by exactly one stop if it satisfies the
  *current* stop's rule; a dart's multiplier never skips more than one
  stop, even a triple on the currently-needed number.
- Advancing is cumulative within a turn: if the first dart clears stop 5,
  the second dart is now checked against stop 6.
- Winning fires the instant the bullseye stop is cleared. Darts thrown
  after that in the same turn do not count, mirroring `foldLeg`'s
  "darts logged after the leg is won cannot change anything."
- No bust concept exists in this mode — a dart either advances the track
  by one or does nothing.

## Domain (`lib/domain/atc/`)

- `AtcVariant` enum: `anyPart`, `masters`, `doublesOnly`.
- `AtcStop` — one of the 22 track positions. Represented as a small closed
  set (numbers 1–20, `bull`, `bullseye`), each knowing how to test a
  `Segment` against it for a given `AtcVariant`.
- `AtcConfig{playerIds, variant}` — the rules a leg is played under. No
  `startingSeat` yet; v1 always starts at seat 0, the same as any x01 leg
  outside a match.
- `AtcTurn` — mirrors x01's `Turn`: `playerId`, `darts`, `stopBefore`,
  `stopAfter`. No `busted` field — nothing in this mode busts.
- `AtcLegState` — mirrors `LegState`: the full dart log, each player's
  current stop index, current-turn darts, completed turns, `winnerId`.
  Constructed only by folding, exactly like `LegState`.
- `foldAroundTheClock(AtcConfig, List<ThrownDart>) -> AtcLegState` — the
  whole engine, structured like `foldLeg`: walk the log, advance or not,
  close a turn every 3 darts or on a win, rotate the seat.

`GameMode` gains `aroundTheClock`, added to `gameModeRegistry` with
`isAvailable: true`.

## Persistence

No changes to `Games`, `GameSeats`, or `DartEvents` — the raw log
(`gameId`, `ordinal`, `playerId`, `number`, `ring`, `value`) already
carries no scoring semantics, so it is mode-agnostic as-is.

New table, additive only:

```
class AtcGames extends Table {
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get variant => textEnum<AtcVariant>()();

  @override
  Set<Column<Object>> get primaryKey => {gameId};
}
```

Schema version bumps to 6, `onUpgrade` creates the table for `from < 6`.
`Games.startScore`/`doubleOut` are left untouched and unused for ATC
rows — no sentinel values written — since `AtcGames` is where this mode's
config actually lives, the same way `Matches`/`Games.gameMode` already
separates x01's rules from the generic leg row.

`GameRepository` gains, alongside the existing x01 methods rather than
inside them:

- `startAtcGame(AtcConfig) -> gameId` — inserts the `Games` row
  (`gameMode: aroundTheClock`) plus the `AtcGames` row plus seats, in one
  transaction, mirroring `startGame`.
- `loadAtcConfig(gameId) -> AtcConfig?` — rebuilds config from `AtcGames`
  + seats, mirroring `loadConfig`.
- `watchAllAtcLegs() -> Stream<List<AtcLegState>>` — mirrors
  `watchAllLegs`, filtered to `gameMode.equals('aroundTheClock')` and
  folded through `foldAroundTheClock`.

## Stats (`lib/domain/stats/atc_stats.dart`, `part of 'mode_stats.dart'`)

```
class AtcStats extends ModeStats {
  final int legsPlayed;
  final int legsWon;
  final int dartsThrown;
  final int qualifyingDarts;       // darts that advanced the track
  final int? fewestDartsToWin;
  final Map<AtcStop, ({int attempts, int hits})> perStop;
}
```

- `hitRate = qualifyingDarts / dartsThrown` (null when nothing thrown
  yet), same null-before-any-data convention as `X01Stats.average`.
- `perStop` attempts is incremented for every dart thrown while that stop
  was the player's current target, hits for the ones that cleared it —
  this is the "which numbers you struggle with" breakdown.

## UI

- `select_game_mode_screen.dart`: add a `GameModeDescriptor` tile to the
  registry, pointing at a new `AtcSetupScreen`. Icon TBD at
  implementation time (candidates: `Icons.timelapse`, `Icons.watch_later`).
- `AtcSetupScreen` — variant picker (3 choices) + roster picker, same tile
  idiom as `x01_setup_screen.dart`'s `_ScoreChoice`/`_tile`.
- `AtcGameScreen` + `AtcController`/providers — new files, not additions
  to `game_screen.dart`/`game_controller.dart`. Current stop rendered
  large and centered, the way remaining score is x01's headline number;
  turn ledger and dart slots reuse the existing `_TurnLedger`/`_DartSlot`
  idiom (extracted if it turns out cheap to share, duplicated if not —
  decided during implementation, not here). `DartKeypad` is reused
  unchanged; it already only emits `Segment`s.
- `stats_screen.dart`: extend the existing mode-aware switch to render
  `AtcStats` alongside `X01Stats`.

## Testing

- `test/domain/atc/` — the fold: every variant's ring rule, the bull to
  bullseye transition, multiple stops cleared in one turn, win detection,
  darts-after-win ignored. Pure Dart, no Flutter.
- `test/data/` — `startAtcGame`/`loadAtcConfig`/`watchAllAtcLegs`,
  migration from schema 5.
- `test/app/` — `AtcSetupScreen`, `AtcGameScreen` widget tests, stats
  screen rendering `AtcStats`.

## Out of scope for this pass

- Match/best-of-N support for Around the Clock.
- Sound/commentary cues specific to this mode.
- A shared abstraction over `LegState`/`AtcLegState` — revisit only if a
  third mode makes the duplication actually hurt.
