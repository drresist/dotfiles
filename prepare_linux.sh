#!/bin/bash
#
# dotfiles prepare script (Linux focused, with macOS support)
# For a cleaner macOS-only experience, use prepare_macos.sh instead.
#
# Strict mode + helpers for safe, maintainable installs.

set -euo pipefail

# Функция для проверки наличия команды
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Определение ОС
get_os() {
	uname -s
}

is_macos() {
	[ "$(get_os)" = "Darwin" ]
}

is_linux() {
	[ "$(get_os)" = "Linux" ]
}

# Architecture normalizer (amd64/arm64) for manual downloads
get_arch() {
	local arch
	arch=$(uname -m)
	case "$arch" in
		x86_64) echo "amd64" ;;
		aarch64|arm64) echo "arm64" ;;
		*) echo "$arch" ;;
	esac
}

# Simple package manager detector (extendable)
get_pkg_manager() {
	if command_exists apt-get; then echo "apt"; 
	elif command_exists dnf; then echo "dnf";
	elif command_exists yum; then echo "yum";
	else echo "unknown"; fi
}

# Source shared code
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# Установка Homebrew
install_homebrew() {
	if ! command_exists brew; then
		echo "Установка Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		
		if is_macos; then
			echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
			eval "$(/opt/homebrew/bin/brew shellenv)"
		else
			echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
			eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		fi
		echo "Homebrew установлен"
	else
		echo "Homebrew уже установлен"
	fi
}


# Simple brew/apt/yum (or dnf) wrapper for common CLI tools
install_pkg() {
	local brew_name="$1" apt_name="${2:-$1}" yum_name="${3:-$apt_name}"
	if is_macos; then
		brew install "$brew_name"
	elif [ "$(get_pkg_manager)" = "apt" ]; then
		sudo apt-get update -qq && sudo apt-get install -y "$apt_name"
	elif [ "$(get_pkg_manager)" = "dnf" ]; then
		sudo dnf install -y "$yum_name"
	elif [ "$(get_pkg_manager)" = "yum" ]; then
		sudo yum install -y "$yum_name"
	else
		echo "No supported package manager for $apt_name; install manually."
		return 1
	fi
}

# Установка tmux
install_tmux() {
	if ! command_exists tmux; then
		echo "Установка tmux..."
		if is_macos; then
			brew install tmux
		else
			install_pkg tmux tmux tmux || {
				echo "Не удалось определить менеджер пакетов. Установите tmux вручную."
				return 1
			}
		fi
	else
		echo "tmux уже установлен."
	fi
}

# Настройка tmux с использованием конфигурации gpakosz/.tmux
setup_tmux() {
	echo "Настройка tmux..."
	if [ -d ~/.tmux ]; then
		echo "Конфигурация tmux уже существует. Обновление..."
		cd ~/.tmux && git pull && cd "$HOME"
	else
		git clone https://github.com/gpakosz/.tmux.git ~/.tmux
	fi
	ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
	[ -f ~/.tmux.conf.local ] || cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
	echo "Конфигурация tmux установлена."
}

# Установка Neovim (pinned for reproducibility)
NEOVIM_VERSION="v0.10.0"

