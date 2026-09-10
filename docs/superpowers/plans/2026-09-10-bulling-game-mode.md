# Bulling Game Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Bulling as a third game mode — every dart that isn't on a bull
scores nothing, the outer bull scores 1, the inner bull (bullseye) scores 2 or
3 depending on a per-leg choice, and the first player to reach or pass a
target score wins the leg instantly.

**Architecture:** A third self-contained mode, structured exactly like Around
the Clock (`lib/domain/atc/`): its own domain package
(`lib/domain/bulling/`) with a config, a leg state, and a pure fold function;
its own sibling table in the database (`BullingGames`, additive, schema
version 7); its own controller, setup screen, and game screen in `lib/app/`;
and its own stats type wired into the existing `ModeStats` sealed dispatch.
Nothing about x01 or Around the Clock changes shape — every touch point that
already switches on `GameMode` (the registry, `computePlayerStats`,
`resumableLegProvider`, the main menu's resume banner, the stats screen)
gains one more case.

**Tech Stack:** Flutter, Riverpod (hand-written providers, no codegen —
`riverpod_generator` is incompatible with `drift_dev`'s analyzer pin, see
Global Constraints), drift (SQLite), `package:test` for the pure-Dart domain
suite.

**Spec:** None — no separate spec doc exists for this feature. Requirements
were pinned down by direct user Q&A in the session that produced this plan;
that decision record is reproduced in full under "Design, precisely" below,
in the same style as `docs/superpowers/specs/2026-09-07-around-the-clock-design.md`
(Around the Clock's own design doc, which this plan's structure mirrors
throughout — read it alongside this plan for the pattern being followed).

## Global Constraints

- `lib/domain/` is pure Dart and must never import `package:flutter`,
  `dart:ui`, or `package:drift/` — enforced mechanically by
  `test/domain/domain_purity_test.dart`. Every new file under
  `lib/domain/bulling/` and `lib/domain/stats/bulling_stats.dart` must stay
  clean of all three.
- No Riverpod codegen. Every provider in this plan is hand-written, matching
  every existing provider in `lib/app/providers.dart`.
- The app is read-only against the board — nothing in this plan writes to
  it. Bulling is scored from board events and the on-screen keypad exactly
  like x01 and Around the Clock.
- Run `dart run build_runner build --delete-conflicting-outputs` after any
  change to `lib/data/db/database.dart` (drift codegen for `database.g.dart`)
  before running any test that touches the database.
- `dart test test/domain test/data` runs the pure-Dart suite (no Flutter
  binding needed); `flutter test` runs everything, including
  `test/app`. `flutter analyze` must be clean before any task is considered
  done.

---

## Design, precisely

**Summary.** A second scoring rule set, alongside x01 and Around the Clock.
Only the two bull rings score: the outer bull is worth 1 point, the inner
bull (the bullseye) is worth 2 or 3 points depending on a choice made at
setup and fixed for the whole leg. Every other segment — every numbered
wedge, at any ring — scores 0, the same as a miss. A turn is 3 darts, same as
every other mode (`dartsPerTurn`, reused as-is). The leg is a race: whoever's
running total first reaches or passes a target score (also chosen at setup)
wins, the instant it happens — darts thrown later in that same turn do not
count, mirroring Around the Clock's "darts logged after the leg is won
cannot change anything." There is no bust concept, the same as Around the
Clock: a dart either adds points or adds nothing. v1 is single-leg only, no
best-of-N match wrapping, matching both x01's `MatchConfig` and Around the
Clock's own v1 scope.

**Decisions made by direct user Q&A** (recorded here since there is no
separate spec doc):
- Bullseye value (2 or 3 points) is a setup-time choice, fixed for the leg —
  the same shape as Around the Clock's `AtcVariant` picker.
- The leg ends the instant a player reaches or passes the target, mid-turn —
  darts thrown afterward in that turn are dropped, exactly like Around the
  Clock's bullseye-clears-and-wins rule.
- The target score is configurable at setup, offered as presets (21/31/41)
  with the engine accepting any value above 0 — the same shape as
  `GameConfig.offeredStartScores`.
- Turns are 3 darts, unconditionally — `dartsPerTurn` reused as-is, no new
  per-leg knob.

## Domain (`lib/domain/bulling/`)

- `BullseyeValue` enum: `two`, `three`, each with an `int get points`.
- `BullingConfig{playerIds, bullseyeValue, target}` — the rules a leg is
  played under. No `startingSeat`, matching `AtcConfig`: v1 always starts at
  seat 0.
- `BullingTurn` — mirrors `AtcTurn`: `playerId`, `darts`, `scoreBefore`,
  `scoreAfter`. No `busted` field — nothing in this mode busts.
- `BullingLegState` — mirrors `AtcLegState`: the full dart log, each
  player's running score, current-turn darts, completed turns, `winnerId`.
  Constructed only by folding.
- `pointsFor(Segment?, BullseyeValue) -> int` — 1 for the outer bull, the
  bullseye value's points for the inner bull, 0 for anything else including
  a miss. Exported so `computeBullingStats` re-derives the same figure per
  dart rather than trusting a running total.
- `foldBulling(BullingConfig, List<ThrownDart>) -> BullingLegState` — the
  whole engine, structured like `foldAroundTheClock`: walk the log, add
  points, close a turn every 3 darts or the instant the target is reached or
  passed, rotate the seat.

`GameMode` gains `bulling`, added to `gameModeRegistry` with
`isAvailable: true`.

## Persistence

No changes to `Games`, `GameSeats`, or `DartEvents`. New table, additive
only:

```dart
class BullingGames extends Table {
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get bullseyeValue => textEnum<BullseyeValue>()();
  IntColumn get target => integer()();

  @override
  Set<Column<Object>> get primaryKey => {gameId};
}
```

Schema version bumps to 7, `onUpgrade` creates the table for `from < 7`.
`Games.startScore`/`doubleOut` are left untouched and unused for Bulling
rows, the same as Around the Clock.

`GameRepository` gains, alongside the x01 and Around the Clock methods:

- `startBullingGame(BullingConfig) -> gameId`
- `loadBullingConfig(gameId) -> BullingConfig?`
- `watchAllBullingLegs() -> Stream<List<BullingLegState>>`

## Stats (`lib/domain/stats/bulling_stats.dart`, `part of 'mode_stats.dart'`)

```dart
class BullingStats extends ModeStats {
  final int legsPlayed;
  final int legsWon;
  final int dartsThrown;
  final int scoringDarts;   // darts that landed on either bull ring
  final int pointsScored;
  final int outerBullHits;
  final int innerBullHits;
  final int? fewestDartsToWin;
}
```

- `hitRate = scoringDarts / dartsThrown` (null before anything thrown), same
  null-before-any-data convention as `AtcStats.hitRate`.
- `winRate = legsWon / legsPlayed`.

## UI

- `select_game_mode_screen.dart`: a `GameModeDescriptor` tile pointing at a
  new `BullingSetupScreen`, icon `Icons.gps_fixed`.
- `BullingSetupScreen` — bullseye-value picker (2 choices) + target picker
  (offered presets) + roster picker, same tile idiom as
  `atc_setup_screen.dart`.
- `BullingGameScreen` + `BullingController`/providers — new files, mirroring
  `AtcGameScreen`/`AtcController`'s shape exactly. The running score is
  rendered large and centered in place of Around the Clock's stop label;
  both bull segments are always highlighted on the keypad, since there is no
  per-player "current target" the way Around the Clock's track has one.
- `stats_screen.dart`: extend the existing mode-aware switch to render
  `BullingStats` alongside `X01Stats`/`AtcStats`.
- `main_menu_screen.dart`: `ResumableBullingLeg` case in the resume switch
  and the resume banner.

## Out of scope for this pass

- Match/best-of-N support for Bulling.
- Sound/commentary cues specific to this mode.
- A shared abstraction over `LegState`/`AtcLegState`/`BullingLegState` —
  three modes now share the same fold shape, but Around the Clock's own
  design doc already deferred this call to when it "actually hurts," and it
  still doesn't.
- Dedicated widget tests for `BullingSetupScreen`/`BullingGameScreen` beyond
  the one navigation assertion in `select_game_mode_screen_test.dart` —
  Around the Clock shipped with the same footprint (no
  `atc_setup_screen_test.dart`/`atc_game_screen_test.dart` exist today); the
  domain fold and the controller carry the real test weight.

---

## Task 1: `BullseyeValue` and `BullingConfig`

**Files:**
- Create: `lib/domain/bulling/bulling_variant.dart`
- Create: `lib/domain/bulling/bulling_config.dart`
- Test: `test/domain/bulling/bulling_config_test.dart`

**Interfaces:**
- Produces: `enum BullseyeValue { two, three }` with `int get points` (2 or
  3). `class BullingConfig({required List<int> playerIds, required
  BullseyeValue bullseyeValue, required int target})`, with
  `static const List<int> offeredTargets = [21, 31, 41]`.
- Consumes: `GameConfig.maxPlayers` from `lib/domain/x01/game_config.dart`
  (already exists).

- [ ] **Step 1: Write the failing test**

```dart
// test/domain/bulling/bulling_config_test.dart
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:test/test.dart';

void main() {
  test('stores the roster, bullseye value, and target', () {
    final config = BullingConfig(
      playerIds: [1, 2],
      bullseyeValue: BullseyeValue.three,
      target: 21,
    );
    expect(config.playerIds, [1, 2]);
    expect(config.bullseyeValue, BullseyeValue.three);
    expect(config.target, 21);
  });

  test('BullseyeValue.points reads as 2 or 3', () {
    expect(BullseyeValue.two.points, 2);
    expect(BullseyeValue.three.points, 3);
  });

  test('refuses an empty roster', () {
    expect(
      () => BullingConfig(
        playerIds: [],
        bullseyeValue: BullseyeValue.two,
        target: 21,
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('refuses more players than GameConfig.maxPlayers', () {
    final tooMany = [for (var i = 1; i <= GameConfig.maxPlayers + 1; i++) i];
    expect(
      () => BullingConfig(
        playerIds: tooMany,
        bullseyeValue: BullseyeValue.two,
        target: 21,
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('refuses a duplicate seat', () {
    expect(
      () => BullingConfig(
        playerIds: [1, 1],
        bullseyeValue: BullseyeValue.two,
        target: 21,
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('refuses a target of zero or below', () {
    expect(
      () => BullingConfig(
        playerIds: [1],
        bullseyeValue: BullseyeValue.two,
        target: 0,
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/domain/bulling/bulling_config_test.dart`
Expected: FAIL — `bulling_config.dart`/`bulling_variant.dart` do not exist
yet (import error).

- [ ] **Step 3: Write the minimal implementation**

```dart
// lib/domain/bulling/bulling_variant.dart
/// How many points the inner bull (the bullseye) is worth in Bulling.
///
/// The outer bull is always worth 1 point regardless of this — only the
/// bullseye's value is a per-leg choice.
enum BullseyeValue {
  /// The bullseye is worth 2 points.
  two,

  /// The bullseye is worth 3 points.
  three;

  /// Points a hit on the bullseye is worth under this value.
  int get points => switch (this) {
    BullseyeValue.two => 2,
    BullseyeValue.three => 3,
  };
}
```

```dart
// lib/domain/bulling/bulling_config.dart
import '../x01/game_config.dart';
import 'bulling_variant.dart';

/// The rules a Bulling leg is played under.
///
/// No `startingSeat`, unlike [GameConfig]: a leg always opens on the first
/// seat, since v1 has no match wrapping to rotate the lead across.
class BullingConfig {
  BullingConfig({
    required this.playerIds,
    required this.bullseyeValue,
    required this.target,
  }) : assert(
         playerIds.isNotEmpty && playerIds.length <= GameConfig.maxPlayers,
         'a leg needs 1 to ${GameConfig.maxPlayers} players',
       ),
       assert(
         playerIds.toSet().length == playerIds.length,
         'the same player cannot occupy two seats',
       ),
       assert(target > 0, 'target must be above 0');

  /// Target values offered in the UI. The engine accepts any value above 0.
  static const List<int> offeredTargets = [21, 31, 41];

  /// Seats in throwing order. Fixed for the whole leg.
  final List<int> playerIds;

  final BullseyeValue bullseyeValue;

  /// Points needed to win. A leg ends the instant a player reaches or
  /// passes this, mid-turn — darts thrown after that in the same turn do
  /// not count.
  final int target;
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/domain/bulling/bulling_config_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/domain/bulling/bulling_variant.dart lib/domain/bulling/bulling_config.dart test/domain/bulling/bulling_config_test.dart
git commit -m "feat(bulling): add BullseyeValue and BullingConfig"
```

---

## Task 2: `BullingLegState`, `BullingTurn`, and the `foldBulling` engine

**Files:**
- Create: `lib/domain/bulling/bulling_leg_state.dart`
- Create: `lib/domain/bulling/bulling_reducer.dart`
- Test: `test/domain/bulling/bulling_reducer_test.dart`

**Interfaces:**
- Consumes: `BullingConfig`, `BullseyeValue` (Task 1); `dartsPerTurn` from
  `lib/domain/x01/leg_state.dart`; `ThrownDart` from
  `lib/domain/x01/thrown_dart.dart`; `Segment`/`Ring` from
  `lib/domain/segment.dart`.
- Produces: `class BullingTurn {playerId, darts, scoreBefore, scoreAfter}`
  with `int get scored`. `class BullingLegState {config, darts, score,
  currentPlayerIndex, currentTurnDarts, turns, winnerId}` with
  `currentPlayerId`, `int scoreFor(int playerId)`, `dartsThrownThisTurn`,
  `dartsLeftThisTurn`, `isFinished`, `lastTurn`, `int dartsThrownBy(int
  playerId)`. `int pointsFor(Segment?, BullseyeValue)`.
  `BullingLegState foldBulling(BullingConfig, List<ThrownDart>)`.
  `BullingLegState initialBullingLegState(BullingConfig)`.

- [ ] **Step 1: Write the failing test**

```dart
// test/domain/bulling/bulling_reducer_test.dart
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_reducer.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart s(int n) => ThrownDart(Segment(n, Ring.outerSingle));
ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
const ThrownDart miss = ThrownDart.miss();
final ThrownDart sbull = ThrownDart(Segment.outerBull);
final ThrownDart dbull = ThrownDart(Segment.innerBull);

BullingConfig config({
  int players = 1,
  BullseyeValue bullseyeValue = BullseyeValue.two,
  int target = 21,
}) => BullingConfig(
  playerIds: [for (var i = 1; i <= players; i++) i],
  bullseyeValue: bullseyeValue,
  target: target,
);

void main() {
  group('opening state', () {
    test('everyone starts on zero with three darts', () {
      final state = initialBullingLegState(config(players: 3));
      expect(state.score, {1: 0, 2: 0, 3: 0});
      expect(state.currentPlayerId, 1);
      expect(state.dartsThrownThisTurn, 0);
      expect(state.dartsLeftThisTurn, 3);
      expect(state.isFinished, isFalse);
      expect(state.turns, isEmpty);
    });
  });

  group('pointsFor', () {
    test('the outer bull is worth 1 point regardless of bullseye value', () {
      expect(pointsFor(Segment.outerBull, BullseyeValue.two), 1);
      expect(pointsFor(Segment.outerBull, BullseyeValue.three), 1);
    });

    test('the inner bull is worth the bullseye value', () {
      expect(pointsFor(Segment.innerBull, BullseyeValue.two), 2);
      expect(pointsFor(Segment.innerBull, BullseyeValue.three), 3);
    });

    test('anything off a bull is worth nothing', () {
      expect(pointsFor(const Segment(20, Ring.triple), BullseyeValue.three), 0);
      expect(pointsFor(const Segment(1, Ring.doubleRing), BullseyeValue.three), 0);
      expect(pointsFor(null, BullseyeValue.three), 0);
    });
  });

  group('scoring darts', () {
    test('an outer bull adds 1', () {
      final state = foldBulling(config(players: 2), [sbull]);
      expect(state.score[1], 1);
    });

    test('an inner bull adds the bullseye value', () {
      final state = foldBulling(
        config(players: 2, bullseyeValue: BullseyeValue.three),
        [dbull],
      );
      expect(state.score[1], 3);
    });

    test('a numbered wedge adds nothing', () {
      final state = foldBulling(config(players: 2), [t(20)]);
      expect(state.score[1], 0);
    });

    test('a miss adds nothing', () {
      final state = foldBulling(config(players: 2), [miss]);
      expect(state.score[1], 0);
    });

    test('points accumulate across darts in a turn', () {
      final state = foldBulling(config(players: 2), [sbull, sbull, s(5)]);
      expect(state.score[1], 2);
    });
  });

  group('winning', () {
    test('landing exactly on the target wins', () {
      final state = foldBulling(
        config(target: 2, bullseyeValue: BullseyeValue.two),
        [dbull],
      );
      expect(state.winnerId, 1);
      expect(state.isFinished, isTrue);
    });

    test('passing the target also wins', () {
      final state = foldBulling(
        config(target: 2, bullseyeValue: BullseyeValue.three),
        [dbull],
      );
      expect(state.winnerId, 1, reason: '3 points passes a target of 2');
    });

    test('darts logged after the win cannot change the result', () {
      final state = foldBulling(
        config(target: 1),
        [sbull, sbull, sbull],
      );
      expect(state.winnerId, 1);
      expect(
        state.turns.single.darts,
        hasLength(1),
        reason: 'the winning dart alone closes the turn',
      );
      expect(state.score[1], 1);
    });
  });

  group('turns', () {
    test('a turn always closes after three darts, scoring or not', () {
      final state = foldBulling(config(players: 2, target: 99), [
        sbull,
        miss,
        miss,
      ]);
      expect(state.turns, hasLength(1));
      expect(state.currentPlayerId, 2);
    });

    test('turns hand over between players', () {
      final state = foldBulling(config(players: 2, target: 99), [
        sbull, miss, miss, // player 1's turn
        sbull, miss, miss, // player 2's turn
      ]);
      expect(state.turns, hasLength(2));
      expect(state.turns.map((turn) => turn.playerId), [1, 2]);
      expect(state.currentPlayerId, 1);
    });
  });

  group('undo, by folding a shorter log', () {
    final log = [sbull, sbull, miss, sbull];

    test('the full log has handed over and player 2 has thrown once', () {
      final state = foldBulling(config(players: 2, target: 99), log);
      expect(state.currentPlayerId, 2);
      expect(state.dartsThrownThisTurn, 1);
      expect(state.score[2], 1);
    });

    test('dropping the last dart rewinds to the start of player 2s turn', () {
      final state = foldBulling(
        config(players: 2, target: 99),
        log.sublist(0, 3),
      );
      expect(state.currentPlayerId, 2);
      expect(state.dartsThrownThisTurn, 0);
      expect(state.score[2], 0);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/domain/bulling/bulling_reducer_test.dart`
Expected: FAIL — `bulling_leg_state.dart`/`bulling_reducer.dart` do not
exist yet.

- [ ] **Step 3: Write the minimal implementation**

```dart
// lib/domain/bulling/bulling_leg_state.dart
import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'bulling_config.dart';

/// A completed turn in a Bulling leg.
///
/// A turn ends after three darts or on the winning dart — so [darts] may
/// hold fewer than three. Unlike x01's `Turn`, nothing here busts: every
/// dart either scores its points or scores zero.
class BullingTurn {
  const BullingTurn({
    required this.playerId,
    required this.darts,
    required this.scoreBefore,
    required this.scoreAfter,
  });

  final int playerId;
  final List<ThrownDart> darts;

  /// Points the player had when the turn started.
  final int scoreBefore;

  /// Points the turn left them on. Never less than [scoreBefore] — nothing
  /// in this mode can take points away.
  final int scoreAfter;

  /// Points earned this turn.
  int get scored => scoreAfter - scoreBefore;

  @override
  String toString() =>
      'BullingTurn(p$playerId, ${darts.join(' ')}, '
      '$scoreBefore->$scoreAfter)';
}

/// Everything derivable about a Bulling leg, produced entirely by folding
/// the dart log — the same idea as x01's `LegState` and Around the Clock's
/// `AtcLegState`.
///
/// Never mutated and never constructed by hand outside the reducer: undoing
/// a dart means dropping it from the log and folding again.
class BullingLegState {
  const BullingLegState({
    required this.config,
    required this.darts,
    required this.score,
    required this.currentPlayerIndex,
    required this.currentTurnDarts,
    required this.turns,
    required this.winnerId,
  });

  final BullingConfig config;

  /// The full ordered log this state was folded from.
  final List<ThrownDart> darts;

  /// Points scored so far, per player id.
  final Map<int, int> score;

  /// Seat whose turn it is. Meaningless once the leg is finished.
  final int currentPlayerIndex;

  /// Darts thrown so far in the turn in progress.
  final List<ThrownDart> currentTurnDarts;

  /// Turns already completed, in order.
  final List<BullingTurn> turns;

  /// Winner, or null while the leg is still running.
  final int? winnerId;

  int get currentPlayerId => config.playerIds[currentPlayerIndex];

  /// Points a player has scored so far.
  int scoreFor(int playerId) => score[playerId]!;

  int get dartsThrownThisTurn => currentTurnDarts.length;

  int get dartsLeftThisTurn => dartsPerTurn - currentTurnDarts.length;

  bool get isFinished => winnerId != null;

  /// The most recently completed turn, or null before the first one ends.
  BullingTurn? get lastTurn => turns.isEmpty ? null : turns.last;

  /// Total darts a player has thrown in this leg, including the turn in
  /// progress.
  int dartsThrownBy(int playerId) {
    var total = 0;
    for (final turn in turns) {
      if (turn.playerId == playerId) total += turn.darts.length;
    }
    if (!isFinished && currentPlayerId == playerId) {
      total += currentTurnDarts.length;
    }
    return total;
  }
}
```

```dart
// lib/domain/bulling/bulling_reducer.dart
import '../segment.dart';
import '../x01/leg_state.dart' show dartsPerTurn;
import '../x01/thrown_dart.dart';
import 'bulling_config.dart';
import 'bulling_leg_state.dart';
import 'bulling_variant.dart';

/// Points a dart is worth in Bulling: 1 for the outer bull, [bullseyeValue]'s
/// points for the inner bull, 0 for anything else including a miss.
///
/// Exported for `computeBullingStats`, which re-derives the same figure per
/// dart to classify it rather than trusting a running total — the same
/// idiom `computeAtcStats` uses with `AtcStop.clears`.
int pointsFor(Segment? segment, BullseyeValue bullseyeValue) {
  if (segment == null) return 0;
  return switch (segment.ring) {
    Ring.outerBull => 1,
    Ring.innerBull => bullseyeValue.points,
    _ => 0,
  };
}

/// Replays a dart log under [config] and returns the resulting leg state.
///
/// This is the whole Bulling engine, structured like x01's `foldLeg` and
/// Around the Clock's `foldAroundTheClock`: a pure function of the log, so
/// undo is dropping the last dart and folding again.
BullingLegState foldBulling(BullingConfig config, List<ThrownDart> darts) {
  final score = <int, int>{for (final id in config.playerIds) id: 0};
  final turns = <BullingTurn>[];

  var playerIndex = 0;
  var turnDarts = <ThrownDart>[];
  var turnStart = 0;
  int? winnerId;

  for (final dart in darts) {
    // Darts logged after the leg is won cannot change anything.
    if (winnerId != null) break;

    final playerId = config.playerIds[playerIndex];
    turnDarts.add(dart);

    final total =
        score[playerId]! + pointsFor(dart.segment, config.bullseyeValue);
    score[playerId] = total;

    final won = total >= config.target;

    if (won || turnDarts.length == dartsPerTurn) {
      turns.add(
        BullingTurn(
          playerId: playerId,
          darts: List<ThrownDart>.unmodifiable(turnDarts),
          scoreBefore: turnStart,
          scoreAfter: total,
        ),
      );
      turnDarts = [];

      if (won) {
        winnerId = playerId;
      } else {
        playerIndex = (playerIndex + 1) % config.playerIds.length;
        turnStart = score[config.playerIds[playerIndex]]!;
      }
    }
  }

  return BullingLegState(
    config: config,
    darts: List<ThrownDart>.unmodifiable(darts),
    score: Map<int, int>.unmodifiable(score),
    currentPlayerIndex: playerIndex,
    currentTurnDarts: List<ThrownDart>.unmodifiable(turnDarts),
    turns: List<BullingTurn>.unmodifiable(turns),
    winnerId: winnerId,
  );
}

/// The state of a leg before anyone has thrown.
BullingLegState initialBullingLegState(BullingConfig config) =>
    foldBulling(config, const []);
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/domain/bulling/bulling_reducer_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/domain/bulling/bulling_leg_state.dart lib/domain/bulling/bulling_reducer.dart test/domain/bulling/bulling_reducer_test.dart
git commit -m "feat(bulling): add BullingLegState/BullingTurn and the foldBulling engine"
```

---

## Task 3: Register `GameMode.bulling`

**Files:**
- Modify: `lib/domain/game_mode.dart:6` (enum), `:30-43` (registry)
- Test: `test/domain/bulling/bulling_config_test.dart` is untouched; add
  the registry assertion inline in a new small test below.

**Interfaces:**
- Consumes: nothing new.
- Produces: `GameMode.bulling` exists; `gameModeRegistry` has 3 entries with
  `GameMode.bulling` marked `isAvailable: true`.

- [ ] **Step 1: Write the failing test**

```dart
// test/domain/game_mode_test.dart
import 'package:fluttergran/domain/game_mode.dart';
import 'package:test/test.dart';

void main() {
  test('the registry lists x01, Around the Clock, and Bulling, all available', () {
    expect(gameModeRegistry.map((mode) => mode.id), [
      GameMode.x01,
      GameMode.aroundTheClock,
      GameMode.bulling,
    ]);
    expect(gameModeRegistry.every((mode) => mode.isAvailable), isTrue);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/domain/game_mode_test.dart`
Expected: FAIL — `GameMode.bulling` does not exist (compile error) and the
registry only has 2 entries.

- [ ] **Step 3: Write the minimal implementation**

Edit `lib/domain/game_mode.dart`:

```dart
enum GameMode { x01, aroundTheClock, bulling }
```

```dart
const List<GameModeDescriptor> gameModeRegistry = [
  GameModeDescriptor(
    id: GameMode.x01,
    displayName: 'X01',
    tagline: '301 · 501 · 701',
    isAvailable: true,
  ),
  GameModeDescriptor(
    id: GameMode.aroundTheClock,
    displayName: 'AROUND THE CLOCK',
    tagline: '1-20 · bull · bullseye',
    isAvailable: true,
  ),
  GameModeDescriptor(
    id: GameMode.bulling,
    displayName: 'BULLING',
    tagline: 'bull · bullseye · race to target',
    isAvailable: true,
  ),
];
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/domain/game_mode_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/domain/game_mode.dart test/domain/game_mode_test.dart
git commit -m "feat(bulling): register GameMode.bulling in the mode registry"
```

---

## Task 4: `BullingStats` and `computeBullingStats`

**Files:**
- Create: `lib/domain/stats/bulling_stats.dart`
- Modify: `lib/domain/stats/mode_stats.dart:4-5` (add `part`)
- Modify: `lib/domain/stats/player_stats.dart:1-35` (imports,
  `computePlayerStats` gains `bullingLegs`), append `computeBullingStats`
  after `computeAtcStats`
- Test: `test/domain/bulling/bulling_stats_test.dart`

**Interfaces:**
- Consumes: `BullingConfig`, `BullingLegState`, `BullingTurn`, `pointsFor`
  (Task 2); `Ring` from `lib/domain/segment.dart`; `GameMode.bulling`
  (Task 3).
- Produces: `class BullingStats extends ModeStats {legsPlayed, legsWon,
  dartsThrown, scoringDarts, pointsScored, outerBullHits, innerBullHits,
  fewestDartsToWin}` with `double? get hitRate` and `double? get winRate`,
  plus `static const BullingStats empty`. `BullingStats
  computeBullingStats(int playerId, Iterable<BullingLegState> legs)`.
  `computePlayerStats(..., {Iterable<BullingLegState> bullingLegs = const
  []})` now also keys `GameMode.bulling`.

- [ ] **Step 1: Write the failing test**

```dart
// test/domain/bulling/bulling_stats_test.dart
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_leg_state.dart';
import 'package:fluttergran/domain/bulling/bulling_reducer.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/game_mode.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/stats/player_stats.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';
import 'package:test/test.dart';

ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));
const ThrownDart miss = ThrownDart.miss();
final ThrownDart sbull = ThrownDart(Segment.outerBull);
final ThrownDart dbull = ThrownDart(Segment.innerBull);

BullingLegState leg(
  List<ThrownDart> darts, {
  int players = 1,
  BullseyeValue bullseyeValue = BullseyeValue.two,
  int target = 21,
}) => foldBulling(
  BullingConfig(
    playerIds: [for (var i = 1; i <= players; i++) i],
    bullseyeValue: bullseyeValue,
    target: target,
  ),
  darts,
);

void main() {
  group('nothing thrown', () {
    test('reads as empty rather than zero', () {
      final stats = computeBullingStats(1, [leg(const [])]);
      expect(stats.legsPlayed, 1);
      expect(stats.dartsThrown, 0);
      expect(stats.hitRate, isNull);
      expect(stats.fewestDartsToWin, isNull);
    });

    test('a player who was not in the leg is skipped entirely', () {
      final stats = computeBullingStats(9, [leg([sbull])]);
      expect(stats.legsPlayed, 0);
      expect(stats.dartsThrown, 0);
    });
  });

  group('darts and hit rate', () {
    test('every dart thrown counts, scoring or not', () {
      final stats = computeBullingStats(1, [
        leg([sbull, miss, t(20)], target: 99),
      ]);
      expect(stats.dartsThrown, 3);
      expect(stats.scoringDarts, 1, reason: 'only the outer bull scored');
      expect(stats.hitRate, closeTo(1 / 3, 0.0001));
    });
  });

  group('point breakdown', () {
    test('counts outer and inner bull hits separately', () {
      final stats = computeBullingStats(1, [
        leg(
          [sbull, dbull, t(20)],
          target: 99,
          bullseyeValue: BullseyeValue.three,
        ),
      ]);
      expect(stats.outerBullHits, 1);
      expect(stats.innerBullHits, 1);
      expect(stats.pointsScored, 1 + 3);
    });
  });

  group('winning', () {
    test('records fewest darts to win', () {
      final stats = computeBullingStats(1, [
        leg([sbull, sbull], target: 2),
      ]);
      expect(stats.legsWon, 1);
      expect(stats.fewestDartsToWin, 2);
    });

    test('keeps the shorter of two winning legs', () {
      final stats = computeBullingStats(1, [
        leg([miss, sbull, sbull], target: 2),
        leg([sbull, sbull], target: 2),
      ]);
      expect(stats.legsWon, 2);
      expect(stats.fewestDartsToWin, 2, reason: 'the leg with no misses');
    });

    test('a leg not won leaves fewestDartsToWin alone', () {
      final stats = computeBullingStats(1, [
        leg([sbull], target: 99),
      ]);
      expect(stats.legsWon, 0);
      expect(stats.fewestDartsToWin, isNull);
    });
  });

  group('computePlayerStats, the mode dispatcher', () {
    test('keys all three modes even when only some have data', () {
      final stats = computePlayerStats(1);
      expect(
        stats.keys,
        containsAll([
          GameMode.x01,
          GameMode.aroundTheClock,
          GameMode.bulling,
        ]),
      );
    });

    test('keys Bulling legs under GameMode.bulling', () {
      final stats = computePlayerStats(
        1,
        bullingLegs: [
          leg([sbull, miss, miss], target: 99),
        ],
      );
      final bulling = stats[GameMode.bulling]! as BullingStats;
      expect(bulling.dartsThrown, 3);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/domain/bulling/bulling_stats_test.dart`
Expected: FAIL — `computeBullingStats`/`BullingStats` do not exist,
`computePlayerStats` has no `bullingLegs` parameter.

- [ ] **Step 3: Write the minimal implementation**

```dart
// lib/domain/stats/bulling_stats.dart
part of 'mode_stats.dart';

/// Everything the stats screens show for one player's Bulling record.
class BullingStats extends ModeStats {
  const BullingStats({
    required this.legsPlayed,
    required this.legsWon,
    required this.dartsThrown,
    required this.scoringDarts,
    required this.pointsScored,
    required this.outerBullHits,
    required this.innerBullHits,
    required this.fewestDartsToWin,
  });

  static const BullingStats empty = BullingStats(
    legsPlayed: 0,
    legsWon: 0,
    dartsThrown: 0,
    scoringDarts: 0,
    pointsScored: 0,
    outerBullHits: 0,
    innerBullHits: 0,
    fewestDartsToWin: null,
  );

  final int legsPlayed;
  final int legsWon;

  final int dartsThrown;

  /// Darts that landed on either bull ring — the only ones worth anything.
  final int scoringDarts;

  final int pointsScored;
  final int outerBullHits;
  final int innerBullHits;

  /// Fewest darts taken to reach the target and win a leg.
  final int? fewestDartsToWin;

  /// Share of darts that scored, 0 to 1.
  double? get hitRate =>
      dartsThrown == 0 ? null : scoringDarts / dartsThrown;

  /// Share of legs won, 0 to 1.
  double? get winRate => legsPlayed == 0 ? null : legsWon / legsPlayed;
}
```

Edit `lib/domain/stats/mode_stats.dart`, add the part directive next to the
existing ones:

```dart
part 'atc_stats.dart';
part 'bulling_stats.dart';
part 'x01_stats.dart';
```

Edit `lib/domain/stats/player_stats.dart`. Add imports:

```dart
import '../atc/atc_leg_state.dart';
import '../atc/atc_stop.dart';
import '../bulling/bulling_leg_state.dart';
import '../bulling/bulling_reducer.dart';
import '../game_mode.dart';
import '../segment.dart';
import '../x01/leg_state.dart';
import '../x01/match_state.dart';
import 'mode_stats.dart';
```

Update `computePlayerStats`:

```dart
Map<GameMode, ModeStats> computePlayerStats(
  int playerId, {
  Iterable<LegState> x01Legs = const [],
  Iterable<MatchState> x01Matches = const [],
  Iterable<AtcLegState> atcLegs = const [],
  Iterable<BullingLegState> bullingLegs = const [],
}) {
  return {
    GameMode.x01: computeX01Stats(playerId, x01Legs, matches: x01Matches),
    GameMode.aroundTheClock: computeAtcStats(playerId, atcLegs),
    GameMode.bulling: computeBullingStats(playerId, bullingLegs),
  };
}
```

Append, after `computeAtcStats`:

```dart
/// Aggregates a player's Bulling record across any number of replayed
/// legs.
///
/// Takes folded [BullingLegState]s rather than raw rows, for the same
/// reason [computeX01Stats] and [computeAtcStats] do: every number here
/// agrees with what was shown during play by construction.
BullingStats computeBullingStats(int playerId, Iterable<BullingLegState> legs) {
  var legsPlayed = 0;
  var legsWon = 0;
  var dartsThrown = 0;
  var scoringDarts = 0;
  var pointsScored = 0;
  var outerBullHits = 0;
  var innerBullHits = 0;
  int? fewestDartsToWin;

  for (final leg in legs) {
    if (!leg.config.playerIds.contains(playerId)) continue;
    legsPlayed++;

    for (final turn in leg.turns) {
      if (turn.playerId != playerId) continue;

      for (final dart in turn.darts) {
        dartsThrown++;
        final points = pointsFor(dart.segment, leg.config.bullseyeValue);
        pointsScored += points;
        if (dart.segment?.ring == Ring.outerBull) outerBullHits++;
        if (dart.segment?.ring == Ring.innerBull) innerBullHits++;
        if (points > 0) scoringDarts++;
      }
    }

    if (leg.winnerId == playerId) {
      legsWon++;
      final darts = leg.dartsThrownBy(playerId);
      if (fewestDartsToWin == null || darts < fewestDartsToWin) {
        fewestDartsToWin = darts;
      }
    }
  }

  return BullingStats(
    legsPlayed: legsPlayed,
    legsWon: legsWon,
    dartsThrown: dartsThrown,
    scoringDarts: scoringDarts,
    pointsScored: pointsScored,
    outerBullHits: outerBullHits,
    innerBullHits: innerBullHits,
    fewestDartsToWin: fewestDartsToWin,
  );
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/domain/bulling/bulling_stats_test.dart test/domain/atc/atc_stats_test.dart test/domain/player_stats_test.dart`
Expected: PASS for all three — the last two guard against having broken
the existing dispatch.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/stats/bulling_stats.dart lib/domain/stats/mode_stats.dart lib/domain/stats/player_stats.dart test/domain/bulling/bulling_stats_test.dart
git commit -m "feat(bulling): add BullingStats and wire it into computePlayerStats"
```

---

## Task 5: `BullingGames` table and schema version 7

**Files:**
- Modify: `lib/data/db/database.dart:1-9` (imports), `:142-153` (table +
  `@DriftDatabase`), `:158-207` (`schemaVersion`, `onUpgrade`)
- Generated: `lib/data/db/database.g.dart` (via build_runner, not hand-edited)
- Modify: `test/app/migration_test.dart` (append a frozen `_SchemaV6` and
  its migration tests)

**Interfaces:**
- Consumes: `BullseyeValue` (Task 1).
- Produces: `class BullingGames extends Table {gameId, bullseyeValue,
  target}` (drift generates the `BullingGame` row class and
  `BullingGamesCompanion`/`BullingGamesCompanion.insert` from it).
  `AppDatabase.schemaVersion == 7`; a fresh install and an upgrade from 6
  both leave a `bulling_games` table present.

- [ ] **Step 1: Write the failing test**

Append to `test/app/migration_test.dart`, after the existing `_SchemaV5`
class and before `void main()`:

```dart
/// An [AppDatabase] frozen at schema 6, the version just before Bulling's
/// `bulling_games` table.
///
/// Every table's shape is already what the current classes produce —
/// `games` gained its nullable `start_score`/`double_out` back at v6, and
/// nothing about `players`/`matches`/`gameSeats`/`dartEvents`/`atcGames`
/// has changed since — so this only has to leave `bullingGames` out of
/// `onCreate`.
class _SchemaV6 extends AppDatabase {
  _SchemaV6(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createTable(players);
      await m.createTable(this.matches);
      await m.createTable(games);
      await m.createTable(gameSeats);
      await m.createTable(dartEvents);
      await m.createTable(atcGames);
    },
  );
}
```

Inside `void main()`, add a `seedV6` helper next to `seedV5`, and the new
tests, at the end of the file just before the closing `}`:

```dart
  /// Writes one x01 leg the way schema 6 stored legs — everything the
  /// current schema also writes, minus `bulling_games`, which did not
  /// exist yet.
  Future<int> seedV6({required List<ThrownDart> darts, int startScore = 501}) async {
    final db = _SchemaV6(NativeDatabase(file));

    final finn = await db
        .into(db.players)
        .insertReturning(PlayersCompanion.insert(name: 'Finn'));
    final sam = await db
        .into(db.players)
        .insertReturning(PlayersCompanion.insert(name: 'Sam'));
    final seats = [finn.id, sam.id];

    final gameId = await db
        .into(db.games)
        .insert(GamesCompanion.insert(startScore: Value(startScore)));

    for (var seat = 0; seat < seats.length; seat++) {
      await db
          .into(db.gameSeats)
          .insert(
            GameSeatsCompanion.insert(
              gameId: gameId,
              playerId: seats[seat],
              seat: seat,
            ),
          );
    }

    for (var i = 0; i < darts.length; i++) {
      await db
          .into(db.dartEvents)
          .insert(
            DartEventsCompanion.insert(
              gameId: gameId,
              ordinal: i,
              playerId: seats[(i ~/ 3) % seats.length],
              number: Value(darts[i].segment?.number),
              ring: Value(darts[i].segment?.ring),
              value: darts[i].value,
            ),
          );
    }

    await db.close();
    return gameId;
  }

  test('a version 6 database opens at the current version', () async {
    await seedV6(darts: [t(20)]);

    final db = migrated();
    await db.select(db.matches).get();

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), db.schemaVersion);

    await db.close();
  });

  test('a fresh install lands on the current version with bulling_games present', () async {
    final db = migrated();
    await db.select(db.matches).get();

    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'bulling_games'",
        )
        .get();
    expect(tables, isNotEmpty);

    await db.close();
  });

  test('an old x01 leg from v6 still folds correctly after gaining bulling_games', () async {
    final gameId = await seedV6(
      darts: [t(20), t(20), t(20), t(1), t(1), t(1), t(19)],
    );

    final db = migrated();
    final repository = GameRepository(db);

    final config = await repository.loadConfig(gameId);
    expect(config, isNotNull);
    expect(config!.startScore, 501);

    final leg = foldLeg(config, await repository.loadLog(gameId));
    expect(leg.remaining[config.playerIds[0]], 501 - 180 - 57);
    expect(leg.remaining[config.playerIds[1]], 501 - 9);

    await db.close();
  });

  test('an old v6 leg still resumes after the migration', () async {
    final gameId = await seedV6(darts: [t(20), t(20)]);

    final db = migrated();
    expect(await GameRepository(db).findResumableGameId(), gameId);

    await db.close();
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/app/migration_test.dart`
Expected: FAIL — `db.schemaVersion` is still 6, so `PRAGMA user_version`
after migration is 6 not 7 in the "opens at the current version" test, and
`bulling_games` does not exist in the fresh-install test.

- [ ] **Step 3: Write the minimal implementation**

Edit `lib/data/db/database.dart`. Add the import:

```dart
import '../../domain/bulling/bulling_variant.dart';
```

Add the table, right after `AtcGames` and before `@DriftDatabase`:

```dart
/// Bulling's own per-leg config: the bullseye value and the target score it
/// was played to.
///
/// A sibling to [Games], the same way [AtcGames] stands beside it for
/// Around the Clock's own rules — x01's `startScore`/`doubleOut` mean
/// nothing here, and this mode's `bullseyeValue`/`target` mean nothing
/// there.
class BullingGames extends Table {
  IntColumn get gameId =>
      integer().references(Games, #id, onDelete: KeyAction.cascade)();
  TextColumn get bullseyeValue => textEnum<BullseyeValue>()();
  IntColumn get target => integer()();

  @override
  Set<Column<Object>> get primaryKey => {gameId};
}
```

Update the `@DriftDatabase` annotation:

```dart
@DriftDatabase(
  tables: [Players, Matches, Games, GameSeats, DartEvents, AtcGames, BullingGames],
)
```

Update `schemaVersion` and `onUpgrade`:

```dart
  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.createTable(matches);
        await m.addColumn(games, games.matchId);
        await m.addColumn(games, games.legNumber);
      }
      if (from < 4 && from >= 2) {
        await m.deleteTable('segment_calibrations');
      }
      if (from < 5) {
        await m.addColumn(games, games.gameMode);
        if (from >= 3) {
          await m.addColumn(matches, matches.gameMode);
        }
      }
      if (from < 6) {
        await m.alterTable(TableMigration(games));
        await m.createTable(atcGames);
      }
      if (from < 7) {
        await m.createTable(bullingGames);
      }
    },
  );
