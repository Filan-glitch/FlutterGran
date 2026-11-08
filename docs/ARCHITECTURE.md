# Architecture

How Chalk is put together, and why the seams are where they are.

## Three layers, one rule

```
lib/
├── domain/   pure Dart. One folder per mode with its config and fold, the
│             match fold, the checkout search, the statistics. Imports
│             nothing from Flutter.
├── data/     the board protocol, the drift database, the update check.
└── app/      Riverpod providers, controllers, screens, widgets, audio,
              lights, the update flow.
```

The full file map and naming conventions are in
[CONTRIBUTING.md](../CONTRIBUTING.md#project-map).

**`lib/domain/` must not import `package:flutter`.**
`test/domain/domain_purity_test.dart` asserts this mechanically (it also
rejects `dart:ui` and `package:drift`). If it ever
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
  the same code. The repository hands legs out as `Dated<LegState>`
  (`lib/domain/stats/dated.dart`), stamped with their game's `startedAt`, so a
  time range is a filter (`playedSince`) and a trend point is the same
  calculator run over one day's legs (`byDay`).

## The domain in detail

### x01

`GameConfig` holds the rules of one leg: start score, seats in throwing order,
the in-rule and out-rule, and which seat throws first. The rules are two
independent enums, `X01InRule` and `X01OutRule` (`straight`, `double`,
`master`), in `lib/domain/x01/x01_rules.dart`; `opens` and `checksOut` are the
predicates for a legal first and last dart. Its constructor asserts the
invariants — score above 1, one to four seats, no player in two seats, a
starting seat that exists.

`foldLeg` walks the darts, opening a turn every three darts (or on a bust or a
checkout), and produces `LegState`: `remaining` per player, the list of
completed `Turn`s, whose turn it is, how many darts are left in it, and the
winner if there is one. The in-rule and bust rules are applied inside the
fold: nothing scores until a dart `opens` under the in-rule, and a turn that
goes below zero, leaves 1 under any out-rule but straight, or reaches zero on
a dart that does not `checksOut` scores nothing and the player returns to where
they started it.

### Matches

`MatchConfig` is the format: start score, seats, in- and out-rule,
`legsToPlay`.
The rule it actually plays is **first to `legsToWin`**, where
`legsToWin = legsToPlay ~/ 2 + 1`.

Head to head, "first to 3" and "best of 5" are the same sentence. With three or
more players they are not: nobody need reach the target inside `legsToPlay`
legs — three players can take one leg each of a best of three — and the match
runs on until somebody does. `MatchConfig.formatLabel` says `BEST OF 5` for a
pair and `FIRST TO 3` for a field, so the screen never claims a rule the engine
is not playing.

### Game modes

`GameMode` (`lib/domain/game_mode.dart`) has four members: `x01`,
`aroundTheClock`, `bulling` and `higherLower`. `gameModeRegistry` holds a
`GameModeDescriptor` for each, and the select-mode screen renders one tile per
entry. Training has its own engine (`lib/domain/training/`) but is not a
`GameMode`: nothing about it is stored. See "Training drills" below.

### Training drills

`TrainingDrill` lists five drills. `TrainingController.start` takes a sealed
`TrainingPlan` (one per drill, carrying its settings) and holds a sealed
`TrainingSession` (one per drill, wrapping its folded state). Every drill is a
pure fold:

| Drill | Fold | Built from |
| --- | --- | --- |
| Free practice | `foldFreePractice` | darts in threes |
| Checkout Challenge | `foldCheckoutChallenge(config, targets, darts)` | one-visit `CheckoutAttempt`s |
| 121 Ladder | `foldLadder121` | three-visit `CheckoutAttempt`s |
| Bob's 27 | `foldBobs27` | visits at D1-D20 and the bull |
| Weak-spot Trainer | `foldWeakSpot(config, targets, darts)` | one visit per `AimTarget` |

Checkout Challenge and the Weak-spot Trainer draw random targets. The drawn
targets are an input to the fold, so it stays pure and undo is a replay; the
controller draws the next one (`drawCheckoutTarget`, `drawWeakSpotTarget`,
both via `training_random.dart`, never repeating the previous target) from
`trainingRandomProvider`, which tests override with a seeded `Random`. Undo
trims any target drawn after the dart it takes back.

The design follows the motor-learning literature: random rather than repeated
targets (contextual interference), difficulty that tracks success (the
challenge-point framework: Checkout Challenge's adaptive levels climb on a
checkout and drop after two misses in a row, settling near 38% success),
something at stake (pressure training: Bob's 27, the ladder), and a summary at
the end of every drill (knowledge of results).

The Weak-spot Trainer weights each target by `1 - (hits + 1) / (attempts + 2)`
over the player's history plus the session. History comes from
`inferAimRecords` (`lib/domain/training/aim_records.dart`) via
`aimRecordsProvider`: no table stores what a dart was aimed at, so it is
rebuilt from the rules - double-out x01 darts on a one-dart finish, Around the
Clock stops (not masters, where the aim is ambiguous), and every Bulling dart.

Each mode has its own config, leg state and fold, in its own folder
(`lib/domain/atc/`, `bulling/`, `higher_lower/`, `x01/`), rather than a generic
`GameEngine` interface: the modes share the shape "a pure fold over the dart
log" and nothing else worth abstracting. The mode is threaded through storage
and statistics:

- `Games.gameMode` / `Matches.gameMode` record which mode a leg or match was
  played under, stored by name like `DartEvents.ring`. Every
  `GameRepository.watchAll*Legs` filters on it, so a row is only ever folded
  through the reducer of the mode it was played in.
- `ModeStats` (`lib/domain/stats/mode_stats.dart`) is a sealed base type with
  four variants, `X01Stats`, `AtcStats`, `BullingStats` and `HigherLowerStats`,
  each in its own `part` file so the `sealed` exhaustiveness check holds.
  `computePlayerStats` returns `Map<GameMode, ModeStats>` - one entry per mode
  a player has a record in - built from per-mode calculators
  (`computeX01Stats`, `computeAtcStats`, ...). The statistics screen sections
  itself the same way: one tab per mode the player has ever played
  (`playedModesProvider`), nothing for a mode with nothing in it.

Which x01 figures the statistics screen leads with follows the research on
what decides matches: three-dart average and checkout rate are the two
strongest predictors (Liebscher & Kirschstein 2017), checkout per *visit* and
the scoring average (visits that could not finish) predict better still, and
legs won inside a hundred-average pace (15 darts at 501,
`X01Stats.fastLegDarts`) beats the plain average as a single figure. A rate
from fewer than ten attempts reads `—` with how many more are needed
(`minRateSample`), since one double from two is not "50%". Win rates divide by
finished legs (`legsFinished`), never by legs entered: an abandoned leg was
neither won nor lost.

Around the Clock (`lib/domain/atc/`) walks 1 to 20 and then the two bulls;
`AtcVariant` decides which rings count on a wedge (`AtcStop.clears`).

Bulling (`lib/domain/bulling/`) scores only the bull: the outer bull is 1, the
bullseye 2 or 3 (`BullseyeValue`), first to the target (21, 31 or 41) wins.

Higher/Lower (`lib/domain/higher_lower/`) is the elimination mode: every turn
must total more than the higher value or less than the lower one (45 and 26 to
start), and each success moves that value to the total. A miss, or a total that
does neither, puts the player out, and the last one standing wins.
`foldHigherLower` keeps the same shape as the other folds: a pure function of
the dart log, so undo brings an eliminated player back for free. It is the one
mode without a config table, because its seats are its whole configuration.

Adding a fifth mode is a checklist, in
[CONTRIBUTING.md](../CONTRIBUTING.md#add-a-game-mode).

### Checkouts

`findCheckouts(score, dartsLeft, {limit, outRule})`
(`lib/domain/checkout/checkout_search.dart`) finds the routes out from any score
between `minCheckoutFor(outRule)` and `maxCheckoutFor(outRule)` (170 under
double-out, 180 otherwise), respecting the darts left in the turn and what the
out-rule accepts as a last dart. `CheckoutTable` caches the answers per
out-rule (`checkoutTableProvider` is a family over `X01OutRule`) so the search
does not re-run on every dart. The
game screen shows the best route and the alternates, and passes the route's
segments to the keypad, which outlines the matching keys — so the advice can be
followed without reading it.

## The app layer

Providers are written **by hand**, with no codegen and no provider lints; why
is in [CONTRIBUTING.md](../CONTRIBUTING.md#golden-rules). Almost all of them
are in `lib/app/providers.dart`; the lights providers are in
`lib/app/lights/lights_providers.dart` and the update ones in
`lib/app/update/update_controller.dart`.

```
boardSourceProvider ──▶ boardReaderProvider ──▶ boardEventsProvider (a Stream)
   │                                                 │ listened to by every controller
   ├──▶ boardConnectionProvider ──▶ keypad visibility, BoardConnectionButton
   └──▶ ledSchedulerProvider ──▶ BoardSource.sendLed

keypadOverrideProvider ──▶ every controller (drops board darts while open)
currentGameIdProvider  ──▶ every controller but training (the row it writes to)

gameConfigProvider ──▶ gameProvider (GameController) ──┬──▶ matchStateProvider
matchProvider (MatchController) ───────────────────────┘
atcConfigProvider ──▶ atcGameProvider (AtcController)
bullingConfigProvider ──▶ bullingGameProvider (BullingController)
higherLowerConfigProvider ──▶ higherLowerGameProvider (HigherLowerController)
trainingProvider (TrainingController)        never persisted

each game provider ──▶ <mode>SoundControllerProvider ──▶ soundPlayerProvider
                   └──▶ <mode>LightsProvider ──▶ ledSchedulerProvider

databaseProvider ──▶ gameRepositoryProvider ──┬──▶ allLegsProvider, allMatchesProvider,
                                              │    allAtcLegsProvider, allBullingLegsProvider,
                                              │    allHigherLowerLegsProvider ──▶ playerStatsProvider,
                                              │    playerTrendProvider, doublesRecordProvider,
                                              │    playedModesProvider   (all but the last cut
                                              │    to statsRangeProvider via statsSinceProvider)
                                              ├──▶ resumableLegProvider ──▶ main menu, splash
                                              └──▶ segmentCountsProvider ──▶ per-mode heatmap

updateProvider (UpdateController) ◀── githubReleasesProvider, updatePlatformProvider
```

Settings are `NotifierProvider<BoolSetting, bool>`s backed by
shared_preferences (`soundEnabledProvider`, `speechEnabledProvider`, the four
`led*Provider`s, `autoConnectProvider`, `updateAutoCheckProvider`), plus
`localeProvider` for the language. `main.dart` keeps the app-lifetime
providers alive by watching them: `ledSchedulerProvider`,
`boardLifecycleProvider` (auto-connect, reconnect on resume, connection
toasts) and `updateLifecycleProvider` (the launch-time update check).

- **`GameController`** owns the x01 leg on screen. It appends darts, holds each
  turn for confirmation, undoes, and persists as it goes. `AtcController`,
  `BullingController` and `HigherLowerController` do the same for their modes;
  `TrainingController` does it without the database.
- **`MatchController`** owns the match around it: `start`, `startNextLeg`,
  `resumeFrom`, `rematch`, `leave`. It deliberately holds only the legs *behind*
  the current one; the leg being played is read from `gameProvider`, which is
  what keeps the tally honest through an undo.
- **`matchStateProvider`** folds the two together on demand.

### Screens

Plain `Navigator.push`/`MaterialPageRoute` throughout - no named routes, no
router package. Eighteen screens (`lib/app/screens/`) in a shallow, linear tree
do not earn one.

```
SplashScreen                                  (MaterialApp's home)
  --pushReplacement--> MainMenuScreen
       [RESUME <leg>]  (shown only while a leg is in progress)
       PLAY       --> SelectGameModeScreen
                          --> X01SetupScreen     --> GameScreen
                          --> AtcSetupScreen     --> AtcGameScreen
                          --> BullingSetupScreen --> BullingGameScreen
                          --> HigherLowerSetupScreen --> HigherLowerGameScreen
       TRAINING   --> TrainingSetupScreen --> TrainingGameScreen
       RULES      --> RulesScreen --> RulesDetailScreen  (phone/tablet; desktop: in place)
       STATISTICS --> StatsScreen
       ROSTER     --> RosterScreen
       SETTINGS   --> SettingsScreen
```

Each setup screen's info button pushes `RulesDetailScreen` for its own mode
directly. The rules section's design is in `docs/RULES_SCREENS.md`.

`SplashScreen` waits on `max(SplashScreen.minimumHold, resumableLegProvider's
first value)` before replacing itself - not for show, but so `MainMenuScreen`
never renders a frame with no Resume card before the database has actually
answered whether there is one. The hold (1 s) is long enough for the tally
mark (`ChalkMark`, `lib/app/widgets/chalk_mark.dart`) to chalk itself in; the
menu then fades in over it while the mark flies into the menu's header as a
`Hero`. It is removed from the back stack by the `pushReplacement`, so the
back button from the main menu exits the app, correctly.

Before the first Flutter frame Android shows its own launch screen: the
ground color with the icon's tally (`drawable/launch_background.xml`, or the
system splash from `values-v31/styles.xml` on Android 12+). There is no
`values-night`: the app is dark in both modes, and a light launch theme is
what flashed white. Windows needs none, since the runner only shows its
window after the first frame.

The main menu has two layouts. On a phone it is one column: header, update
and resume cards, PLAY, then the other actions. On a hero device
(`isHeroDevice`) it splits into two panes, the header, resume card and PLAY
on the left and the update card and the other actions on the right. The
board light sits in its app bar as on every other screen.

The roster is deliberately its own screen, reachable only from the main
menu, with no mode of its own - the same board is played by different
people under different modes, so player management has no business being
owned by any one mode's setup screen. Every setup screen picks players
through the same `PlayerPicker` (`lib/app/widgets/player_picker.dart`):
tap to seat or unseat, and a name typed in is added and seated in one go.
It never deletes anyone. Renaming and deleting a player (their darts and
seat cascade with them - see `GameRepository.removePlayer`) live only in
`RosterScreen`. A tap on
delete hides the player at once behind a 4-second UNDO snackbar, and the
real delete runs when that closes - through a repository captured up front,
so it lands even if the roster was left meanwhile. The snackbar sets
`persist: false`: one with an action otherwise never closes on its own, and
the delete never happened.

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

Every mode has its own mapping of the same shape - `soundsForAtc`,
`soundsForBulling`, `soundsForHigherLower`, `soundsForTraining` - and its own
provider that the game screen watches to keep alive. x01 alone speaks 180s;
the others click every dart, call game on, say "no score" for an empty turn
(Bulling reads its points out) and play the checkout for a win. Higher/Lower
reads out the total of a turn that stays in and plays a bust for one that goes
out.

Two players are held open. Cues run on `PlayerMode.lowLatency` (a SoundPool of
decoded PCM on Android) because a click that lags is worse than no click;
commentary runs on the normal media player, where a few tens of milliseconds do
not matter. The four cues are warmed at startup; the 186 spoken lines are not,
because they are needed once a turn rather than three times. Neither player
has a position updater: audioplayers' default one leaks a per-frame polling
loop on every play of a sound that never completes, which a SoundPool cue
never does - see [CONTRIBUTING.md](../CONTRIBUTING.md#golden-rules).

Spoken lines wait for the cue under them — `SoundTiming.afterBustCue` and
friends — so the pair reads as one event instead of two sounds fighting.

### Lights

The board's LED ring uses the same design as audio, in `lib/app/lights/`:

```
state (before, after) ──▶ ledCuesFor…() ──▶ List<LedCue> ──▶ showFor() ──▶ LedScheduler ──▶ BoardSource.sendLed
state (now)           ──▶ x01Ring / atcRing / … ──▶ resting RingPaint ──┘
```

- **`led_reactions.dart`** holds pure functions, one set per mode, with the same
  one-dart guard as `soundsFor`. Undo and resume light nothing.
  - It also works out the **resting ring**: the checkout route (next dart yellow,
    the rest orange), the Around the Clock target, or turquoise all round for
    bulling. Higher/Lower has no bed to aim at, so its ring stays dark.
- **`led_cue.dart`** is *what* happened. **`led_theme.dart`** is *how it looks*:
  every colour, op, speed and hold time lives there. Seat colours are chosen so
  the RGB effects and the 8-colour ring palette agree.
- **`led_scheduler.dart`** owns the ring.
  - Shows have priorities, so a stray dart can't cut a 180 short.
  - After a show ends, the resting ring is painted back.
  - Writes are spaced at least 60 ms apart, and only the latest one inside a
    gap is sent.
  - While no board is connected it does nothing at all: no writes and no timers.
- **`lights_providers.dart`**:
  - `ledSchedulerProvider` lives for the whole app, watched from `main.dart`.
    It plays the connect sweep.
  - **Outside a game** the ring rests on a slow forest-green pulse
    (`idlePulse` in `led_theme.dart`). Inside one it rests on the game's own ring.
  - Each game screen watches its `…LightsProvider` (autoDispose), which calls
    `enterGame()`. Leaving the screen calls `leaveGame()` and the idle pulse
    comes back.
  - Settings: a master switch plus dart flashes, target ring and celebrations.
    With the master off, nothing is written.

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
  (800dp shortest side at its shipped display size; the measurement is in
  [DEVELOPMENT.md](DEVELOPMENT.md#layout-breakpoints)), a real tablet's
  threshold rather than a round guess. At or above it: the
  scoreboard becomes per-player hero cards instead of a thin row, a turn's
  result becomes a full-screen takeover (`Positioned.fill` in the same
  `Stack` the game-over card uses) instead of sharing the play slot, and the
  aim strip (the checkout card, or Around the Clock's aim card) is drawn at
  its larger `hero` scale. `_Scaled` in `main.dart` also locks the app to
  landscape at this threshold — a scoreboard on a stand is mounted once, not
  rotated screen to screen.

`typeScaleFor(size)` grows type on large viewports, keyed to the shortest
side and applied once around the whole app in `main.dart` on top of the
platform's own text setting; its top tier lines up with `heroLayout`.

A desktop window (`isDesktop`: Windows, plus Linux and macOS should they ever
be added) is the opposite shape to a tablet: wide, short, and any size its
owner drags it to. A maximised 1080p laptop at 150% scaling is about 1280x640
logical, well short of `heroLayout`, so a desktop takes its own route into
the same treatment:

- `isHeroSize` also lets in any desktop window of at least
  `desktopHeroLayout` (900x580). The Windows runner refuses to shrink the
  window below 960x600, so on Windows every window is a hero window.
  `isHeroDevice(context)` (also in `theme.dart`) is the one call sites use;
  never compare `shortestSide` against `heroLayout` directly.
- `typeScaleFor` uses desktop tiers by window height: 1.25 from 580, 1.5
  from 780, 1.75 from 1000 (a full-height window on a monitor at 100%).
- Beside the keypad, the seat cards fill the column's height instead of
  sitting mid-column at their content size, and from 1200 wide the score
  side takes three fifths of the width, the keypad two.
- `CenteredContent` grows its 640 cap by the type scale, so a form keeps a
  tablet's words per line instead of becoming a strip down a monitor.
- No orientation lock is ever requested, and `buildTheme` pins
  `VisualDensity.standard` and padded tap targets, which Flutter would
  otherwise shrink for a mouse.

The panels built around `Spacer`s are wrapped in `FitOrScroll`, which gives
them the height when there is height and a scroll when there is not. The
measurements behind each breakpoint are in
[DEVELOPMENT.md](DEVELOPMENT.md#layout-breakpoints).

Every game screen - x01, Around the Clock, Bulling, Higher/Lower and every
training drill -
is laid out by one `GameLayout` (`lib/app/widgets/game_layout.dart`) and
differs only in what it puts in the slots:

| Slot | Widget | x01 | Around the Clock | Bulling | Higher/Lower | Training |
| --- | --- | --- | --- | --- | --- | --- |
| seats | `Scoreboard` of `SeatView`s | remaining | stop needed + 22-tick rail | points + rail to target | turns survived, or OUT | remaining, level, rung, score or target, plus session rate |
| aim | `AimStrip` | `CheckoutCard` | `AimCard` | - | `BoundsCard` (higher and lower) | `CheckoutCard`, or the target to hit |
| ledger | `TurnLedger` | turn total, struck on a bust | `+n` stops | `+n` points | turn total | turn total |
| turn result | `TurnResultPanel` | score, `before → after` | `+n`, stop → stop | `+n`, score → score | total, `HIGHER 45 → 60` or why out | - |
| outcome | `OutcomePanel` | leg won mid-match | - | - | - | checked out, or the drill's summary |
| game over | `GameOverCard` | match won | leg won | leg won | last one standing | - |

`GameAppBar` gives every one of them the same actions (board light, keypad
toggle while a board is connected, undo), and `LeaveGuard` the same
"we are keeping it" question before leaving a leg with darts in it. A
game that needs something new asks `GameLayout` for a slot rather than
growing its own arrangement.

Setup screens are one column of controls sized for a phone,
built from the same pieces (`lib/app/widgets/setup_controls.dart`):
`SectionLabel`, `NumeralChoiceRow` for numbers (a start score, a target),
`ChoiceRow` for named options as equal-width tiles, and `StartBar`.
`CenteredContent` (`lib/app/theme.dart`) caps that column at
`formContentWidth` (640) and centers it, so a tablet's extra width becomes
margin rather than a stretched, sparse form — invisible on any screen
narrower than the cap.

Statistics is the exception that outgrew that column. Each tab is a row of
headline `StatTile`s (two abreast on a phone, four from 700 wide) over a
`StatsGrid` of `StatCard`s (`lib/app/widgets/stats/`), dealt into one, two or
three columns by the width a `LayoutBuilder` sees (`statsColumnsFor`: 700 and
1100), inside `CenteredContent(maxWidth: 1200)`. Charts are drawn by hand
(`stats_charts.dart`): no chart package for four small charts. Figures in a
row or a split bar shrink to fit rather than overflow, so desktop type sizes
and German labels fit a narrow card.

### The keypad and a connected board

`DartKeypad` is the manual-entry path — a player taps in what landed, and it
calls `addDart` directly regardless of what is feeding the board. Once a real
board is actually connected (`boardConnectionProvider`'s
`BoardConnectionState.connected`), the keypad hides itself: the board is
trusted to score for itself, and a corner toggle in every game's app bar
(`GameAppBar`) brings the keypad back for a hand-entered correction. While
that override is open, every mode's controller suppresses board-driven
`DartHit`/`BoardMiss` events (`keypadOverrideProvider`, checked in
`handleBoardEvent`) so the same dart cannot score twice, once from the tap and
once from the board's own frame. `ButtonPress` (`BTN@`) is never suppressed —
confirming a turn is not scoring, and stays useful with the keypad pulled up.

This is unrelated to `boardSourceProvider`: that picks which `BoardSource`
implementation feeds the app. In the app it is always `BleBoardSource`; tests
override it with the scripted `FakeBoardSource`.

## Where to start reading

| If you want to understand… | Read |
|---|---|
| the rules of the game | `lib/domain/x01/leg_reducer.dart`, then each mode's `*_reducer.dart` |
| what a match is | `lib/domain/x01/match_state.dart` |
| how a dart gets from the board to the screen | `lib/data/board/frame_assembler.dart`, then `segment_codec.dart`, then `lib/app/game_controller.dart` (`handleBoardEvent`) |
| what is stored | [DATA_MODEL.md](DATA_MODEL.md) |
| why a sound plays | `lib/app/audio/sound_controller.dart` |
| how the screens connect | "Screens" above, or start at `lib/main.dart` |
| how to add a game mode | [CONTRIBUTING.md](../CONTRIBUTING.md#add-a-game-mode) |
