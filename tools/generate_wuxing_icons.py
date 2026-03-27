#!/usr/bin/env python3
"""生成五行占位 UI 图标（32x32 PNG）。依赖: pip install pillow"""

from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("请安装: pip install pillow")
    raise SystemExit(1)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "realtime" / "ui"
OUT.mkdir(parents=True, exist_ok=True)

# 金木水火土 主色 (RGBA)
COLORS = [
    ((220, 215, 180, 255), "metal", "金"),
    ((80, 180, 90, 255), "wood", "木"),
    ((70, 130, 230, 255), "water", "水"),
    ((240, 90, 60, 255), "fire", "火"),
    ((160, 120, 80, 255), "earth", "土"),
]


def main() -> None:
    for rgba, key, _cn in COLORS:
        img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        dr = ImageDraw.Draw(img)
        dr.rounded_rectangle([2, 2, 29, 29], radius=4, fill=rgba)
        dr.rectangle([6, 6, 25, 25], outline=(255, 255, 255, 200), width=1)
        path = OUT / f"icon_{key}.png"
        img.save(path)
        print("Wrote", path)


if __name__ == "__main__":
    main()
