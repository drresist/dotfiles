#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
command -v aerospace >/dev/null || { echo 'Run packages.sh first.' >&2; exit 1; }
if ! pgrep -x AeroSpace >/dev/null; then
  open -a AeroSpace
  sleep 2
fi
aerospace reload-config
exec /bin/bash "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy-macos/start.sh"
