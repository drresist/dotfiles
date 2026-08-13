#!/bin/bash

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

# Установка tmux
install_tmux() {
	if ! command_exists tmux; then
		echo "Установка tmux..."
		if is_macos; then
			brew install tmux
		elif command_exists apt-get; then
			sudo apt-get update
			sudo apt-get install -y tmux
		elif command_exists yum; then
			sudo yum install -y tmux
		else
			echo "Не удалось определить менеджер пакетов. Установите tmux вручную."
			exit 1
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

# Установка Neovim

# Установка Neovim версии 0.10.0
install_neovim() {
	if ! command_exists nvim || [[ $(nvim --version | head -n1 | awk '{print $2}') != "v0.10"* ]]; then
		echo "Установка Neovim версии 0.10.0..."

		if is_macos; then
			brew install neovim
		else
			local temp_dir=$(mktemp -d)
			cd "$temp_dir"
			curl -Lo nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/v0.10.0/nvim-linux64.tar.gz
			tar xzf nvim-linux64.tar.gz
			sudo cp -r nvim-linux64/* /usr/local/
			cd "$HOME"
			rm -rf "$temp_dir"
		fi

		echo "Neovim версии 0.10.0 установлен."
	else
		echo "Neovim версии 0.10.0 уже установлен."
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
		brew tap homebrew/cask-fonts
		brew install --cask font-jetbrains-mono-nerd-font
	else
		local temp_dir=$(mktemp -d)
		cd "$temp_dir"
		curl -Lo JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
		mkdir -p ~/.local/share/fonts
		unzip JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
		fc-cache -f -v
		cd "$HOME"
		rm -rf "$temp_dir"
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
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        local os_name=$(uname -s | tr '[:upper:]' '[:lower:]')
        local arch=$(uname -m)
        curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${os_name}_${arch}.tar.gz"
        tar xf lazydocker.tar.gz
        sudo mv lazydocker /usr/local/bin
        cd "$HOME"
        rm -rf "$temp_dir"
    fi

    echo "lazydocker установлен."
}

# Установка k9s
install_k9s() {
    echo "Установка k9s..."

    if is_macos; then
        brew install k9s
    else
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        local arch=$(uname -m)
        local k9s_arch="amd64"
        case "$arch" in
            x86_64) k9s_arch="amd64" ;;
            aarch64) k9s_arch="arm64" ;;
            arm64) k9s_arch="arm64" ;;
        esac
        curl -Lo k9s.tar.gz "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${k9s_arch}.tar.gz"
        tar xf k9s.tar.gz
        sudo mv k9s /usr/local/bin
        cd "$HOME"
        rm -rf "$temp_dir"
    fi

    echo "k9s установлен."
}


# Установка и настройка конфигураций
dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup_configs() {
    echo "Настройка конфигурационных файлов..."

    # Создаем директории
    mkdir -p ~/.config

    # Starship
    if [ -f "$dotfiles_dir/configs/starship/starship.toml" ]; then
        mkdir -p ~/.config
        ln -sf "$dotfiles_dir/configs/starship/starship.toml" ~/.config/starship.toml
        echo "Starship конфигурация установлена"
    fi

    # bat
    if [ -f "$dotfiles_dir/configs/bat/config" ]; then
        mkdir -p ~/.config/bat
        ln -sf "$dotfiles_dir/configs/bat/config" ~/.config/bat/config
        echo "bat конфигурация установлена"
    fi

    # btop
    if [ -f "$dotfiles_dir/configs/btop/btop.conf" ]; then
        mkdir -p ~/.config/btop
        ln -sf "$dotfiles_dir/configs/btop/btop.conf" ~/.config/btop/btop.conf
        echo "btop конфигурация установлена"
    fi

    # Git
    if [ -f "$dotfiles_dir/configs/git/config" ]; then
        mkdir -p ~/.config/git
        ln -sf "$dotfiles_dir/configs/git/config" ~/.config/git/config
        if ! grep -q "path = ~/.config/git/config" ~/.gitconfig 2>/dev/null; then
            git config --global include.path ~/.config/git/config
        fi
        echo "Git конфигурация установлена"
    fi

    # Fish shell
    if [ -f "$dotfiles_dir/configs/fish/config.fish" ]; then
        mkdir -p ~/.config/fish
        ln -sf "$dotfiles_dir/configs/fish/config.fish" ~/.config/fish/config.fish
        echo "Fish shell конфигурация установлена"
    fi

    # Shell configs
    if [ -f "$dotfiles_dir/shell/.zshrc" ]; then
        ln -sf "$dotfiles_dir/shell/.zshrc" ~/.zshrc
        echo ".zshrc установлен"
    fi

    if [ -f "$dotfiles_dir/shell/.bashrc" ]; then
        if [ -f ~/.bashrc ]; then
            if ! grep -q "dotfiles bashrc" ~/.bashrc; then
                echo -e "\n# dotfiles bashrc\nsource \"$dotfiles_dir/shell/.bashrc\"" >> ~/.bashrc
            fi
        else
            ln -sf "$dotfiles_dir/shell/.bashrc" ~/.bashrc
        fi
        echo ".bashrc настроен"
    fi

    echo "Конфигурации установлены!"
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
        if is_macos; then
            brew install ripgrep
        elif command_exists apt-get; then
            sudo apt-get install -y ripgrep
        elif command_exists yum; then
            sudo yum install -y ripgrep
        else
            local arch=$(uname -m)
            local rg_arch="amd64"
            [ "$arch" = "aarch64" ] && rg_arch="arm64"
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            curl -Lo ripgrep.deb "https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep_${rg_arch}.deb"
            sudo dpkg -i ripgrep.deb || sudo apt-get install -f -y
            cd "$HOME"
            rm -rf "$temp_dir"
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
        elif command_exists apt-get; then
            sudo apt-get install -y fd-find
            mkdir -p ~/.local/bin
            ln -sf $(which fdfind) ~/.local/bin/fd 2>/dev/null || true
        elif command_exists yum; then
            sudo yum install -y fd-find
        else
            local arch=$(uname -m)
            local fd_arch="amd64"
            [ "$arch" = "aarch64" ] && fd_arch="arm64"
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            curl -Lo fd.deb "https://github.com/sharkdp/fd/releases/latest/download/fd_${fd_arch}.deb"
            sudo dpkg -i fd.deb || sudo apt-get install -f -y
            cd "$HOME"
            rm -rf "$temp_dir"
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
        elif command_exists apt-get; then
            sudo apt-get install -y bat
            mkdir -p ~/.local/bin
            ln -sf $(which batcat) ~/.local/bin/bat 2>/dev/null || true
        elif command_exists yum; then
            sudo yum install -y bat
        else
            local arch=$(uname -m)
            local bat_arch="amd64"
            [ "$arch" = "aarch64" ] && bat_arch="arm64"
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            curl -Lo bat.deb "https://github.com/sharkdp/bat/releases/latest/download/bat_${bat_arch}.deb"
            sudo dpkg -i bat.deb || sudo apt-get install -f -y
            cd "$HOME"
            rm -rf "$temp_dir"
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
        elif command_exists apt-get; then
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt-get update
            sudo apt-get install -y eza
        else
            local arch=$(uname -m)
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            curl -Lo eza.zip "https://github.com/eza-community/eza/releases/latest/download/eza_${arch}.zip"
            unzip eza.zip
            sudo mv eza /usr/local/bin/
            cd "$HOME"
            rm -rf "$temp_dir"
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
            local arch=$(uname -m)
            local tre_arch="x86_64"
            [ "$arch" = "aarch64" ] && tre_arch="aarch64"
            local temp_dir=$(mktemp -d)
            cd "$temp_dir"
            curl -Lo tre.tgz "https://github.com/dduan/tre/releases/latest/download/tre-${tre_arch}-unknown-linux-gnu.tar.gz"
            tar xzf tre.tgz
            sudo mv tre /usr/local/bin/
            cd "$HOME"
            rm -rf "$temp_dir"
        fi
        echo "tre установлен"
    else
        echo "tre уже установлен"
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

install_cli_utilities() {
    echo "Установка CLI утилит..."
    install_fzf
    install_ripgrep
    install_fd
    install_bat
    install_eza
    install_zoxide
    install_tre
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

# Функция для получения выбора пользователя
get_selection() {
    local choice
    choice=$(
        gum choose --no-limit --header "Выберите компоненты для установки" \
            "1) tmux" \
            "2) Neovim (v0.10.0) + LazyNvim" \
            "3) JetBrains Nerd Font" \
            "4) lazydocker" \
            "5) k9s" \
            "6) CLI утилиты (fzf, ripgrep, fd, bat, eza, zoxide, tre)" \
            "7) Инструменты разработки (gh, delta, docker)" \
            "8) Shell-инструменты (zsh, oh-my-zsh, fish, starship)" \
            "9) Системные утилиты (btop, ncdu)" \
            "10) Flatpak приложения" \
            "11) Конфигурации dotfiles" \
            "99) Установить все" \
            "0) Выход"
    )
    echo "$choice" | awk -F')' '{print $1}' | tr '\n' ' ' | xargs
}

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Supported OS: Linux (apt/yum) and macOS (Homebrew)"
    echo ""
    echo "Options:"
    echo "  --tmux          Install tmux and setup config"
    echo "  --nvim          Install Neovim and LazyNvim"
    echo "  --fonts         Install JetBrains Nerd Font"
    echo "  --lazydocker    Install lazydocker"
    echo "  --k9s           Install k9s"
    echo "  --cli           Install CLI utilities (fzf, ripgrep, fd, bat, eza, zoxide, tre)"
    echo "  --dev           Install development tools (gh, delta, docker)"
    echo "  --shell         Install shell tools (zsh, oh-my-zsh, fish, starship)"
    echo "  --system        Install system tools (btop, ncdu)"
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

    if [[ $selection == *"0"* ]]; then
        echo "Выход из программы."
        return 1
    fi

    if [[ $selection == *"99"* ]] || [[ "$selection" == "all" ]]; then
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
        setup_flatpak_apps
        setup_configs
        echo "Все компоненты установлены."
        return 0
    fi

    if [[ $selection == *"1"* ]] || [[ "$selection" == "tmux" ]]; then
        install_tmux
        setup_tmux
    fi

    if [[ $selection == *"2"* ]] || [[ "$selection" == "nvim" ]]; then
        install_neovim
        setup_lazyvim
    fi

    if [[ $selection == *"3"* ]] || [[ "$selection" == "fonts" ]]; then
        install_jetbrains_nerd_font
    fi

    if [[ $selection == *"4"* ]] || [[ "$selection" == "lazydocker" ]]; then
        install_lazydocker
    fi

    if [[ $selection == *"5"* ]] || [[ "$selection" == "k9s" ]]; then
        install_k9s
    fi

    if [[ $selection == *"6"* ]] || [[ "$selection" == "cli" ]]; then
        install_cli_utilities
    fi

    if [[ $selection == *"7"* ]] || [[ "$selection" == "dev" ]]; then
        install_dev_tools
    fi

    if [[ $selection == *"8"* ]] || [[ "$selection" == "shell" ]]; then
        install_shell_tools
    fi

    if [[ $selection == *"9"* ]] || [[ "$selection" == "system" ]]; then
        install_system_tools
    fi

    if [[ $selection == *"10"* ]] || [[ "$selection" == "flatpak" ]]; then
        setup_flatpak_apps
    fi

    if [[ $selection == *"11"* ]] || [[ "$selection" == "configs" ]]; then
        setup_configs
    fi

    echo "Установка выбранных компонентов завершена."
    return 0
}

# Основная функция
main() {
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
                --tmux|--nvim|--fonts|--lazydocker|--k9s|--cli|--dev|--shell|--system|--flatpak|--configs|--all)
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

# Запуск основной функции
main "$@"
