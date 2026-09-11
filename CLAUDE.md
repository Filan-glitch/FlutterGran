# fluttergran

Flutter companion app for a **GranBoard 132** Bluetooth electronic dartboard.
x01 (301/501/701, single/double/master in and out) for up to 4 players, best of 1/3/5/7
legs, live checkout suggestions, spoken commentary and sound cues, and
per-player statistics across every dart ever thrown.

MVP finished 2026-09-07 — real hardware connects and scores correctly, and the
five post-MVP features (multi-leg matches, sound, app icon, end screen,
responsive/tablet layout) have all shipped. Now polishing. Architecture and
protocol reference: `docs/`.

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

## X01 rules and schema

In-rule and out-rule are independent `X01InRule`/`X01OutRule` enums (straight/double/
master) on `GameConfig`/`MatchConfig` — there is no `doubleOut` bool any more. A
same-named DB column survives only as a frozen, always-derived legacy mirror; nothing
else reads it. Current drift schema version: **8**.

**drift `TableMigration` gotcha:** it copies every column the *current* table class has,
assuming the on-disk table already has them all. When a later schema version adds a
column to that table, any earlier `TableMigration(table)` step must be updated to
declare the new column via `newColumns: [table.newColumn]` — otherwise a multi-version
upgrade (e.g. v2 straight to v8) crashes trying to copy a column that doesn't exist yet
at that point in the chain. `test/app/migration_test.dart` freezes historical
`games`/`matches` shapes with raw SQL for exactly this reason, once the current table
classes outgrow them.

## Board protocol, in one paragraph

The board sends ASCII frames terminated by `@`, e.g. `3.4@`. The payload is a
**physical sensor-matrix coordinate (column.row), not a score** — `3.4@` is triple 20.
Frames arrive split across notifications, glued together, duplicated within 50 ms, and
preceded on connect by a `GB<n>;<ddd>` greeting with no terminator. The parser must
buffer, strip the greeting, split on `@`, and dedupe before lookup. Unknown frames must
log the **raw body**, never the failed lookup result.

The segment table shipped is derived from the **GRANBOARD 3s**. Hardware day
(2026-09-04) verified it against a real 132: all 82 scoring segments decoded
correctly, with nothing to correct. The table is settled, not provisional.

## Hardware day (done)

Connecting, framing, and decoding were all verified end to end against a real
132 on 2026-09-04. Findings: the 3s segment table matches the 132 exactly
(zero corrections needed), the touch sensor does emit `BTN@`, `OUT@` does fire
(unlike the 3s, which reportedly never sends it), and the full advertised name
is `GRANBOARD`. Details and the connect-path bug that had to be fixed first
are in `docs/BOARD_PROTOCOL.md`.

The calibration screen this needed (diagnostics, tap-to-correct, the coverage
checklist, the `SegmentCalibrations` table and the codec's override layer)
existed only to answer those questions and has been removed now that they're
answered. What's left in the UI is a single connection icon
(`BoardConnectionButton`): tap to connect, tap again to disconnect, coloured
by state.

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
- Before grepping or exploring for a symbol, file, or relationship, run `graphify query "<question>"` first when graphify-out/graph.json exists — cheaper and more scoped than raw search. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost). Commit the graphify-out diff as its own separate commit (e.g. `chore: update graphify knowledge graph`) — never squashed into the code change.
