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

# Aliases
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias cat="bat"
alias ls="eza --group-directories-first --icons"
alias ll="eza -lbF --git --icons"
alias la="eza -lbhHigUmuSa --time-style=long-iso --git --color-scale --icons"
alias lt="eza --tree --level=2 --icons"
alias ..="cd .."
alias ...="cd ../.."
alias grep="rg"
alias find="fd"
alias top="btop"

# Git aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"

# Docker aliases
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dlogs="docker logs -f"

# Kubernetes aliases
alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kapply="kubectl apply -f"

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

# dotfiles bashrc
source "/Users/mfesenko/Project/dotfiles/shell/.bashrc"
