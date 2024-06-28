#!/bin/bash

# Функция для проверки наличия команды
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Установка tmux
install_tmux() {
	if ! command_exists tmux; then
		echo "Установка tmux..."
		if command_exists apt-get; then
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
	git clone https://github.com/gpakosz/.tmux.git ~/.tmux
	ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
	cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
	echo "Конфигурация tmux установлена."
}

# Установка Neovim

# Установка Neovim версии 8.0
install_neovim() {
	if ! command_exists nvim || [[ $(nvim --version | head -n1 | awk '{print $2}') != "v8.0"* ]]; then
		echo "Установка Neovim версии 10.0..."

		# Создаем временную директорию для загрузки
		temp_dir=$(mktemp -d)
		cd "$temp_dir"

		# Загружаем архив с Neovim 8.0
		wget https://github.com/neovim/neovim/releases/download/v0.10.0/nvim-linux64.tar.gz

		# Распаковываем архив
		tar xzf nvim-linux64.tar.gz

		# Копируем файлы в /usr/local
		sudo cp -r nvim-linux64/* /usr/local/

		# Очищаем временную директорию
		cd
		rm -rf "$temp_dir"

		echo "Neovim версии 8.0 установлен."
	else
		echo "Neovim версии 8.0 уже установлен."
	fi
}

# Настройка LazyNvim
setup_lazyvim() {
	echo "Настройка LazyNvim..."
	# Создаем резервную копию существующей конфигурации Neovim, если она есть
	[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak

	# Клонируем стартовый шаблон LazyVim
	git clone https://github.com/LazyVim/starter ~/.config/nvim

	# Удаляем папку .git, чтобы отвязать от репозитория LazyVim
	rm -rf ~/.config/nvim/.git

	echo "LazyNvim установлен. Запустите 'nvim' для завершения установки плагинов."
}

install_jetbrains_nerd_font() {
	echo "Установка JetBrains Nerd Font..."

	# Создаем временную директорию для загрузки
	temp_dir=$(mktemp -d)
	cd "$temp_dir"

	# Загружаем архив с шрифтом
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip

	# Создаем директорию для шрифтов, если она не существует
	mkdir -p ~/.local/share/fonts

	# Распаковываем архив в директорию с шрифтами
	unzip JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono

	# Обновляем кэш шрифтов
	fc-cache -f -v

	# Очищаем временную директорию
	cd
	rm -rf "$temp_dir"

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
    io.github.kotatogram \

}

# Установка lazydocker
install_lazydocker() {
    echo "Установка lazydocker..."

    # Создаем временную директорию для загрузки
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Загружаем последнюю версию lazydocker
    curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_$(uname)_$(uname -m).tar.gz"

    # Распаковываем архив
    tar xf lazydocker.tar.gz

    # Перемещаем исполняемый файл в /usr/local/bin
    sudo mv lazydocker /usr/local/bin

    # Очищаем временную директорию
    cd
    rm -rf "$temp_dir"

    echo "lazydocker установлен."
}

# Установка k9s
install_k9s() {
    echo "Установка k9s..."

    # Создаем временную директорию для загрузки
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Загружаем последнюю версию k9s
    curl -Lo k9s.tar.gz "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz"

    # Распаковываем архив
    tar xf k9s.tar.gz

    # Перемещаем исполняемый файл в /usr/local/bin
    sudo mv k9s /usr/local/bin

    # Очищаем временную директорию
    cd
    rm -rf "$temp_dir"

    echo "k9s установлен."
}


# Функция для отображения меню
show_menu() {
    echo "Выберите компоненты для установки:"
    echo "1) tmux"
    echo "2) Neovim (версия 8.0) с LazyNvim"
    echo "3) JetBrains Nerd Font"
    echo "4) lazydocker"
    echo "5) k9s"
    echo "6) Установить все"
    echo "0) Выход"
}

# Функция для получения выбора пользователя
get_selection() {
    local choice
    read -p "Введите номера выбранных опций (разделите пробелами): " choice
    echo $choice
}

# Основная функция
main() {
    local selection

    while true; do
        show_menu
        selection=$(get_selection)

        if [[ $selection == *"0"* ]]; then
            echo "Выход из программы."
            break
        fi

        if [[ $selection == *"6"* ]]; then
            install_tmux
            setup_tmux
            install_neovim
            setup_lazyvim
            install_jetbrains_nerd_font
            install_lazydocker
            install_k9s
            echo "Все компоненты установлены."
            break
        fi

        if [[ $selection == *"1"* ]]; then
            install_tmux
            setup_tmux
        fi

        if [[ $selection == *"2"* ]]; then
            install_neovim
            setup_lazyvim
        fi

        if [[ $selection == *"3"* ]]; then
            install_jetbrains_nerd_font
        fi

        if [[ $selection == *"4"* ]]; then
            install_lazydocker
        fi

        if [[ $selection == *"5"* ]]; then
            install_k9s
        fi

        echo "Установка выбранных компонентов завершена."
        read -p "Нажмите Enter для продолжения..."
    done
}

# Запуск основной функции
main
