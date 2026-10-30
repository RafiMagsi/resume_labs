"""Generate ResumePace app icons, adaptive icons, and Play feature graphic."""

from __future__ import annotations

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
IOS_ICONS = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
ANDROID_RES = ROOT / "android/app/src/main/res"
ASSETS = ROOT / "store_assets"
FONT_BOLD = ROOT / "assets/fonts/Inter-Bold.ttf"
FONT_SEMIBOLD = ROOT / "assets/fonts/Inter-SemiBold.ttf"
FONT_MEDIUM = ROOT / "assets/fonts/Inter-Medium.ttf"
FONT_REGULAR = ROOT / "assets/fonts/Inter-Regular.ttf"

PURPLE_TOP = (124, 108, 246)
PURPLE_BOTTOM = (68, 38, 174)
LAVENDER = (201, 194, 245)
SHEET = (252, 251, 255)
FOLD = (226, 220, 255)


def lerp(a: tuple[int, int, int], b: tuple[int, int, int], t: float):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient_background(size: int) -> Image.Image:
    y, x = np.mgrid[0:size, 0:size]
    t = np.clip((x + y * 0.72) / (size * 1.72), 0, 1)
    top = np.array(PURPLE_TOP, dtype=np.float32)
    bottom = np.array(PURPLE_BOTTOM, dtype=np.float32)
    img = top[None, None, :] * (1 - t[..., None]) + bottom[None, None, :] * t[..., None]

    # Soft top-left light.
    cx, cy, sigma = size * 0.26, size * 0.14, size * 0.52
    glow = np.exp(-(((x - cx) ** 2 + (y - cy) ** 2) / (2 * sigma**2)))
    img += (255 - img) * (glow[..., None] * 0.17)

    # Gentle bottom-right vignette.
    cx2, cy2, sigma2 = size * 0.88, size * 0.92, size * 0.62
    shade = np.exp(-(((x - cx2) ** 2 + (y - cy2) ** 2) / (2 * sigma2**2)))
    img *= 1 - (shade[..., None] * 0.16)

    return Image.fromarray(np.uint8(np.clip(img, 0, 255)), "RGB")


def bolt_polygon(cx: float, cy: float, scale: float):
    points = [
        (0.12, -0.52),
        (-0.30, 0.07),
        (-0.02, 0.07),
        (-0.14, 0.52),
        (0.30, -0.09),
        (0.02, -0.09),
    ]
    return [(cx + px * scale, cy + py * scale) for px, py in points]


def draw_mark(canvas: Image.Image, size: int, inset: float = 0.0) -> None:
    """Draw the white document + speed badge on a transparent overlay."""
    overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    scale = 1 - inset * 2
    ox = oy = inset * size
    s = size * scale

    doc_x = ox + s * 0.235
    doc_y = oy + s * 0.165
    doc_w = s * 0.49
    doc_h = s * 0.66
    radius = s * 0.06

    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        (doc_x, doc_y + s * 0.025, doc_x + doc_w, doc_y + doc_h + s * 0.025),
        radius=radius,
        fill=(31, 12, 86, 110),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(s * 0.035))
    overlay.alpha_composite(shadow)
    draw = ImageDraw.Draw(overlay)

    draw.rounded_rectangle(
        (doc_x, doc_y, doc_x + doc_w, doc_y + doc_h),
        radius=radius,
        fill=SHEET,
    )

    fold = s * 0.125
    draw.polygon(
        [
            (doc_x + doc_w - fold, doc_y),
            (doc_x + doc_w, doc_y + fold),
            (doc_x + doc_w - fold, doc_y + fold),
        ],
        fill=FOLD,
    )

    line_x0 = doc_x + doc_w * 0.17
    line_x1 = doc_x + doc_w * 0.83
    line_ys = [doc_y + doc_h * 0.36, doc_y + doc_h * 0.49, doc_y + doc_h * 0.62]
    line_h = s * 0.027
    for index, y in enumerate(line_ys):
        end = line_x1 if index == 0 else line_x0 + (line_x1 - line_x0) * 0.82
        draw.rounded_rectangle(
            (line_x0, y, end, y + line_h),
            radius=line_h / 2,
            fill=(190, 181, 242),
        )

    badge_r = s * 0.145
    badge_cx = ox + s * 0.735
    badge_cy = oy + s * 0.735

    badge_shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    badge_draw = ImageDraw.Draw(badge_shadow)
    badge_draw.ellipse(
        (
            badge_cx - badge_r,
            badge_cy - badge_r + s * 0.018,
            badge_cx + badge_r,
            badge_cy + badge_r + s * 0.018,
        ),
        fill=(31, 12, 86, 100),
    )
    badge_shadow = badge_shadow.filter(ImageFilter.GaussianBlur(s * 0.022))
    overlay.alpha_composite(badge_shadow)

    draw = ImageDraw.Draw(overlay)
    draw.ellipse(
        (
            badge_cx - badge_r,
            badge_cy - badge_r,
            badge_cx + badge_r,
            badge_cy + badge_r,
        ),
        fill=(255, 255, 255),
    )
    draw.polygon(
        bolt_polygon(badge_cx, badge_cy, badge_r * 1.05),
        fill=PURPLE_TOP,
    )

    canvas.alpha_composite(overlay)