```

(Every comment already in the file above the existing `if` blocks stays
untouched — only the new `if (from < 7)` block is added at the end.)

- [ ] **Step 4: Regenerate drift code and run the tests**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test test/app/migration_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/db/database.dart lib/data/db/database.g.dart test/app/migration_test.dart
git commit -m "feat(bulling): add BullingGames table, schema version 7"
```

---

## Task 6: `GameRepository` Bulling methods

**Files:**
- Modify: `lib/data/db/game_repository.dart:1-30` (imports, `_bulling`
  constant), append a `// Bulling` section at the end (after `//
  Around the Clock`)
- Test: `test/app/bulling_persistence_test.dart`

**Interfaces:**
- Consumes: `BullingConfig`, `BullingLegState`, `foldBulling` (Task 2);
  `BullingGames`/`BullingGame`/`BullingGamesCompanion` (Task 5);
  `GameMode.bulling` (Task 3).
- Produces: `Future<int> startBullingGame(BullingConfig config)`,
  `Future<BullingGame?> loadBullingGame(int gameId)`, `Future<BullingConfig?>
  loadBullingConfig(int gameId)`, `Stream<List<BullingLegState>>
  watchAllBullingLegs()`.

- [ ] **Step 1: Write the failing test**

```dart
// test/app/bulling_persistence_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_reducer.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/game_mode.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

void main() {
  late AppDatabase database;
  late GameRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = GameRepository(database);
  });

  tearDown(() => database.close());

  final ThrownDart sbull = ThrownDart(Segment.outerBull);

  Future<BullingConfig> seedBullingGame({
    int players = 2,
    BullseyeValue bullseyeValue = BullseyeValue.two,
    int target = 21,
  }) async {
    final roster = [
      for (var i = 0; i < players; i++)
        await repository.addPlayer('Player ${i + 1}'),
    ];
    return BullingConfig(
      playerIds: [for (final player in roster) player.id],
      bullseyeValue: bullseyeValue,
      target: target,
    );
  }

  group('starting a game', () {
    test('writes a games row under bulling and seats the players', () async {
      final config = await seedBullingGame(players: 3);
      final gameId = await repository.startBullingGame(config);

      final game = await repository.loadGame(gameId);
      expect(game!.gameMode, GameMode.bulling);
      expect(game.startScore, isNull);
      expect(game.doubleOut, isNull);

      final loaded = await repository.loadBullingConfig(gameId);
      expect(loaded!.playerIds, config.playerIds);
      expect(loaded.bullseyeValue, config.bullseyeValue);
      expect(loaded.target, config.target);
    });

    test('the bullseye value and target round-trip through BullingGames', () async {
      final config = await seedBullingGame(
        bullseyeValue: BullseyeValue.three,
        target: 31,
      );
      final gameId = await repository.startBullingGame(config);

      final loaded = await repository.loadBullingConfig(gameId);
      expect(loaded!.bullseyeValue, BullseyeValue.three);
      expect(loaded.target, 31);
    });
  });

  group('replaying a stored game', () {
    test('the reloaded log folds to the same state it was played to', () async {
      final config = await seedBullingGame();
      final gameId = await repository.startBullingGame(config);

      await repository.appendDart(
        gameId: gameId,
        ordinal: 0,
        playerId: config.playerIds[0],
        dart: sbull,
      );

      final storedConfig = await repository.loadBullingConfig(gameId);
      final storedLog = await repository.loadLog(gameId);
      final leg = foldBulling(storedConfig!, storedLog);

      expect(leg.scoreFor(config.playerIds[0]), 1);
    });

    test('a game with no seats has no Bulling config to replay', () async {
      final gameId = await repository.startBullingGame(
        BullingConfig(
          playerIds: const [1],
          bullseyeValue: BullseyeValue.two,
          target: 21,
        ),
      );
      await database.delete(database.bullingGames).go();

      expect(await repository.loadBullingConfig(gameId), isNull);
    });
  });

  group('this mode alongside the others', () {
    test('watchAllBullingLegs only ever returns Bulling rows', () async {
      final config = await seedBullingGame();
      await repository.startBullingGame(config);

      final legs = await repository.watchAllBullingLegs().first;
      expect(legs, hasLength(1));
    });

    test('appears in the resumable-leg query the same as any other mode', () async {
      final config = await seedBullingGame();
      final gameId = await repository.startBullingGame(config);
      await repository.appendDart(
        gameId: gameId,
        ordinal: 0,
        playerId: config.playerIds[0],
        dart: sbull,
      );

      expect(await repository.findResumableGameId(), gameId);
    });

    test('finishGame/reopenGame work unchanged for a Bulling row', () async {
      final config = await seedBullingGame();
      final gameId = await repository.startBullingGame(config);

      await repository.finishGame(gameId, config.playerIds[0]);
      expect(
        (await repository.loadGame(gameId))!.winnerPlayerId,
        config.playerIds[0],
      );

      await repository.reopenGame(gameId);
      expect((await repository.loadGame(gameId))!.winnerPlayerId, isNull);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/app/bulling_persistence_test.dart`
