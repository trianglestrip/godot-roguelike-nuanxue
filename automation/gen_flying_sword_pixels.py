# -*- coding: utf-8 -*-
"""Generate horizontal strips: 4 frames * 16px wide, 12px tall. One PNG per element."""
from pathlib import Path
from typing import Optional, Tuple

from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parents[1] / "assets" / "realtime" / "projectiles"
FRAMES = 4
FW, FH = 16, 12


def _px(img: Image.Image, x: int, y: int, c: tuple) -> None:
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), c)


def draw_blade(
    draw: ImageDraw.ImageDraw, ox: int, oy: int, blade: Tuple[int, ...], edge: Tuple[int, ...], glow: Optional[Tuple[int, ...]]
) -> None:
    # Simple sword silhouette: blade + hilt (pixel art)
    pts = [
        (7 + ox, 0 + oy),
        (9 + ox, 0 + oy),
        (10 + ox, 2 + oy),
        (10 + ox, 8 + oy),
        (9 + ox, 10 + oy),
        (7 + ox, 10 + oy),
        (6 + ox, 8 + oy),
        (6 + ox, 2 + oy),
    ]
    draw.polygon(pts, fill=blade, outline=edge)
    if glow:
        draw.line([(5 + ox, 3 + oy), (5 + ox, 7 + oy)], fill=glow)
        draw.line([(11 + ox, 3 + oy), (11 + ox, 7 + oy)], fill=glow)


def make_strip(
    name: str, blade: Tuple[int, ...], edge: Tuple[int, ...], glow: Optional[Tuple[int, ...]], accent: Optional[Tuple[int, ...]]
) -> None:
    w, h = FRAMES * FW, FH
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    for f in range(FRAMES):
        ox = f * FW
        tilt = f - 1.5  # -1.5 .. 1.5
        oy = int(tilt * 0.8)
        draw_blade(draw, ox, oy, blade, edge, glow)
        if accent and f % 2 == 0:
            draw.ellipse([ox + 4, oy + 3, ox + 6, oy + 5], fill=accent)
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"flying_sword_{name}.png"
    img.save(path, "PNG")
    print("Wrote", path)


def main() -> None:
    # RGBA tuples
    make_strip("metal", (220, 225, 235, 255), (140, 148, 168, 255), (255, 255, 255, 120), None)
    make_strip("wood", (72, 140, 68, 255), (32, 72, 28, 255), (120, 200, 90, 100), (40, 100, 36, 255))
    make_strip("water", (110, 170, 240, 255), (50, 90, 180, 255), (180, 220, 255, 90), (200, 240, 255, 200))
    make_strip("fire", (255, 120, 60, 255), (180, 40, 20, 255), (255, 220, 80, 140), (255, 200, 40, 255))
    make_strip("earth", (150, 120, 88, 255), (80, 60, 44, 255), (200, 180, 140, 80), (110, 90, 70, 255))


if __name__ == "__main__":
    main()
