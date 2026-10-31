"""Generate the App Store product-page Header (3840x1646) and Search Results
(3840x2560) creative assets for ResumePace into store_assets/marketing/."""

from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "store_assets"
OUT = ASSETS / "marketing"
RAW = ASSETS / "screenshots/ios_iphone17promax"
FONT_BOLD = ROOT / "assets/fonts/Inter-Bold.ttf"
FONT_MEDIUM = ROOT / "assets/fonts/Inter-Medium.ttf"
FONT_SEMI = ROOT / "assets/fonts/Inter-SemiBold.ttf"

PURPLE_TOP = (124, 108, 246)
PURPLE_BOTTOM = (62, 34, 168)


def gradient(w: int, h: int) -> Image.Image:
    y, x = np.mgrid[0:h, 0:w]
    t = np.clip((x * 0.6 + y) / (w * 0.6 + h), 0, 1)[..., None]
    img = np.array(PURPLE_TOP, np.float32) * (1 - t) + np.array(PURPLE_BOTTOM, np.float32) * t
    glow = np.exp(-(((x - w * 0.15) ** 2 + (y - h * 0.1) ** 2) / (2 * (w * 0.35) ** 2)))
    img += (255 - img) * glow[..., None] * 0.14
    return Image.fromarray(np.uint8(np.clip(img, 0, 255)), "RGB").convert("RGBA")


def phone(name: str, width: int, height: int, radius: int) -> Image.Image:
    shot = Image.open(RAW / f"{name}.png").convert("RGB")
    shot = shot.crop((0, round(shot.height * 0.058), shot.width, shot.height))
    shot = shot.resize((width, round(shot.height * width / shot.width)), Image.LANCZOS)
    shot = shot.crop((0, 0, width, height))
    mask = Image.new("L", shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, width, height), radius=radius, fill=255)
    out = shot.convert("RGBA")
    out.putalpha(mask)
    return out


def paste_with_shadow(canvas: Image.Image, img: Image.Image, xy: tuple[int, int],
                      radius: int, blur: int) -> None:
    x, y = xy
    sh = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle(
        (x, y + 40, x + img.width, y + img.height + 40), radius=radius, fill=(20, 8, 70, 130))
    canvas.alpha_composite(sh.filter(ImageFilter.GaussianBlur(blur)))
    ring = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(ring).rounded_rectangle(
        (x - 10, y - 10, x + img.width + 10, y + img.height + 10),
        radius=radius + 10, fill=(255, 255, 255, 80))
    canvas.alpha_composite(ring)
    canvas.alpha_composite(img, (x, y))


def text_block(canvas: Image.Image, x: int, y: int, scale: float) -> None:
    d = ImageDraw.Draw(canvas)
    icon = Image.open(ASSETS / "app_icon_1024.png").convert("RGBA")
    isz = round(300 * scale)
    mask = Image.new("L", (isz, isz), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, isz, isz), radius=round(isz * 0.225), fill=255)
    icon = icon.resize((isz, isz), Image.LANCZOS)
    icon.putalpha(mask)
    canvas.alpha_composite(icon, (x, y))
    d.text((x + isz + 60 * scale, y + 20 * scale), "ResumePace",
           font=ImageFont.truetype(str(FONT_BOLD), round(150 * scale)), fill="white")
    d.text((x + isz + 60 * scale, y + 200 * scale), "AI Resume Builder & CV Maker",
           font=ImageFont.truetype(str(FONT_MEDIUM), round(66 * scale)), fill=(226, 220, 255))
    head = ImageFont.truetype(str(FONT_BOLD), round(190 * scale))
    yy = y + isz + 120 * scale
    for line in ["Build a resume", "that gets hired"]:
        d.text((x, yy), line, font=head, fill="white")
        yy += 230 * scale
    chip = ImageFont.truetype(str(FONT_SEMI), round(62 * scale))
    cx = x
    yy += 40 * scale
    for label in ["14 ATS templates", "AI optimizer", "PDF export"]:
        bbox = d.textbbox((0, 0), label, font=chip)
        w = bbox[2] - bbox[0] + 100 * scale
        pill = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        ImageDraw.Draw(pill).rounded_rectangle(
            (cx, yy, cx + w, yy + 130 * scale), radius=65 * scale,
            fill=(255, 255, 255, 46), outline=(255, 255, 255, 120), width=4)
        canvas.alpha_composite(pill)
        d = ImageDraw.Draw(canvas)
        d.text((cx + 50 * scale, yy + 28 * scale), label, font=chip, fill="white")
        cx += w + 30 * scale


def header() -> None:
    w, h = 3840, 1646
    canvas = gradient(w, h)
    text_block(canvas, 300, 250, 0.9)
    pw, ph = 800, 1500
    for i, name in enumerate(["ios_optimizer", "ios_history"]):
        shot = phone(name, pw, ph, 90)
        paste_with_shadow(canvas, shot, (2150 + i * 850, 250 + (1 - i) * 90), 90, 50)
    canvas.convert("RGB").save(OUT / "app_store_header_3840x1646.png", optimize=True)


def search_results() -> None:
    w, h = 3840, 2560
    canvas = gradient(w, h)
    text_block(canvas, 300, 420, 0.95)
    pw, ph = 900, 1830
    for i, name in enumerate(["ios_optimizer", "ios_history"]):
        shot = phone(name, pw, ph, 110)
        paste_with_shadow(canvas, shot, (1950 + i * 950, 480 + (1 - i) * 120),
                          110, 60)
    canvas.convert("RGB").save(OUT / "app_store_search_results_3840x2560.png", optimize=True)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    header()
    search_results()
    print("ok")
