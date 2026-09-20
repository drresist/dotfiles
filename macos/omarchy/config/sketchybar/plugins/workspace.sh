#!/usr/bin/env bash

SID="$1"
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

if [[ "$SID" == "$FOCUSED" ]]; then
  sketchybar --set "$NAME" \
    icon.color=0xff11111b \
    background.drawing=on \
    background.color=0xffa6e3a1
else
  sketchybar --set "$NAME" \
    icon.color=0xffcdd6f4 \
    background.drawing=off
fi
