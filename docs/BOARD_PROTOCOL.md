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

**The only thing written to the board is LED frames**, and all audio is app-side.
See below.

## LED control

The 132's LED ring is driven over the vendor service's **write**
characteristic, `442f1572-8a00-9a28-cbe1-e1d4212d53eb`, using write without
response. The format was reverse-engineered by others from the official app's
traffic, in [GranBoard-with-Autodarts](https://github.com/Lennart-Jerome/GranBoard-with-Autodarts)
(`dev-tools/README GranBoard_LED_Control.md`). That repo has no licence, so
only the documented facts are used and none of its code. On 2026-09-21 the
format was checked against a real 132 with that repo's
`GranBoard_LED_Control.html`, run in desktop Chrome.

The LEDs only light on **USB power**. They stay dark on AA batteries whatever
is sent.

### Static ring: 20 bytes

One palette code per number, S1 to S20. Byte *n* is the segment with **number**
*n* printed on it, not the *n*-th position around the ring (confirmed on the 132).
The codes are:

| Code | Colour | | Code | Colour |
|---|---|---|---|---|
| `00` | off | | `04` | light green |
| `01` | red | | `05` | turquoise |
| `02` | orange | | `06` | purple |
| `03` | yellow | | `07` | white |

Twenty `00` bytes turns the whole ring off.

### Effect frames: 16 bytes

| Byte | Meaning |
|---|---|
| `[0]` | op-code |
| `[1..3]` | colour A, RGB |
| `[4..6]` | colour B, RGB |
| `[7..9]` | colour C, RGB |
| `[10..11]` | hit-flash target id, little-endian |
| `[12]` | speed. Effects run 0 (fast) to 35 (slow); the hit flash runs 0 (slow) to 255 (fast) |
| `[15]` | always `01` |

- **Hit flash:** op `01`, `02` or `03` for single, double or triple, with colours A
  and B. The target ids for 1 to 20 are
  `1C 31 37 22 16 28 01 07 10 2B 0A 13 25 0D 2E 04 34 1F 3A 19`. **Verified on the
  132: each id lights the right number.** There is no target id for the bull.
- **Effects that work on the 132:**
  - `0C` touch rainbow
  - `0D` rainbow + flicker (needs `[11]=02, [13]=02`)
  - `0F` rainbow rotate
  - `10` split rainbow
  - `11` next-player sweep (needs `[10]=10`)
  - `14` pulse (needs `[4]=7D`)
  - `15` dim solid
  - `16` colour cycle
  - `17` blink
  - `18` flicker
  - `1B` shake
  - `1D` sweep + fade
  - `1F` 3-colour fade
- **`19` hunt flicker does nothing on the 132.** It is left out of the
  allow-list.

Whether each effect loops or plays once was not measured. The app doesn't
depend on either: `LedScheduler` holds each show for a fixed time and then
repaints the resting ring, and that repaint also stops a looping effect.

### Settings frames: never sent

The same characteristic also accepts **12-byte settings frames**. These change
how the board scores, and the app must never send them:

| Frame ends in | Setting |
|---|---|
| `34 35` | reply interval |
| `36 37` | out sensitivity |
| `3A 3B` | target sensitivity presets |

`BoardSource.sendLed` takes a `LedCommand`, not bytes, and
`encodeLedCommand` (`lib/data/board/led_command.dart`) can only build 20- or
16-byte frames from an allow-listed op. A settings frame therefore cannot be
built from app code at all. `test/data/led_command_test.dart` pins this down.
