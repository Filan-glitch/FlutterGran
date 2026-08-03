#!/usr/bin/env python3
"""Draw the launcher icon and write every platform asset it needs.

The icon is a chalk tally: four uprights struck through by a fifth, chalk-white
on the app's forest ground. It ties to the name, it is not another dartboard,
and five thick strokes are still five thick strokes at 48px - which is the size
that decides whether a launcher icon works at all.

The icon is drawn here rather than stored as a binary someone has to re-open in
an editor, and the two colours are read straight out of `lib/app/theme.dart`.
Change `Palette.ground` or `Palette.chalk`, re-run this, and the icon follows;
there is no second copy of the palette for it to drift from.

    python3 tool/make_icon.py

Requires Pillow (10.x). Writes, all of it overwritten in place:

    android/app/src/main/res/mipmap-*/ic_launcher.png             legacy, 48dp
    android/app/src/main/res/mipmap-*/ic_launcher_foreground.png  adaptive, 108dp
    android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
    android/app/src/main/res/values/ic_launcher_background.xml
    ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png

Why it is drawn the way it is:

-   Everything is drawn on a 4096px master and downsampled with Lanczos. That is
    where the antialiasing comes from, and it is also what keeps the chalk grain
    honest: the texture is sized in master pixels, so it reads at 1024 and
    averages away to nothing by 48. Texture still visible at 48px is mud.
-   The strokes lean, wobble and end unevenly, from a fixed seed so re-runs are
    identical. A tally built from exact rectangles reads as a UI glyph, not as
    chalk. Every deviation is deliberately under a pixel at 48px and only really
    shows at 1024.
-   Adaptive foregrounds are 108dp, not 48dp. The system scales that layer to a
    108dp canvas and masks it down to the 72dp that is actually visible, so 48dp
    art would be upscaled and soft. The mark is then sized to cover the same
    share of the *visible* tile as it does on the legacy square, which is why its
    extent there is smaller than on the legacy icon rather than equal to it.
"""

from __future__ import annotations

import json
import math
import random
import re
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
THEME = ROOT / "lib" / "app" / "theme.dart"

# Drawn once at this size and reduced from there. Big enough that the smallest
# asset (48px) is a 85:1 reduction, which is what makes the strokes clean.
MASTER = 4096

# One seed for the whole drawing, so the hand-drawn wobble is a property of the
# icon rather than of the run that produced it.
SEED = 20250803

# --- the mark ----------------------------------------------------------------
#
# Every length below is in stroke widths, because at 48px the only measurement
# that matters is how the gaps compare to the strokes. x runs left to right and
# y downwards from the top of the mark; the whole thing is then scaled onto each
# canvas, so the proportions are identical at 48px and at 1024px.

# Between uprights. Just under a stroke width: any tighter and four strokes stop
# being four strokes once 48px of antialiasing has been over them.
GAP = 0.95

# How far the strike runs past the outer uprights. It has to clear them by more
# than a stroke width, or the bit that sticks out is shorter than it is wide and
# reads as an arrowhead on the end rather than as a line drawn through.
OVERSHOOT = 1.15

# How tall the uprights stand. Slightly less than the mark is wide, which is the
# proportion a tally actually gets scrawled at.
HEIGHT = 7.3

PITCH = 1.0 + GAP
WIDTH = 2 * OVERSHOOT + 3 * PITCH + 1.0

# Per-upright deviation: lean in degrees, where it starts and stops, and how far
# it bows out sideways. Written out rather than randomised so the four are
# individually chosen to look unrelated, not merely different.
UPRIGHTS = (
    # lean°  top   bottom  bow
    (-1.6, 0.10, 7.22, 0.07),
    (1.2, 0.00, 6.97, -0.05),
    (-0.8, 0.07, 7.30, 0.05),
    (1.9, 0.02, 7.03, -0.08),
)

# The strike: low on the left, high on the right, about 29 degrees, crossing the
# middle upright pair dead centre.
STRIKE = ((0.0, 6.19), (WIDTH, 1.11), 0.06)

# --- how much of each canvas the mark covers ---------------------------------

# Legacy square and iOS: the mark's full width on a filled tile, the way a
# product icon sits on its background. The mark is wider than it is tall, so
# this leaves more room above and below than at the sides, which is correct.
EXTENT_TILE = 0.72

# Adaptive foreground: only the middle 72dp of the 108dp layer is ever visible,
# so covering the same share of what the user sees means covering less of the
# canvas. That lands the furthest chalk 30.6dp from the centre, inside the 33dp
# radius that every launcher mask is guaranteed to spare.
EXTENT_ADAPTIVE = EXTENT_TILE * 72 / 108

# Corner rounding for the legacy PNG. Pre-26 launchers draw the bitmap as-is, so
# a bare square would be the only square in the drawer.
CORNER = 0.20

# --- output sizes ------------------------------------------------------------

