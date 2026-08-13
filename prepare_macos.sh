#!/bin/bash
#
# prepare_macos.sh
# macOS-only bootstrap (Homebrew focused)
#
# Sources common.sh for shared logic.

set -euo pipefail

# OS-specific helpers
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

is_macos() { true; }   # Always true in this script
is_linux() { false; }

# macOS-only Homebrew installer
install_homebrew() {
	if ! command_exists brew; then
		echo "Установка Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		if [[ -d /opt/homebrew ]]; then
			echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
			eval "$(/opt/homebrew/bin/brew shellenv)"
		else
			echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
			eval "$(/usr/local/bin/brew shellenv)"
		fi
		echo "Homebrew установлен"
	else
		echo "Homebrew уже установлен"
	fi
}

# Simple wrapper for macOS
install_pkg() {
	brew install "$@"
}

# Source shared code (must be after defining OS-specific functions that common may call)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# === Install functions (macOS versions) ===

install_tmux() {
	if ! command_exists tmux; then
		echo "Installing tmux..."
		brew install tmux
	else
		echo "tmux already installed."
	fi
}

setup_tmux() {
	echo "Setting up tmux (gpakosz/.tmux)..."
	if [ -d ~/.tmux ]; then
		cd ~/.tmux && git pull && cd "$HOME"
	else
		git clone https://github.com/gpakosz/.tmux.git ~/.tmux
	fi
	ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
	[ -f ~/.tmux.conf.local ] || cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
	echo "tmux config installed."
}

install_neovim() {
	if ! command_exists nvim; then
		echo "Installing Neovim..."
		brew install neovim
		echo "Neovim installed."
	else
		echo "Neovim already installed."
	fi
}

setup_lazyvim() {
	echo "Setting up LazyVim..."
	if [ -d ~/.config/nvim ]; then
		local backup_suffix=$(date +%Y%m%d_%H%M%S)
		mv ~/.config/nvim ~/.config/nvim.bak.$backup_suffix
		echo "Backed up existing nvim config"
	fi
	git clone https://github.com/LazyVim/starter ~/.config/nvim
	rm -rf ~/.config/nvim/.git
	echo "LazyVim installed. Run 'nvim' to finish."
}

install_jetbrains_nerd_font() {
	echo "Installing JetBrains Nerd Font..."
	brew tap homebrew/cask-fonts || true
	brew install --cask font-jetbrains-mono-nerd-font
	echo "JetBrains Nerd Font installed."
}

install_lazydocker() {
	if ! command_exists lazydocker; then
		echo "Installing lazydocker..."
		brew install lazydocker
	else
		echo "lazydocker already installed."
	fi
}

install_k9s() {
	if ! command_exists k9s; then
		echo "Установка k9s..."
		brew install k9s
	else
		echo "k9s уже установлен."
	fi
}

# === macOS-specific install functions (many are simple because of Homebrew) ===

install_tmux() {
	if ! command_exists tmux; then
		echo "Установка tmux..."
		brew install tmux
	else
		echo "tmux уже установлен."
	fi
}

setup_tmux() {
	echo "Настройка tmux (gpakosz/.tmux)..."
	if [ -d ~/.tmux ]; then
		cd ~/.tmux && git pull && cd "$HOME"
	else
		git clone https://github.com/gpakosz/.tmux.git ~/.tmux
	fi
	ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
	[ -f ~/.tmux.conf.local ] || cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
	echo "Конфигурация tmux установлена."
}

install_neovim() {
	if ! command_exists nvim; then
		echo "Установка Neovim..."
		brew install neovim
		echo "Neovim установлен."
	else
		echo "Neovim уже установлен."
	fi
}

setup_lazyvim() {
	echo "Настройка LazyVim..."
	if [ -d ~/.config/nvim ]; then
		local backup_suffix=$(date +%Y%m%d_%H%M%S)
		mv ~/.config/nvim ~/.config/nvim.bak.$backup_suffix
		echo "Существующая конфигурация сохранена"
	fi
	git clone https://github.com/LazyVim/starter ~/.config/nvim
	rm -rf ~/.config/nvim/.git
	echo "LazyVim установлен. Запустите 'nvim' для завершения."
}

