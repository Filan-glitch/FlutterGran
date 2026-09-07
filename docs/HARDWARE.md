# The GranBoard 132

What the board is, how it decides a dart landed where it did, and — just as
importantly — which parts of this are **verified** and which are **inference**.

> **Read this first.** Everything below about the 132's sensor matrix is
> derived from the **GRANBOARD 3s**. Six independent implementations agree on
> the 3s exactly. Hardware day (2026-09-04) verified it against a real
> **132**: all 82 scoring segments decoded correctly, with nothing to
> correct. Treat the table below as confirmed, not provisional.

## What kind of device it is

An electronic soft-tip dartboard with a segmented plastic face. Each scoring
area is a physically separate segment sitting over a **sensor matrix**. A dart
pushes a segment down, the matrix closes at one intersection, and the board
reports **which intersection closed** — not what it is worth.

That last point is the whole reason this app has a decoding layer:

> The payload is a **physical sensor-matrix coordinate (`column.row`), not a
> score.** `3.4@` is triple 20 — but nothing in `3`, `.`, or `4` says "sixty".

A conventional scoring app that treats the payload as a number will appear to
work and be wrong in a way nobody notices until a leg is lost by it.

## The matrix

**12 columns × 7 rows = 84 slots.** Written `column.row`, both zero-based.

The board has 82 scoring areas: 20 wedges × 4 rings (inner single, triple,
outer single, double), plus the outer and inner bull.

```
20 wedges × 4 rings  = 80
outer bull (25)      =  1
inner bull (50)      =  1
                       ──
                       82  scoring areas
                       84  matrix slots
                       ──
                        2  slots that carry nothing
```

Ten of the twelve columns serve **two wedges each**. Two wedges need eight
segments, but a column has only seven rows — so exactly one double per column
overflows into **column 4 or column 8**, the two columns that also carry the
bulls. That accounts for 82 of the 84 slots and leaves exactly two empty:

```dart
const Set<String> unusedMatrixSlots = {'4.1', '8.1'};
```

A frame carrying `4.1` or `8.1` is therefore **a decoding fault, not a hit** —
useful, because it is a signal that the table is wrong for this board rather
than a dart to be scored.

## The segment table

`lib/data/board/granboard_segment_map.dart`. One row per wedge, four codes per
row, in the column order `[inner single, triple, outer single, double]` — the
same order as the published tables, so it can be audited line by line against
them.

```dart
const Map<int, List<String>> wedgeCodes = {
  1:  ['2.3',  '2.4',  '2.5',  '2.6'],
  2:  ['9.1',  '9.0',  '9.2',  '8.2'],   // ← the double lives in column 8
  3:  ['7.1',  '7.0',  '7.2',  '8.4'],
  ...
  20: ['3.3',  '3.4',  '3.5',  '3.6'],
};

const String outerBullCode = '8.0';   // 25
const String innerBullCode = '4.0';   // 50
```

Reading wedge 20 as an example: `3.3` is a single 20, `3.4` a **treble 20**,
`3.5` the outer single, `3.6` the double. Wedge 20 is tidy — one column, four
consecutive rows. Wedge 2 is not: three of its segments are in column 9 and its
double is at `8.2`, one of the overflow slots described above.

The flat lookup the decoder actually uses (`granboardSegmentMap`) is built from
that table plus the two bulls, so the human-auditable shape and the machine
lookup cannot drift apart.

## Non-dart frames

| Body | Meaning | Confirmed? |
|---|---|---|
| `BTN` | the change-player button / touch sensor | **Unverified on the 132.** Nothing needed for play depends on it; it is a convenience for confirming a turn |
| `OUT` | a dart outside the scoring area | **Unverified.** The 3s reportedly never sends it, so the keypad's MISS key is the reliable path |

Both are treated as optional. The app is fully playable if the 132 sends
neither.

## What is confirmed, and what is not

| | Status |
|---|---|
| Frames are ASCII, terminated by `@` | Confirmed across implementations |
| Payload is `column.row`, not a score | Confirmed |
| The 3s segment table | Confirmed for the **3s** |
| The 3s table applies to the **132** | **Confirmed 2026-09-04.** 82/82 segments verified live, zero corrections |
| `GB<n>;<ddd>` greeting on connect | Confirmed |
| Frames split, glued and duplicated | Confirmed on real hardware |
| `BTN@` on the 132 | **Confirmed 2026-09-04.** Fires. |
| `OUT@` on the 132 | **Confirmed 2026-09-04.** Fires, unlike the 3s. |
| The full advertised BLE name | **Confirmed 2026-09-04.** `GRANBOARD` |

## Hardware day (2026-09-04) — done

Every question above that needed a real 132 to answer has been answered. The
app never guesses on a bad frame - an unrecognised body still becomes
`UnknownFrame` carrying the body **verbatim** - but the calibration screen that
existed to confirm or correct the table live (raw body, decoded meaning,
right/wrong, an 82-cell coverage checklist, a codec override layer) is gone
now that there is nothing left for it to find. See `BOARD_PROTOCOL.md` for
the full results and the connect-path bug that had to be fixed before any of
this could be tested.

## See also

- [BOARD_PROTOCOL.md](BOARD_PROTOCOL.md) — the frame format and the parser
- [CONNECTIVITY.md](CONNECTIVITY.md) — how the app finds, connects to and stays connected to the board
