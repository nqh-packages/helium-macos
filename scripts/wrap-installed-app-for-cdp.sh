#!/usr/bin/env bash
# Wrap /Applications/Helium.app so every launch passes CDP flags to the real binary.
# Reversible via scripts/unwrap-installed-app-for-cdp.sh
set -euo pipefail

APP="${1:-/Applications/Helium.app}"
MACOS="$APP/Contents/MacOS"
BIN="$MACOS/Helium"
REAL="$MACOS/Helium.real"
WRAPPER="$MACOS/Helium"

if [[ ! -d "$APP" ]]; then
  echo "Helium.app not found: $APP" >&2
  exit 1
fi

osascript -e 'tell application "Helium" to quit' 2>/dev/null || true
sleep 2
pkill -x Helium 2>/dev/null || true
pkill -x Helium.real 2>/dev/null || true
sleep 1

if [[ -f "$REAL" ]]; then
  echo "Already wrapped ($REAL exists). Re-run unwrap first to reset." >&2
  exit 1
fi

if [[ ! -f "$BIN" ]]; then
  echo "Missing binary: $BIN" >&2
  exit 1
fi

mv "$BIN" "$REAL"

cat > "$WRAPPER" <<'EOF'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
EXTRA=()
if [[ -z "${HELIUM_DISABLE_CDP:-}" ]]; then
  EXTRA+=(--remote-debugging-port=9222 --remote-allow-origins='*')
fi
exec "$DIR/Helium.real" "${EXTRA[@]}" "$@"
EOF
chmod +x "$WRAPPER" "$REAL"

echo "Wrapped $APP"
echo "  Real binary: $REAL"
echo "  Launcher:    $WRAPPER (adds --remote-debugging-port=9222)"
echo "  Disable CDP: HELIUM_DISABLE_CDP=1 open -a Helium"
echo "Verify: curl -s http://127.0.0.1:9222/json/version"
