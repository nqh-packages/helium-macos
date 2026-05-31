#!/usr/bin/env bash
# Install a locally built Helium.app over /Applications/Helium.app
# without touching ~/Library/Application Support/net.imput.helium
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILT_APP="${1:-$ROOT_DIR/build/src/out/Default/Helium.app}"
TARGET_APP="/Applications/Helium.app"
BACKUP_ROOT="${HELIUM_BACKUP_ROOT:-}"

if [[ ! -d "$BUILT_APP" ]]; then
  echo "Built app not found: $BUILT_APP" >&2
  echo "Pass path to Helium.app or build first: cd $ROOT_DIR && ./build.sh" >&2
  exit 1
fi

echo "Quitting Helium if running..."
osascript -e 'tell application "Helium" to quit' 2>/dev/null || true
sleep 2
pkill -x Helium 2>/dev/null || true
sleep 1

if [[ -d "$TARGET_APP" && -z "$BACKUP_ROOT" ]]; then
  echo "Set HELIUM_BACKUP_ROOT or backup manually before replacing $TARGET_APP" >&2
  exit 1
fi

echo "Installing $BUILT_APP -> $TARGET_APP"
sudo rm -rf "$TARGET_APP"
sudo ditto "$BUILT_APP" "$TARGET_APP"
sudo xattr -cr "$TARGET_APP" 2>/dev/null || true

echo "Done. Profile unchanged at:"
echo "  $HOME/Library/Application Support/net.imput.helium"
echo "Launch Helium from Applications or Dock."