# Legacy launcher icons are 48dp; adaptive layers are 108dp. Same buckets, and
# the reason the two lists differ is the whole point of the adaptive format.
DENSITIES = {
    "mdpi": 1,
    "hdpi": 1.5,
    "xhdpi": 2,
    "xxhdpi": 3,
    "xxxhdpi": 4,
}
LEGACY_DP = 48
ADAPTIVE_DP = 108


def read_palette() -> dict[str, tuple[int, int, int]]:
    """Pull the `Palette` colours out of theme.dart.

    Parsing the Dart is the point: it is the one thing that stops the icon and
    the app from ending up two different greens.
    """
    pattern = re.compile(
        r"static const Color (\w+) = Color\(0x[0-9A-Fa-f]{2}([0-9A-Fa-f]{6})\)"
    )
    found = {
        name: (int(hexes[0:2], 16), int(hexes[2:4], 16), int(hexes[4:6], 16))
        for name, hexes in pattern.findall(THEME.read_text())
    }
    missing = {"ground", "chalk"} - found.keys()
    if missing:
        raise SystemExit(f"{THEME} no longer defines: {', '.join(sorted(missing))}")
    return found


def _smooth_noise(count: int, amplitude: float, rng: random.Random) -> list[float]:
    """Random wobble with the spikes taken off.

    Raw per-sample noise on a stroke edge looks like a saw blade. Two passes of
    a three-tap mean leave a chalky ripple instead.
    """
    values = [rng.uniform(-amplitude, amplitude) for _ in range(count)]
    for _ in range(2):
        values = [
            (values[max(i - 1, 0)] + values[i] + values[min(i + 1, count - 1)]) / 3
            for i in range(count)
        ]
    return values


def _chalk_polygon(
    start: tuple[float, float],
    end: tuple[float, float],
    width: float,
    bow: float,
    rng: random.Random,
    samples: int = 96,
) -> list[tuple[float, float]]:
    """One stroke, as an outline walked up one side and back down the other."""
    (x0, y0), (x1, y1) = start, end
    dx, dy = x1 - x0, y1 - y0
    length = math.hypot(dx, dy)
    along = (dx / length, dy / length)
    normal = (-along[1], along[0])

    # Two slow waves stand in for the pressure a hand varies along a stroke. The
    # frequencies and phases differ per stroke, so no two thin in the same place.
    f1, p1 = rng.uniform(1.1, 1.9), rng.random()
    f2, p2 = rng.uniform(2.4, 3.6), rng.random()
    ripple = _smooth_noise(samples, 0.035 * width, rng)

    left: list[tuple[float, float]] = []
    right: list[tuple[float, float]] = []
    for i in range(samples):
        t = i / (samples - 1)
        pressure = 1.0 + 0.055 * math.sin(math.tau * (f1 * t + p1))
        pressure += 0.035 * math.sin(math.tau * (f2 * t + p2))
        # The chalk is landing at one end and lifting at the other, so both ends
        # come in a little narrower than the middle. Only a little: any more and
        # the slanted end cut below turns the corner into an arrowhead.
        lift = 1.0 - 0.05 * (
            max(0.0, 1 - t / 0.10) ** 2 + max(0.0, 1 - (1 - t) / 0.10) ** 2
        )
        half = 0.5 * width * pressure * lift + ripple[i]

        swell = bow * math.sin(math.pi * t)
        cx = x0 + dx * t + normal[0] * swell
        cy = y0 + dy * t + normal[1] * swell
        left.append((cx + normal[0] * half, cy + normal[1] * half))
        right.append((cx - normal[0] * half, cy - normal[1] * half))

    # Cut both ends off square but not perpendicular: one side of the stroke
    # stops before the other, which is what a stick of chalk actually leaves.
    # The slant is eased back over several samples, because moving only the last
    # point puts a step in the outline that reads as a nick rather than an end.
    ramp = 6
    for anchor, inwards in ((0, 1), (samples - 1, -1)):
        slip = rng.uniform(-0.16, 0.16) * width
        for k in range(ramp):
            shift = slip * (1 - k / ramp) ** 2
            i = anchor + inwards * k
            lx, ly = left[i]
            left[i] = (lx + along[0] * shift, ly + along[1] * shift)
            rx, ry = right[i]
            right[i] = (rx - along[0] * shift, ry - along[1] * shift)

    return left + right[::-1]


