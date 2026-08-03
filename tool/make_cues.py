#!/usr/bin/env python3
"""Synthesise Chalk's non-speech cues to `assets/sounds/cues/`.

Four sounds, a few KB each, written with nothing but Python's `wave` and
`math`. Sampling a library would mean a licence to track and a file nobody can
adjust; these are described by the numbers below, so "the bust is too shrill"
is a one-line change and a re-run rather than a hunt through a sound pack.

    python3 tool/make_cues.py

They stay 16-bit WAV rather than being encoded. Each one is under 100KB, and
the dart click fires three times a turn on a `PlayerMode.lowLatency` player -
handing that path an undecoded PCM buffer is the whole point.

The four are separated by pitch, not just by shape, because they are heard from
the oche with darts in hand and no eyes on the phone:

    dart      ~1500Hz, 45ms   a tick, felt more than heard
    bust       ~98Hz, 420ms   two octaves below anything else here
    checkout   880 -> 1319Hz  a rising perfect fifth, A5 to E6
    one_eighty 523 -> 1047Hz  a major triad climbing an octave

A bust and a checkout are the two that must never be confused - one ends a turn
badly, the other ends the leg - and they sit three octaves apart with opposite
contours: the bust sinks, the checkout rises.

If a duration here changes, `SoundEvents.cue*` in
`lib/app/audio/sound_controller.dart` holds the delays that keep the spoken
line off the top of the cue. They are written down in both places on purpose;
the comment there says which.
"""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 44100
AMPLITUDE = 0.72
"""Peak, as a fraction of full scale. Short of 1.0 so summed partials in the
fanfare have somewhere to go before they clip."""

REPO_ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = REPO_ROOT / "assets" / "sounds" / "cues"

Samples = list[float]


def silence(seconds: float) -> Samples:
    return [0.0] * int(SAMPLE_RATE * seconds)


def mix(into: Samples, at: float, samples: Samples) -> None:
    """Adds `samples` into `into` starting at `at` seconds, extending as needed."""
    start = int(SAMPLE_RATE * at)
    if len(into) < start + len(samples):
        into.extend([0.0] * (start + len(samples) - len(into)))
    for i, value in enumerate(samples):
        into[start + i] += value


def envelope(count: int, attack: float, release: float) -> Samples:
    """A raised-cosine attack and an exponential decay, in seconds.

    Both ends matter. A tone that starts at full amplitude on sample zero has a
    step discontinuity in it, and a step is a click across every frequency at
    once - which is exactly why a raw square wave sounds cheap. A tone that
    stops dead has the same click at the other end.
    """
    attack_n = max(1, int(SAMPLE_RATE * attack))
    release_n = max(1, int(SAMPLE_RATE * release))
    # Shifted so the decay reaches exactly zero on the last sample. An
    # exponential that merely gets close still ends on a step.
    floor = math.exp(-5.0)

    out = []
    for i in range(count):
        gain = 1.0
        if i < attack_n:
            gain = 0.5 - 0.5 * math.cos(math.pi * i / attack_n)
        # The release is measured from the end, so shortening a tone shortens
        # its body rather than clipping its tail off.
        remaining = count - i
        if remaining < release_n:
            through = 1.0 - remaining / release_n
            gain *= (math.exp(-5.0 * through) - floor) / (1.0 - floor)
        out.append(gain)
    return out


def tone(
    freq: float,
    seconds: float,
    *,
    attack: float = 0.004,
    release: float = 0.08,
    partials: tuple[float, ...] = (1.0,),
    gain: float = 1.0,
    bend: float = 1.0,
) -> Samples:
    """A shaped additive tone.

    `partials` are the amplitudes of harmonics 1, 2, 3 ... A single 1.0 is a
    sine; adding a little second and third harmonic is what separates a chime
    from a test tone. `bend` is the ratio the pitch slides to by the end.
    """
    count = int(SAMPLE_RATE * seconds)
    shape = envelope(count, attack, release)
    out = []
    phase = 0.0
    for i in range(count):
        progress = i / max(1, count - 1)
        current = freq * (1.0 + (bend - 1.0) * progress)
        phase += 2.0 * math.pi * current / SAMPLE_RATE
        value = sum(
            amp * math.sin(phase * (harmonic + 1))
            for harmonic, amp in enumerate(partials)
        )
        out.append(value * shape[i] * gain)
    return out


