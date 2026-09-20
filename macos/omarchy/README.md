# Omarchy-like macOS — исправленный комплект

Тайлинг AeroSpace, панель SketchyBar, рамки JankyBorders, тема Catppuccin Mocha
для Ghostty и Starship. Ориентир — Apple Silicon и macOS Sonoma 14.
Homebrew устанавливает актуальные версии; их требования к macOS могут меняться.

## Установка

Из каталога комплекта выполните в Fish, Bash или Zsh:

```sh
bash packages.sh
bash install.sh
bash activate.sh
```

`packages.sh` ставит приложения, Fish, Starship и шрифт через Homebrew.
`install.sh` требует Python 3.9+ (подходит Python из Command Line Tools),
копирует только файлы конфигов, создаёт резервную копию и печатает команду отката.
Он не запускает приложения. Неизменённые файлы при повторном запуске пропускаются.

`activate.sh` запускает AeroSpace, проверяет результат `reload-config` и запускает
панель/рамки. При отказе загрузить конфиг возвращается ошибка, а не сообщение об успехе.
На первом запуске разрешите AeroSpace доступ в **Privacy & Security → Accessibility**,
затем повторите `bash activate.sh`. Глобальная клавиша Ghostty также может потребовать
разрешения Accessibility. Ghostty перезапустите или перезагрузите его конфиг.

Если SketchyBar или borders уже работают, стартовый скрипт сообщает об этом и
не запускает дубликат. Для перехода с Homebrew services сначала остановите именно
эти сервисы (`brew services stop sketchybar`, `brew services stop borders`),
затем повторите активацию. Если процессы запускались вручную, завершите их обычным
способом перед повторной активацией.

AeroSpace запускается при входе в систему; его `after-startup-command` запускает
панель и рамки. Они не регистрируются как отдельные Homebrew services. Логи лежат
в `${XDG_CONFIG_HOME:-$HOME/.config}/omarchy-macos/logs/`.

## Расположение и сохранность конфигов

- Поддерживается абсолютный `XDG_CONFIG_HOME`, в том числе путь с пробелами.
  Экспортируйте его перед `install.sh` и `activate.sh` и используйте то же значение
  для Fish. Плагины панели находят свой каталог относительно самого файла панели.
- AeroSpace устанавливается в `~/.aerospace.toml`. Другие стандартные файлы
  `aerospace/aerospace.toml` перемещаются в бэкап, чтобы избежать ошибки неоднозначности.
- Ghostty получает настройки в `~/Library/Application Support/com.mitchellh.ghostty/config`.
  Старые нативные `config` и `config.ghostty` сохраняются; второй заменяется пустым
  комментарием. Это убирает конфликт с поздно загружаемыми нативными настройками.
  XDG-конфиги Ghostty остаются на месте; их несовпадающие параметры продолжают действовать.
- Пользовательские плагины SketchyBar и `fish/config.fish` сохраняются на месте.
  Заменяемые отдельные файлы и ссылки сохраняются в бэкапе. Каталоги целиком не удаляются.
- Fish не заменяет заданные EDITOR/VISUAL. Neovim выбирается только если он установлен.
  Системная оболочка не меняется; Ghostty автоматически определяет свою оболочку.
  Если нужна Fish, запустите `fish` в терминале или отдельно настройте login shell.

## Клавиши

| Клавиши | Действие |
|---|---|
| Option + Enter | Открыть Ghostty |
| Option + H/J/K/L | Фокус влево/вниз/вверх/вправо |
| Option + Shift + H/J/K/L | Переместить окно |
| Option + 1…9 | Рабочее пространство |
| Option + Shift + 1…9 | Отправить окно на рабочее пространство |
| Option + / | Горизонтальный/вертикальный тайлинг |
| Option + , | Accordion layout |
| Option + F | Полноэкранный режим AeroSpace |
| Option + Shift + Space | Floating/tiling |
| Option + Shift + R | Перечитать конфиг |
| Option + Shift + ; | Service mode: Esc — выход, R — flatten, F — floating |
| Command + ` | Выпадающий терминал Ghostty |

Стандартное меню macOS можно скрыть: **Control Center → Automatically hide and show
the menu bar → Always**. Если позже отключите SketchyBar, уменьшите `outer.top = 38`
в AeroSpace. Настройки Mission Control автоматически не меняются.

## Восстановление

Завершите AeroSpace, SketchyBar и borders, затем выполните напечатанную установщиком
команду, например:

```sh
bash install.sh --restore "/полный/путь/omarchy-macos-backups/install-XXXX/receipt.json"
```

Восстановление возвращает прежние файлы и симлинки, убирает добавленные файлы
из активных расположений. Текущие версии сохраняются рядом с бэкапом под именами
`after-N` — последующие ручные правки не теряются. Пустые созданные каталоги могут
остаться. Приложения не удаляются. Для нескольких установок откатывайтесь от новой
к старой; скрипт проверяет порядок. Бэкапы не редактируйте вручную.

Настройки приложений вне файлов (например разрешения Accessibility и регистрация
AeroSpace для входа в систему) откат не меняет. Их можно изменить в System Settings.

## Проверка без установки в настоящий домашний каталог

```sh
python3 -m unittest discover -s tests -v
```

Тесты используют временные каталоги: восстановление прежних файлов, сохранность
плагинов, ссылки на dotfiles, повторная установка, порядок откатов, ручные правки
после установки и автоматический откат при сбое записи.

Документация: [AeroSpace](https://nikitabobko.github.io/AeroSpace/guide),
[Ghostty](https://ghostty.org/docs/config),
[SketchyBar](https://felixkratz.github.io/SketchyBar/setup),
[JankyBorders](https://github.com/FelixKratz/JankyBorders).
