# Zsh configuration
# Place as ~/.zshrc

# Path
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Auto-completion
autoload -Uz compinit
compinit -d ~/.zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Auto-suggestions and syntax highlighting (if installed)
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# fzf
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} | head -200'"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide
eval "$(zoxide init zsh)"

# Starship
eval "$(starship init zsh)"

# Key bindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

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
autoload -Uz colors && colors

# Prompt (backup if starship fails)
# PROMPT='%F{cyan}%n%f@%F{yellow}%m%f:%F{blue}%~%f$ '

# Window title
precmd() { print -Pn "\e]0;%~\a" }
eval "$(mise activate zsh)"


export SSH_AUTH_SOCK=/Users/mfesenko/.bitwarden-ssh-agent.sock
