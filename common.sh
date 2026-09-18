#!/bin/bash
#
# common.sh
# Shared functions for prepare_macos.sh and prepare_linux.sh
# Source this from the OS-specific prepare scripts.

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

get_arch() {
	local arch
	arch=$(uname -m)
	case "$arch" in
		x86_64) echo "amd64" ;;
		aarch64|arm64) echo "arm64" ;;
		*) echo "$arch" ;;
	esac
}

# Reusable downloader/extractor (works for both OSes)
download_and_install() {
	local url="$1" atype="$2" bin="$3" dest="${4:-/usr/local/bin}"
	local td
	td=$(mktemp -d)
	(
		cd "$td"
		curl -fsSL -o pkg "$url"
		case "$atype" in
			tar.gz|tgz) tar xzf pkg ;;
			tar.bz2|tbz) tar xjf pkg ;;
			zip) unzip -q pkg ;;
			deb) dpkg -x pkg . || true ;;
			raw) mv pkg "$bin" ;;
			*) echo "Unknown archive type: $atype"; exit 1 ;;
		esac

		if [ -f "$bin" ]; then
			sudo mv "$bin" "$dest/" 2>/dev/null || sudo cp "$bin" "$dest/"
		else
			find . -type f -perm -111 -name "*${bin}*" -exec sudo cp {} "$dest/" \; 2>/dev/null | head -1 || true
			find . -type f -name "$bin" -exec sudo cp {} "$dest/" \; 2>/dev/null || true
		fi
		chmod +x "$dest/$(basename "$bin")" 2>/dev/null || true
	)
	cd "$HOME"
	rm -rf "$td"
}

# dotfiles location (used by setup_configs)
dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper to symlink a config file (backup-aware; same semantics as install.sh)
link_config() {
	local src="$dotfiles_dir/$1" dst="$2"
	mkdir -p "$(dirname "$dst")"
	if [ ! -f "$src" ]; then
		return
	fi
	if [ -L "$dst" ]; then
		if [ "$(readlink "$dst")" = "$src" ]; then
			echo "$(basename "$src") already linked"
			return
		fi
		rm "$dst"
	elif [ -e "$dst" ]; then
		mv "$dst" "$dst.bak.$(date +%Y%m%d_%H%M%S)"
	fi
	ln -s "$src" "$dst"
	echo "$(basename "$src") configuration installed"
}

setup_configs() {
	echo "Настройка конфигурационных файлов..."
	bash "$dotfiles_dir/install.sh"
}

# Group installers (call the OS-specific individual functions)
install_cli_utilities() {
	echo "Установка CLI утилит..."
	install_fzf
	install_ripgrep
	install_fd
	install_bat
	install_eza
	install_zoxide
	install_tre
	install_herdr
	echo "CLI утилиты установлены"
}

install_dev_tools() {
	echo "Установка инструментов разработки..."
	install_gh
	install_delta
	install_docker
	echo "Инструменты разработки установлены"
}

install_shell_tools() {
	echo "Установка shell-инструментов..."
	install_zsh
	install_ohmyzsh
	install_fish
	install_starship
	echo "Shell-инструменты установлены"
}

install_system_tools() {
	echo "Установка системных утилит..."
	install_btop
	install_ncdu
	echo "Системные утилиты установлены"
}

install_all() {
	install_tmux
	install_neovim
	install_jetbrains_nerd_font
	install_lazydocker
	install_k9s
	install_cli_utilities
	install_dev_tools
	install_shell_tools
	install_system_tools
	if command -v is_linux >/dev/null 2>&1 && is_linux; then
		setup_flatpak_apps
	fi
	setup_configs
	echo "Все компоненты установлены."
}
