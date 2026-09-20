#!/usr/bin/env bash

STATE="$(pmset -g batt)"
PERCENTAGE="$(printf '%s\n' "$STATE" | grep -Eo '[0-9]+%' | head -1)"
if [[ -z "$PERCENTAGE" ]]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi
LABEL="$PERCENTAGE"
COLOR=0xffbac2de
if [[ "$STATE" == *"AC Power"* ]]; then
  LABEL="+ $PERCENTAGE"
  COLOR=0xffa6e3a1
elif (( ${PERCENTAGE%%%} <= 20 )); then
  COLOR=0xfff38ba8
fi
sketchybar --set "$NAME" drawing=on label="$LABEL" label.color="$COLOR"