install_neovim() {
	local current_ver=""
	if command_exists nvim; then
		current_ver=$(nvim --version | head -n1 | grep -o 'v[0-9.]*' | head -1 || echo "")
	fi
	if [ -z "$current_ver" ] || [[ "$current_ver" != "$NEOVIM_VERSION" && "$current_ver" != v0.10* ]]; then
		echo "Установка Neovim ${NEOVIM_VERSION}..."

		if is_macos; then
			brew install neovim
		else
			download_and_install \
				"https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz" \
				tar.gz "nvim-linux64/bin/nvim" "/usr/local/bin"
			# Also bring runtime etc if needed (the tar layout is nvim-linux64/*)
			# For simplicity the helper handles the bin; full tree copy for linux manual if missing
			if [ ! -d /usr/local/share/nvim ]; then
				# lightweight fallback - the tar top level copy was original behavior
				local td; td=$(mktemp -d); cd "$td"
				curl -fsSL -o nvim.tar.gz "https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz"
				tar xzf nvim.tar.gz
				sudo cp -r nvim-linux64/* /usr/local/ 2>/dev/null || true
				cd "$HOME"; rm -rf "$td"
			fi
		fi

		echo "Neovim ${NEOVIM_VERSION} установлен."
	else
		echo "Neovim ${NEOVIM_VERSION} уже установлен."
	fi
}

# Настройка LazyNvim
setup_lazyvim() {
	echo "Настройка LazyNvim..."
	# Создаем резервную копию существующей конфигурации Neovim, если она есть
	if [ -d ~/.config/nvim ]; then
		local backup_suffix=$(date +%Y%m%d_%H%M%S)
		mv ~/.config/nvim ~/.config/nvim.bak.$backup_suffix
		echo "Существующая конфигурация сохранена как ~/.config/nvim.bak.$backup_suffix"
	fi

	# Клонируем стартовый шаблон LazyVim
	git clone https://github.com/LazyVim/starter ~/.config/nvim

	# Удаляем папку .git, чтобы отвязать от репозитория LazyVim
	rm -rf ~/.config/nvim/.git

	echo "LazyNvim установлен. Запустите 'nvim' для завершения установки плагинов."
}

install_jetbrains_nerd_font() {
	echo "Установка JetBrains Nerd Font..."

	if is_macos; then
		brew tap homebrew/cask-fonts || true
		brew install --cask font-jetbrains-mono-nerd-font
	else
		local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip"
		local td; td=$(mktemp -d); cd "$td"
		curl -fsSL -o JetBrainsMono.zip "$font_url"
		mkdir -p ~/.local/share/fonts
		unzip -q JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
		fc-cache -f -v
		cd "$HOME"; rm -rf "$td"
	fi

	echo "JetBrains Nerd Font установлен."
}

setup_flatpak_apps() {

echo "Install flatpak apps..."

flatpak install -y \
    com.calibre_ebook.calibre \
    com.github.flxzt.rnote \
    com.github.marhkb.Pods \
    com.gitlab.newsflash \
    org.remmina.Remmina \
    org.telegram.desktop \
    org.telegram.desktop.webview \
    org.qbittorrent.qBittorrent \
    md.obsidian.Obsidian \
    io.dbeaver.DBeaverCommunity \
    com.todoist.Todoist \
    com.teamspeak.TeamSpeak \
    com.github.tchx84.Flatseal \
    com.bitwarden.desktop \
    org.videolan.VLC \
    com.github.johnfactotum.Foliate \
    com.github.debauchee.barrier \
    com.obsproject.Studio \
    com.leinardi.gwe \
    io.github.kotatogram
}

# Установка lazydocker
install_lazydocker() {
    echo "Установка lazydocker..."

    if is_macos; then
        brew install lazydocker
    else
        local os_name; os_name=$(uname -s | tr '[:upper:]' '[:lower:]')
        local a; a=$(get_arch)
        download_and_install \
            "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${os_name}_${a}.tar.gz" \
            tar.gz "lazydocker" "/usr/local/bin"
    fi

    echo "lazydocker установлен."
}

# Установка k9s
install_k9s() {
    echo "Установка k9s..."

    if is_macos; then
        brew install k9s
    else
        local a; a=$(get_arch)
        # k9s release uses k9s_Linux_{amd64,arm64}
        download_and_install \
            "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${a}.tar.gz" \
            tar.gz "k9s" "/usr/local/bin"
    fi

    echo "k9s установлен."
}



# CLI Utilities
install_fzf() {
    if ! command_exists fzf; then
        echo "Установка fzf..."
        if is_macos; then
            brew install fzf
            $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish --no-zsh
        else
            if [ -d ~/.fzf ]; then
                cd ~/.fzf && git pull && cd "$HOME"
            else
                git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            fi
            ~/.fzf/install --all --no-bash --no-fish --no-zsh
        fi
        echo "fzf установлен"
    else
        echo "fzf уже установлен"
    fi
}

install_ripgrep() {
    if ! command_exists rg; then
        echo "Установка ripgrep..."
        if is_macos || [ "$(get_pkg_manager)" != "unknown" ]; then
            install_pkg ripgrep ripgrep ripgrep || true
        else
            download_and_install "https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep_$(get_arch).deb" deb rg /usr/local/bin
        fi
        echo "ripgrep установлен"
    else
        echo "ripgrep уже установлен"
    fi
}

install_fd() {
    if ! command_exists fd && ! command_exists fdfind; then
        echo "Установка fd..."
        if is_macos; then
            brew install fd
        else
            install_pkg fd fd-find fd-find || true
            # symlink fdfind -> fd on debian style
            if command_exists fdfind && ! command_exists fd; then
                mkdir -p ~/.local/bin
                ln -sf "$(which fdfind)" ~/.local/bin/fd 2>/dev/null || true
            fi
        fi
        echo "fd установлен"
    else
        echo "fd уже установлен"
    fi
}

install_bat() {
    if ! command_exists bat && ! command_exists batcat; then
        echo "Установка bat..."
        if is_macos; then
            brew install bat
        else
            install_pkg bat bat bat || true
            if command_exists batcat && ! command_exists bat; then
                mkdir -p ~/.local/bin
                ln -sf "$(which batcat)" ~/.local/bin/bat 2>/dev/null || true
            fi
        fi
        echo "bat установлен"
    else
        echo "bat уже установлен"
    fi
}

install_eza() {
    if ! command_exists eza; then
        echo "Установка eza..."
        if is_macos; then
            brew install eza
        elif [ "$(get_pkg_manager)" = "apt" ]; then
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt-get update -qq
            sudo apt-get install -y eza
        else
            download_and_install "https://github.com/eza-community/eza/releases/latest/download/eza_$(get_arch).zip" zip eza /usr/local/bin
        fi
        echo "eza установлен"
    else
        echo "eza уже установлен"
    fi
}

install_zoxide() {
    if ! command_exists zoxide; then
        echo "Установка zoxide..."
        if is_macos; then
            brew install zoxide
        else
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        fi
        echo "zoxide установлен"
    else
        echo "zoxide уже установлен"
    fi
}

install_tre() {
    if ! command_exists tre; then
        echo "Установка tre..."
        if is_macos; then
            brew install tre-command
        else
            local a; a=$(get_arch)
            local tre_arch="x86_64"; [ "$a" = "arm64" ] && tre_arch="aarch64"
            download_and_install "https://github.com/dduan/tre/releases/latest/download/tre-${tre_arch}-unknown-linux-gnu.tar.gz" tar.gz tre /usr/local/bin
        fi
        echo "tre установлен"
    else
        echo "tre уже установлен"
    fi
}

install_herdr() {
    if ! command_exists herdr; then
        echo "Установка herdr..."
        if is_macos; then
            brew install herdr
        else
            curl -fsSL https://herdr.dev/install.sh | sh
        fi
        echo "herdr установлен"
    else
        echo "herdr уже установлен"
    fi
}

# Development Tools
install_gh() {
    if ! command_exists gh; then
        echo "Установка GitHub CLI..."
        if is_macos; then
            brew install gh
        elif command_exists apt-get; then
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
            && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && sudo apt update \
            && sudo apt install gh -y
        elif command_exists yum; then
            sudo yum install -y gh
        else
            local arch=$(uname -m)
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            curl -Lo gh.tar.gz "https://github.com/cli/cli/releases/latest/download/gh_${arch}.tar.gz"
            tar xzf gh.tar.gz
            sudo cp gh_*/bin/gh /usr/local/bin/
            cd "$HOME"
            rm -rf "$temp_dir"
        fi
        echo "GitHub CLI установлен"
    else
        echo "GitHub CLI уже установлен"
    fi
}

