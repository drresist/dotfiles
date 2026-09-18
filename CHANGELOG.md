# Changelog

Изменения dotfiles и окружения. Формат: дата, контекст, изменения, проверка.

## 2026-09-18 — server/: аудит хостов, off-site бэкапы, ротация ключей

### Контекст

- Проведена инвентаризация домашней сети (omamac, cloudcode, proxy.host): что
  установлено, что слушает, что лежит без присмотра.
- Нашлось: off-site бэкапов нет ни на одном хосте (данные Basic Memory, n8n и
  gatus живут на одном диске одной VPS); публикация портов docker обходит
  host_firewall (DNAT → FORWARD), поэтому политика DROP в input-цепочке
  docker-порты не защищает; ключи Cloud.ru попали в чат-сессию и требуют ротации;
  остались легаси Hiddify, мёртвые контейнеры и аккаунты-наследники.
- Всё это делалось руками по SSH — перенесено в репозиторий, чтобы повторялось,
  а не вспоминалось.

### Изменения

- Добавлен `server/` — Ansible-набор: инвентарь (omamac локально, cloudcode,
  proxy), `site.yml`, обёртка `bin/ops` (при отсутствии ставит ansible-core через
  `uv`, без sudo).
- Роли: `audit` (read-only: публичные порты, состояние контейнеров, свежесть
  бэкапа, права на файлы с секретами, аккаунты-наследники, состояние
  DOCKER-USER), `restic_backup` (restic, env с ключами, шаблоны
  `backup.sh`/`verify-restore.sh`, cron), `s3_keys` (ротация с проверкой и
  откатом), `docker_firewall` (whitelist портов в DOCKER-USER), `cleanup`
  (легаси, opt-in).
- Секретов в репозитории нет: `group_vars/vault.yml.example`, а `vault.yml` и
  `reports/` закрыты `.gitignore`.
- Рискованные операции (`docker-firewall`, `cleanup`) по умолчанию ничего не
  применяют: сначала `--check`, потом осознанный запуск.

### Проверка

- `./bin/ops audit` — прогнан на всех трёх хостах без падений, отчёты в
  `server/reports/<host>.txt`. Найдено ровно ожидаемое: у proxy пустая цепочка
  DOCKER-USER и аккаунты Hiddify, у omamac аккаунт `alarm`.
- `./bin/ops backups` — развёрнуто на cloudcode и proxy; шаблонные скрипты
  прогнаны (снапшоты `8e6c2a46` и `98e9eda7`), затем `./bin/ops verify` →
  `RESULT: OK` на обоих (restic check, реальное восстановление,
  `PRAGMA integrity_check`, сверка содержимого с живыми данными).
- Ротация ключей: прогон с текущими ключами идемпотентен (`changed=0`); прогон с
  заведомо неверным секретом падает, откатывает файл (хэш `s3.env` до и после
  совпал) и оставляет бэкап рабочим.

### Примечание

- Ротация требует консоли Cloud.ru: создать новый ключ → `./bin/ops rotate-s3` →
  отозвать старый.
- Ключи, побывавшие в переписке, считаются скомпрометированными и подлежат смене.

## 2026-08-13 — git: email убран из публичного репо, identity = noreply

### Контекст

- Репозиторий публичный (проверено `git ls-remote` без авторизации).
- `drresist@gmail.com` светился в авторстве коммитов на origin; файл
  `configs/git/gitconfig` с email готовился уйти туда же с новым коммитом.

### Изменения

- Email в `configs/git/gitconfig` заменён на GitHub noreply
  (`22808856+drresist@users.noreply.github.com`). Файл залинкован как
  `~/.gitconfig`, поэтому все новые коммиты локально тоже идут с noreply.
- История полностью переписана (rebase --root + явный --author): автор и
  коммитер всех коммитов — noreply.
- Force-push в `origin/main` (с `--force-with-lease`): старая история с
  gmail-авторством заменена.
- Remote переведён с HTTPS на SSH (`git@github.com:drresist/dotfiles.git`):
  в keychain не было креденшелов GitHub, HTTPS-push не работал.

### Проверка

- `git log --all --format='%ae %ce' | sort -u` — единственный email noreply.
- `git grep drresist@gmail` по всем коммитам — пусто.
- `main` синхронизирован с `origin/main`.

### Примечание

