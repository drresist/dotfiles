#!/usr/bin/env bash
set -euo pipefail
command -v brew >/dev/null || { echo 'Install Homebrew from https://brew.sh first.' >&2; exit 1; }
brew tap FelixKratz/formulae
brew install --cask nikitabobko/tap/aerospace ghostty font-jetbrains-mono-nerd-font
brew install sketchybar borders starship fish
