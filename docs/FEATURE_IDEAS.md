# Feature ideas (not yet built)

Backlog of game modes and features discussed for post-MVP work. Nothing here
is committed or scheduled — this exists so a future session doesn't have to
re-derive the same list. Written 2026-09-12.

Current modes: X01, Around the Clock, Bulling, plus a training/free-practice
mode (`lib/domain/training/`). `select_game_mode_screen.dart` already renders
a "coming soon" tile after the registry entries, deliberately not naming a
specific next mode.

## How a mode fits the existing architecture

Every mode so far follows the same triad, one folder per mode under
`lib/domain/`:

- a `*_config.dart` (setup choices)
- a `*_leg_state.dart` + `*_reducer.dart` (pure fold over thrown darts)
- a `*_stats.dart` under `lib/domain/stats/`

...plus a `GameMode` enum entry (`lib/domain/game_mode.dart`), a setup screen
and a game screen under `lib/app/screens/`. A new mode that fits this shape
(single leg-state, single reducer, no cross-player elimination bookkeeping)
is a small, well-contained addition.

## Candidate game modes

- **Cricket** (and Cut-Throat) — hit/close numbers 15–20 + bull, no checkout
  math. Good contrast to X01. Fits the existing triad directly.
- **Shanghai** — single/double/treble of the same number each round; single
  target number ordering per round, out on completing the pattern.
- **Halve It** — penalty-flavoured: missing a target halves the running
  score instead of adding to it.
- **High-Low / countdown ladder** — practice-flavoured, would sit naturally
  alongside the existing free-practice/training drills.
- **Killer** — elimination with lives, player-vs-player targeting. Does
  **not** fit the current single-leg-state triad: needs per-player
  elimination state and inter-player interaction the reducer shape doesn't
  have today. Biggest domain-model lift of this list; do this one after
  brainstorming the state shape, not by copying the X01 triad.

## Stats / data features

- Checkout-percentage trend over time; per-double hit rate (the segment-level
  throw data already captures which double a player struggles with).
- Heatmap overlay on the board graphic per player.
- Head-to-head record between two specific players.
- Session/match history list with leg-by-leg replay.
- Local export of stats (CSV/JSON) — no cloud sync; see the dependency
  constraints in the root `CLAUDE.md` (no online/backend component planned).

## Quality-of-life

- Mis-throw correction / undo for the current leg.
- Player profiles: persisted avatar/colour in the roster.
- Quick-launch shortcut (home-screen widget or in-app) for the last-used game
  config.
- Expanded training drill library (ton-plus targets, doubles-only drill),
  building on `lib/domain/training/training_drill.dart`.

## Process note

New mode design should go through the brainstorming skill before code —
especially Killer, which needs a state-shape decision the other modes don't.
The rest slot into the config/reducer/stats triad with comparatively little
design risk.
