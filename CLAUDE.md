# fluttergran

Flutter companion app for a **GranBoard 132** Bluetooth electronic dartboard.
MVP: x01 (301/501/701, straight-in, double-out, single leg) for up to 4 players,
live checkout suggestions, and per-player statistics across every dart ever thrown.

Full design and milestones: `docs/PLAN.md`.

## Commands

```
flutter analyze
flutter test                          # everything
dart test test/domain test/data       # engine, checkout and protocol, no Flutter
dart run build_runner build --delete-conflicting-outputs   # drift codegen
```

`test/domain` and `test/data` run under plain `dart test` because neither layer
imports Flutter. `test/app` needs `flutter test`.

## Layering rule

`lib/domain/` is **pure Dart and must not import `package:flutter`**. It holds the
x01 fold and the checkout search — the parts worth testing hardest. A test asserts
this mechanically; if it fails, the fix is to move the Flutter-dependent code out of
`domain/`, not to relax the test.

Everything else: `lib/data/` (board protocol, drift database), `lib/app/` (Riverpod
providers, screens, widgets).

## Board protocol, in one paragraph

The board sends ASCII frames terminated by `@`, e.g. `3.4@`. The payload is a
**physical sensor-matrix coordinate (column.row), not a score** — `3.4@` is triple 20.
Frames arrive split across notifications, glued together, duplicated within 50 ms, and
preceded on connect by a `GB<n>;<ddd>` greeting with no terminator. The parser must
buffer, strip the greeting, split on `@`, and dedupe before lookup. Unknown frames must
log the **raw body**, never the failed lookup result.

The segment table currently shipped is derived from the **GRANBOARD 3s**. No public
source has ever verified the 132. Treat the table as provisional data until the
calibration screen confirms it against real hardware.

## Hardware day

Open **Board diagnostics** from the setup screen, switch the source to Bluetooth,
and connect. Throw at every segment: each frame shows its raw body and what the
table thinks it means, with `Right` to confirm and `Wrong` to correct. Corrections
are written to `SegmentCalibrations` and pushed into the live decoder immediately,
so the next dart scores correctly without reconnecting. The coverage bar reaches
82 when every scoring area has been verified.

Things to settle while the board is connected:

- Does the 132's matrix match the 3s table, or does calibration fill up with
  corrections?
- Does the touch sensor emit `BTN@`? Nothing needed for play depends on it.
- Does `OUT@` ever fire? The 3s reportedly never sends it.
- What is the full advertised name? Only the prefix `GRAN` is confirmed.

## Dependency constraints (learned the hard way)

- **`flutter_blue_plus` is not open source.** Free for personal use only; any for-profit
  use requires a purchased commercial license. If this app ever ships commercially,
  swap it for `flutter_blue_ultra` or `universal_ble` (both BSD-3).
- **No Riverpod codegen.** `riverpod_generator` requires `analyzer ^13` while `drift_dev`
  pins an older analyzer — they cannot coexist. Providers are written by hand.
  `riverpod_lint`/`custom_lint` are also unavailable: `riverpod_lint` caps
  `riverpod_annotation <4.0.0` and so is incompatible with Riverpod 3.
- Do not write to the board. The MVP is read-only; all audio is app-side.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