install_jetbrains_nerd_font() {
	echo "Установка JetBrains Nerd Font..."
	brew tap homebrew/cask-fonts || true
	brew install --cask font-jetbrains-mono-nerd-font
	echo "JetBrains Nerd Font установлен."
}

install_lazydocker() {
	if ! command_exists lazydocker; then
		echo "Установка lazydocker..."
		brew install lazydocker
	else
		echo "lazydocker уже установлен."
	fi
}

# The following simple wrappers use Russian messages for consistency
install_fzf() {
	if ! command_exists fzf; then
		echo "Установка fzf..."
		brew install fzf
		"$(brew --prefix)"/opt/fzf/install --all --no-bash --no-fish --no-zsh || true
		echo "fzf установлен"
	else
		echo "fzf уже установлен"
	fi
}

install_ripgrep() {
	if ! command_exists rg; then
		echo "Установка ripgrep..."
		brew install ripgrep
		echo "ripgrep установлен"
	else
		echo "ripgrep уже установлен"
	fi
}

install_fd() {
	if ! command_exists fd && ! command_exists fdfind; then
		echo "Установка fd..."
		brew install fd
		echo "fd установлен"
	else
		echo "fd уже установлен"
	fi
}

install_bat() {
	if ! command_exists bat; then
		echo "Установка bat..."
		brew install bat
		echo "bat установлен"
	else
		echo "bat уже установлен"
	fi
}

install_eza() {
	if ! command_exists eza; then
		echo "Установка eza..."
		brew install eza
		echo "eza установлен"
	else
		echo "eza уже установлен"
	fi
}

install_zoxide() {
	if ! command_exists zoxide; then
		echo "Установка zoxide..."
		brew install zoxide
		echo "zoxide установлен"
	else
		echo "zoxide уже установлен"
	fi
}

install_tre() {
	if ! command_exists tre; then
		echo "Установка tre..."
		brew install tre-command
		echo "tre установлен"
	else
		echo "tre уже установлен"
	fi
}

install_herdr() {
	if ! command_exists herdr; then
		echo "Установка herdr..."
		brew install herdr
		echo "herdr установлен"
	else
		echo "herdr уже установлен"
	fi
}

install_gh() {
	if ! command_exists gh; then
		echo "Установка GitHub CLI..."
		brew install gh
		echo "GitHub CLI установлен"
	else
		echo "GitHub CLI уже установлен"
	fi
}

install_delta() {
	if ! command_exists delta; then
		echo "Установка git-delta..."
		brew install git-delta
		echo "git-delta установлен"
	else
		echo "git-delta уже установлен"
	fi
}

install_docker() {
	if ! command_exists docker; then
		echo "Установка Docker Desktop..."
		brew install --cask docker
		echo "Docker Desktop установлен. Запустите приложение из Applications."
	else
		echo "Docker уже установлен"
	fi
}

install_zsh() {
	if ! command_exists zsh; then
		echo "Установка zsh..."
		brew install zsh
	else
		echo "zsh уже установлен"
	fi
}

install_ohmyzsh() {
	if [ ! -d ~/.oh-my-zsh ]; then
		echo "Установка Oh My Zsh..."
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
		echo "Oh My Zsh установлен"
	else
		echo "Oh My Zsh уже установлен"
	fi
}

install_fish() {
	if ! command_exists fish; then
		echo "Установка fish..."
		brew install fish
	else
		echo "fish уже установлен"
	fi
}

install_starship() {
	if ! command_exists starship; then
		echo "Установка Starship..."
		brew install starship
	else
		echo "Starship уже установлен"
	fi
}

install_btop() {
	if ! command_exists btop; then
		echo "Установка btop..."
		brew install btop
	else
		echo "btop уже установлен"
	fi
}

install_ncdu() {
	if ! command_exists ncdu; then
		echo "Установка ncdu..."
		brew install ncdu
	else
		echo "ncdu уже установлен"
	fi
}

