#!/usr/bin/env python3
"""Generate assets/animations/streak_glyph.json — the animated flame
shown next to the login streak on the Account screen.

Emits plain Lottie JSON rather than a zipped .lottie bundle. The zip
container only earns its keep with the dotLottie player (themes, state
machines, multiple animations); with the pure-Dart `lottie` package it
is a liability, because that decoder picks the archive's FIRST .json --
which would be manifest.json, not the animation.

Hand-authored Lottie (no design tool involved), so it stays small and
re-tunable. Run from the repo root:

    python tool/gen_streak_glyph.py

The timeline holds three 30-frame intensity stages, played as segments
by StreakGlyph (lib/ui/streak_glyph.dart). Keep STAGES in sync with the
frame ranges declared there.

    ember    frames  0-30   early streak, small dim flicker
    burning  frames 30-60   mid streak
    blaze    frames 60-90   day 7+ jackpot, big and bright

Each stage is its own layer, gated by Lottie in/out points, so colour
and size can differ per stage instead of being one tweened blob.
"""

import json
import os

W = H = 128
FPS = 30
STAGE_FRAMES = 30

# name, base scale %, outer rgb, core rgb
STAGES = [
    # Scale range is deliberately narrow: at the ~30px the glyph actually
    # renders at, a small early stage reads as a speck rather than a
    # flame. Colour carries most of the progression.
    ("ember",   76, (0.76, 0.25, 0.05), (0.98, 0.55, 0.15)),
    ("burning", 88, (0.92, 0.35, 0.05), (0.99, 0.65, 0.25)),
    ("blaze",  100, (0.96, 0.62, 0.04), (0.99, 0.90, 0.55)),
]

# Flame silhouette in layer-local space, y-down (tip is negative y).
# v = vertices, i = in tangent, o = out tangent (both vertex-relative).
FLAME = {
    "c": True,
    # Tip leans slightly right with asymmetric tangents so it curls like a
    # flame instead of closing into an egg. Widest point sits just past
    # halfway down; the base is broad and flat.
    "v": [[3, -48], [25, 2], [17, 30], [0, 37], [-17, 30], [-24, 0]],
    "i": [[-4, 16], [-3, -20], [7, -9], [10, 0], [3, 7], [-1, -13]],
    "o": [[5, 13], [2, 12], [-5, 7], [-10, 0], [-5, -9], [3, -22]],
}


def scaled_path(factor, dy):
    """The flame silhouette, scaled about its own centre and nudged."""
    def sc(pts, translate):
        return [[round(x * factor + (dy if translate and i == 1 else 0), 2)
                 for i, x in enumerate(p)] for p in pts]
    return {
        "c": True,
        "v": sc(FLAME["v"], True),
        "i": sc(FLAME["i"], False),
        "o": sc(FLAME["o"], False),
    }


def shape_group(path, rgb):
    return {
        "ty": "gr",
        "nm": "flame",
        "it": [
            {"ty": "sh", "ind": 0, "ks": {"a": 0, "k": path}},
            {"ty": "fl", "c": {"a": 0, "k": [*rgb, 1]}, "o": {"a": 0, "k": 100},
             "r": 1},
            {"ty": "tr",
             "p": {"a": 0, "k": [0, 0]}, "a": {"a": 0, "k": [0, 0]},
             "s": {"a": 0, "k": [100, 100]}, "r": {"a": 0, "k": 0},
             "o": {"a": 0, "k": 100}},
        ],
    }


def keyframes(start, values):
    """Evenly spaced looping keyframes across one stage window.

    Easing arrays are sized to match the value's dimensionality --
    strict Lottie renderers reject a 1-element ease on a multi-component
    property, which shows up as a silently blank animation.
    """
    step = STAGE_FRAMES / (len(values) - 1)
    dims = len(values[0])
    out = []
    for idx, value in enumerate(values):
        out.append({
            "t": round(start + idx * step, 3),
            "s": value,
            # Ease both ways so the flicker breathes instead of ticking.
            "i": {"x": [0.4] * dims, "y": [1.0] * dims},
            "o": {"x": [0.6] * dims, "y": [0.0] * dims},
        })
    out[-1].pop("i", None)
    out[-1].pop("o", None)
    return out


def stage_layer(index, name, scale, outer, core):
    start = index * STAGE_FRAMES
    end = start + STAGE_FRAMES

    # Flicker: squash and stretch, returning to the start value so the
    # segment loops seamlessly.
    # Scale carries a z component: some renderers expect a 3-vector on a
    # transform's scale and treat a 2-vector as malformed.
    s = scale
    scale_kf = keyframes(start, [
        [s, s, 100],
        [round(s * 1.07, 2), round(s * 0.95, 2), 100],
        [round(s * 0.96, 2), round(s * 1.06, 2), 100],
        [s, s, 100],
    ])
    rot_kf = keyframes(start, [[0], [3.5], [-3.5], [0]])

    return {
        "ddd": 0,
        "ind": index + 1,
        "ty": 4,
        "nm": name,
        "sr": 1,
        "ks": {
            "o": {"a": 0, "k": 100},
            "r": {"a": 1, "k": rot_kf},
            "p": {"a": 0, "k": [W / 2, H / 2 + 6, 0]},
            "a": {"a": 0, "k": [0, 0, 0]},
            "s": {"a": 1, "k": scale_kf},
        },
        "ao": 0,
        "shapes": [
            shape_group(scaled_path(1.0, 0), outer),
            # Inner core sits low and small, like the hot part of a flame.
            shape_group(scaled_path(0.52, 10), core),
        ],
        "ip": start,
        "op": end,
        "st": start,
        "bm": 0,
    }


def build_animation():
    return {
        "v": "5.7.4",
        "fr": FPS,
        "ip": 0,
        "op": len(STAGES) * STAGE_FRAMES,
        "w": W,
        "h": H,
        "nm": "streak_glyph",
        "ddd": 0,
        "assets": [],
        "layers": [stage_layer(i, *s) for i, s in enumerate(STAGES)],
        "markers": [
            {"tm": i * STAGE_FRAMES, "cm": s[0], "dr": STAGE_FRAMES}
            for i, s in enumerate(STAGES)
        ],
    }


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out_dir = os.path.join(root, "assets", "animations")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "streak_glyph.json")

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(build_animation(), f, separators=(",", ":"))

    # Drop the old dotLottie bundle so a stale one can't be picked up.
    legacy = os.path.join(out_dir, "streak_glyph.lottie")
    if os.path.exists(legacy):
        os.remove(legacy)
        print(f"removed legacy {legacy}")

    size = os.path.getsize(out_path)
    print(f"wrote {out_path} ({size} bytes)")
    for i, (name, *_rest) in enumerate(STAGES):
        print(f"  {name:8s} frames {i * STAGE_FRAMES}-{(i + 1) * STAGE_FRAMES}")


if __name__ == "__main__":
    main()
