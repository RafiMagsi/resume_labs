"""Generate captioned App Store / Play marketing screenshots for ResumePace.

Reads raw captures from store_assets/screenshots/<set>/ and writes framed,
headline-captioned images to store_assets/marketing/<out>/. The device status
bar is cropped away (it carries simulator artifacts), the capture is placed in a
rounded frame on the brand gradient, and a headline sits above it.
"""

from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "store_assets/screenshots"
OUT = ROOT / "store_assets/marketing"
FONT_BOLD = ROOT / "assets/fonts/Inter-Bold.ttf"
FONT_MEDIUM = ROOT / "assets/fonts/Inter-Medium.ttf"

PURPLE_TOP = (124, 108, 246)
PURPLE_BOTTOM = (62, 34, 168)

# (raw file, headline lines, sub caption) — order matters: first three show in search.
SLIDES = [
    ("ios_history", ["Build a resume", "that gets hired"], "AI resume builder & CV maker"),
    ("ios_optimizer", ["Optimize your", "resume with AI"], "Stronger summary, sharper bullets"),
    ("ios_templates", ["14 ATS-friendly", "templates"], "For tech, sales, finance & more"),
    ("ios_preview", ["See it live,", "export in one tap"], "Polished PDF, ready to send"),
    ("ios_builder", ["Guided, step-", "by-step builder"], "From first draft to final CV"),
]

# out dir, raw set, canvas size, status-bar crop (fraction of height), phone width fraction
TARGETS = [
    ("ios_iphone_6_9", "ios_iphone17promax", (1320, 2868), 0.058, 0.80),
    ("ios_iphone_6_3", "ios_iphone17pro", (1206, 2622), 0.058, 0.80),
    ("ios_ipad_13", "ios_ipad", (2064, 2752), 0.012, 0.66),
    ("android_phone", "android_phone", (1080, 2400), 0.040, 0.80),
]


def gradient(w: int, h: int) -> Image.Image:
    y, x = np.mgrid[0:h, 0:w]
    t = np.clip((x * 0.35 + y) / (w * 0.35 + h), 0, 1)[..., None]
    top = np.array(PURPLE_TOP, dtype=np.float32)
    bottom = np.array(PURPLE_BOTTOM, dtype=np.float32)
    img = top * (1 - t) + bottom * t
    glow = np.exp(-(((x - w * 0.2) ** 2 + (y - h * 0.08) ** 2) / (2 * (w * 0.6) ** 2)))
    img += (255 - img) * glow[..., None] * 0.14
    return Image.fromarray(np.uint8(np.clip(img, 0, 255)), "RGB")


def rounded_top(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, img.width, img.height + radius * 2), radius=radius, fill=255
    )
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def render(raw: Path, lines: list[str], sub: str, size: tuple[int, int], crop: float,
           width_frac: float) -> Image.Image:
    w, h = size
    u = w / 1320
    canvas = gradient(w, h)
    draw = ImageDraw.Draw(canvas)

    head = ImageFont.truetype(str(FONT_BOLD), round(118 * u))
    cap = ImageFont.truetype(str(FONT_MEDIUM), round(54 * u))
    y = round(150 * u)
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=head)
        draw.text(((w - (bbox[2] - bbox[0])) / 2 - bbox[0], y), line, font=head, fill="white")
        y += round(140 * u)
    bbox = draw.textbbox((0, 0), sub, font=cap)
    draw.text(((w - (bbox[2] - bbox[0])) / 2 - bbox[0], y + round(14 * u)), sub, font=cap,
              fill=(226, 220, 255))
    top = y + round(14 * u) + round(54 * u) + round(90 * u)

    shot = Image.open(raw).convert("RGB")
    shot = shot.crop((0, round(shot.height * crop), shot.width, shot.height))
    # Fill the space below the caption so the capture bleeds off the bottom edge.
    sw = min(round(w * 0.92), max(round(w * width_frac), round((h - top) * shot.width / shot.height)))
    shot = shot.resize((sw, round(shot.height * sw / shot.width)), Image.LANCZOS)
    shot = shot.crop((0, 0, sw, h - top))  # bleed off the bottom edge
    framed = rounded_top(shot, round(64 * u))

    x = (w - sw) // 2
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (x, top + 24, x + sw, h + 200), radius=round(64 * u), fill=(20, 8, 70, 120)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(round(36 * u)))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow)
    border = round(8 * u)
    ring = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(ring).rounded_rectangle(
        (x - border, top - border, x + sw + border, h + 200),
        radius=round(64 * u) + border, fill=(255, 255, 255, 70),
    )
    canvas = Image.alpha_composite(canvas, ring)
    canvas.alpha_composite(framed, (x, top))
    return canvas.convert("RGB")  # opaque RGB — Apple rejects alpha


def main() -> None:
    for out_name, raw_set, size, crop, frac in TARGETS:
        out_dir = OUT / out_name
        out_dir.mkdir(parents=True, exist_ok=True)
        for i, (name, lines, sub) in enumerate(SLIDES, start=1):
            img = render(RAW / raw_set / f"{name}.png", lines, sub, size, crop, frac)
            assert img.size == size and img.mode == "RGB"
            img.save(out_dir / f"{i:02d}_{name.removeprefix('ios_')}.png", optimize=True)
        print(f"{out_name}: {len(SLIDES)} images @ {size[0]}x{size[1]}")


if __name__ == "__main__":
    main()