install_delta() {
    if ! command_exists delta; then
        echo "Установка git-delta..."
        if is_macos; then
            brew install git-delta
        else
            local arch=$(uname -m)
            local delta_arch="x86_64"
            [ "$arch" = "aarch64" ] && delta_arch="aarch64"
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            curl -Lo delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${delta_arch}.deb"
            sudo dpkg -i delta.deb || sudo apt-get install -f -y
            cd "$HOME"
            rm -rf "$temp_dir"
        fi
        echo "git-delta установлен"
    else
        echo "git-delta уже установлен"
    fi
}

install_docker() {
    if ! command_exists docker; then
        echo "Установка Docker..."
        if is_macos; then
            brew install --cask docker
            echo "Docker Desktop установлен. Запустите приложение из Applications."
        else
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            rm get-docker.sh
            sudo usermod -aG docker "$USER"
            echo "Docker установлен. Перезайдите для применения группы docker."
        fi
    else
        echo "Docker уже установлен"
    fi
}

# Shell Tools
install_zsh() {
    if ! command_exists zsh; then
        echo "Установка zsh..."
        if is_macos; then
            brew install zsh
        elif command_exists apt-get; then
            sudo apt-get install -y zsh
        elif command_exists yum; then
            sudo yum install -y zsh
        fi
        echo "zsh установлен"
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
        if is_macos; then
            brew install fish
        elif command_exists apt-get; then
            sudo apt-get install -y fish
        elif command_exists yum; then
            sudo yum install -y fish
        fi
        echo "fish установлен"
    else
        echo "fish уже установлен"
    fi
}

install_starship() {
    if ! command_exists starship; then
        echo "Установка Starship..."
        if is_macos; then
            brew install starship
        else
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi
        echo "Starship установлен"
    else
        echo "Starship уже установлен"
    fi
}

