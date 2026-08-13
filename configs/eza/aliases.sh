# Common shell aliases (eza + git + docker + k8s + helpers)
# Source this in your shell config (setup_configs creates ~/.dotfiles symlink for portability)

# eza (enhanced ls)
alias ls='eza --group-directories-first --icons'
alias l='eza -lbF --git --icons'
alias ll='eza -lbGF --git --icons'
alias llm='eza -lbGF --git --sort=modified --icons'
alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale --icons'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --icons'
alias lS='eza -1 --icons'
alias lt='eza --tree --level=2 --icons'
alias l.='eza -a --icons | grep -E "^\."'

# Core
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias cat="bat"
alias ..="cd .."
alias ...="cd ../.."
alias grep="rg"
alias find="fd"
alias top="btop"

# Git
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"

# Docker
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dlogs="docker logs -f"

# Kubernetes
alias k="kubectl"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kapply="kubectl apply -f"

