# eza aliases for better ls experience
# Source this in your shell config

alias ls='eza --group-directories-first --icons'
alias l='eza -lbF --git --icons'
alias ll='eza -lbGF --git --icons'
alias llm='eza -lbGF --git --sort=modified --icons'
alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale --icons'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --icons'
alias lS='eza -1 --icons'
alias lt='eza --tree --level=2 --icons'
alias l.='eza -a --icons | grep -E "^\."'
