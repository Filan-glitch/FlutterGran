# Connectivity

How the app finds a GranBoard, connects to it, keeps the connection, and gets
out of the way when there is no board at all.

Implementation: `lib/data/board/ble_board_source.dart`.
Tests: `test/app/reconnect_delay_test.dart`, `test/data/board_reader_test.dart`.

## The seam

```
BleBoardSource ─┐
                ├──▶ BoardSource ──▶ BoardReader ──▶ BoardEvent stream
FakeBoardSource ┘        (bytes in, connection state out)
```

`BoardSource` is deliberately **the narrowest possible seam: raw notification
bytes in, connection state out.** No framing, no decoding, no scoring. That is
what lets the fake and real Bluetooth go through *exactly* the same parsing
path, and it means `BleBoardSource` is the only class that has to be verified
against hardware.

Swapping the two is one provider override (`boardSourceProvider`) - the
in-app default is always `BleBoardSource` now that hardware day has confirmed
it works; tests override the provider with `FakeBoardSource` directly, and
there is no runtime switch between the two any more.

## GATT

```dart
abstract final class GranBoardGatt {
  static final Guid service = Guid('442f1570-8a00-9a28-cbe1-e1d4212d53eb');
  static final Guid notify  = Guid('442f1571-8a00-9a28-cbe1-e1d4212d53eb');
  static final Guid write   = Guid('442f1572-8a00-9a28-cbe1-e1d4212d53eb');
  static const String namePrefix = 'GRAN';
}
```

| | |
|---|---|
| **service** | The vendor service. Six independent implementations agree on it, and the board **advertises** it — which is what makes the scan filter possible |
| **notify** | Board → app. The only characteristic the MVP uses |
| **write** | App → board, write without response. **Never used.** The MVP is read-only |
| **namePrefix** | `GRAN`, used only as a fallback when the service filter finds nothing. The full advertised name is not documented anywhere |

## Connection lifecycle

```
        connect()
            │
            ▼
   ┌────────────────┐   known device?   ┌──────────────┐
   │  disconnected  │──────── yes ─────▶│  connecting  │
   └────────────────┘                   └──────────────┘
            │ no                                │
            ▼                                   │ discoverServices
      ┌──────────┐    found     ─────────────────┤ setNotifyValue(true)
      │ scanning │───────────────────────────────┤
      └──────────┘                               ▼
            │ nothing                      ┌───────────┐
            ▼                              │ connected │
     schedule reconnect ◀───── dropped ────└───────────┘
```

`BoardConnectionState` is exactly these four: `disconnected`, `scanning`,
`connecting`, `connected`.

### Reconnecting without scanning

A board that has already been seen is reconnected to **directly**, skipping the
scan. That is faster and immune to the scan throttle below. But a board that has
been replaced or re-paired will never connect that way, so after
`reconnectsBeforeRescan = 3` consecutive failures the cached device is dropped
and the app scans again.

### Services are rediscovered every time

Handles from a previous session are not valid after a reconnect, so
`discoverServices()` runs on every connection — not once at first pairing.

### A forgiving characteristic lookup

The documented notify UUID is tried first. If it is not there, **any notify
characteristic on the vendor service** is accepted, because some boards expose
the pair without matching the documented UUID. Only if there is no notify
characteristic at all does it throw.

## Scanning, and Android's throttle

> Android refuses a scan when an app starts **more than five within 30
> seconds**, answering `onScannerRegistered(status=6)` — "scanning too
> frequently" — and **the rejection is silent from Dart's side**. Once tripped,
> the board stays undiscoverable even though it is advertising.

This is the failure mode that looks exactly like broken hardware, so the app
spaces scans out:

```dart
const Duration minimumScanInterval = Duration(seconds: 7);
Duration scanCooldown(DateTime? lastScanAt, DateTime now);
```

Before every scan the source waits out any remaining cooldown. `scanCooldown`
also treats a negative interval — a clock that moved backwards — as "no wait".

