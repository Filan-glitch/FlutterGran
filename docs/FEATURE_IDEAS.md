# Feature ideas (not yet built)

Backlog of game modes and features discussed for future work. Nothing here
is committed or scheduled — this exists so a future session doesn't have to
re-derive the same list.

Current modes: X01, Around the Clock, Bulling, Higher/Lower, plus training
(free practice, checkout practice, Checkout Challenge, 121 Ladder, Bob's 27,
Weak-spot Trainer; `lib/domain/training/`).
`select_game_mode_screen.dart` renders a "coming soon" tile after the registry
entries, deliberately not naming a specific next mode.

## How a mode fits the existing architecture

Every mode so far has the same shape, one folder per mode under
`lib/domain/`: a `*_config.dart`, a `*_leg_state.dart` and a `*_reducer.dart`
(a pure fold over the darts thrown), plus a `*_stats.dart` under
`lib/domain/stats/`. The full list of touch points, from the `GameMode` enum to
the LED cues, is the "Add a game mode" recipe in
[CONTRIBUTING.md](../CONTRIBUTING.md#add-a-game-mode).

## Candidate game modes

- **Cricket** (and Cut-Throat) — hit/close numbers 15–20 + bull, no checkout
  math. Good contrast to X01. Fits the existing shape directly.
- **Shanghai** — single/double/treble of the same number each round; single
  target number ordering per round, out on completing the pattern.
- **Halve It** — penalty-flavoured: missing a target halves the running
  score instead of adding to it.
- **Countdown ladder** — practice-flavoured, would sit naturally alongside the
  training drills. The High-Low idea from this list shipped as Higher/Lower, so
  anything here should be clearly different from it.
- **Killer** — elimination with lives and player-vs-player targeting.
  Higher/Lower already shows that elimination fits a fold (`eliminated` in
  `HigherLowerLegState`, and undo brings a player back for free), but Killer
  adds lives and one player's dart changing another player's state. Brainstorm
  the state shape before copying an existing mode.

## Stats / data features

- Checkout-percentage trend over time; per-double hit rate (the segment-level
  throw data already captures which double a player struggles with).
- Heatmap overlay on the board graphic per player.
- Head-to-head record between two specific players.
- Session/match history list with leg-by-leg replay.
- Local export of stats (CSV/JSON). No cloud sync: there is no online/backend
  component planned.

## Quality-of-life

- Undo exists (every game screen's app bar, one dart at a time back to the
  start of the leg, including a winning checkout). What is missing is
  correcting one dart in the middle of a turn without undoing the darts after
  it.
- Player profiles: persisted avatar/colour in the roster.
- Quick-launch shortcut (home-screen widget or in-app) for the last-used game
  config.
- More training drills (ton-plus targets), building on
  `lib/domain/training/training_drill.dart`.
- Saved training sessions (a schema bump), for progress across sessions; the
  drills are pure folds already, so only storage is missing.
- A personal "aim here" heatmap: fit the player's scatter from where their
  darts land (Tibshirani, Price & Taylor, "A statistician plays darts", JRSS A
  2011, an EM fit on score-only data) and show where to aim for the most
  points.

## Process note

New mode design should go through brainstorming before code — especially
Killer, which needs a state-shape decision the other modes didn't.
