#!/usr/bin/env python3
"""Render Chalk's spoken commentary to `assets/sounds/speech/`.

A darts commentator has a closed vocabulary. Every three-dart total is an
integer between 0 and 180, and everything else it ever says is one of five
fixed calls. That is 186 lines, and they never change, so there is no reason to
carry a text-to-speech engine on the phone: rendering them once here removes a
runtime dependency, removes the first-call latency of a cold TTS engine, and -
the point that actually matters - removes per-device variation. The line the
player hears is the line that was listened to when it was tuned.

Requires `piper` (pipx install piper-tts) and `ffmpeg`. The voice model is
~63MB, downloads on first run into `--voices-dir`, and is build-time only: it
is never shipped and never committed.

    python3 tool/make_speech.py

The output is Ogg Vorbis, which Android's ExoPlayer decodes natively. Note for
whenever iOS becomes real: AVFoundation cannot decode Ogg at all, so an iOS
build needs a second encode pass to AAC/m4a. Nothing else here changes.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

VOICE = "en_GB-northern_english_male-medium"
"""Northern English male: the accent darts is commentated in.

Anything else sounds like a satnav reading out a score. Licence and attribution
for the voice are recorded in `assets/sounds/SPEECH-VOICE-LICENCE.txt`, beside
the audio it produced, as was done for the bundled font.
"""

VOICE_URL = (
    "https://huggingface.co/rhasspy/piper-voices/resolve/main/"
    "en/en_GB/northern_english_male/medium/" + VOICE
)

REPO_ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = REPO_ROOT / "assets" / "sounds" / "speech"
DEFAULT_VOICES_DIR = Path.home() / ".local" / "share" / "piper-voices"

UNITS = [
    "zero", "one", "two", "three", "four", "five", "six", "seven", "eight",
    "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
    "sixteen", "seventeen", "eighteen", "nineteen",
]
TENS = [
    "", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy",
    "eighty", "ninety",
]

# The highest three-dart total. Nothing above this is reachable, so nothing
# above this is rendered.
MAX_TOTAL = 180


def spell(n: int) -> str:
    """A number as a commentator says it: "one hundred and eighty", not "one eight zero"."""
    if n < 20:
        return UNITS[n]
    if n < 100:
        rest = n % 10
        return TENS[n // 10] + (f" {UNITS[rest]}" if rest else "")
    # Only 100-180 reach here, so the hundreds digit is always one.
    rest = n % 100
    return "one hundred" + (f" and {spell(rest)}" if rest else "")


# Filename stem -> (text, length scale). A length scale above 1 slows the read.
#
# `one_hundred_and_eighty` is deliberately not the same recording as `180`. The
# number file is the flat total a scorer reads out; this one is the call, drawn
# out and exclaimed, and it is the only line in the app that is allowed to be
# theatrical. The sound controller plays this one, never `180`, for a maximum.
#
# `no_score` exists for the same reason: `0` renders as the word "zero", which
# no commentator has ever said about a darts turn.
PHRASES: dict[str, tuple[str, float]] = {
    "bust": ("Bust.", 1.0),
    "no_score": ("No score.", 1.0),
    "game_shot": ("Game shot!", 1.05),
    "one_hundred_and_eighty": ("One hundred and eighty!", 1.15),
    "game_on": ("Game on!", 1.0),
}

# Trim silence from both ends, then leave a little headroom.
#
# Piper pads its output, and a quarter second of nothing before "one hundred and
# forty" reads as the app being slow. Piper also normalises to full scale, and a
# lossy codec reconstructs peaks slightly above where it found them - so 1.5dB
# is given back before encoding, which is inaudible and is the difference
# between a clean decode and one that clips on the loudest syllable.
FILTERS = (
    "silenceremove=start_periods=1:start_threshold=-50dB:"
    "start_silence=0.02:detection=peak,"
    "areverse,"
    "silenceremove=start_periods=1:start_threshold=-50dB:"
    "start_silence=0.02:detection=peak,"
    "areverse,"
    "volume=-1.5dB"
)


def ensure_voice(voices_dir: Path) -> Path:
    """Downloads the voice if it is not already there, and returns the model path."""
    voices_dir.mkdir(parents=True, exist_ok=True)
    model = voices_dir / f"{VOICE}.onnx"

    for suffix in (".onnx", ".onnx.json"):
        target = voices_dir / f"{VOICE}{suffix}"
        if target.exists():
            continue
        print(f"downloading {target.name} (once, ~63MB) ...", flush=True)
        # Straight from the Piper voice repository rather than through
        # `piper.download_voices`, which only exists inside piper's own venv
        # and is not importable from whichever Python runs this script.
        partial = target.with_suffix(target.suffix + ".part")
        urllib.request.urlretrieve(f"{VOICE_URL}{suffix}", partial)
        partial.rename(target)

    return model


def synthesise(piper: str, model: Path, text: str, wav: Path, length_scale: float) -> None:
    subprocess.run(
        [
            piper,
            "--model", str(model),
            "--output-file", str(wav),
            "--length-scale", str(length_scale),
            "--sentence-silence", "0",
            text,
        ],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def encode(wav: Path, ogg: Path, quality: int) -> None:
    subprocess.run(
        [
            "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
            "-i", str(wav),
            "-ac", "1",
            "-af", FILTERS,
            "-c:a", "libvorbis", "-q:a", str(quality),
            str(ogg),
        ],
        check=True,
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--piper",
        default=str(Path.home() / ".local" / "bin" / "piper"),
        help="piper executable",
    )
    parser.add_argument(
        "--voices-dir",
        type=Path,
        default=DEFAULT_VOICES_DIR,
        help="where the voice model lives; outside the repo on purpose",
    )
    parser.add_argument(
        "--quality",
        type=int,
        default=1,
        help="libvorbis -q:a. 1 is ~55kbps mono, which is plenty for speech "
             "heard across a garage",
    )
    parser.add_argument(
        "--only",
        help="render just the lines whose stem contains this, for tuning",
    )
    args = parser.parse_args()

    if not Path(args.piper).exists():
        print(f"piper not found at {args.piper} (pipx install piper-tts)", file=sys.stderr)
        return 1
    if shutil.which("ffmpeg") is None:
        print("ffmpeg not found (sudo apt install ffmpeg)", file=sys.stderr)
        return 1

    model = ensure_voice(args.voices_dir)

    lines: list[tuple[str, str, float]] = [
        (str(n), spell(n), 1.0) for n in range(MAX_TOTAL + 1)
    ]
    lines += [(stem, text, scale) for stem, (text, scale) in PHRASES.items()]
    if args.only:
        lines = [line for line in lines if args.only in line[0]]

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    scratch = OUT_DIR / ".wav"
    scratch.mkdir(exist_ok=True)

    total = 0
    for index, (stem, text, scale) in enumerate(lines, start=1):
        wav = scratch / f"{stem}.wav"
        ogg = OUT_DIR / f"{stem}.ogg"
        synthesise(args.piper, model, text, wav, scale)
        encode(wav, ogg, args.quality)
        total += ogg.stat().st_size
        print(f"[{index:>3}/{len(lines)}] {ogg.name:<28} {text}", flush=True)

    shutil.rmtree(scratch)
    print(f"\n{len(lines)} files, {total / 1024:.0f} KiB in {OUT_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
