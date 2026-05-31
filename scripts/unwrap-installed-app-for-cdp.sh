#!/usr/bin/env bash
set -euo pipefail

APP="${1:-/Applications/Helium.app}"
MACOS="$APP/Contents/MacOS"
BIN="$MACOS/Helium"
REAL="$MACOS/Helium.real"

osascript -e 'tell application "Helium" to quit' 2>/dev/null || true
sleep 2
pkill -x Helium 2>/dev/null || true
pkill -x Helium.real 2>/dev/null || true

if [[ ! -f "$REAL" ]]; then
  echo "Not wrapped (no $REAL)." >&2
  exit 1
fi

rm -f "$BIN"
mv "$REAL" "$BIN"
echo "Restored stock launcher at $BIN"