def normalise(samples: Samples, peak: float = AMPLITUDE) -> Samples:
    loudest = max((abs(v) for v in samples), default=0.0)
    if loudest == 0.0:
        return samples
    return [v * peak / loudest for v in samples]


def write(name: str, samples: Samples) -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUT_DIR / f"{name}.wav"
    frames = b"".join(
        struct.pack("<h", int(max(-1.0, min(1.0, v)) * 32767)) for v in samples
    )
    with wave.open(str(path), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(SAMPLE_RATE)
        out.writeframes(frames)
    return path.stat().st_size


def dart() -> Samples:
    """A dart registering. 45ms, and it has to stay that way.

    This fires three times a turn, on every turn, for the life of the app. Any
    longer and it stops being punctuation and starts being a noise you turn off.
    """
    click = tone(1500, 0.045, attack=0.0015, release=0.042, partials=(1.0, 0.35))
    # A touch of the octave above, three milliseconds long, for the transient
    # edge that makes it read as a tick rather than a beep.
    mix(click, 0.0, tone(3000, 0.006, attack=0.0005, release=0.005, gain=0.5))
    return normalise(click, 0.45)


def bust() -> Samples:
    """A bust. Low, buzzing, and sagging - 420ms of bad news.

    Sawtooth-ish rather than a sine: a bust should sound like something went
    wrong, and the upper harmonics are what carry that across a room.
    """
    buzz = tone(
        98,
        0.42,
        attack=0.006,
        release=0.16,
        partials=(1.0, 0.6, 0.42, 0.3, 0.22, 0.16),
        bend=0.86,  # sags a minor third by the end
    )
    # Amplitude modulation at 22Hz is the buzz itself. Slow enough to be heard
    # as a rattle rather than as a second pitch.
    for i in range(len(buzz)):
        buzz[i] *= 0.72 + 0.28 * math.sin(2.0 * math.pi * 22.0 * i / SAMPLE_RATE)
    return normalise(buzz, 0.8)


def checkout() -> Samples:
    """The double that wins the leg. A5 up to E6, ringing.

    Rising, because it is the one unambiguously good thing that happens in a
    leg, and high, because the bust is low and these two must never be mistaken
    for one another.
    """
    out: Samples = silence(0.0)
    mix(out, 0.00, tone(880, 0.30, attack=0.003, release=0.22, partials=(1.0, 0.3, 0.12)))
    mix(out, 0.16, tone(1318.5, 0.50, attack=0.003, release=0.40, partials=(1.0, 0.28, 0.14)))
    return normalise(out, 0.75)


def one_eighty() -> Samples:
    """A maximum. A C major triad climbing an octave, then held.

    Longer than the rest at a second, and it can afford to be: a 180 arrives
    about once a session and the spoken call waits for it to finish.
    """
    brass = (1.0, 0.5, 0.32, 0.18, 0.1)
    out: Samples = silence(0.0)
    for at, freq in ((0.00, 523.25), (0.09, 659.25), (0.18, 783.99)):
        mix(out, at, tone(freq, 0.26, attack=0.008, release=0.12, partials=brass, gain=0.7))
    # The octave lands on its own and rings out under nothing.
    mix(out, 0.30, tone(1046.5, 0.70, attack=0.006, release=0.5, partials=brass))
    return normalise(out, 0.82)


def main() -> None:
    total = 0
    for name, build in (
        ("dart", dart),
        ("bust", bust),
        ("checkout", checkout),
        ("one_eighty", one_eighty),
    ):
        samples = build()
        size = write(name, samples)
        total += size
        print(f"{name + '.wav':<16} {len(samples) / SAMPLE_RATE * 1000:>6.0f} ms  {size / 1024:>6.1f} KiB")
    print(f"\n4 files, {total / 1024:.0f} KiB in {OUT_DIR}")


if __name__ == "__main__":
    main()
