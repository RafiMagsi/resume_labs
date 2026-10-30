#!/usr/bin/env bash
#
# Capture screenshots from the screenshot integration test.
# Usage: tool/capture_ios_screenshots.sh <simulator-udid> <output-dir>
#
set -euo pipefail

UDID="${1:?simulator UDID required}"
OUT_DIR="${2:?output directory required}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="/tmp/resumepace_screenshots_${UDID}.log"

mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"
: > "$LOG"

xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl ui "$UDID" appearance light >/dev/null 2>&1 || true
xcrun simctl status_bar "$UDID" override \
  --time '9:41' \
  --dataNetwork wifi \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100 >/dev/null 2>&1 || true

cd "$ROOT"
flutter test integration_test/screenshot_test.dart \
  -d "$UDID" \
  --dart-define=DISABLE_ADS=true \
  > "$LOG" 2>&1 &
TEST_PID=$!

cleanup() {
  xcrun simctl status_bar "$UDID" clear >/dev/null 2>&1 || true
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
      xcrun simctl io "$UDID" screenshot "$OUT_DIR/${marker}.png" >/dev/null || echo "Screenshot failed for $marker"
      echo "Captured $OUT_DIR/${marker}.png"
      seen=$next
    fi
  fi
  sleep 0.25
done

wait "$TEST_PID"
