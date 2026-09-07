# Architecture

How Chalk is put together, and why the seams are where they are.

## Three layers, one rule

```
lib/
├── domain/   pure Dart. The x01 fold, the checkout search, the match fold,
│             the statistics. Imports nothing from Flutter.
├── data/     the board protocol and the drift database.
└── app/      Riverpod providers, screens, widgets, audio.
```

**`lib/domain/` must not import `package:flutter`.**
`test/domain/domain_purity_test.dart` asserts this mechanically. If it ever
fails, the fix is to move the Flutter-dependent code out of `domain/`, not to
relax the test. The rules of x01 and the search for a checkout are the parts
worth testing hardest, so they live somewhere a widget cannot reach and a test
can run under plain `dart test`.

Dependencies point one way only: `app` → `data` → `domain`. Nothing in
`domain/` knows a database exists; nothing in `domain/` or `data/` knows a
sound exists.

## Everything is a fold

The central decision. **No running totals are stored anywhere.** A leg is the
list of darts thrown in it; a match is the list of legs won in it. State is
recomputed from those lists.

```
List<ThrownDart> ──foldLeg(config, darts)──▶ LegState
List<int> winners ──foldMatch(config, ...)──▶ MatchState
```

| | Input | Output |
|---|---|---|
| `foldLeg` (`lib/domain/x01/leg_reducer.dart`) | `GameConfig` + every dart in order | remaining per player, turns, current seat, winner |
| `foldMatch` (`lib/domain/x01/match_state.dart`) | `MatchConfig` + the winner of each finished leg | legs won per player, match winner, who throws next |

Undo is therefore *folding a shorter list*. Undoing the dart that checked out a
leg — even the one that won the match — puts the tally, the winner, the end
screen and the statistics back with nothing to retract, because nothing was
ever written forward. The same property is what lets a stored leg be replayed
into exactly the state it was played to.

Two consequences worth naming:

- **A leg's starting seat is not stored.** It is rebuilt from the leg's number
  in its match: `startingSeatForLeg(legNumber, playerCount) = legNumber % playerCount`.
  Change that rule and history replays differently, which is why it is a
  free-standing function with its own tests rather than a line inside a widget.
- **Statistics are computed from replayed legs**, not from counters updated as
  darts land. `computePlayerStats` takes `Iterable<LegState>`, so a figure on
  the statistics screen and the same figure on the match card are produced by
  the same code.

## The domain in detail

### x01

`GameConfig` holds the rules of one leg: start score, seats in throwing order,
double-out, and which seat throws first. Its constructor asserts the
invariants — score above 1, one to four seats, no player in two seats, a
starting seat that exists.

`foldLeg` walks the darts, opening a turn every three darts (or on a bust or a
checkout), and produces `LegState`: `remaining` per player, the list of
completed `Turn`s, whose turn it is, how many darts are left in it, and the
winner if there is one. Bust rules are applied inside the fold — a turn that
goes below zero, to exactly one, or to zero without a double scores nothing and
the player returns to where they started it.

### Matches

`MatchConfig` is the format: start score, seats, double-out, `legsToPlay`.
The rule it actually plays is **first to `legsToWin`**, where
`legsToWin = legsToPlay ~/ 2 + 1`.

Head to head, "first to 3" and "best of 5" are the same sentence. With three or
more players they are not: nobody need reach the target inside `legsToPlay`
legs — three players can take one leg each of a best of three — and the match
runs on until somebody does. `MatchConfig.formatLabel` says `BEST OF 5` for a
pair and `FIRST TO 3` for a field, so the screen never claims a rule the engine
is not playing.

### Checkouts

`findCheckouts(score, dartsLeft, {limit})`
(`lib/domain/checkout/checkout_search.dart`) finds the routes out from any score
up to `maxCheckout = 170`, respecting the darts left in the turn and the
double-out requirement. `CheckoutTable.routesFor` caches the answers so the
search does not re-run on every dart. The
game screen shows the best route and the alternates, and passes the route's
segments to the keypad, which outlines the matching keys — so the advice can be
followed without reading it.

## The app layer

Providers are written **by hand**. `riverpod_generator` needs `analyzer ^13`
while `drift_dev` pins an older one, and `riverpod_lint` caps
`riverpod_annotation <4.0.0`, so neither codegen nor the lints are available.
That makes provider mistakes uncaught by tooling and is why they are kept few
and small.

```
boardSourceProvider ──▶ boardReaderProvider ──▶ boardEventsProvider
                                                      │
gameConfigProvider ──────────────┐                    ▼
                                 ├──▶ gameProvider (GameController)
currentGameIdProvider ───────────┘         │
                                           ├──▶ matchStateProvider ──▶ game screen
matchProvider (MatchController) ───────────┘
                                           └──▶ soundControllerProvider ──▶ SoundPlayer

gameRepositoryProvider ──▶ allLegsProvider ──┐
                       └──▶ allMatchesProvider ├──▶ playerStatsProvider
                                              ┘
```

