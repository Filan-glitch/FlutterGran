# Data model

Drift over SQLite, currently at **schema version 4**.
Definitions: `lib/data/db/database.dart`. Queries: `lib/data/db/game_repository.dart`.

## The one idea

**Every dart ever thrown is stored raw, in throwing order, with no scoring
applied.** No remaining score, no turn total, no average is ever written down.
A game is replayed through the same fold that scored it live.

That is why there is no "score" column anywhere, and why the rules are not
restated in SQL. One implementation of the rules, in `lib/domain/`, used both
live and on replay — so a figure shown during play and the same figure shown a
month later cannot disagree.

## Tables

```
Players ──┬──< GameSeats >── Games ──> Matches
          │                    │
          └──< DartEvents >────┘
```

### `Players`

| Column | Notes |
|---|---|
| `id` | autoincrement |
| `name` | 1–40 characters |
| `createdAt` | |

A player persists across games so their history means something.

### `Matches` — a run of legs

| Column | Notes |
|---|---|
| `id` | autoincrement |
| `startScore`, `doubleOut` | the format, agreed before anyone threw |
| `legsToPlay` | best of this many. `1` is a single leg |
| `startedAt`, `finishedAt` | `finishedAt` null while running |
| `winnerPlayerId` | null until decided; **cleared again if the deciding checkout is undone** |

The rules are repeated here rather than read off the first leg: the match owns
them, and every leg it spawns inherits them. Declared with
`@DataClassName('Match')` because drift would otherwise singularise `Matches`
to `Matche`.

### `Games` — one leg

| Column | Notes |
|---|---|
| `id` | autoincrement |
| `startScore`, `doubleOut` | |
| `matchId` | **nullable**, references `Matches` |
| `legNumber` | **nullable**, position in the match from zero |
| `startedAt`, `finishedAt`, `winnerPlayerId` | |

A "game" in the database is a **leg**. `matchId` and `legNumber` are nullable
because they have to be: every leg stored before matches existed is a real leg
with no match around it, and nothing that reads legs — statistics, the resume
offer, the fold — may start depending on a match being there.

`legNumber` is also what pins **who threw first**: the starting seat is rebuilt
from it on replay (`legNumber % playerCount`). The alternation rule and this
column have to stay in step, which is why the rule is a free-standing tested
function rather than a line inside a widget.

### `GameSeats` — who sat where

| Column | Notes |
|---|---|
| `gameId` | cascade delete |
| `playerId` | |
| `seat` | throwing order, from zero |

Primary key `(gameId, seat)`.

### `DartEvents` — every dart

| Column | Notes |
|---|---|
| `id` | autoincrement |
| `gameId` | cascade delete |
| `ordinal` | position in the leg's dart log, from zero |
| `playerId` | |
| `number` | wedge number, 25 for a bull, **null for a miss** |
| `ring` | stored **by name**, not index |
| `value` | denormalised |
| `thrownAt` | |

Unique on `(gameId, ordinal)`, so a replayed or double-written dart cannot
duplicate itself.

Two deliberate choices:

- **`ring` is stored by name** so the enum can be reordered without
  reinterpreting existing history.
- **`value` is denormalised** *only* so that rule-free aggregates — the accuracy
  heatmap — stay a single query. Nothing that applies rules reads it.

## Migrations

`AppDatabase.migration`, in the same file:

| To | What it does |
|---|---|
| **v2** | creates `SegmentCalibrations` |
| **v3** | creates `Matches`, then **adds** `Games.matchId` and `Games.legNumber` |
| **v4** | **drops** `SegmentCalibrations` |

`SegmentCalibrations` recorded what a frame code was confirmed to mean on the
board it was verified against, with a `corrected` flag for rows that disagreed
with the shipped table — those became the codec's override layer, and the rest
were what the diagnostics screen's coverage checklist counted. Hardware day
(2026-09-04) found zero corrections against a real 132, so the table, the
override layer, and the screen around them are all gone; see
[BOARD_PROTOCOL.md](BOARD_PROTOCOL.md#the-segment-table-is-settled).

The v3 migration **does not backfill**. A leg thrown before matches existed
belongs to no match, and inventing one for it would invent a result nobody
played for. Those legs keep working everywhere: statistics count them, the
resume offer finds them, `loadConfig` rebuilds them with `startingSeat = 0`.

`test/app/migration_test.dart` runs v2 → v3 with rows already in the table and
then plays a match on the migrated database, so "old legs still work" is a test
rather than a hope.

## Reading it back

`GameRepository` is the only thing that talks to the database.

| Method | Returns |
|---|---|
| `loadConfig(gameId)` | the rules a leg was played under, or **null** if the leg or its seats are missing |
| `loadLog(gameId)` | every dart, in order |
| `loadMatchLegs(matchId, beforeLegNumber:)` | the match's legs, replayed |
| `loadMatchConfig(matchId)` | the format, with seating taken from the first leg |
| `watchAllLegs()` / `watchAllMatches()` | streams behind the statistics screen |
| `findResumableGameId()` | the unfinished leg to offer on the setup screen |
| `segmentCounts(playerId)` | the heatmap aggregate — the one query that reads `value` |

`watchAllMatches` joins to games rather than reading the matches table alone: a
stream over `select(matches)` is only invalidated by writes to `matches`, and a
match in progress never touches its own row, so the tally would not refresh as
legs were won.

## Regenerating

`database.g.dart` is generated. After changing any table:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Bump `schemaVersion` and add an `onUpgrade` branch in the same commit as the
table change — and add a migration test with rows already present.
