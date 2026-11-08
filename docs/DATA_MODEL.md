# Data model

Drift over SQLite, currently at **schema version 8**.
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
          └──< DartEvents >────┤
                               ├──── AtcGames      (Around the Clock legs)
                               └──── BullingGames  (Bulling legs)
```

### `Players`

| Column | Notes |
|---|---|
| `id` | autoincrement |
| `name` | 1–40 characters |
| `createdAt` | |

A player persists across games so their history means something.
Renaming (`GameRepository.renamePlayer`) touches only `name`. Deletion is
the one deliberate exception to "every dart ever thrown is stored":
`GameRepository.removePlayer` cascades a player's `DartEvents` and
`GameSeats` rows with them (in application code, not a foreign key - see
the doc comment there for why). The roster is not a place that should
ever refuse a player who wants gone, so a leg they shared with someone
else can be left with a hole - that other player's darts stay, replayed
one seat short - rather than the deletion being blocked or the whole leg
going with it.

### `Matches` — a run of x01 legs

| Column | Notes |
|---|---|
| `id` | autoincrement |
| `startScore` | the format, agreed before anyone threw |
| `inRule`, `outRule` | `X01InRule` / `X01OutRule`, stored by name: `straight`, `double` or `master` |
| `doubleOut` | **frozen legacy mirror** of `outRule` (`true` for double-out), written on every insert; nothing but the v8 migration reads it |
| `legsToPlay` | best of this many. `1` is a single leg |
| `gameMode` | stored by name, like `DartEvents.ring` |
| `startedAt`, `finishedAt` | `finishedAt` null while running |
| `winnerPlayerId` | null until decided; **cleared again if the deciding checkout is undone** |

Only x01 plays matches: Around the Clock, Bulling and Higher/Lower legs stand
on their own, so every match row is `x01`. The column is there so that if
another mode gains matches, its rows are never folded through the x01 engine;
`watchAllLegs` and `loadMatchLegs` filter on it.

The rules are repeated here rather than read off the first leg: the match owns
them, and every leg it spawns inherits them. Declared with
`@DataClassName('Match')` because drift would otherwise singularise `Matches`
to `Matche`.

### `Games` — one leg

| Column | Notes |
|---|---|
| `id` | autoincrement |
| `startScore` | **nullable**: x01 always writes it, the other modes leave it null |
| `inRule`, `outRule` | **nullable**, as on `Matches`; null for a non-x01 leg |
| `doubleOut` | **nullable** frozen legacy mirror of `outRule`, as on `Matches` |
| `matchId` | **nullable**, references `Matches` |
| `legNumber` | **nullable**, position in the match from zero |
| `gameMode` | stored by name: `x01`, `aroundTheClock`, `bulling` or `higherLower` |
| `startedAt`, `finishedAt`, `winnerPlayerId` | |

The x01 columns have defaults (`true`, `straight`, `double`), so a non-x01 leg
must write them as explicit nulls; `startAtcGame` and its siblings do.

Around the Clock and Bulling keep their own per-leg settings in a sibling
table keyed by `gameId`. Higher/Lower has none: every leg opens on the same two
values, so its seats are its whole config, and adding it needed no schema
change.

A "game" in the database is a **leg**. `matchId` and `legNumber` are nullable
because they have to be: every leg outside a match is a real leg with no match
around it, and nothing that reads legs — statistics, the resume offer, the
fold — may start depending on a match being there.

`legNumber` is also what pins **who threw first**: the starting seat is rebuilt
from it on replay (`legNumber % playerCount`). The alternation rule and this
column have to stay in step, which is why the rule is a free-standing tested
function rather than a line inside a widget.

### `AtcGames` — an Around the Clock leg's settings

| Column | Notes |
|---|---|
| `gameId` | primary key, cascade delete from `Games` |
| `variant` | `AtcVariant` by name: `anyPart`, `masters` or `doublesOnly` |

### `BullingGames` — a Bulling leg's settings

| Column | Notes |
|---|---|
| `gameId` | primary key, cascade delete from `Games` |
| `bullseyeValue` | `BullseyeValue` by name: the bullseye is worth `two` or `three` points |
| `target` | the score the leg is played to |

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
  reinterpreting existing history. Every enum column does the same.
- **`value` is denormalised** *only* so that rule-free aggregates — the accuracy
  heatmap — stay a single query. Nothing that applies rules reads it.

No column says what a dart was **aimed at**. Where the rules make it plain,
`inferAimRecords` (`lib/domain/training/aim_records.dart`) rebuilds it by
replaying legs, for the Weak-spot Trainer: it is derived, never stored.

## Migrations

`AppDatabase.migration`, in the same file:

| To | What it does |
|---|---|
| **v2** | creates `SegmentCalibrations` |
| **v3** | creates `Matches`, then **adds** `Games.matchId` and `Games.legNumber` |
| **v4** | **drops** `SegmentCalibrations` |
| **v5** | **adds** `Games.gameMode` and `Matches.gameMode`, backfilled to `x01` by the column default - true of every row written before it |
| **v6** | **rebuilds** `Games` with a `TableMigration` so `startScore` and `doubleOut` become nullable (SQLite cannot loosen `NOT NULL` in place), and creates `AtcGames` |
| **v7** | creates `BullingGames` |
| **v8** | **adds** `inRule`/`outRule` to `Matches` and `Games`, then backfills: the defaults (`straight` in, `double` out) for most rows, `out_rule = 'straight'` where `double_out = 0`, and both null where `double_out` is null (a non-x01 leg) |

`SegmentCalibrations` existed only for the hardware-day calibration screen;
the story is in [BOARD_PROTOCOL.md](BOARD_PROTOCOL.md#hardware-day).

The v3 migration **does not backfill**. A leg thrown before matches existed
belongs to no match, and inventing one for it would invent a result nobody
played for. Those legs keep working everywhere: statistics count them, the
resume offer finds them, `loadConfig` rebuilds them with `startingSeat = 0`.

Several steps guard on `from`: a table that an earlier step creates fresh (or
rebuilds) from the current class already has every current column, so adding
one again would be a duplicate. That is why v5 and v8 only `addColumn` to
`Matches` when `from >= 3`, and v8 only to `Games` when `from >= 6`.

### The `TableMigration` gotcha

drift's `TableMigration(table)` copies every column the *current* table class
has, assuming the on-disk table already has them all. When a later version adds
a column to that table, the earlier `TableMigration` step must declare it with
`newColumns: [table.newColumn]`, or a multi-version upgrade (v2 straight to v8)
crashes copying a column that does not exist yet at that point in the chain.
The v6 step declares `games.inRule` and `games.outRule` for exactly this reason.

### Migration tests

`test/app/migration_test.dart` freezes the historical `games`/`matches` shapes
as raw SQL, with an `AppDatabase` subclass pinned to each old version
(`_SchemaV2`, `_SchemaV4` to `_SchemaV7`), because the current table classes
can no longer produce them. Each group seeds rows, opens the database at the
current version and checks that:

- it reaches the current version, and a dropped table is not carried forward;
- an old leg still folds to exactly what was thrown, still resumes, and stays
  finished if it was;
- a match can be played on top of migrated history;
- `gameMode` backfills to `x01`, ids are not reused after the v6 rebuild, and
  v8's in/out backfill gets double-out, straight-out and non-x01 rows right.

## Reading it back

`GameRepository` is the only thing that talks to the database.

**Players**

| Method | Does |
|---|---|
| `watchPlayers()` / `allPlayers()` | the roster, by name |
| `addPlayer(name)` / `renamePlayer(id, name)` | |
| `removePlayer(id)` | deletes the player with their darts and seats |

**x01 legs and matches**

| Method | Does |
|---|---|
| `startGame(config, {matchId, legNumber})` | a leg and its seats |
| `finishGame(id, winner)` / `reopenGame(id)` | sets the result, or clears it when the winning dart is undone; used by every mode |
| `startMatch(config)` | a match and its first leg, in one transaction |
| `startNextLeg(...)` | leg *n* of a match, with the throw rotated |
| `finishMatch(id, winner)` / `reopenMatch(id)` | as for a leg |
| `loadConfig(gameId)` | the rules a leg was played under, or **null** if the leg or its seats are missing |
| `loadMatchConfig(matchId)` | the format, with seating taken from the first leg |
| `loadMatchLegs(matchId, beforeLegNumber:)` | the match's legs, replayed |
| `legWinners(matchId)` | winners of its decided legs |
| `watchAllLegs()` / `watchAllMatches()` | x01 streams behind the statistics screen |

**Darts, for every mode**

| Method | Does |
|---|---|
| `appendDart(...)` | one dart at the next ordinal |
| `truncateLog(gameId, ordinal)` | drops every dart from `ordinal` on: undo rewinds the log rather than recording a correction |
| `loadLog(gameId)` | every dart, in order |
| `loadGame(gameId)` | the raw `Games` row, read to switch on `gameMode` |
| `findResumableGameId()` / `watchResumableGameId()` | the newest unfinished leg with darts in it, of any mode |
| `segmentCounts(playerId)` | the heatmap aggregate — the one query that reads `value` |

**Per mode**

| Mode | Start | Config | Stream |
|---|---|---|---|
| Around the Clock | `startAtcGame` | `loadAtcGame`, `loadAtcConfig` | `watchAllAtcLegs` |
| Bulling | `startBullingGame` | `loadBullingGame`, `loadBullingConfig` | `watchAllBullingLegs` |
| Higher/Lower | `startHigherLowerGame` | `loadHigherLowerConfig` (from the seats) | `watchAllHigherLowerLegs` |

Each `watchAll*Legs` filters on `gameMode` and folds through its own mode's
reducer, so no row is ever replayed under rules it was not played by.

`watchAllMatches` joins to games rather than reading the matches table alone: a
stream over `select(matches)` is only invalidated by writes to `matches`, and a
match in progress never touches its own row, so the tally would not refresh as
legs were won. `watchResumableGameId` joins to darts for the same reason: the
first dart is what makes a leg worth resuming.

## Regenerating

`database.g.dart` is generated and committed. After changing any table:

```bash
dart run build_runner build --delete-conflicting-outputs
```

The full checklist for a schema change is in
[CONTRIBUTING.md](../CONTRIBUTING.md#add-a-database-column-or-table).