Expected: FAIL — `startBullingGame`/`loadBullingConfig`/
`watchAllBullingLegs` do not exist on `GameRepository`.

- [ ] **Step 3: Write the minimal implementation**

Edit `lib/data/db/game_repository.dart`. Add imports:

```dart
import '../../domain/bulling/bulling_config.dart';
import '../../domain/bulling/bulling_leg_state.dart';
import '../../domain/bulling/bulling_reducer.dart';
```

Add the filter constant next to `_aroundTheClock`:

```dart
  /// The stored form of [GameMode.bulling], for filtering `gameMode`
  /// columns.
  static final String _bulling = GameMode.bulling.name;
```

Append, after the `// Around the Clock` section's last method
(`watchAllAtcLegs`):

```dart
  // Bulling

  /// Creates a Bulling leg and seats its players.
  ///
  /// No `matchId`/`legNumber` — this mode has no match wrapping yet, so
  /// every leg stands on its own, the same as Around the Clock.
  Future<int> startBullingGame(BullingConfig config) {
    return db.transaction(() async {
      final gameId = await db
          .into(db.games)
          .insert(
            GamesCompanion.insert(
              startScore: const Value.absent(),
              doubleOut: const Value(null),
              gameMode: const Value(GameMode.bulling),
            ),
          );

      await db
          .into(db.bullingGames)
          .insert(
            BullingGamesCompanion.insert(
              gameId: Value(gameId),
              bullseyeValue: config.bullseyeValue,
              target: config.target,
            ),
          );

      await _seatPlayers(gameId, config.playerIds);
      return gameId;
    });
  }

  /// The `BullingGames` row for a game, or null if there is not one.
  Future<BullingGame?> loadBullingGame(int gameId) =>
      (db.select(db.bullingGames)..where((g) => g.gameId.equals(gameId)))
          .getSingleOrNull();

  /// Rebuilds the configuration a Bulling leg was played under.
  ///
  /// Null under the same "half-written row" contract [loadConfig]
  /// documents: missing config row, or no seats, both mean there is
  /// nothing honest to replay.
  Future<BullingConfig?> loadBullingConfig(int gameId) async {
    final bullingGame = await loadBullingGame(gameId);
    if (bullingGame == null) return null;

    final seats = await _seatsOf(gameId);
    if (seats.isEmpty) return null;

    return BullingConfig(
      playerIds: seats,
      bullseyeValue: bullingGame.bullseyeValue,
      target: bullingGame.target,
    );
  }

  /// Every stored Bulling leg, replayed. Refreshes itself when a game
  /// changes.
  ///
  /// A sibling to [watchAllLegs]/[watchAllAtcLegs], not a parameterisation
  /// of either — the three fold through different engines and there is no
  /// rule shared between them worth entangling.
  Stream<List<BullingLegState>> watchAllBullingLegs() =>
      (db.select(db.games)..where((g) => g.gameMode.equals(_bulling)))
          .watch()
          .asyncMap((games) async {
            final legs = <BullingLegState>[];
            for (final game in games) {
              final config = await loadBullingConfig(game.id);
              if (config == null) continue;
              legs.add(foldBulling(config, await loadLog(game.id)));
            }
            return legs;
          });
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/app/bulling_persistence_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/db/game_repository.dart test/app/bulling_persistence_test.dart
git commit -m "feat(bulling): add GameRepository methods for Bulling"
```

