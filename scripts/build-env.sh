#!/usr/bin/env bash
# Source from repo root: source scripts/build-env.sh
# Sets PATH to Helium/.venv (Python 3.11) for clone.py and depot_tools.

if [[ -n "${ZSH_VERSION:-}" ]]; then
  _script_dir="${0:A:h}"
  ROOT_DIR="${_script_dir:h}"
elif [[ -n "${BASH_VERSION:-}" ]]; then
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Source this file: source scripts/build-env.sh" >&2
    return 1 2>/dev/null || exit 1
  fi
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
  echo "Unsupported shell; use bash or zsh." >&2
  return 1 2>/dev/null || exit 1
fi

cd "$ROOT_DIR" || return 1 2>/dev/null || exit 1

if [[ ! -d "$ROOT_DIR/.venv" ]]; then
  echo "Creating Python 3.11 venv (uv) in $ROOT_DIR/.venv ..." >&2
  uv venv "$ROOT_DIR/.venv" --python 3.11
  uv pip install --python "$ROOT_DIR/.venv/bin/python3" httplib2==0.22.0 requests pillow
fi

export PATH="$ROOT_DIR/.venv/bin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/bin:$PATH"
export VIRTUAL_ENV="$ROOT_DIR/.venv"

# depot_tools gclient reads packages from PYTHONPATH; clone.py also appends venv site-packages.
if [[ -d "$ROOT_DIR/build/src/uc_staging/depot_tools" ]]; then
  uv pip install --python "$ROOT_DIR/.venv/bin/python3" \
    --target "$ROOT_DIR/build/src/uc_staging/depot_tools" \
    httplib2==0.22.0 requests 2>/dev/null || true
fi

echo "HELIUM_ROOT=$ROOT_DIR"
echo "python3: $(command -v python3) ($(python3 --version))"
