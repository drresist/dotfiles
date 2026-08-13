#!/usr/bin/env bash
#
# install.sh — линкует конфиги из репозитория в $HOME.
#
# Идемпотентный:
#   - правильный симлинк уже стоит  -> пропускает;
#   - симлинк не туда               -> перелинковывает;
#   - на месте обычный файл         -> бэкапит в <имя>.bak.<timestamp> и линкует.
#
# Установка пакетов (brew и пр.) — это prepare_macos.sh / prepare_linux.sh.
# Этот скрипт отвечает только за конфиги.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d_%H%M%S)"

link() {
	local src="$ROOT/$1" dst="$HOME/$2"

	if [ ! -e "$src" ]; then
		echo "skip:    $1 (нет в репо)"
		return
	fi

	mkdir -p "$(dirname "$dst")"

	if [ -L "$dst" ]; then
		if [ "$(readlink "$dst")" = "$src" ]; then
			echo "ok:      $dst"
		else
			rm "$dst"
			ln -s "$src" "$dst"
			echo "relink:  $dst -> $src"
		fi
	elif [ -e "$dst" ]; then
		mv "$dst" "$dst.bak.$STAMP"
		ln -s "$src" "$dst"
		echo "linked:  $dst -> $src (бэкап: $dst.bak.$STAMP)"
	else
		ln -s "$src" "$dst"
		echo "linked:  $dst -> $src"
	fi
}

# Терминал и тулзы
link configs/starship/starship.toml     .config/starship.toml
link configs/bat/config                 .config/bat/config
link configs/btop/btop.conf             .config/btop/btop.conf
link configs/git/config                 .config/git/config
link configs/git/gitconfig              .gitconfig
link configs/atuin/config.toml          .config/atuin/config.toml
link configs/herdr/config.toml          .config/herdr/config.toml

# fish
link configs/fish/config.fish           .config/fish/config.fish
link configs/fish/completions/grok.fish .config/fish/completions/grok.fish
link configs/fish/conf.d/atuin.env.fish .config/fish/conf.d/atuin.env.fish

# Shell rc
link shell/.zshrc                       .zshrc
link shell/.bashrc                      .bashrc

# Портативный указатель на репо: rc-файлы source'ят через него
# configs/eza/aliases.sh и пр.
if [ ! -e "$HOME/.dotfiles" ]; then
	ln -s "$ROOT" "$HOME/.dotfiles"
	echo "linked:  ~/.dotfiles -> $ROOT"
else
	echo "ok:      ~/.dotfiles"
fi

echo "done."