---

## Task 7: `BullingController`, `BullingSession`, and providers

**Files:**
- Create: `lib/app/bulling_controller.dart`
- Modify: `lib/app/providers.dart:12-25` (imports), append
  `BullingConfigController`/`bullingConfigProvider`/`bullingGameProvider`
  near the ATC providers, add `allBullingLegsProvider` near
  `allAtcLegsProvider`, update `playerStatsProvider` and
  `segmentCountsProvider`
- Test: `test/app/bulling_controller_test.dart`

**Interfaces:**
- Consumes: `BullingConfig`, `BullseyeValue`, `foldBulling`,
  `initialBullingLegState`, `BullingLegState`, `BullingTurn` (Tasks 1-2);
  `GameRepository` (Task 6); `boardEventsProvider`, `keypadOverrideProvider`,
  `currentGameIdProvider`, `gameRepositoryProvider` (existing, from
  `providers.dart`); `BoardEvent`/`DartHit`/`BoardMiss`/`ButtonPress`/
  `UnknownFrame` from `lib/domain/board_event.dart`.
- Produces: `class BullingSession {leg, acknowledgedTurns}` with
  `awaitingTurnConfirm`, `pendingTurn`. `class BullingController extends
  Notifier<BullingSession>` with `handleBoardEvent`, `addDart`, `undo`,
  `confirmTurn`, `restart([BullingConfig?])`, `leave`, `resume(BullingConfig,
  List<ThrownDart>)`. `bullingConfigProvider`,
  `bullingGameProvider`, `allBullingLegsProvider`.