def make_icon(size: int = 4096) -> Image.Image:
    base = gradient_background(size).convert("RGBA")
    draw_mark(base, size)
    return base.convert("RGB")


def rounded_icon(master: Image.Image, size: int, radius_ratio: float = 0.22):
    icon = master.resize((size, size), Image.LANCZOS)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size - 1, size - 1),
        radius=round(size * radius_ratio),
        fill=255,
    )
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(icon, (0, 0), mask)
    return out


def save_ios_icons(master: Image.Image) -> None:
    for path in sorted(IOS_ICONS.glob("*.png")):
        with Image.open(path) as existing:
            size = existing.size[0]
        master.resize((size, size), Image.LANCZOS).save(path, optimize=True)
        print(f"iOS  {path.name:32} {size}x{size}")


def save_android_icons(master: Image.Image) -> None:
    legacy_sizes = {
        "mdpi": 48,
        "hdpi": 72,
        "xhdpi": 96,
        "xxhdpi": 144,
        "xxxhdpi": 192,
    }
    foreground_sizes = {
        "mdpi": 108,
        "hdpi": 162,
        "xhdpi": 216,
        "xxhdpi": 324,
        "xxxhdpi": 432,
    }
    for density, size in legacy_sizes.items():
        folder = ANDROID_RES / f"mipmap-{density}"
        icon = master.resize((size, size), Image.LANCZOS)
        icon.save(folder / "ic_launcher.png", optimize=True)
        icon.save(folder / "ic_launcher_round.png", optimize=True)
        print(f"Android {density:8} legacy {size}x{size}")

    for density, size in foreground_sizes.items():
        folder = ANDROID_RES / f"mipmap-{density}"
        fg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw_mark(fg, size, inset=0.19)
        fg.save(folder / "ic_launcher_foreground.png", optimize=True)
        print(f"Android {density:8} foreground {size}x{size}")

    play_icon = master.resize((512, 512), Image.LANCZOS)
    play_icon.save(ANDROID_RES / "playstore-icon.png", optimize=True)
    print("Android playstore-icon.png 512x512")


def save_adaptive_background() -> None:
    path = ANDROID_RES / "drawable/ic_launcher_background.xml"
    path.write_text(
        """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:height="108dp"
    android:width="108dp"
    android:viewportHeight="108"
    android:viewportWidth="108">
    <path
        android:fillColor="#6C5CE7"
        android:pathData="M0,0h108v108h-108z" />
</vector>
"""
    )
    print("Android adaptive background updated")


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def text_width(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont):
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0]


def make_feature_graphic(master: Image.Image) -> None:
    width, height = 1024, 500
    bg = gradient_background(1400).resize((width, height), Image.LANCZOS)
    canvas = bg.convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    # Decorative translucent sheets.
    decor = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    dd = ImageDraw.Draw(decor)
    dd.rounded_rectangle((760, 54, 980, 446), radius=28, fill=(255, 255, 255, 18))
    dd.rounded_rectangle((812, 92, 992, 430), radius=24, fill=(255, 255, 255, 26))
    canvas.alpha_composite(decor)

    icon = rounded_icon(master, 250, 0.23)
    canvas.alpha_composite(icon, (74, 125))

    x = 382
    draw.text((x, 122), "ResumePace", font=font(FONT_BOLD, 76), fill=(255, 255, 255))
    draw.text(
        (x, 212),
        "AI Resume Builder",
        font=font(FONT_SEMIBOLD, 34),
        fill=(226, 220, 255),
    )

    chip_font = font(FONT_MEDIUM, 21)
    chips = ["ATS templates", "AI optimization", "PDF export"]
    chip_x = x
    chip_y = 292
    chip_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    chip_draw = ImageDraw.Draw(chip_layer)
    chip_text = []
    for chip in chips:
        w = text_width(draw, chip, chip_font)
        chip_draw.rounded_rectangle(
            (chip_x, chip_y, chip_x + w + 36, chip_y + 44),
            radius=22,
            fill=(255, 255, 255, 34),
            outline=(255, 255, 255, 90),
            width=1,
        )
        chip_text.append((chip_x + 18, chip_y + 10, chip))
        chip_x += w + 52
    canvas.alpha_composite(chip_layer)
    draw = ImageDraw.Draw(canvas)
    for tx, ty, chip in chip_text:
        draw.text((tx, ty), chip, font=chip_font, fill=(255, 255, 255))

    draw.text(
        (x, 372),
        "Build a polished, interview-ready resume in minutes.",
        font=font(FONT_REGULAR, 22),
        fill=(226, 220, 255),
    )

    ASSETS.mkdir(exist_ok=True)
    canvas.convert("RGB").save(ASSETS / "google_play_feature_graphic_1024x500.png", optimize=True)
    print("Feature graphic 1024x500")


def main() -> None:
    master = make_icon()
    ASSETS.mkdir(exist_ok=True)
    master.save(ASSETS / "app_icon_master_4096.png", optimize=True)
    master.resize((1024, 1024), Image.LANCZOS).save(
        ASSETS / "app_icon_1024.png", optimize=True
    )
    save_ios_icons(master)
    save_android_icons(master)
    save_adaptive_background()
    make_feature_graphic(master)
    print(f"\nWrote brand assets to {ASSETS}")


if __name__ == "__main__":
    main()
