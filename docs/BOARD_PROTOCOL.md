# The board protocol

Everything known about how a GranBoard talks, and which parts of it are still
guesses.

Companion documents: [HARDWARE.md](HARDWARE.md) for the board itself and its
sensor matrix, [CONNECTIVITY.md](CONNECTIVITY.md) for finding and holding the
Bluetooth connection that delivers these frames.

## In one paragraph

The board sends ASCII frames terminated by `@`, e.g. `3.4@`. The payload is a
**physical sensor-matrix coordinate (column.row), not a score** — `3.4@` is
triple 20. Frames arrive split across notifications, glued together, duplicated
within 50 ms, and preceded on connect by a `GB<n>;<ddd>` greeting with no
terminator. The parser must buffer, strip the greeting, split on `@`, and dedupe
before lookup. Unknown frames must log the **raw body**, never the failed lookup
result.

## The pipeline

```
BLE notification bytes
      │
      ▼
FrameAssembler.feed()        buffer, strip greeting, split on @, dedupe
      │  List<String> bodies
      ▼
SegmentCodec.decode()        overrides first, then the shipped table
      │  BoardEvent
      ▼
BoardReader.events           DartHit | BoardMiss | ButtonPress | UnknownFrame
      │
      ▼
GameController               scores it, or logs the raw body
```

## Frame assembly

`lib/data/board/frame_assembler.dart`. All four of these happen on real
hardware, and each has a test:

| What arrives | Example |
|---|---|
| Several frames in one notification | `2.5@8.0@OUT@` |
| One frame split across two notifications | `2.` then `5@` |
| The greeting glued to the first hit | `GB8;1027.0@` |
| The same frame re-emitted within tens of ms | `3.4@` … `3.4@` |

Rules the assembler follows:

- **Latin-1, not UTF-8.** The payload is plain ASCII, and a malformed byte must
  not throw in the middle of a game.
- **The greeting is recognised by shape** — `^GB\d;\d{3}` — because it carries
  no terminator and cannot be found by splitting.
- **Whatever follows the last `@` is kept** as the start of the next frame.
- **Dedupe window: 50 ms**, matched to what the board has been observed to
  re-emit within. The clock is injectable so the behaviour is deterministic
  under test.
- **The buffer is capped at 256 characters.** A garbage stream must not grow it
  without bound; any real frame is a handful of characters.
- **`reset()` on every reconnect.** A half-received frame from before a drop
  would otherwise be glued to the first frame after it.

## Decoding

`lib/data/board/segment_codec.dart` turns a body into a `BoardEvent`:

| Body | Event |
|---|---|
| `BTN` | `ButtonPress` — the change-player button or touch sensor |
| `OUT` | `BoardMiss` — a dart outside the scoring area |
| a known coordinate | `DartHit(Segment)` |
| anything else | `UnknownFrame(body)` |

An unrecognised body becomes `UnknownFrame` carrying the body **verbatim** —
never a silently dropped hit and never a guess.

## The segment table is settled

The table in `lib/data/board/granboard_segment_map.dart` is derived from the
**GRANBOARD 3s**. Hardware day (2026-09-04) verified it against a real **132**:
all 82 scoring segments decoded correctly, with nothing to correct. It is no
longer provisional.

## Hardware day (2026-09-04) — resolved

Every question that could only be answered with a 132 connected:

- Does the 132's matrix match the 3s table, or does calibration fill up with
  corrections? **Matches.** 82/82 segments verified with zero corrections.
- Does the touch sensor emit `BTN@`? **Yes**, confirmed live.
- Does `OUT@` ever fire? **Yes**, confirmed live (the 3s reportedly never
  sends it, so this is a real difference between the two boards).
- What is the full advertised name? **`GRANBOARD`**, confirmed via an
  unfiltered `bluetoothctl` scan against the connected board.

The calibration screen that answered these questions — a live diagnostics
view with a tap-to-correct dialog, an 82-cell coverage checklist, an override
layer in `SegmentCodec`, and a `SegmentCalibrations` table — existed only to
answer them, and has been removed now that they're answered. So has
`lib/data/board/frame_recorder.dart`: it existed to capture a hardware-day
session as a replay fixture, was never wired to a file or a screen control,
and never captured one. What is left in the UI is a single connection icon
(`BoardConnectionButton`, in the app bar) that connects or disconnects on tap
and is coloured by state - white unclicked, blue while connecting, green
connected, red disconnected. Nothing about the protocol below needs verifying
again unless the board itself changes.

## Playing without a board

`FakeBoardSource` emits the same raw byte chunks real hardware does, through the
same code path — including split frames, glued frames, duplicates and the
greeting. `boardSourceProvider` always builds a real `BleBoardSource` now that
hardware day has confirmed it works; tests override the provider directly with
`FakeBoardSource`, so every protocol quirk above stays reproducible without
hardware attached.

## Connection lifecycle

`BleBoardSource` scans for the `GRAN` name prefix, connects, and subscribes to
any notify characteristic on the vendor service — some boards expose the pair
without matching the documented UUID. A dropped connection schedules a
reconnect with backoff (`reconnectDelay`, tested in
`test/app/reconnect_delay_test.dart`) for as long as a connection is still
wanted.

**Found and fixed on hardware day:** `_findBoard()` awaited
`FlutterBluePlus.startScan(timeout: scanTimeout)` to learn whether the board
had been found, but that call's Future resolves as soon as the platform scan
*starts* - the plugin's `timeout` is a fire-and-forget internal timer, not
something the caller can await. Every connect attempt was therefore declaring
the board absent and tearing the scan down within milliseconds of starting it,
before any advertisement could arrive - the board never had a chance to be
found. The fix races the completer that the scan-results listener fills in
against `scanTimeout` directly, instead of trusting `startScan`'s return to
mean anything about elapsed time.

**The MVP is read-only. Nothing writes to the board.** All audio is app-side.