- [ ] **Step 1: Write the failing test**

```dart
// test/app/bulling_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/bulling_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// Lets queued stream events reach the controller before assertions run.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeBoardSource board;
  late ProviderContainer container;

  BullingSession session() => container.read(bullingGameProvider);
  BullingController controller() =>
      container.read(bullingGameProvider.notifier);

  setUp(() {
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [boardSourceProvider.overrideWithValue(board)],
    );
    container.listen(bullingGameProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
    board.dispose();
  });

  final ThrownDart sbull = ThrownDart(Segment.outerBull);
  final ThrownDart dbull = ThrownDart(Segment.innerBull);

  group('scoring by hand', () {
    test('an outer bull adds a point', () {
      controller().addDart(sbull);
      expect(session().leg.score[1], 1);
    });

    test('a third dart ends the turn and holds the summary', () {
      controller()
        ..addDart(sbull)
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss());

      expect(session().awaitingTurnConfirm, isTrue);
      expect(session().pendingTurn!.scored, 1);
      expect(session().leg.currentPlayerId, 2);
    });

    test('darts thrown while the summary is up are ignored', () {
      controller()
        ..addDart(sbull)
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss());

      controller().addDart(sbull);

      expect(session().leg.score[2], 0);
      expect(session().leg.darts, hasLength(3));
    });

    test('confirming lets play resume', () {
      controller()
        ..addDart(sbull)
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss())
        ..confirmTurn()
        ..addDart(sbull);

      expect(session().awaitingTurnConfirm, isFalse);
      expect(session().leg.score[2], 1);
    });
  });

  group('undo', () {
    test('drops the last dart', () {
      controller()
        ..addDart(sbull)
        ..addDart(sbull)
        ..undo();

      expect(session().leg.score[1], 1);
      expect(session().leg.darts, hasLength(1));
    });

    test('backs out of a turn summary', () {
      controller()
        ..addDart(sbull)
        ..addDart(const ThrownDart.miss())
        ..addDart(const ThrownDart.miss());
      expect(session().awaitingTurnConfirm, isTrue);

      controller().undo();

      expect(session().awaitingTurnConfirm, isFalse);
      expect(session().leg.currentPlayerId, 1);
      expect(session().leg.dartsThrownThisTurn, 2);
    });

    test('does nothing on an empty leg', () {
      controller().undo();
      expect(session().leg.darts, isEmpty);
    });
  });

  group('driven by the board', () {
    setUp(() => controller().restart());

    test('a hit is ignored when no leg is open', () async {
      controller().leave();

      board.hit(Segment.outerBull);
      await settle();

      expect(session().leg.darts, isEmpty);
    });

    test('a hit scores, through framing and decoding', () async {
      board.hit(Segment.outerBull);
      await settle();

      expect(session().leg.score[1], 1);
    });

    test('the button confirms the turn', () async {
      board.emitBatch(['3.4', '3.5', '3.6']);
      await settle();
      expect(session().awaitingTurnConfirm, isTrue);

      board.pressButton();
      await settle();

      expect(session().awaitingTurnConfirm, isFalse);
    });
  });

  group('resuming a stored leg', () {
    test('restores the score and whose turn it is', () {
      final config = BullingConfig(
        playerIds: const [1, 2],
        bullseyeValue: BullseyeValue.two,
        target: 99,
      );
      controller().resume(config, [sbull, sbull, const ThrownDart.miss(), sbull]);

      expect(session().leg.score[1], 2);
      expect(session().leg.score[2], 1);
      expect(session().leg.currentPlayerId, 2);
      expect(session().leg.dartsThrownThisTurn, 1);
    });

    test('an empty log resumes as a fresh leg', () {
      final config = BullingConfig(
        playerIds: const [1],
        bullseyeValue: BullseyeValue.three,
        target: 21,
      );
      controller().resume(config, const []);

      expect(session().leg.score[1], 0);
      expect(session().leg.darts, isEmpty);
    });

    test('reopens the leg to board input', () async {
      controller()
        ..leave()
        ..resume(
          BullingConfig(
            playerIds: const [1, 2],
            bullseyeValue: BullseyeValue.two,
            target: 99,
          ),
          [sbull],
        );

      board.hit(Segment.outerBull);
      await settle();

      expect(session().leg.darts, hasLength(2));
    });
  });

  group('configuration', () {
    test('changing the config starts a fresh leg', () {
      controller().addDart(sbull);

      container.read(bullingConfigProvider.notifier).update(
        BullingConfig(
          playerIds: const [1, 2],
          bullseyeValue: BullseyeValue.three,
          target: 31,
        ),
      );

      expect(session().leg.config.bullseyeValue, BullseyeValue.three);
      expect(session().leg.darts, isEmpty);
    });
  });

  test('reaching the target wins the leg instantly', () {
    container.read(bullingConfigProvider.notifier).update(
      BullingConfig(
        playerIds: const [1, 2],
        bullseyeValue: BullseyeValue.three,
        target: 3,
      ),
    );
    controller().restart();

    controller().addDart(dbull);

    expect(session().leg.isFinished, isTrue);
    expect(session().leg.winnerId, 1);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/app/bulling_controller_test.dart`
Expected: FAIL — `bulling_controller.dart` does not exist,
`bullingGameProvider`/`bullingConfigProvider` are not defined.

- [ ] **Step 3: Write the minimal implementation**

```dart
// lib/app/bulling_controller.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/game_repository.dart';
import '../domain/board_event.dart';
import '../domain/bulling/bulling_config.dart';
import '../domain/bulling/bulling_leg_state.dart';
import '../domain/bulling/bulling_reducer.dart';
import '../domain/x01/thrown_dart.dart';
import 'providers.dart';

/// The leg, plus the one piece of state the rules do not care about:
/// whether the player has acknowledged the turn that just ended.
///
/// Mirrors x01's `GameSession` and Around the Clock's `AtcSession` exactly —
/// see either type's own doc.
class BullingSession {
  const BullingSession({required this.leg, required this.acknowledgedTurns});

  final BullingLegState leg;

  final int acknowledgedTurns;

  bool get awaitingTurnConfirm => leg.turns.length > acknowledgedTurns;

  BullingTurn? get pendingTurn =>
      awaitingTurnConfirm ? leg.turns[acknowledgedTurns] : null;
}

/// Owns the dart log for a Bulling leg and turns board events into points.
///
/// Structured exactly like `AtcController` — every mutation goes through
/// [foldBulling], so the leg is always a pure function of the darts thrown,
/// and undo replays a shorter log rather than reversing anything. Like
/// Around the Clock, this mode has no match wrapping yet.
class BullingController extends Notifier<BullingSession> {
  bool _live = false;
  bool _manualOverrideOpen = false;

  @override
  BullingSession build() {
    final config = ref.watch(bullingConfigProvider);

    ref.listen(boardEventsProvider, (previous, next) {
      final event = next.value;
      if (event != null) handleBoardEvent(event);
    });

    _manualOverrideOpen = ref.read(keypadOverrideProvider);
    ref.listen(keypadOverrideProvider, (previous, next) {
      _manualOverrideOpen = next;
    });

    return BullingSession(
      leg: initialBullingLegState(config),
      acknowledgedTurns: 0,
    );
  }

  void handleBoardEvent(BoardEvent event) {
    if (!_live) return;

    switch (event) {
      case DartHit(:final segment):
        if (_manualOverrideOpen) return;
        addDart(ThrownDart(segment));
      case BoardMiss():
        if (_manualOverrideOpen) return;
        addDart(const ThrownDart.miss());
      case ButtonPress():
        confirmTurn();
      case UnknownFrame():
        break;
    }
  }

  /// Records a dart. Ignored while a turn summary is showing, so a stray
  /// frame arriving as the player walks to the board cannot score for the
  /// next player.
  void addDart(ThrownDart dart) {
    if (state.leg.isFinished || state.awaitingTurnConfirm) return;

    final ordinal = state.leg.darts.length;
    final thrownBy = state.leg.currentPlayerId;

    final leg = foldBulling(state.leg.config, [...state.leg.darts, dart]);
    state = BullingSession(
      leg: leg,
      acknowledgedTurns: state.acknowledgedTurns,
    );

    _persist((repository, gameId) async {
      await repository.appendDart(
        gameId: gameId,
        ordinal: ordinal,
        playerId: thrownBy,
        dart: dart,
      );
      if (leg.winnerId case final winner?) {
        await repository.finishGame(gameId, winner);
      }
    });
  }

  /// Drops the last dart thrown and replays the leg without it.
  void undo() {
    final darts = state.leg.darts;
    if (darts.isEmpty) return;

    final wasFinished = state.leg.isFinished;
    final leg = foldBulling(
      state.leg.config,
      darts.sublist(0, darts.length - 1),
    );
    state = BullingSession(
      leg: leg,
      acknowledgedTurns: min(state.acknowledgedTurns, leg.turns.length),
    );

    _persist((repository, gameId) async {
      await repository.truncateLog(gameId, leg.darts.length);
      if (wasFinished && !leg.isFinished) {
        await repository.reopenGame(gameId);
      }
    });
  }

  void _persist(
    Future<void> Function(GameRepository repository, int gameId) write,
  ) {
    final gameId = ref.read(currentGameIdProvider);
    if (gameId == null) return;
    unawaited(write(ref.read(gameRepositoryProvider), gameId));
  }

  /// Dismisses the turn summary and hands over.
  void confirmTurn() {
    if (!state.awaitingTurnConfirm) return;
    state = BullingSession(
      leg: state.leg,
      acknowledgedTurns: state.leg.turns.length,
    );
  }

  /// Starts a fresh leg under [config], or the current one if omitted.
  void restart([BullingConfig? config]) {
    _live = true;
    state = BullingSession(
      leg: initialBullingLegState(config ?? state.leg.config),
      acknowledgedTurns: 0,
    );
  }

  /// Steps away from the leg without ending it.
  void leave() => _live = false;

  /// Picks a leg back up from its stored dart log.
  ///
  /// Callers must set [bullingConfigProvider] before calling this, the same
  /// requirement `AtcController.resume` documents.
  void resume(BullingConfig config, List<ThrownDart> darts) {
    _live = true;
    final leg = foldBulling(config, darts);
    state = BullingSession(leg: leg, acknowledgedTurns: leg.turns.length);
  }
}
```

