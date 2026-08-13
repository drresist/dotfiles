# Bash configuration
# Place as ~/.bashrc additions or ~/.bash_profile

# Path
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# History
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL="erasedups:ignoreboth"
export HISTTIMEFORMAT="%F %T "
shopt -s histappend
shopt -s cmdhist

# Check window size after each command
shopt -s checkwinsize

# Auto-cd
shopt -s autocd 2>/dev/null

# fzf
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} | head -200'"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# zoxide
eval "$(zoxide init bash)"

# Starship
eval "$(starship init bash)"

# Enable bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Source common aliases (centralized in configs/eza/aliases.sh, made available via ~/.dotfiles)
# shellcheck disable=SC1090
[ -f ~/.dotfiles/configs/eza/aliases.sh ] && source ~/.dotfiles/configs/eza/aliases.sh

# Functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

fzfp() {
    fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
}

# Colors
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Better history search
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
