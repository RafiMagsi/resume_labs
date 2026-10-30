#!/usr/bin/env bash
#
# Capture Google Play phone screenshots from the screenshot integration test.
# Usage: tool/capture_android_screenshots.sh <device-serial> <output-dir>
#
set -euo pipefail

SERIAL="${1:?android device serial required (adb devices)}"
OUT_DIR="${2:?output directory required}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"
LOG="/tmp/resumepace_android_screenshots_${SERIAL//[^a-zA-Z0-9]/_}.log"
: > "$LOG"

ADB="adb -s $SERIAL"
$ADB wait-for-device
$ADB shell settings put global stay_on_while_plugged_in 3 >/dev/null 2>&1 || true
$ADB shell settings put system screen_off_timeout 600000 >/dev/null 2>&1 || true

cd "$ROOT"
flutter test integration_test/screenshot_test.dart \
  -d "$SERIAL" \
  --dart-define=DISABLE_ADS=true \
  > "$LOG" 2>&1 &
TEST_PID=$!

cleanup() {
  $ADB shell settings reset system screen_off_timeout >/dev/null 2>&1 || true
}
trap cleanup EXIT

seen=0
while kill -0 "$TEST_PID" 2>/dev/null; do
  count=$(grep -c 'SHOT:' "$LOG" 2>/dev/null || true)
  if [ "${count:-0}" -gt "$seen" ]; then
    next=$((seen + 1))
    marker=$(grep 'SHOT:' "$LOG" | sed -n "${next}p" | sed 's/.*SHOT://' | tr -d '\r')
    if [ -n "$marker" ]; then
      sleep 1
      # exec-out keeps the PNG binary intact (no CRLF rewriting).
      if $ADB exec-out screencap -p > "$OUT_DIR/${marker}.png"; then
        echo "Captured $OUT_DIR/${marker}.png"
      else
        echo "Screenshot failed for $marker"
      fi
      seen=$next
    fi
  fi
  sleep 0.25
done

wait "$TEST_PID"

# Play rejects transparency in some asset slots and Apple already requires
# opaque PNGs; normalise every capture to RGB so one step serves both stores.
python3 - "$OUT_DIR" <<'PY'
import pathlib
import sys

from PIL import Image

for path in sorted(pathlib.Path(sys.argv[1]).glob("*.png")):
    image = Image.open(path)
    if image.mode == "RGB":
        continue
    flat = Image.new("RGB", image.size, (255, 255, 255))
    flat.paste(image, mask=image.split()[-1] if image.mode == "RGBA" else None)
    flat.save(path, optimize=True)
    print(f"Flattened {path.name} -> RGB {flat.size}")
PY
