#
# ~/.bashrc — рабочий bash на Omarchy-машине:
# слой Omarchy + локальные правки поверх него.
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Дефолтный слой Omarchy: OMARCHY_PATH и PATH, EDITOR/BROWSER/locale, история,
# completion, алиасы (a/c/cx/cy/h/t/n/ff/g/..., cd -> zd, ls/lt -> eza),
# functions и init (mise, starship, zoxide).
# Сам слой в репо не копируется — см. configs/omarchy/aliases.sh.
if [ -r "$HOME/.dotfiles/configs/omarchy/aliases.sh" ]; then
	. "$HOME/.dotfiles/configs/omarchy/aliases.sh"
fi

#
# Локальные правки. Всё ниже перекрывает слой Omarchy.
#

# Слой Omarchy (envs) ставит EDITOR сам; фолбэк — для машин без Omarchy.
export EDITOR="${EDITOR:-nvim}"

alias grep='grep --color=auto'

__mproxy_prompt_status() {
  if [[ -n ${http_proxy:-} || -n ${HTTP_PROXY:-} ]]; then
    printf ' proxy:on'
  else
    printf ' proxy:off'
  fi
}

PS1='[\u@\h \W$(__mproxy_prompt_status)]\$ '
export PATH="$HOME/.local/bin:$PATH"
export SSH_AUTH_SOCK="$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"

# Enable or disable Mihomo for commands launched from this terminal.
mproxy() {
  case "${1:-status}" in
    on)
      if ! mihoro start; then
        printf 'Failed to start Mihomo.\n' >&2
        return 1
      fi

      export http_proxy='http://127.0.0.1:7890'
      export https_proxy="$http_proxy"
      export all_proxy='socks5h://127.0.0.1:7892'
      export no_proxy='localhost,127.0.0.1,::1'
      export HTTP_PROXY="$http_proxy"
      export HTTPS_PROXY="$https_proxy"
      export ALL_PROXY="$all_proxy"
      export NO_PROXY="$no_proxy"
      printf 'Terminal proxy: ON (Mihomo 127.0.0.1:7890)\n'
      ;;
    off)
      local mihomo_status=0
      mihoro stop || mihomo_status=$?
      unset http_proxy https_proxy all_proxy no_proxy
      unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
      printf 'Terminal proxy: OFF\n'
      return "$mihomo_status"
      ;;
    status)
      mihoro status
      if [[ -n ${http_proxy:-} || -n ${HTTP_PROXY:-} ]]; then
        printf 'Terminal environment: ON (%s)\n' "${http_proxy:-$HTTP_PROXY}"
      else
        printf 'Terminal environment: OFF\n'
      fi
      ;;
    *)
      printf 'Usage: mproxy {on|off|status}\n' >&2
      return 2
      ;;
  esac
}