get_selection() {
	local choice
	choice=$(
		gum choose --no-limit --header "Выберите компоненты для установки (macOS)" \
			"1) tmux" \
			"2) Neovim (v0.10.0) + LazyVim" \
			"3) JetBrains Nerd Font" \
			"4) lazydocker" \
			"5) k9s" \
			"6) CLI утилиты (fzf, ripgrep, fd, bat, eza, zoxide, tre, herdr)" \
			"7) Инструменты разработки (gh, delta, docker)" \
			"8) Shell-инструменты (zsh, oh-my-zsh, fish, starship)" \
			"9) Системные утилиты (btop, ncdu)" \
			"10) herdr" \
			"11) Конфигурации dotfiles" \
			"99) Установить все" \
			"0) Выход"
	)
	echo "$choice" | awk -F')' '{print $1}' | tr '\n' ' ' | xargs
}

usage() {
	echo "Usage: $0 [options]"
	echo ""
	echo "macOS + Homebrew"
	echo ""
	echo "Options:"
	echo "  --tmux          Install tmux and setup config"
	echo "  --nvim          Install Neovim and LazyVim"
	echo "  --fonts         Install JetBrains Nerd Font"
	echo "  --lazydocker    Install lazydocker"
	echo "  --k9s           Install k9s"
	echo "  --cli           Install CLI utilities (fzf, ripgrep, fd, bat, eza, zoxide, tre, herdr)"
	echo "  --dev           Install development tools (gh, delta, docker)"
	echo "  --shell         Install shell tools (zsh, oh-my-zsh, fish, starship)"
	echo "  --system        Install system tools (btop, ncdu)"
	echo "  --herdr         Install herdr (agent multiplexer for AI coding agents)"
	echo "  --configs       Setup dotfiles configurations"
	echo "  --all           Install everything"
	echo "  --brew          Install Homebrew"
	echo "  -h, --help      Show this help message"
	echo ""
	echo "Interactive mode (requires gum):"
	echo "  Run without arguments for interactive menu"
}

run_installer() {
	local selection="$1"

	local -a tokens=()
	IFS=' ' read -ra tokens <<< "$selection" 2>/dev/null || true

	for tok in "${tokens[@]:-}"; do
		case "$tok" in
			0|exit)
				echo "Выход из программы."
				return 1
				;;
			99|all)
				install_tmux
				setup_tmux
				install_neovim
				setup_lazyvim
				install_jetbrains_nerd_font
				install_lazydocker
				install_k9s
				install_cli_utilities
				install_dev_tools
				install_shell_tools
				install_system_tools
				setup_configs
				echo "Все компоненты установлены."
				return 0
				;;
			1|tmux)
				install_tmux
				setup_tmux
				;;
			2|nvim)
				install_neovim
				setup_lazyvim
				;;
			3|fonts)
				install_jetbrains_nerd_font
				;;
			4|lazydocker)
				install_lazydocker
				;;
			5|k9s)
				install_k9s
				;;
			6|cli)
				install_cli_utilities
				;;
			7|dev)
				install_dev_tools
				;;
			8|shell)
				install_shell_tools
				;;
			9|system)
				install_system_tools
				;;
			10|herdr)
				install_herdr
				;;
			11|configs)
				setup_configs
				;;
		esac
	done

	echo "Установка выбранных компонентов завершена."
	return 0
}

main() {
	if [ $# -eq 0 ]; then
		if ! command_exists gum; then
			echo "gum не найден. Для неинтерактивного режима используйте аргументы:"
			usage
			exit 1
		fi

		if ! command_exists brew; then
			echo "Homebrew не найден. Установка..."
			install_homebrew
		fi

		local selection
		while true; do
			selection=$(get_selection)
			run_installer "$selection" || break
			if ! gum confirm "Продолжить?"; then
				break
			fi
		done
	else
		while [[ $# -gt 0 ]]; do
			case "$1" in
				--brew)
					install_homebrew
					;;
				--tmux|--nvim|--fonts|--lazydocker|--k9s|--cli|--dev|--shell|--system|--configs|--herdr|--all)
					if ! command_exists brew; then
						echo "Homebrew не найден. Установка..."
						install_homebrew
					fi
					local arg="${1#--}"
					run_installer "$arg"
					;;
				-h|--help)
					usage
					exit 0
					;;
				*)
					echo "Unknown option: $1"
					usage
					exit 1
					;;
			esac
			shift
		done
	fi
}

main "$@"