def draw_mark(extent: float) -> Image.Image:
    """The five strokes alone, as a MASTER-sized alpha mask."""
    rng = random.Random(SEED)
    mask = Image.new("L", (MASTER, MASTER), 0)
    pen = ImageDraw.Draw(mask)

    # The mark is fitted by width and centred by height, so the leftover margin
    # is the one the shape earns rather than a number chosen twice.
    width = extent * MASTER / WIDTH
    left = (MASTER - WIDTH * width) / 2
    top_edge = (MASTER - HEIGHT * width) / 2

    def place(u: float, v: float) -> tuple[float, float]:
        return (left + u * width, top_edge + v * width)

    for index, (lean, top, bottom, bow) in enumerate(UPRIGHTS):
        centre = OVERSHOOT + 0.5 + index * PITCH
        # Lean about the stroke's own middle, so leaning does not also shift it.
        offset = math.tan(math.radians(lean)) * (bottom - top) / 2
        pen.polygon(
            _chalk_polygon(
                place(centre + offset, top),
                place(centre - offset, bottom),
                width,
                bow * width,
                rng,
            ),
            fill=255,
        )

    (sx, sy), (ex, ey), bow = STRIKE
    pen.polygon(
        _chalk_polygon(place(sx, sy), place(ex, ey), width, bow * width, rng),
        fill=255,
    )

    # Chalk skips. Soft blobs of noise bitten out of the strokes, coarse enough
    # to read as dust at 1024 and to vanish entirely by 48.
    speckle = MASTER // 20
    grain = Image.effect_noise((speckle, speckle), 42).resize(
        (MASTER, MASTER), Image.Resampling.BICUBIC
    )
    mask = ImageChops.subtract(mask, grain.point(lambda v: max(0, 86 - v)))

    # Chalk does not have a vector edge. A hair of blur is a dusty edge at 1024
    # and nothing at all by the time it reaches 48.
    return mask.filter(ImageFilter.GaussianBlur(MASTER / 900))


def corner_mask() -> Image.Image:
    mask = Image.new("L", (MASTER, MASTER), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, MASTER - 1, MASTER - 1), radius=int(CORNER * MASTER), fill=255
    )
    return mask


def _down(mask: Image.Image, size: int) -> Image.Image:
    return mask.resize((size, size), Image.Resampling.LANCZOS)


def tile(
    mark: Image.Image,
    size: int,
    ground: tuple[int, int, int],
    chalk: tuple[int, int, int],
    corners: Image.Image | None = None,
) -> Image.Image:
    """Chalk on ground, filling the square. RGB unless corners are rounded."""
    out = Image.new("RGB", (size, size), ground)
    out.paste(Image.new("RGB", (size, size), chalk), (0, 0), _down(mark, size))
    if corners is None:
        return out
    out = out.convert("RGBA")
    out.putalpha(_down(corners, size))
    return out


def foreground(
    mark: Image.Image, size: int, chalk: tuple[int, int, int]
) -> Image.Image:
    """The strokes on nothing, for the adaptive layer and for themed icons."""
    out = Image.new("RGBA", (size, size), chalk + (0,))
    out.putalpha(_down(mark, size))
    return out


def write(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)
    print(f"  {path.relative_to(ROOT)}  {image.width}px {image.mode}")


def _hex(colour: tuple[int, int, int]) -> str:
    return "#%02X%02X%02X" % colour


def main() -> None:
    palette = read_palette()
    ground, chalk = palette["ground"], palette["chalk"]
    print(
        f"palette from {THEME.relative_to(ROOT)}: "
        f"ground {_hex(ground)}, chalk {_hex(chalk)}"
    )

    on_tile = draw_mark(EXTENT_TILE)
    on_layer = draw_mark(EXTENT_ADAPTIVE)
    corners = corner_mask()

    res = ROOT / "android" / "app" / "src" / "main" / "res"
    print("android")
    for bucket, scale in DENSITIES.items():
        folder = res / f"mipmap-{bucket}"
        write(
            tile(on_tile, round(LEGACY_DP * scale), ground, chalk, corners),
            folder / "ic_launcher.png",
        )
        write(
            foreground(on_layer, round(ADAPTIVE_DP * scale), chalk),
            folder / "ic_launcher_foreground.png",
        )

    background = res / "values" / "ic_launcher_background.xml"
    background.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<!-- Generated by tool/make_icon.py from Palette.ground. Do not edit. -->\n"
        "<resources>\n"
        f'    <color name="ic_launcher_background">{_hex(ground)}</color>\n'
        "</resources>\n"
    )
    print(f"  {background.relative_to(ROOT)}")

    adaptive = res / "mipmap-anydpi-v26" / "ic_launcher.xml"
    adaptive.parent.mkdir(parents=True, exist_ok=True)
    adaptive.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<!-- Generated by tool/make_icon.py. Do not edit.\n"
        "     The foreground is a flat silhouette on transparency, so it doubles as\n"
        "     the monochrome layer for themed icons on Android 13+ unchanged. -->\n"
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_foreground" />\n'
        "</adaptive-icon>\n"
    )
    print(f"  {adaptive.relative_to(ROOT)}")

    # iOS wants a fixed set of filenames and will warn about any it does not
    # find, so take the list from the catalogue rather than repeating it here.
    appicon = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    catalogue = json.loads((appicon / "Contents.json").read_text())
    wanted = {
        entry["filename"]: round(
            float(entry["size"].split("x")[0]) * int(entry["scale"].rstrip("x"))
        )
        for entry in catalogue["images"]
        if entry.get("filename")
    }
    print("ios")
    for filename, size in sorted(wanted.items(), key=lambda kv: kv[1]):
        # No alpha channel anywhere in the set: the App Store rejects icons that
        # have one, and iOS applies its own mask regardless.
        write(tile(on_tile, size, ground, chalk), appicon / filename)


if __name__ == "__main__":
    main()