The scan itself filters on the advertised service UUID, with the name prefix as
a fallback match on results.

## Reconnect backoff

```dart
Duration reconnectDelay(int attempt, {Random? random});
```

Exponential, **capped at 30 seconds**, with up to 30% jitter on top.

- **Why jitter:** a board that drops repeatedly would otherwise be retried on a
  fixed cadence that can line up with whatever is causing the drop.
- **Why the exponent is clamped to 16 before it is raised:** `pow` on two ints
  overflows 64-bit at attempt 64 and wraps to **zero**, which would turn a board
  that has been missing for an hour into a tight reconnect loop. This is tested.

Any failure — adapter off, scan timeout, GATT error — is treated identically:
there is no board, so back off and try again. `_wantConnection` is the single
flag that separates "the user asked for a board" from "the user pressed
disconnect"; nothing reconnects once it is false.

## Permissions

### Android

```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
                 android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

**No location permission, on any Android version.** Because the board
advertises its service UUID, the scan can filter by service and declare
`neverForLocation`, and the scan call passes `androidUsesFineLocation: false`.
Android 12+ therefore never prompts for location — which matters, because a
darts scorer asking for your location is a reasonable thing to refuse.

### iOS

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Connects to your GranBoard to read the darts you throw.</string>
```

## Licensing note

`flutter_blue_plus` is **not open source**. The connect call passes
`License.nonprofit`, which is the tier this project is distributed under:

```dart
await board.connect(license: License.nonprofit);
```

Shipping commercially requires a purchased licence, or swapping the package for
`flutter_blue_ultra` or `universal_ble` (both BSD-3). The seam that makes that
swap small is `BoardSource` — a replacement only has to produce bytes and
connection state.

## What happens to the bytes

`BoardReader` composes a source with framing and decoding. It is the only place
those three layers are wired together, so the fake and the real board cannot
diverge.

One behaviour worth knowing lives here rather than in the BLE source: when the
connection goes from connected to not-connected, **the frame assembler is
reset**, so a half-received frame from before the drop is never glued to the
first frame after it.

## Playing without a board

`FakeBoardSource` emits the same raw byte chunks real hardware does, through
the same code path, and can reproduce every protocol quirk on demand. It is no
longer the in-app default - `boardSourceProvider` always builds a real
`BleBoardSource` - but tests still override the provider with it directly:

| Method | Reproduces |
|---|---|
| `emitBody('3.4')` | a normal frame |
| `emitBatch([...])` | several frames glued into one notification |
| `emitSplit('3.4')` | one frame split across two notifications |
| `emitDuplicate('3.4')` | the same frame twice inside the dedupe window |
| `emitGreetingGluedTo('3.4')` | the connect greeting stuck to the first hit |
| `pressButton()` / `emitMiss()` | `BTN@` / `OUT@` |

That is why the whole app — including every parser edge case — is developed and
tested with no hardware present.

## Connecting from the app

The setup screen's `BoardConnectionButton` is the whole interface: one icon,
tap to connect or disconnect, coloured by state (white unclicked, blue
connecting, green connected, red disconnected). The live diagnostics screen
this replaced - switch source, watch each frame's raw body and decoded
meaning, confirm or correct it - existed to verify the protocol against real
hardware; hardware day (2026-09-04) finished that verification, so the screen
is gone. See `BOARD_PROTOCOL.md` for what it found.

If a real board will not appear, in order of likelihood:

1. **The scan throttle** — more than five scans in 30 seconds, silently
   rejected. Wait half a minute and try once.
2. **The adapter is off**, or permissions were declined.
3. **The board is connected to something else** — a phone that paired with it
   earlier will hold it.
4. **The name/service does not match** — check what the scan sees; only the
   `GRAN` prefix is confirmed.

## See also

- [HARDWARE.md](HARDWARE.md) — the board itself, the sensor matrix and the segment table
- [BOARD_PROTOCOL.md](BOARD_PROTOCOL.md) — the frame format and the parser
