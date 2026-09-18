# Алиасы (и остальной bash-слой), которые поставляет Omarchy.
#
# Omarchy держит их системно в /usr/share/omarchy (Arch) или как
# пользовательский чекаут в ~/.local/share/omarchy (macOS). Здесь ничего не
# копируется специально: на живой Omarchy системная копия остаётся
# единственным источником правды и обновляется вместе с дистрибутивом, а на
# машине без Omarchy файл — no-op.
#
# Алиасы: a/c/cx/cy/h/t/n/ic/ix/icx/mup/ff/sff/g/..., cd -> zd,
# ls/lt -> eza. Полный список — $OMARCHY_PATH/default/bash/aliases.
#
# Подключается из shell/.bashrc через указатель ~/.dotfiles.
# Только bash: слой написан на bash (shopt, bind, inputrc, `open() (`),
# в zsh его сорсить нельзя.

[ -n "${BASH_VERSION:-}" ] || return 0

# OMARCHY_PATH обычно приходит из /etc/profile.d/omarchy.sh; для сессий без
# логин-профиля (ssh, herdr) доискиваем сами.
if [ -z "${OMARCHY_PATH:-}" ] || [ ! -r "$OMARCHY_PATH/default/bash/rc" ]; then
	for candidate in /usr/share/omarchy "$HOME/.local/share/omarchy"; do
		if [ -r "$candidate/default/bash/rc" ]; then
			OMARCHY_PATH="$candidate"
			export OMARCHY_PATH
			break
		fi
	done
fi

[ -n "${OMARCHY_PATH:-}" ] && [ -r "$OMARCHY_PATH/default/bash/rc" ] || return 0

# rc — та же точка входа, что и в ~/.bashrc самого Omarchy: envs (EDITOR,
# BROWSER, locale, PATH), shell (история, completion), aliases, functions,
# init (mise, starship, zoxide).
. "$OMARCHY_PATH/default/bash/rc"