# System Tools
install_btop() {
    if ! command_exists btop; then
        echo "Установка btop..."
        if is_macos; then
            brew install btop
        else
            local arch=$(uname -m)
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            curl -Lo btop.tbz "https://github.com/aristocratos/btop/releases/latest/download/btop-${arch}-linux.tbz"
            tar -xjf btop.tbz
            sudo cp btop/bin/btop /usr/local/bin/
            sudo mkdir -p /usr/local/share/btop
            sudo cp -r btop/config /usr/local/share/btop/
            cd "$HOME"
            rm -rf "$temp_dir"
        fi
        echo "btop установлен"
    else
        echo "btop уже установлен"
    fi
}

install_ncdu() {
    if ! command_exists ncdu; then
        echo "Установка ncdu..."
        if is_macos; then
            brew install ncdu
        elif command_exists apt-get; then
            sudo apt-get install -y ncdu
        elif command_exists yum; then
            sudo yum install -y ncdu
        fi
        echo "ncdu установлен"
    else
        echo "ncdu уже установлен"
    fi
}


# Функция для получения выбора пользователя
# Emits space-separated tokens (numbers or keywords). Parsing now safe (no substring bugs).
get_selection() {
    local choice
    choice=$(
        gum choose --no-limit --header "Выберите компоненты для установки" \
            "1) tmux" \
            "2) Neovim (v0.10.0) + LazyNvim" \
            "3) JetBrains Nerd Font" \
            "4) lazydocker" \
            "5) k9s" \
            "6) CLI утилиты (fzf, ripgrep, fd, bat, eza, zoxide, tre, herdr)" \
            "7) Инструменты разработки (gh, delta, docker)" \
            "8) Shell-инструменты (zsh, oh-my-zsh, fish, starship)" \
            "9) Системные утилиты (btop, ncdu)" \
            "10) herdr" \
            "11) Flatpak приложения" \
            "12) Конфигурации dotfiles" \
            "99) Установить все" \
            "0) Выход"
    )
    # Produce clean tokens: numbers or the keywords used in CLI
    echo "$choice" | awk -F')' '{print $1}' | tr '\n' ' ' | xargs
}

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Supported OS: Linux (apt/yum/dnf) and macOS (Homebrew)"
    echo ""
    echo "Options:"
    echo "  --tmux          Install tmux and setup config"
    echo "  --nvim          Install Neovim and LazyNvim"
    echo "  --fonts         Install JetBrains Nerd Font"
    echo "  --lazydocker    Install lazydocker"
    echo "  --k9s           Install k9s"
    echo "  --cli           Install CLI utilities (fzf, ripgrep, fd, bat, eza, zoxide, tre, herdr)"
    echo "  --dev           Install development tools (gh, delta, docker)"
    echo "  --shell         Install shell tools (zsh, oh-my-zsh, fish, starship)"
    echo "  --system        Install system tools (btop, ncdu)"
    echo "  --herdr         Install herdr (agent multiplexer for AI coding agents)"
    echo "  --flatpak       Install flatpak applications (Linux only)"
    echo "  --configs       Setup dotfiles configurations"
    echo "  --all           Install everything"
    echo "  --brew          Install Homebrew (macOS/Linux)"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Interactive mode (requires gum):"
    echo "  Run without arguments for interactive menu"
}

run_installer() {
    local selection="$1"
    local -a tokens=()
    # Safe parse under set -u / nounset
    IFS=' ' read -ra tokens <<< "$selection" 2>/dev/null || true

    for tok in "${tokens[@]:-}"; do
        case "$tok" in
            0|exit)
                echo "Выход из программы."
                return 1
                ;;
            99|all)
                install_all
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
            11|flatpak)
                if is_linux; then
                    setup_flatpak_apps
                else
                    echo "Flatpak is Linux-only. Skipping."
                fi
                ;;
            12|configs)
                setup_configs
                ;;
            *)
                # ignore unknown tokens gracefully
                ;;
        esac
    done

    echo "Установка выбранных компонентов завершена."
    return 0
}

# Основная функция
main() {
    local need_brew_check=0

    if [ $# -eq 0 ]; then
        if ! command_exists gum; then
            echo "gum не найден. Для неинтерактивного режима используйте аргументы:"
            usage
            exit 1
        fi

        if is_macos && ! command_exists brew; then
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
                --tmux|--nvim|--fonts|--lazydocker|--k9s|--cli|--dev|--shell|--system|--flatpak|--configs|--herdr|--all)
                    if is_macos && ! command_exists brew; then
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

# Run only when executed (not sourced for testing or reuse)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
