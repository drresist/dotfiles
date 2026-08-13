# Fish shell configuration
# Place in ~/.config/fish/config.fish

# Set PATH (guarded: prepends only if absent, so no duplicates across shells;
# /usr/local/bin is already in /etc/paths)
for p in $HOME/.local/bin $HOME/bin
    if not contains $p $PATH
        set -gx PATH $p $PATH
    end
end

# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Disable greeting
set -g fish_greeting

# fzf configuration
set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --level=2 --color=always {} | head -200'"

# fzf key bindings
fzf --fish | source

# zoxide
zoxide init fish | source

# Starship prompt
starship init fish | source

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

# Useful functions
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

function fzfp
    fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
end

# Colors
set -g fish_color_normal normal
set -g fish_color_command blue
set -g fish_color_quote green
set -g fish_color_redirection cyan
set -g fish_color_end normal
set -g fish_color_error red
set -g fish_color_param normal
set -g fish_color_comment brblack
set -g fish_color_match cyan
set -g fish_color_search_match bryellow
set -g fish_color_operator cyan
set -g fish_color_escape cyan
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_valid_path cyan
set -g fish_color_autosuggestion brblack
set -g fish_color_user brgreen
set -g fish_color_host normal
set -g fish_color_cancel red
set -g fish_pager_color_prefix cyan
set -g fish_pager_color_completion normal
set -g fish_pager_color_description yellow
set -g fish_pager_color_progress brwhite
set -g fish_pager_color_selected_background --background=blue
set -g fish_color_history_current cyan