Edit `lib/app/providers.dart`. Add imports, alongside the existing ATC ones:

```dart
import '../domain/bulling/bulling_config.dart';
import '../domain/bulling/bulling_leg_state.dart';
import '../domain/bulling/bulling_reducer.dart';
import '../domain/bulling/bulling_variant.dart';
import 'bulling_controller.dart';
```

Add, right after `atcGameProvider`'s definition:

```dart
class BullingConfigController extends Notifier<BullingConfig> {
  @override
  BullingConfig build() => BullingConfig(
    playerIds: const [1, 2],
    bullseyeValue: BullseyeValue.two,
    target: 21,
  );

  void update(BullingConfig config) => state = config;
}

final bullingConfigProvider =
    NotifierProvider<BullingConfigController, BullingConfig>(
      BullingConfigController.new,
    );

final bullingGameProvider =
    NotifierProvider<BullingController, BullingSession>(
      BullingController.new,
    );
```

Add, right after `allAtcLegsProvider`:

```dart
/// Every stored Bulling leg, replayed.
final allBullingLegsProvider = StreamProvider<List<BullingLegState>>(
  (ref) => ref.watch(gameRepositoryProvider).watchAllBullingLegs(),
);
```

Update `playerStatsProvider`:

```dart
final playerStatsProvider =
    Provider.family<Map<GameMode, ModeStats>, int>((ref, playerId) {
      return computePlayerStats(
        playerId,
        x01Legs: ref.watch(allLegsProvider).value ?? const [],
        x01Matches: ref.watch(allMatchesProvider).value ?? const [],
        atcLegs: ref.watch(allAtcLegsProvider).value ?? const [],
        bullingLegs: ref.watch(allBullingLegsProvider).value ?? const [],
      );
    });
```

Update `segmentCountsProvider` to also depend on the new stream:

```dart
final segmentCountsProvider = FutureProvider.family<Map<Segment, int>, int>(
  (ref, playerId) {
    ref.watch(allLegsProvider);
    ref.watch(allAtcLegsProvider);
    ref.watch(allBullingLegsProvider);
    return ref.watch(gameRepositoryProvider).segmentCounts(playerId);
  },
);
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/app/bulling_controller_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/bulling_controller.dart lib/app/providers.dart test/app/bulling_controller_test.dart
git commit -m "feat(bulling): add BullingController and its providers"
```

---

## Task 8: `BullingSetupScreen` and the mode-select tile

**Files:**
- Create: `lib/app/screens/bulling_setup_screen.dart`
- Modify: `lib/app/screens/select_game_mode_screen.dart:11-22` (icon map,
  setup-screen switch)
- Modify: `test/app/select_game_mode_screen_test.dart` (add a navigation
  test)

**Interfaces:**
- Consumes: `BullingConfig`, `BullseyeValue` (Task 1); `bullingConfigProvider`,
  `bullingGameProvider`, `currentGameIdProvider`, `gameRepositoryProvider`,
  `playersProvider` (Task 7 / existing); `GameConfig.maxPlayers` (existing).
- Produces: `String bullseyeValueLabel(BullseyeValue value)` (imported by
  Task 9's game screen and Task 10's resume banner). `class
  BullingSetupScreen extends ConsumerStatefulWidget`.

- [ ] **Step 1: Write the failing test**

Add to `test/app/select_game_mode_screen_test.dart`, alongside the existing
imports:

```dart
import 'package:fluttergran/app/screens/bulling_setup_screen.dart';
```

Add a new `testWidgets` block, next to the "Around the Clock tile" one:

```dart
  testWidgets('the Bulling tile navigates to its setup screen', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('BULLING'), findsOneWidget);

    await tester.tap(find.text('BULLING'));
    await tester.pumpAndSettle();

    expect(find.byType(BullingSetupScreen), findsOneWidget);
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/app/select_game_mode_screen_test.dart`
Expected: FAIL — `bulling_setup_screen.dart` does not exist, and the
`select_game_mode_screen.dart` switch has no `bulling` case, so the widget
tree never reaches `BullingSetupScreen`.

- [ ] **Step 3: Write the minimal implementation**

```dart
// lib/app/screens/bulling_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/bulling/bulling_config.dart';
import '../../domain/bulling/bulling_variant.dart';
import '../../domain/x01/game_config.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/board_connection_button.dart';
import 'bulling_game_screen.dart';

/// How each [BullseyeValue] reads on the setup tile and everywhere else a
/// short label is needed for it.
String bullseyeValueLabel(BullseyeValue value) => switch (value) {
  BullseyeValue.two => 'BULLSEYE = 2',
  BullseyeValue.three => 'BULLSEYE = 3',
};

/// Picks the bullseye value, the target score, and who is playing, then
/// starts a persisted leg.
///
/// Mirrors `AtcSetupScreen`'s shape exactly — same reasons for what
/// belongs here and what does not.
class BullingSetupScreen extends ConsumerStatefulWidget {
  const BullingSetupScreen({super.key});

  @override
  ConsumerState<BullingSetupScreen> createState() =>
      _BullingSetupScreenState();
}

class _BullingSetupScreenState extends ConsumerState<BullingSetupScreen> {
  final TextEditingController _newPlayer = TextEditingController();

  /// Selected players, in the order they were tapped — which is throwing
  /// order.
  final List<int> _seats = [];

  BullseyeValue _bullseyeValue = BullseyeValue.two;
  int _target = 21;

  @override
  void dispose() {
    _newPlayer.dispose();
    super.dispose();
  }

  Future<void> _addPlayer() async {
    final name = _newPlayer.text.trim();
    if (name.isEmpty) return;

    final player = await ref.read(gameRepositoryProvider).addPlayer(name);
    _newPlayer.clear();
    if (_seats.length < GameConfig.maxPlayers) {
      setState(() => _seats.add(player.id));
    }
  }

  Future<void> _start() async {
    final config = BullingConfig(
      playerIds: _seats,
      bullseyeValue: _bullseyeValue,
      target: _target,
    );
    final gameId = await ref
        .read(gameRepositoryProvider)
        .startBullingGame(config);
    if (!mounted) return;

    ref.read(bullingConfigProvider.notifier).update(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(bullingGameProvider.notifier).restart(config);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const BullingGameScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BULLING SETUP'),
        actions: const [BoardConnectionButton(), SizedBox(width: Gap.xs)],
      ),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              const _Eyebrow('Bullseye value'),
              const SizedBox(height: Gap.md),
              Column(
                key: const Key('bullseye-value-column'),
                children: [
                  for (final value in BullseyeValue.values) ...[
                    if (value != BullseyeValue.values.first)
                      const SizedBox(height: Gap.sm),
                    _VariantChoice(
                      label: bullseyeValueLabel(value),
                      selected: value == _bullseyeValue,
                      onTap: () => setState(() => _bullseyeValue = value),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Gap.lg),
              const _Eyebrow('Target'),
              const SizedBox(height: Gap.md),
              Row(
                key: const Key('target-row'),
                children: [
                  for (final target in BullingConfig.offeredTargets) ...[
                    if (target != BullingConfig.offeredTargets.first)
                      const SizedBox(width: Gap.sm),
                    Expanded(
                      child: _ScoreChoice(
                        score: target,
                        selected: target == _target,
                        onTap: () => setState(() => _target = target),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Gap.xl),
              Row(
                children: [
                  const _Eyebrow('Players'),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Text(
                      _seats.isEmpty
                          ? 'tap to add, in throwing order'
                          : '${_seats.length} of ${GameConfig.maxPlayers}',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Type.label.copyWith(color: Palette.chalkDim),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newPlayer,
                      style: Type.body.copyWith(color: Palette.chalk),
                      cursorColor: Palette.live,
                      decoration: const InputDecoration(
                        labelText: 'Add a player',
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addPlayer(),
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  SizedBox(
                    height: 46,
                    width: 46,
                    child: FilledButton(
                      onPressed: _addPlayer,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Icon(Icons.add, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              switch (players) {
                AsyncError(:final error) => Text(
                  'Could not load players: $error',
                  style: Type.body.copyWith(color: Palette.doubleBed),
                ),
                AsyncData(:final value) when value.isEmpty => Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.xl),
                  child: Text(
                    'No players yet. Add the first one above.',
                    style: Type.body.copyWith(color: Palette.chalkDim),
                  ),
                ),
                AsyncData(:final value) => Column(
                  children: [for (final player in value) _tile(player)],
                ),
                _ => const SizedBox.shrink(),
              },
            ],
          ),
        ),
      ),
      bottomNavigationBar: CenteredContent(
        child: Padding(
          key: const Key('start-button-padding'),
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('start-leg-button'),
              onPressed: _seats.isEmpty ? null : _start,
              child: Text(
                _seats.isEmpty ? 'PICK AT LEAST ONE PLAYER' : 'START LEG',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(Player player) {
    final seat = _seats.indexOf(player.id);
    final selected = seat >= 0;
    final full = _seats.length >= GameConfig.maxPlayers;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Material(
        color: selected ? Palette.raised : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: selected ? Palette.live : Palette.edge),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selected
              ? () => setState(() => _seats.remove(player.id))
              : full
              ? null
              : () => setState(() => _seats.add(player.id)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.md,
              vertical: Gap.md,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    selected ? '${seat + 1}' : '',
                    style: Type.notation.copyWith(color: Palette.live),
                  ),
                ),
                Expanded(
                  child: Text(
                    player.name,
                    style: Type.body.copyWith(
                      color: selected ? Palette.chalk : Palette.chalkDim,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Remove ${player.name}',
                  onPressed: () async {
                    setState(() => _seats.remove(player.id));
                    await ref
                        .read(gameRepositoryProvider)
                        .removePlayer(player.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Type.eyebrow.copyWith(color: Palette.chalkDim),
  );
}

/// One bullseye-value choice, as a full-width row — the same idiom
/// `AtcSetupScreen`'s `_VariantChoice` uses.
class _VariantChoice extends StatelessWidget {
  const _VariantChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Palette.chalk : Palette.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: selected ? Palette.chalk : Palette.edge),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.lg,
            vertical: Gap.md,
          ),
          child: Text(
            label,
            style: Type.body.copyWith(
              color: selected ? Palette.ground : Palette.chalk,
            ),
          ),
        ),
      ),
    );
  }
}

/// One number in a row of them — the same idiom `X01SetupScreen`'s
/// `_ScoreChoice` uses for the start score.
class _ScoreChoice extends StatelessWidget {
  const _ScoreChoice({
    required this.score,
    required this.selected,
    required this.onTap,
  });

  final int score;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Palette.chalk : Palette.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: selected ? Palette.chalk : Palette.edge),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Gap.md),
          child: Center(
            child: Text(
              '$score',
              style: Type.scoreSmall.copyWith(
                color: selected ? Palette.ground : Palette.chalkDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

Note: this file is not yet compilable on its own — it imports
`bulling_game_screen.dart`, which Task 9 creates. Task 8's test run
(Step 4 below) will not pass until Task 9 also lands; run both tasks'
tests together, or write Task 9's screen file (without its own test) as
part of this task's Step 3 to keep the build green. Treat Task 9's
`BullingGameScreen` file creation as a prerequisite compile step for this
task, and Task 9's own checklist below as the task that gives it its
review.

Edit `lib/app/screens/select_game_mode_screen.dart`:

```dart
import 'bulling_setup_screen.dart';
```

```dart
const Map<GameMode, IconData> _icons = {
  GameMode.x01: Icons.adjust,
  GameMode.aroundTheClock: Icons.timelapse,
  GameMode.bulling: Icons.gps_fixed,
};
```

```dart
Widget _setupScreenFor(GameMode mode) => switch (mode) {
  GameMode.x01 => const X01SetupScreen(),
  GameMode.aroundTheClock => const AtcSetupScreen(),
  GameMode.bulling => const BullingSetupScreen(),
};
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/app/select_game_mode_screen_test.dart`
Expected: PASS (after Task 9's `bulling_game_screen.dart` also exists, so
the import in Step 3 resolves)

- [ ] **Step 5: Commit**

```bash
git add lib/app/screens/bulling_setup_screen.dart lib/app/screens/select_game_mode_screen.dart test/app/select_game_mode_screen_test.dart
git commit -m "feat(bulling): add BullingSetupScreen and wire the mode-select tile"
```

---

## Task 9: `BullingGameScreen`

**Files:**
- Create: `lib/app/screens/bulling_game_screen.dart`

**Interfaces:**
- Consumes: `BullingSession`, `BullingController` (Task 7);
  `bullingGameProvider`, `currentGameIdProvider`, `gameRepositoryProvider`,
  `playerNamesProvider`, `boardConnectionProvider`, `keypadOverrideProvider`
  (existing/Task 7); `bullseyeValueLabel` (Task 8); `nameFor` from
  `lib/app/screens/game_screen.dart` (existing); `DartKeypad` from
  `lib/app/widgets/dart_keypad.dart` (existing).
- Produces: `class BullingGameScreen extends ConsumerWidget`, used by Task
  8's setup screen and Task 10's resume flow.

No new automated test in this task — Around the Clock shipped its game
screen the same way, exercised only through `BullingController`'s own
tests (Task 7) and the manual verification in Task 12. This file is a pure
mirror of `lib/app/screens/atc_game_screen.dart`, so the risk this leaves
uncovered is the same risk `atc_game_screen.dart` itself already carries in
the shipped app.

- [ ] **Step 1: Write the file**

```dart
// lib/app/screens/bulling_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/bulling/bulling_config.dart';
import '../../domain/bulling/bulling_leg_state.dart';
import '../../domain/segment.dart';
import '../../domain/x01/leg_state.dart' show dartsPerTurn;
import '../../domain/x01/thrown_dart.dart';
import '../bulling_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/dart_keypad.dart';
import 'bulling_setup_screen.dart' show bullseyeValueLabel;
import 'game_screen.dart' show nameFor;

