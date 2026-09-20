#!/usr/bin/env bash

PERCENTAGE="$(pmset -g batt | grep -Eo '[0-9]+%' | head -1)"
SOURCE="$(pmset -g batt | head -1)"
ICON="BAT"
[[ "$SOURCE" == *"AC Power"* ]] && ICON="CHG"
sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE:-?}"
