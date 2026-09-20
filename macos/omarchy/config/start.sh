#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
CONFIG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export XDG_CONFIG_HOME="$CONFIG_ROOT"
for tool in sketchybar borders; do
  command -v "$tool" >/dev/null || { echo "Missing $tool; run packages.sh" >&2; exit 1; }
done
LOG_DIR="$CONFIG_ROOT/omarchy-macos/logs"
mkdir -p "$LOG_DIR"
if ! pgrep -x sketchybar >/dev/null; then
  nohup sketchybar --config "$CONFIG_ROOT/sketchybar/sketchybarrc" >"$LOG_DIR/sketchybar.log" 2>&1 &
else
  echo 'SketchyBar is already running; its existing configuration was left active.'
fi
if ! pgrep -x borders >/dev/null; then
  nohup /bin/bash "$CONFIG_ROOT/borders/bordersrc" >"$LOG_DIR/borders.log" 2>&1 &
else
  echo 'Borders is already running; its existing configuration was left active.'
fi
sleep 1
pgrep -x sketchybar >/dev/null || { echo "SketchyBar failed; see $LOG_DIR/sketchybar.log" >&2; exit 1; }
pgrep -x borders >/dev/null || { echo "Borders failed; see $LOG_DIR/borders.log" >&2; exit 1; }
sketchybar --trigger aerospace_workspace_change
