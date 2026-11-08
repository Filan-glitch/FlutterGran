The rules of darts as pure Dart, with no Flutter, drift or I/O: the board's
segments and events, the x01 engine, the checkout search and the statistics.

Every game state is a fold over the darts thrown. `foldLeg` replays a leg's
dart log into a `LegState`, `foldMatch` turns the winners of finished legs into
a `MatchState`, and undo is folding a shorter log. Nothing keeps a running
total. A test fails the build if anything here imports Flutter.

The per-mode engines built on the same pattern are under **Game modes**.

More in the handbook:
[Architecture](https://github.com/Filan-glitch/FlutterGran/blob/main/docs/ARCHITECTURE.md),
[Contributing](https://github.com/Filan-glitch/FlutterGran/blob/main/CONTRIBUTING.md).
