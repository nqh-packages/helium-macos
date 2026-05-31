#!/usr/bin/env bash
# Build Helium from source and install to /Applications (profile preserved).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT_DIR/build/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/build-$(date +%Y%m%d-%H%M%S).log"

# Homebrew python@3.14 is broken against system libexpat on this host; prefer Apple python3.
export PATH="/usr/bin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/bin:$PATH"

echo "Logging to $LOG_FILE"
echo "Using python3: $(which python3) ($(python3 --version))"

cd "$ROOT_DIR"
arch="${1:-arm64}"
./build.sh "$arch" 2>&1 | tee "$LOG_FILE"

BUILT_APP="$ROOT_DIR/build/src/out/Default/Helium.app"
if [[ ! -d "$BUILT_APP" ]]; then
  echo "Build finished but app missing: $BUILT_APP" >&2
  exit 1
fi

export HELIUM_BACKUP_ROOT="${HELIUM_BACKUP_ROOT:-/Volumes/BIWIN/CODES/Helium-backup-required}"
if [[ ! -d "$HELIUM_BACKUP_ROOT" ]]; then
  echo "Set HELIUM_BACKUP_ROOT to your backup folder before install." >&2
  echo "Example: HELIUM_BACKUP_ROOT=/Volumes/BIWIN/CODES/Helium-backup-20260531-172943 $0" >&2
  exit 1
fi

"$ROOT_DIR/scripts/install-built-app.sh" "$BUILT_APP"
