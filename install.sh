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

# Omarchy отдаёт активную тему Neovim сгенерированным симлинком внутри конфига
# (~/.config/nvim/lua/plugins/theme.lua -> <state>/omarchy/current/theme/neovim.lua).
# Это машинное состояние, в репо оно не хранится — пересоздаём здесь.
# Цель абсолютная: сам каталог конфига — симлинк в репо, и относительный путь
# omarchy ("../../../../.local/state/...") оттуда уже не резолвится.
link_nvim_theme() {
	local dst="$HOME/.config/nvim/lua/plugins/theme.lua" src=""

	[ -d "$HOME/.config/nvim/lua/plugins" ] || return 0

	for src in "$HOME/.local/state/omarchy/current/theme/neovim.lua" \
		"$HOME/.config/omarchy/current/theme/neovim.lua"; do
		[ -f "$src" ] && break
	done
	[ -f "$src" ] || return 0

	if [ -e "$dst" ] && [ ! -L "$dst" ]; then
		echo "skip:    $dst (обычный файл, не трогаем)"
		return 0
	fi

	if [ "$(readlink "$dst" 2>/dev/null)" = "$src" ]; then
		echo "ok:      $dst"
		return 0
	fi

	rm -f "$dst"
	ln -s "$src" "$dst"
	echo "linked:  $dst -> $src"
}

# Терминал и тулзы
link configs/starship/starship.toml     .config/starship.toml
link configs/bat/config                 .config/bat/config
link configs/btop/btop.conf             .config/btop/btop.conf
link configs/git/config                 .config/git/config
link configs/git/gitconfig              .gitconfig
link configs/atuin/config.toml          .config/atuin/config.toml

# Агент-мультиплексор и его окружение (herdr 0.9.x, конфиг = omarchy-дефолт)
link configs/herdr/config.toml          .config/herdr/config.toml

# tmux и Neovim (LazyVim): конфиги версионируются целиком, включая lazy-lock.json
link configs/tmux/tmux.conf             .config/tmux/tmux.conf
link configs/nvim                       .config/nvim

# Слой алиасов Omarchy линковать не нужно: shell/.bashrc сорсит его через
# указатель ~/.dotfiles.

# fish
link configs/fish/config.fish           .config/fish/config.fish
link configs/fish/completions/grok.fish .config/fish/completions/grok.fish
link configs/fish/conf.d/atuin.env.fish .config/fish/conf.d/atuin.env.fish

# Shell rc
link shell/.bash_profile                .bash_profile
link shell/.bashrc                      .bashrc
link shell/.zshrc                       .zshrc

# Портативный указатель на репо: rc-файлы source'ят через него
# configs/eza/aliases.sh и пр.
if [ ! -e "$HOME/.dotfiles" ]; then
	ln -s "$ROOT" "$HOME/.dotfiles"
	echo "linked:  ~/.dotfiles -> $ROOT"
else
	echo "ok:      ~/.dotfiles"
fi

# Тема Neovim — после линковки configs/nvim, от ~/.dotfiles не зависит.
link_nvim_theme

echo "done."
