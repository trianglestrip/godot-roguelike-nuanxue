#!/usr/bin/env python3
"""
生成 docs/res.md 中引用的 HUD / 特效占位图（像素风示意，便于后续替换正式美术）。

依赖:
  pip install Pillow

用法（在项目根目录）:
  python automation/generate_res_placeholders.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent


def _ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def draw_hud_bars(hud: Path) -> None:
    w_bg, h_bg = 160, 14
    # HP
    im = Image.new("RGBA", (w_bg, h_bg), (28, 28, 32, 255))
    dr = ImageDraw.Draw(im)
    dr.rectangle([0, 0, w_bg - 1, h_bg - 1], outline=(60, 62, 72, 255))
    im.save(hud / "bar_hp_bg.png")
    Image.new("RGBA", (156, 10), (200, 70, 70, 255)).save(hud / "bar_hp_fill.png")

    Image.new("RGBA", (160, 12), (28, 28, 32, 255)).save(hud / "bar_rage_bg.png")
    Image.new("RGBA", (156, 8), (220, 180, 60, 255)).save(hud / "bar_rage_fill.png")

    Image.new("RGBA", (120, 10), (28, 28, 32, 255)).save(hud / "bar_return_cd_bg.png")
    Image.new("RGBA", (116, 6), (100, 160, 220, 255)).save(hud / "bar_return_cd_fill.png")

    Image.new("RGBA", (140, 10), (28, 28, 32, 255)).save(hud / "bar_shield_bg.png")
    Image.new("RGBA", (136, 6), (120, 200, 255, 255)).save(hud / "bar_shield_fill.png")

    slot = Image.new("RGBA", (26, 26), (0, 0, 0, 0))
    dr2 = ImageDraw.Draw(slot)
    dr2.rectangle([0, 0, 25, 25], outline=(255, 220, 120, 255), width=2)
    slot.save(hud / "element_slot_selected.png")


def _sheet_shock_burst(out: Path, frames: int, fw: int, fh: int) -> None:
    im = Image.new("RGBA", (fw * frames, fh), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    for i in range(frames):
        t = i / max(frames - 1, 1)
        ox = i * fw
        cx, cy = ox + fw // 2, fh // 2
        r = int(fw * 0.35 * (0.35 + 0.65 * t))
        a = int(200 * (1.0 - t * 0.45))
        dr.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(210, 215, 230, a), width=2)
        for j in range(8):
            import math

            ang = j / 8.0 * 6.28318 + t * 0.3
            x1 = cx + math.cos(ang) * r * 0.35
            y1 = cy + math.sin(ang) * r * 0.35
            x2 = cx + math.cos(ang) * r * 0.95
            y2 = cy + math.sin(ang) * r * 0.95
            dr.line([(x1, y1), (x2, y2)], fill=(230, 230, 245, a), width=2)
    im.save(out)


def _sheet_fire_nova(out: Path, frames: int, fw: int, fh: int) -> None:
    im = Image.new("RGBA", (fw * frames, fh), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    for i in range(frames):
        t = i / max(frames - 1, 1)
        ox = i * fw
        cx, cy = ox + fw // 2, fh // 2
        for ring in range(3):
            rr = int(fw * 0.18 * (0.45 + ring * 0.22) * (0.45 + 0.55 * t))
            col = (255, 100 + ring * 25, 40, 160 - ring * 35)
            dr.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], outline=col, width=2)
    im.save(out)


def draw_vfx_sheets(vfx: Path) -> None:
    fw, fh = 64, 64

    def save_sheet(name: str, frames: int, draw_one) -> None:
        im = Image.new("RGBA", (fw * frames, fh), (0, 0, 0, 0))
        dr = ImageDraw.Draw(im)
        for fi in range(frames):
            draw_one(dr, fi * fw, fw, fh, fi, frames)
        im.save(vfx / f"{name}_sheet.png")

    # BURST：扩散圆环
    def burst(dr, ox, fw_, fh_, fi, tot):
        t = fi / max(tot - 1, 1)
        cx, cy = ox + fw_ // 2, fh_ // 2
        r = int(fw_ * 0.25 * (0.4 + 0.6 * t))
        a = int(180 * (1.0 - t))
        dr.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(200, 200, 220, a), width=2)

    save_sheet("burst", 8, burst)

    # SLASH_ARC：三道弧示意
    def slash(dr, ox, fw_, fh_, fi, tot):
        t = fi / max(tot - 1, 1)
        cx, cy = ox + fw_ // 2, fh_ // 2
        r = int(fw_ * 0.4 * (0.5 + 0.5 * t))
        for k in range(3):
            ang = k * 2.094 + t * 0.5
            import math

            dr.arc(
                [cx - r, cy - r, cx + r, cy + r],
                int(math.degrees(ang)),
                int(math.degrees(ang + 1.4)),
                fill=(220, 220, 240, 200),
                width=3,
            )

    save_sheet("slash_arc", 8, slash)

    _sheet_shock_burst(vfx / "shock_burst_sheet.png", 10, fw, fh)

    def vine(dr, ox, fw_, fh_, fi, tot):
        t = fi / max(tot - 1, 1)
        cx, cy = ox + fw_ // 2, fh_ // 2
        rx, ry = int(fw_ * 0.45), int(fh_ * 0.28)
        dr.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], outline=(70, 170, 85, 210), width=2)

    save_sheet("vine_snare", 10, vine)

    def poison(dr, ox, fw_, fh_, fi, tot):
        import random

        rng = random.Random(12345 + fi)
        for _ in range(6):
            px = ox + rng.randint(8, fw_ - 8)
            py = rng.randint(8, fh_ - 8)
            rr = rng.randint(4, 10)
            dr.ellipse([px - rr, py - rr, px + rr, py + rr], fill=(70, 150, 80, 90))

    save_sheet("poison_cloud", 12, poison)

    def ice_spike(dr, ox, fw_, fh_, fi, tot):
        import math

        for k in range(6):
            ang = k / 6.0 * 6.28318
            cx = ox + fw_ // 2 + math.cos(ang) * fw_ * 0.15 * fi / max(tot - 1, 1)
            cy = fh_ // 2 + math.sin(ang) * 8
            tip = (cx + math.cos(ang) * fw_ * 0.35, cy + math.sin(ang) * fw_ * 0.35)
            dr.polygon([(cx, cy), tip, (cx - 6, cy + 8)], outline=(180, 220, 255, 230), width=2)

    save_sheet("ice_spike", 8, ice_spike)

    def ice_ring(dr, ox, fw_, fh_, fi, tot):
        t = fi / max(tot - 1, 1)
        cx, cy = ox + fw_ // 2, fh_ // 2
        r = int(fw_ * 0.38 * (0.55 + 0.45 * t))
        dr.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(190, 220, 255, 220), width=3)

    save_sheet("ice_ring", 8, ice_ring)

    def fire_fan(dr, ox, fw_, fh_, fi, tot):
        cx, cy = ox + fw_ // 2, fh_ // 2
        r = int(fw_ * 0.42)
        dr.pieslice([cx - r, cy - r, cx + r, cy + r], -45, 45, fill=(255, 130, 60, 100))

    save_sheet("fire_fan", 8, fire_fan)

    _sheet_fire_nova(vfx / "fire_nova_sheet.png", 10, fw, fh)

    def stone_spike(dr, ox, fw_, fh_, fi, tot):
        import math

        for k in range(8):
            ang = k / 8.0 * 6.28318
            h = fw_ * 0.4 * (0.4 + 0.6 * fi / max(tot - 1, 1))
            tip = (ox + fw_ // 2 + math.cos(ang) * h, fh_ // 2 + math.sin(ang) * h)
            base = (ox + fw_ // 2 + math.cos(ang) * h * 0.15, fh_ // 2 + math.sin(ang) * h * 0.15)
            orth = (-math.sin(ang) * 6, math.cos(ang) * 6)
            dr.polygon(
                [
                    (base[0] + orth[0], base[1] + orth[1]),
                    tip,
                    (base[0] - orth[0], base[1] - orth[1]),
                ],
                fill=(150, 125, 95, 220),
            )

    save_sheet("stone_spike", 8, stone_spike)

    def stone_rain(dr, ox, fw_, fh_, fi, tot):
        import random

        rng = random.Random(54321 + fi)
        for _ in range(5):
            x = ox + rng.randint(4, fw_ - 10)
            y = rng.randint(4, fh_ - 16) + int(fi / max(tot - 1, 1) * 8)
            dr.rectangle([x, y, x + 4, y + 12], fill=(130, 110, 90, 200))

    save_sheet("stone_rain", 12, stone_rain)


def generate_all() -> None:
    hud = ROOT / "assets" / "realtime" / "ui" / "hud"
    vfx = ROOT / "assets" / "realtime" / "vfx" / "spritesheets"
    _ensure_dir(hud)
    _ensure_dir(vfx)
    draw_hud_bars(hud)
    draw_vfx_sheets(vfx)
    print("已生成:", hud)
    print("已生成:", vfx)


if __name__ == "__main__":
    generate_all()