- **`GameController`** owns the leg on screen. It appends darts, holds each turn
  for confirmation, undoes, and persists as it goes.
- **`MatchController`** owns the match around it: `start`, `startNextLeg`,
  `resumeFrom`, `rematch`, `leave`. It deliberately holds only the legs *behind*
  the current one; the leg being played is read from `gameProvider`, which is
  what keeps the tally honest through an undo.
- **`matchStateProvider`** folds the two together on demand.

### Audio

Sound is a **pure consequence of a state transition**, and the domain never
learns it exists.

```
GameSession (before) ──┐
                       ├──▶ soundsFor(previous, next) ──▶ List<Sound> ──▶ SoundPlayer
GameSession (after)  ──┘
```

`soundsFor` is a pure function, so the entire mapping is tested with no audio
device and no plugin. Its central guard: a dart is *exactly one entry appended
to the log*, so anything that moves the log by more than one — a restart, a
resume, an undo, the start of the next leg — plays nothing. Resuming a stored
leg would otherwise read out the total of a turn thrown yesterday.

Two players are held open. Cues run on `PlayerMode.lowLatency` (a SoundPool of
decoded PCM on Android) because a click that lags is worse than no click;
commentary runs on the normal media player, where a few tens of milliseconds do
not matter. The four cues are warmed at startup; the 186 spoken lines are not,
because they are needed once a turn rather than three times.

Spoken lines wait for the cue under them — `SoundTiming.afterBustCue` and
friends — so the pair reads as one event instead of two sounds fighting.

### Layout

Two breakpoints, both `lib/app/theme.dart`, both keyed to the device's
shortest side rather than a `LayoutBuilder`'s local width — the same question
`typeScaleFor` answers, and the two are meant to move together:

- `wideLayout = 600` — below it the game screen stacks scoreboard, ledger,
  then keypad in a column; above it, scoreboard and ledger go left, whatever
  is asking for a decision goes right. The right-hand side is the same widget
  in both arrangements; only where it sits moves. Nothing shrinks to fit,
  because the size of the score is what makes it readable from the oche.
- `heroLayout = 780` — measured against a Samsung Galaxy Tab S6 Lite
  (800dp shortest side at its shipped display size; see the doc comment on
  `heroLayout` for the `adb shell wm size`/`wm density` numbers), a real
  tablet's threshold rather than a round guess. At or above it: the
  scoreboard becomes per-player hero cards (`_HeroPlayerCard`) instead of a
  thin row, a turn's result becomes a full-screen takeover
  (`Positioned.fill` in the same `Stack` `_MatchWon` already used) instead of
  sharing the play slot, and checkout gets its own panel (`_CheckoutPanel`)
  instead of a strip. `_Scaled` in `main.dart` also locks the app to
  landscape at this threshold — a scoreboard on a stand is mounted once, not
  rotated screen to screen.

`typeScaleFor(size)` grows type on large viewports, keyed to the shortest
side and applied once around the whole app in `main.dart` on top of the
platform's own text setting; its top tier lines up with `heroLayout`. The
panels built around `Spacer`s are wrapped in `_FitOrScroll`, which gives them
the height when there is height and a scroll when there is not.

Setup and statistics are both one column of controls sized for a phone.
`CenteredContent` (`lib/app/theme.dart`) caps that column at
`formContentWidth` (640) and centers it, so a tablet's extra width becomes
margin rather than a stretched, sparse form — invisible on any screen
narrower than the cap.

### The keypad and a connected board

`DartKeypad` is the manual-entry path — a player taps in what landed, and it
calls `addDart` directly regardless of what is feeding the board. Once a real
board is actually connected (`boardConnectionProvider`'s
`BoardConnectionState.connected`), the keypad hides itself: the board is
trusted to score for itself, and a corner toggle on `game_screen` (labelled
Manual/Bluetooth mode) brings the keypad back for a hand-entered correction.
While that override is open, `GameController` suppresses board-driven
`DartHit`/`BoardMiss` events (`keypadOverrideProvider`, checked in
`handleBoardEvent`) so the same dart cannot score twice, once from the tap and
once from the board's own frame. `ButtonPress` (`BTN@`) is never suppressed —
confirming a turn is not scoring, and stays useful with the keypad pulled up.

This is unrelated to `boardSourceProvider`/`FakeBoardSource`: that picks which
`BoardSource` implementation feeds the app, and in-app is always
`BleBoardSource` now that hardware day has confirmed it works — only tests
still reach for the scripted `FakeBoardSource`, by overriding the provider
directly. There is no runtime switch between them any more.

## Where to start reading

| If you want to understand… | Read |
|---|---|
| the rules of the game | `lib/domain/x01/leg_reducer.dart` |
| what a match is | `lib/domain/x01/match_state.dart` |
| how a dart gets from the board to the screen | `lib/data/board/frame_assembler.dart`, then `segment_codec.dart`, then `lib/app/game_controller.dart` |
| what is stored | [DATA_MODEL.md](DATA_MODEL.md) |
| why a sound plays | `lib/app/audio/sound_controller.dart` |
