if status is-interactive
    if type -q starship
        starship init fish | source
    end

    if type -q nvim
        set -q EDITOR; or set -gx EDITOR nvim
        set -q VISUAL; or set -gx VISUAL nvim
        alias v='nvim'
    end

    alias ll='ls -lah'
    alias gs='git status --short --branch'
end
