# Zsh configuration for dotfiles
# Uses Zinit + Powerlevel10k for prompt
# Sources common aliases from the dotfiles repo

# Early PATH (macOS: include Apple Silicon Homebrew before Intel paths)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/bin:/usr/local/bin:$PATH"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Zinit setup
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Disable p10k config wizard before loading the theme
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Powerlevel10k theme
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Load p10k config if it exists
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Oh My Zsh libs & plugins via Zinit (turbo mode for speed)
zinit wait lucid for \
    OMZL::functions.zsh \
    OMZL::completion.zsh \
    OMZL::history.zsh \
    OMZL::key-bindings.zsh \
    OMZL::termsupport.zsh \
    OMZL::directories.zsh \
    OMZP::colored-man-pages \
    OMZP::colorize \
    OMZP::git \
    OMZP::history

# Community plugins (turbo)
zinit wait lucid for \
    zsh-users/zsh-completions \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-history-substring-search \
    zdharma-continuum/fast-syntax-highlighting

# Source centralized aliases (eza, git, docker, k8s, mkcd, fzfp, etc.)
[ -f ~/.dotfiles/configs/eza/aliases.sh ] && source ~/.dotfiles/configs/eza/aliases.sh

# Useful personal/general aliases (cleaned)
alias chmox="chmod +x"
# No alias needed on macOS; the Zed CLI is already `zed`.

# Custom meson wrapper (kept for your workflow; uses epm for deps)
meson() {
    if [[ "$1" == "build" || "$1" == "setup" ]]; then
        local MESON_BUILD="meson.build"
        local LOCK_FILE="epm.lock"

        if [[ -f "$MESON_BUILD" ]]; then
            local DEPS=$(grep -rhoE "dependency\('[^']+" . --include="meson.build" 2>/dev/null | sed "s/dependency('//" | sort -u)
            local DEPS_HASH=$(printf '%s' "$DEPS" | shasum -a 256 | cut -d' ' -f1)

            local need_install=true
            if [[ -f "$LOCK_FILE" ]]; then
                local LOCK_HASH=$(grep "^hash:" "$LOCK_FILE" | cut -d' ' -f2)
                [[ "$DEPS_HASH" == "$LOCK_HASH" ]] && need_install=false
            fi

            if $need_install; then
                echo "→ installing deps..."
                if epmi $(echo "$DEPS" | sed "s/.*/pkgconfig(&)/"); then
                    {
                        echo "hash: $DEPS_HASH"
                        echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
                        echo "deps:"
                        echo "$DEPS" | sed "s/^/  - /"
                    } > "$LOCK_FILE"
                    echo "✓ lock updated"
                else
                    echo "⚠ install failed, lock not updated"
                fi
            fi
        fi
    fi

    command meson "$@"
}

# SSH agent (Bitwarden example - customize or comment)
# export SSH_AUTH_SOCK=$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock

# Atuin (history) via zinit
zinit wait lucid atload'eval "$(atuin init zsh)"' for zdharma-continuum/null

# Optional: fastfetch on new shell (uncomment if you want it)
# fastfetch