- GitHub может некоторое время отдавать старые (dangling) коммиты по прямым
  SHA; со временем они удаляются сборщиком мусора.
- Если в рабочих репозиториях нужен другой email — задавать локально,
  `git config user.email` в конкретном репо.

## 2026-08-13 — dotfiles: оживление репозитория, новый инсталлятор

### Контекст

- Репозиторий `~/Project/dotfiles` (remote `github.com/drresist/dotfiles`)
  существует с февраля, но июльская работа не была закоммичена: модифицированные
  tracked-файлы и untracked `prepare_macos.sh`, `common.sh`, `configs/{gh,herdr,kitty,zsh}`.
- `~/.dotfiles` отсутствовал, поэтому `.zshrc`/`.bashrc` тихо не source'или
  `configs/eza/aliases.sh`.
- Живой `~/.config/herdr/config.toml` был новее шаблонной копии в репо.

### Изменения

- `install.sh` (новый): идемпотентный линковщик конфигов — верные симлинки
  пропускает, неверные перелинковывает, обычные файлы бэкапит в
  `*.bak.<timestamp>`.
- `common.sh`: `link_config` теперь с бэкапами; `setup_configs` делегирует
  в `install.sh` (одна точка правды для маппинга).
- В репо добавлены: `configs/fish/completions/grok.fish`,
  `configs/fish/conf.d/atuin.env.fish`, `configs/atuin/config.toml`,
  `configs/git/gitconfig` (include-путь сделан переносимым:
  `~/.config/git/config`), живой `configs/herdr/config.toml`, `.gitignore`,
  `CHANGELOG.md`.
- `README.md`: задокументированы роли `install.sh` (конфиги) и `prepare*.sh`
  (bootstrap пакетов на свежей машине).
- Создан `~/.dotfiles -> ~/Project/dotfiles`: eza-алиасы снова source'ятся
  в zsh/bash.

### Проверка

- `install.sh` запущен дважды: второй прогон — все линки `ok` (идемпотентно).
- `starship prompt`, `fish -ic`, `git config --global` (include через `~`),
  `zsh -ic 'alias ll'` — всё работает.

### Примечание

- tmux остаётся на oh-my-tmux (`~/.tmux`): его клонирует `prepare_macos.sh`,
  `install.sh` не трогает.
- `configs/kitty/` и `configs/zsh/` — пустые директории, git их не отслеживает.

## 2026-08-13 — starship: читаемый промпт

### Контекст

- В промпте отображался сегмент `admin@homelab (default) in`, похожий на
  `user@host`. На деле это модуль kubernetes: kubectl-контекст `admin@homelab`,
  неймспейс `default`, плюс буквальный хвост ` in ` в format-строке модуля.
- Все символы git_status были заданы zero-width пробелами (U+200B) — статусы
  git в промпте не отображались вообще.
- Во всех модулях `symbol = ""` — иконки отсутствовали, хотя nerd-шрифты
  (Hack Nerd Font, Sauce Code Pro Nerd Font) установлены.

### Изменения (`~/.config/starship.toml`)

- `[kubernetes]`: `disabled = true`; из format убран dangling-суффикс ` in `.
- Восстановлены стандартные nerd-font-иконки starship: `git_branch`,
  `docker_context`, `package`, `golang`, `rust`, `nodejs`, `python`, `java`,
  `kubernetes`.
- `[git_status]`: zero-width пробелы заменены стандартным набором starship
  со счётчиками: conflicted ``, ahead `⇡`, behind `⇣`, diverged `⇕`,
  untracked `?`, stashed ``, modified `!`, staged `+`, renamed `»`,
  deleted `✘`.
- В `format` добавлен `$cmd_duration`; новая секция `[cmd_duration]`
  (`min_time = 2000`, жёлтый стиль) — время выполнения команд дольше 2 секунд.
- Не тронуто: `[username]`/`[hostname]` (скрыты локально), `[directory]`,
  `[character]`, цвета, `[line_break]`.

### Проверка

- `starship prompt` в `~` — чистый промпт без лишних сегментов.
- `starship prompt` в git-репо с изменённым и неотслеживаемым файлом —
  отображаются ветка и статусы `!1?1`.
- `starship module git_status` — `!1?1`, статусы видимые.

### Примечание

Иконки отображаются только при nerd-шрифте в терминале (Tabby: профиль должен
использовать Hack/Sauce Code Pro Nerd Font).