/// Plays a leg of Bulling.
///
/// Mirrors `AtcGameScreen`'s shape: a scoreboard, a turn ledger, and
/// whichever of the keypad / turn-confirm / leg-won panel the moment calls
/// for. Like Around the Clock, this mode has no match wrapping yet, so
/// there is no match-won equivalent — a leg won here just offers another
/// leg under the same config.
class BullingGameScreen extends ConsumerWidget {
  const BullingGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(bullingGameProvider);
    final controller = ref.read(bullingGameProvider.notifier);
    final names = ref.watch(playerNamesProvider);
    final leg = session.leg;

    final confirmBeforeLeaving = leg.darts.isNotEmpty && !leg.isFinished;

    return PopScope(
      canPop: !confirmBeforeLeaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!await _confirmLeave(context)) return;

        controller.leave();
        ref.read(currentGameIdProvider.notifier).set(null);
        if (context.mounted) Navigator.of(context).pop();
      },
      child: _build(context, ref, session, controller, names, leg),
    );
  }

  /// Starts a fresh leg under the same config, persisted as its own row —
  /// the mode-agnostic equivalent of what `matchProvider.notifier.rematch`
  /// does for x01, done directly since this mode has no match controller.
  Future<void> _playAgain(WidgetRef ref, BullingConfig config) async {
    final gameId = await ref
        .read(gameRepositoryProvider)
        .startBullingGame(config);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(bullingGameProvider.notifier).restart(config);
  }

  Future<bool> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave this leg?'),
        content: Text(
          'Your darts are saved. Resume from the main menu whenever '
          'you like.',
          style: Type.body.copyWith(color: Palette.chalkDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('STAY'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('LEAVE'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Widget _build(
    BuildContext context,
    WidgetRef ref,
    BullingSession session,
    BullingController controller,
    Map<int, String> names,
    BullingLegState leg,
  ) {
    final connectionState = ref.watch(boardConnectionProvider).value;
    final boardConnected = connectionState?.isConnected ?? false;
    final manualOverride = ref.watch(keypadOverrideProvider);
    final keypadVisible = !boardConnected || manualOverride;

    // Both bull segments always score in this mode — there is no
    // per-player "current target" the way Around the Clock's track has
    // one, so the highlight never changes with whose turn it is.
    final highlight = leg.isFinished || session.awaitingTurnConfirm
        ? const <Segment>{}
        : const {Segment.outerBull, Segment.innerBull};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${bullseyeValueLabel(leg.config.bullseyeValue)} · '
          'FIRST TO ${leg.config.target}',
        ),
        actions: [
          if (boardConnected)
            IconButton(
              key: const Key('keypad-override-toggle'),
              onPressed: () =>
                  ref.read(keypadOverrideProvider.notifier).toggle(),
              icon: Icon(
                manualOverride ? Icons.videogame_asset : Icons.dialpad,
              ),
              tooltip: manualOverride
                  ? 'Hide manual entry'
                  : 'Enter a score by hand',
            ),
          IconButton(
            onPressed: leg.darts.isEmpty ? null : controller.undo,
            icon: const Icon(Icons.undo),
            tooltip: 'Undo last dart',
          ),
          const SizedBox(width: Gap.xs),
        ],
      ),
      body: SafeArea(
        child: Column(
          key: const Key('bulling-game-body'),
          children: [
            _Scoreboard(leg: leg, names: names),
            const Divider(),
            _TurnLedger(session: session, names: names),
            const Divider(),
            Expanded(
              child: session.awaitingTurnConfirm
                  ? _TurnConfirm(
                      turn: session.pendingTurn!,
                      leg: leg,
                      names: names,
                      onConfirm: controller.confirmTurn,
                      onUndo: controller.undo,
                    )
                  : leg.isFinished
                  ? _LegWon(
                      leg: leg,
                      names: names,
                      onPlayAgain: () => _playAgain(ref, leg.config),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Gap.md,
                        Gap.sm,
                        Gap.md,
                        Gap.md,
                      ),
                      child: keypadVisible
                          ? DartKeypad(
                              onDart: (segment) =>
                                  controller.addDart(ThrownDart(segment)),
                              onMiss: () => controller.addDart(
                                const ThrownDart.miss(),
                              ),
                              highlight: highlight,
                            )
                          : const _BoardScoringAlone(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown in the keypad's place while a real board is scoring for itself.
class _BoardScoringAlone extends StatelessWidget {
  const _BoardScoringAlone();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'THROW WHEN READY',
        style: Type.eyebrow.copyWith(color: Palette.chalkDim),
      ),
    );
  }
}

/// Players side by side, the running score in place of a remaining score —
/// the same "only the thrower is lit" idiom `game_screen.dart`'s
/// `_PlayerColumn` and `atc_game_screen.dart`'s use.
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.leg, required this.names});

  final BullingLegState leg;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final players = leg.config.playerIds;

    return Padding(
      key: const Key('bulling-scoreboard'),
      padding: const EdgeInsets.only(top: Gap.sm, bottom: Gap.lg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var seat = 0; seat < players.length; seat++) ...[
              if (seat > 0) const VerticalDivider(width: 1),
              Expanded(
                child: _PlayerColumn(
                  name: nameFor(names, players[seat]),
                  score: leg.scoreFor(players[seat]),
                  target: leg.config.target,
                  live:
                      players[seat] == leg.currentPlayerId && !leg.isFinished,
                  won: leg.winnerId == players[seat],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlayerColumn extends StatelessWidget {
  const _PlayerColumn({
    required this.name,
    required this.score,
    required this.target,
    required this.live,
    required this.won,
  });

  final String name;
  final int score;
  final int target;
  final bool live;
  final bool won;

  @override
  Widget build(BuildContext context) {
    final accent = won ? Palette.trebleBed : Palette.live;
    final lit = live || won;

    return Column(
      children: [
        Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: Gap.lg),
          color: lit ? accent : Colors.transparent,
        ),
        const SizedBox(height: Gap.md),
        Text(
          name.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Type.eyebrow.copyWith(color: lit ? accent : Palette.chalkDim),
        ),
        const SizedBox(height: Gap.sm),
        Expanded(
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                '$score',
                style: Type.score.copyWith(
                  color: lit ? Palette.chalk : Palette.chalkDim,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Gap.xs),
        Text(
          'of $target',
          style: Type.label.copyWith(color: Palette.chalkDim),
        ),
      ],
    );
  }
}

/// The turn in progress, dart by dart — the same idiom
/// `atc_game_screen.dart`'s `_TurnLedger` uses, minus the bust
/// strikethrough this mode has no use for.
class _TurnLedger extends StatelessWidget {
  const _TurnLedger({required this.session, required this.names});

  final BullingSession session;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final pending = session.pendingTurn;
    final darts = pending?.darts ?? session.leg.currentTurnDarts;
    final scored = pending?.scored ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Gap.md,
        vertical: Gap.md,
      ),
      child: Row(
        children: [
          for (var i = 0; i < dartsPerTurn; i++) ...[
            if (i > 0) const SizedBox(width: Gap.sm),
            Expanded(
              child: _DartSlot(dart: i < darts.length ? darts[i] : null),
            ),
          ],
          const SizedBox(width: Gap.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 72),
            child: Text(
              scored == 0 ? '·' : '+$scored',
              textAlign: TextAlign.right,
              style: Type.scoreSmall.copyWith(
                color: scored == 0 ? Palette.chalkDim : Palette.live,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DartSlot extends StatelessWidget {
  const _DartSlot({required this.dart});

  final ThrownDart? dart;

  @override
  Widget build(BuildContext context) {
    final empty = dart == null;

    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(vertical: Gap.xs),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: empty ? Palette.sunk : Palette.raised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.edge),
      ),
      child: Text(
        empty ? '·' : dart!.label,
        style: Type.notation.copyWith(
          color: empty ? Palette.chalkDim : Palette.chalk,
        ),
      ),
    );
  }
}

/// Held after every turn, in place of the keypad — the same reasoning as
/// `atc_game_screen.dart`'s `_TurnConfirm`.
class _TurnConfirm extends StatelessWidget {
  const _TurnConfirm({
    required this.turn,
    required this.leg,
    required this.names,
    required this.onConfirm,
    required this.onUndo,
  });

  final BullingTurn turn;
  final BullingLegState leg;
  final Map<int, String> names;
  final VoidCallback onConfirm;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final dartsThrown = turn.darts.map((dart) => dart.label).join('  ·  ');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Column(
          children: [
            const SizedBox(height: Gap.xl),
            Text(
              nameFor(names, turn.playerId).toUpperCase(),
              style: Type.eyebrow.copyWith(color: Palette.chalkDim),
            ),
            const SizedBox(height: Gap.md),
            Text(
              turn.scored == 0
                  ? 'NOTHING SCORED'
                  : turn.scored == 1
                  ? '1 POINT SCORED'
                  : '${turn.scored} POINTS SCORED',
              style: Type.score.copyWith(color: Palette.chalk),
            ),
            const SizedBox(height: Gap.sm),
            Text(
              'now on ${turn.scoreAfter}',
              style: Type.label.copyWith(color: Palette.chalkDim),
            ),
            if (dartsThrown.isNotEmpty) ...[
              const SizedBox(height: Gap.md),
              Text(
                dartsThrown,
                style: Type.label.copyWith(color: Palette.chalkDim),
              ),
            ],
            const SizedBox(height: Gap.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onUndo,
                    child: const Text('WRONG'),
                  ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: onConfirm,
                    child: Text(leg.isFinished ? 'FINISH' : 'NEXT PLAYER'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.md),
            Text(
              'or press the board button',
              style: Type.label.copyWith(color: Palette.chalkDim),
            ),
          ],
        ),
      ),
    );
  }
}

/// The end of a leg. No match to fold in — v1 has none — so this simply
/// offers another leg under the same config.
class _LegWon extends StatelessWidget {
  const _LegWon({
    required this.leg,
    required this.names,
    required this.onPlayAgain,
  });

  final BullingLegState leg;
  final Map<int, String> names;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final winner = leg.winnerId!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.lg),
        child: Column(
          children: [
            Text(
              'LEG WON',
              style: Type.eyebrow.copyWith(color: Palette.trebleBed),
            ),
            const SizedBox(height: Gap.md),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                nameFor(names, winner).toUpperCase(),
                style: Type.score.copyWith(color: Palette.chalk),
              ),
            ),
            const SizedBox(height: Gap.lg),
            Text(
              '${leg.scoreFor(winner)} points · '
              '${leg.dartsThrownBy(winner)} darts',
              style: Type.label.copyWith(color: Palette.chalkDim),
            ),
            const SizedBox(height: Gap.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('bulling-play-again'),
                onPressed: onPlayAgain,
                child: const Text('PLAY AGAIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run the full existing suite to verify nothing broke**

Run: `flutter analyze`
Expected: no errors — this file completes the import Task 8's setup screen
needs.

Run: `flutter test test/app/select_game_mode_screen_test.dart test/app/bulling_controller_test.dart`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add lib/app/screens/bulling_game_screen.dart
git commit -m "feat(bulling): add BullingGameScreen"
```

---

## Task 10: Resumable Bulling legs

**Files:**
- Modify: `lib/app/providers.dart` (add `ResumableBullingLeg`, extend the
  `resumableLegProvider` switch)
- Modify: `lib/app/screens/main_menu_screen.dart:1-67` (import, `_resume`
  switch), `:227-259` (`_ResumeBanner` switch)
- Modify: `test/app/resumable_leg_provider_test.dart` (add a Bulling
  round-trip test)

**Interfaces:**
- Consumes: `BullingConfig`, `BullingLegState`, `foldBulling` (Task 2);
  `loadBullingConfig` (Task 6); `bullseyeValueLabel` (Task 8);
  `bullingConfigProvider`, `bullingGameProvider` (Task 7);
  `BullingGameScreen` (Task 9).
- Produces: `class ResumableBullingLeg extends ResumableLeg {gameId, leg}`.
  `resumableLegProvider` yields `ResumableBullingLeg` for a
  `GameMode.bulling` row. `main_menu_screen.dart` resumes and renders a
  Bulling leg exactly as it does x01 and Around the Clock ones.

- [ ] **Step 1: Write the failing test**

Add to `test/app/resumable_leg_provider_test.dart`, alongside the existing
imports:

```dart
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
```

Add a new `test`, next to the "ATC leg" one:

```dart
  test('a Bulling leg round-trips as ResumableBullingLeg', () async {
    final finn = await repository.addPlayer('Finn');
    final gameId = await repository.startBullingGame(
      BullingConfig(
        playerIds: [finn.id],
        bullseyeValue: BullseyeValue.two,
        target: 21,
      ),
    );
    await repository.appendDart(
      gameId: gameId,
      ordinal: 0,
      playerId: finn.id,
      dart: ThrownDart(Segment.outerBull),
    );

    final resumable = await readResumable();
    expect(resumable, isA<ResumableBullingLeg>());
    expect(resumable!.gameId, gameId);
    expect((resumable as ResumableBullingLeg).leg.scoreFor(finn.id), 1);
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/app/resumable_leg_provider_test.dart`
Expected: FAIL — `ResumableBullingLeg` does not exist and
`resumableLegProvider`'s switch has no `bulling` case (a `GameMode.bulling`
row currently falls through unhandled, which is itself a compile error
once the enum has three values and the switch is non-exhaustive — the
switch must already have been made to cover it, or this fails to compile).

- [ ] **Step 3: Write the minimal implementation**

Edit `lib/app/providers.dart`. Add, next to `ResumableAtcLeg`:

```dart
class ResumableBullingLeg extends ResumableLeg {
  const ResumableBullingLeg({required super.gameId, required this.leg});

  final BullingLegState leg;
}
```

Extend the `switch (game.gameMode)` inside `resumableLegProvider`:

```dart
    switch (game.gameMode) {
      case GameMode.x01:
        final config = await repository.loadConfig(gameId);
        if (config == null) {
          yield null;
          continue;
        }
        yield ResumableX01Leg(
          gameId: gameId,
          leg: foldLeg(config, await repository.loadLog(gameId)),
        );
      case GameMode.aroundTheClock:
        final config = await repository.loadAtcConfig(gameId);
        if (config == null) {
          yield null;
          continue;
        }
        yield ResumableAtcLeg(
          gameId: gameId,
          leg: foldAroundTheClock(config, await repository.loadLog(gameId)),
        );
      case GameMode.bulling:
        final config = await repository.loadBullingConfig(gameId);
        if (config == null) {
          yield null;
          continue;
        }
        yield ResumableBullingLeg(
          gameId: gameId,
          leg: foldBulling(config, await repository.loadLog(gameId)),
        );
    }
```

Edit `lib/app/screens/main_menu_screen.dart`. Add imports:

```dart
import '../domain/bulling/bulling_config.dart' show BullingConfig;
import 'bulling_game_screen.dart';
import 'bulling_setup_screen.dart' show bullseyeValueLabel;
```

(`BullingConfig` is only referenced by type inference here, so the explicit
import may be trimmed by the linter if unused directly — keep it only if
`flutter analyze` flags it as needed; the two screen/label imports are
required.)

Extend the `switch (resumable)` inside `_resume`:

```dart
      case ResumableBullingLeg(:final gameId):
        final repository = ref.read(gameRepositoryProvider);
        final config = await repository.loadBullingConfig(gameId);
        if (config == null || !context.mounted) return;
        final darts = await repository.loadLog(gameId);
        if (!context.mounted) return;

        ref.read(bullingConfigProvider.notifier).update(config);
        ref.read(currentGameIdProvider.notifier).set(gameId);
        ref.read(bullingGameProvider.notifier).resume(config, darts);

        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const BullingGameScreen(),
          ),
        );
```

Extend the `switch (resumable)` inside `_ResumeBanner.build`:

```dart
    final (format, playerIds, currentPlayerId, figures) = switch (resumable) {
      ResumableX01Leg(:final leg) => (
        '${leg.config.startScore}',
        leg.config.playerIds,
        leg.currentPlayerId,
        <int, String>{
          for (final id in leg.config.playerIds) id: '${leg.remaining[id]}',
        },
      ),
      ResumableAtcLeg(:final leg) => (
        atcVariantLabel(leg.config.variant),
        leg.config.playerIds,
        leg.currentPlayerId,
        <int, String>{
          for (final id in leg.config.playerIds)
            id: leg.currentStopFor(id).label,
        },
      ),
      ResumableBullingLeg(:final leg) => (
        '${bullseyeValueLabel(leg.config.bullseyeValue)} · ${leg.config.target}',
        leg.config.playerIds,
        leg.currentPlayerId,
        <int, String>{
          for (final id in leg.config.playerIds) id: '${leg.scoreFor(id)}',
        },
      ),
    };
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/app/resumable_leg_provider_test.dart test/app/main_menu_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/providers.dart lib/app/screens/main_menu_screen.dart test/app/resumable_leg_provider_test.dart
git commit -m "feat(bulling): resume a Bulling leg from the main menu"
```

---

## Task 11: Bulling section on the stats screen

**Files:**
- Modify: `lib/app/screens/stats_screen.dart:66-213` (`_Body.build`)

**Interfaces:**
- Consumes: `BullingStats` (Task 4, exported via `mode_stats.dart`);
  `playerStatsProvider` (already updated in Task 7).
- Produces: a rendered "BULLING" section, following the same layout the
  "AROUND THE CLOCK" section already uses.

No new automated test — `stats_screen.dart` has no dedicated widget test
today (only `test/app/stats_query_test.dart`, which exercises
`computeX01Stats` alone, and `BullingStats`/`computeBullingStats` already
have full domain coverage from Task 4). This task is manually verified in
Task 12.

- [ ] **Step 1: Edit the file**

In `_Body.build`, add the cast next to the existing two:

```dart
    final x01 = statsByMode[GameMode.x01] as X01Stats?;
    final atc = statsByMode[GameMode.aroundTheClock] as AtcStats?;
    final bulling = statsByMode[GameMode.bulling] as BullingStats?;
```

Add the presence flag next to the existing two:

```dart
    final hasX01 = x01 != null && x01.legsPlayed > 0;
    final hasAtc = atc != null && atc.legsPlayed > 0;
    final hasBulling = bulling != null && bulling.legsPlayed > 0;
```

Update the combined empty check:

```dart
    if (!hasX01 && !hasAtc && !hasBulling) {
      return _Empty(
        headline: 'No legs yet',
        detail: 'Play a leg and every dart in it lands here.',
      );
    }
```

Add, right after the `if (hasAtc) ...` block's closing `],`:

```dart
          if (hasBulling) ...[
            if (hasX01 || hasAtc) const SizedBox(height: Gap.xl),
            const _Eyebrow('BULLING'),
            const SizedBox(height: Gap.sm),
            _Headline(
              value: _percent(bulling.hitRate),
              label: 'Hit rate',
              detail: '${bulling.scoringDarts} of ${bulling.dartsThrown} darts',
            ),
            const SizedBox(height: Gap.xl),
            _Section(
              title: 'Legs',
              rows: [
                _Row('Won', '${bulling.legsWon} of ${bulling.legsPlayed}'),
                _Row('Win rate', _percent(bulling.winRate)),
                _Row(
                  'Best leg',
                  _optional(bulling.fewestDartsToWin, suffix: ' darts'),
                ),
              ],
            ),
            _Section(
              title: 'Scoring',
              rows: [
                _Row('Points scored', '${bulling.pointsScored}'),
                _Row('Outer bull hits', '${bulling.outerBullHits}'),
                _Row('Bullseye hits', '${bulling.innerBullHits}'),
              ],
            ),
          ],
```

- [ ] **Step 2: Run the existing suite to verify nothing broke**

Run: `flutter analyze`
Expected: no errors.

Run: `flutter test test/app/`
Expected: PASS (no test names this file directly, but every widget test
that pumps `StatsScreen`, if any, and the whole `test/app/` suite must
stay green).

- [ ] **Step 3: Commit**

```bash
git add lib/app/screens/stats_screen.dart
git commit -m "feat(bulling): show Bulling stats on the stats screen"
```

---

## Task 12: Final verification

**Files:** none (verification only).

- [ ] **Step 1: Run the full analyzer**

Run: `flutter analyze`
Expected: "No issues found!"

- [ ] **Step 2: Run the pure-Dart domain and data suites**

Run: `dart test test/domain test/data`
Expected: PASS, including the new `test/domain/bulling/` files, the
updated `test/domain/game_mode_test.dart`, and the domain purity check
(`test/domain/domain_purity_test.dart`), which now also covers
`lib/domain/bulling/` and `lib/domain/stats/bulling_stats.dart`.

- [ ] **Step 3: Run the full Flutter suite**

Run: `flutter test`
Expected: PASS, including every modified and new file under `test/app/`.

- [ ] **Step 4: Manually verify a leg end to end**

Use the `run` skill (or `flutter run`) to launch the app against a
connected board or the fake board source, and play one full Bulling leg:
open Select Game Mode, tap BULLING, pick a bullseye value and a target,
add at least two players, start the leg, throw darts (through the keypad
if no board is connected), confirm at least one turn, and win the leg by
reaching the target. Confirm:
- Non-bull darts visibly add nothing to the score.
- The outer bull adds 1, the inner bull adds 2 or 3 per the chosen value.
- The leg ends the instant the target is reached or passed, even mid-turn.
- "PLAY AGAIN" starts a fresh leg under the same config.
- Leaving mid-leg and resuming from the main menu restores the score and
  whose turn it is.
- The stats screen shows a "BULLING" section for a player who has played
  at least one leg.

- [ ] **Step 5: Update the knowledge graph**

Run: `graphify update .`

- [ ] **Step 6: Commit any final cleanup**

If Steps 1-4 required no changes, there is nothing to commit — the feature
is already fully committed task by task. If they did surface a fix,
commit it with a message describing what verification caught.

---

## Self-review notes

- **Spec coverage:** every decision recorded under "Design, precisely" has
  a task: `BullseyeValue`/`BullingConfig` (Task 1), the fold and instant-win
  rule (Task 2), mode registration (Task 3), stats (Task 4), persistence
  (Tasks 5-6), scoring UI and controller (Tasks 7-9), resume (Task 10),
  stats display (Task 11).
- **Placeholder scan:** every step carries real code — no "add appropriate
  handling" language anywhere in this plan.
- **Type consistency:** `BullingConfig{playerIds, bullseyeValue, target}` is
  used with those exact field names in every task from 1 onward;
  `BullingLegState.scoreFor(int)` (not `remaining`/`score(...)`) is used
  consistently in Tasks 2, 6, 9, 10, 11; `pointsFor(Segment?, BullseyeValue)`
  keeps the same signature in Tasks 2 and 4; `foldBulling`/
  `initialBullingLegState` are named identically everywhere they are
  imported.
