Everything that talks to the outside world: the GranBoard over Bluetooth, the
drift database, and GitHub's releases for the in-app update.

The board path is `BoardSource` (raw notification bytes), `FrameAssembler`
(complete frames), and `SegmentCodec` (one `BoardEvent` per frame), composed
by `BoardReader`. The only bytes ever written back are LED frames, through
`encodeLedCommand`. `GameRepository` is the one way into the database, and
stores darts, never derived totals.

More in the handbook:
[Board protocol](https://github.com/Filan-glitch/FlutterGran/blob/main/docs/BOARD_PROTOCOL.md),
[Hardware](https://github.com/Filan-glitch/FlutterGran/blob/main/docs/HARDWARE.md),
[Connectivity](https://github.com/Filan-glitch/FlutterGran/blob/main/docs/CONNECTIVITY.md),
[Data model](https://github.com/Filan-glitch/FlutterGran/blob/main/docs/DATA_MODEL.md),
[Releasing](https://github.com/Filan-glitch/FlutterGran/blob/main/docs/RELEASING.md).
