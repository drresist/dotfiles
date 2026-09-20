# dotfiles

Bootstrap installer + portable configuration files for Linux and macOS.

## What this is
- `install.sh` — **Linker for configs**: idempotently symlinks everything from
  this repo into `$HOME` (existing files are backed up as `*.bak.<timestamp>`).
- `prepare.sh` — **Recommended entry point for a fresh machine**. Auto-detects
  your OS, installs packages and runs the right script.
- `prepare_macos.sh` — Clean macOS-only script (Homebrew).
- `prepare_linux.sh` — Linux-focused script (with some macOS support).
- `common.sh` — Shared logic used by both prepare scripts.
- `shell/` and `configs/`: the actual dotfiles.
- `CHANGELOG.md` — all notable config changes.

**Fresh machine:**
```bash
./prepare.sh
```

**Existing machine, configs only:**
```bash
./install.sh
```

## Optional Omarchy-like macOS desktop

The [macOS desktop bundle](macos/omarchy/README.md) adds AeroSpace, SketchyBar,
JankyBorders, Ghostty and Fish/Starship styling. It is opt-in and has its own
file-level backups and restore command:

```sh
cd macos/omarchy
bash packages.sh
bash install.sh
bash activate.sh
```

Run the desktop installer **after** the root dotfiles linker: both manage
Starship, so running the root linker later replaces the desktop prompt theme.
The desktop installer preserves existing editor settings and unrelated plugins.
Restore instructions and macOS permissions are documented in its README.

## Prerequisites
- For interactive menu: `gum` (install via brew/apt or your pkg manager).
- macOS: Homebrew (script can install it).
- Linux: sudo privileges for package installs; a supported package manager.
- Internet for downloads/clones.

## Quick start
Clone the repo (conventionally to `~/dotfiles` works great; any location is fine).

```bash
git clone <your-fork-or-repo> ~/dotfiles
cd ~/dotfiles
chmod +x prepare.sh

# Recommended (auto-detects OS)
./prepare.sh

# Or call directly
./prepare_macos.sh
./prepare_linux.sh

# CLI examples
./prepare.sh --help
./prepare.sh --configs
./prepare.sh --cli --shell
./prepare.sh --all
```

The installer is idempotent for most things.

## CLI flags (both scripts)
- `--all` : everything
- `--tmux`, `--nvim` : tmux / Neovim (both link their tracked configs)
- `--fonts`, `--lazydocker`, `--k9s`
- `--cli` : fzf, ripgrep, fd, bat, eza, zoxide, tre, herdr
- `--herdr` : herdr (agent multiplexer for AI coding agents)
- `--dev` : gh, delta, docker
- `--shell` : zsh + Oh My Zsh, fish, starship
- `--system` : btop, ncdu
- `--configs` : symlink configs + create ~/.dotfiles pointer
- `--brew` : ensure Homebrew

**Note:** `prepare_macos.sh` does **not** include `--flatpak` (Linux only).

## Configs & portability
`install.sh` (also invoked by `prepare.sh --configs`):
- Symlinks `~/.config/*` (starship, bat, btop, git, atuin, **herdr, tmux, nvim**),
  `~/.gitconfig`, `~/.bash_profile`, `~/.bashrc`, `~/.zshrc`.
- Creates `~/.dotfiles` symlink → your clone. This makes sourcing portable.
- Recreates the generated Neovim theme link
  (`~/.config/nvim/lua/plugins/theme.lua`) when Omarchy state exists — that link
  is per-machine, so it is not tracked.
- Idempotent: correct links are skipped, stale links re-pointed, real files
  backed up as `*.bak.<timestamp>` before linking.

Common aliases (eza + git + docker + k8s + helpers) live in one place:
`configs/eza/aliases.sh`

Aliases shipped by Omarchy (`h`→herdr, `t`→tmux, `n`→nvim, `c`/`cx`/`cy`→agents,
`cd`→zd, `ls`/`lt`→eza, …) are **not copied** here: `shell/.bashrc` loads them
from the installed Omarchy tree through `configs/omarchy/aliases.sh`, so the
system copy stays authoritative. The layer is bash-only (Omarchy writes it in
bash syntax) and is a no-op on machines without Omarchy.

Shell rcs source it via `~/.dotfiles/...` (or set `DOTFILES`).

## Installed / managed items (high level)
- tmux + tracked `configs/tmux/tmux.conf` (Omarchy key layout, prefix C-Space)
- Neovim + LazyVim config tracked in `configs/nvim` (with `lazy-lock.json`)
- herdr + tracked `configs/herdr/config.toml`
- JetBrains Nerd Font
- CLI: fzf, rg, fd, bat, eza, zoxide, tre, herdr
- Dev: gh, git-delta, Docker
- Shells + starship
- System: btop, ncdu
- Flatpak (Linux only, in `prepare_linux.sh`)
- Configs for starship, bat, btop, git, fish, tmux, nvim, herdr, shell aliases

## Project structure
- `install.sh` — idempotent config linker (symlinks + backups)
- `prepare.sh` — OS auto-dispatcher
- `prepare_macos.sh` / `prepare_linux.sh` — OS-specific installers
- `common.sh` — Shared functions (setup_configs delegates to install.sh, download helper, group installers, etc.)
- `configs/` — Configuration files symlinked by the scripts
- `shell/` — Shell rc files
- `server/` — Ansible set for host operations (audit, off-site backups, key
  rotation, docker firewall, cleanup); see `server/README.md`
- `CHANGELOG.md` — history of config changes

## Notes
- Idempotent where possible ("already installed" messages).
- Manual downloads use temp dirs + cleanup.
- Linux package manager detection prefers apt → dnf → yum.
- Review the scripts; they will run commands with sudo when needed.
- Personal customizations belong in your local shell after sourcing the common layer.

Enjoy a consistent, reproducible environment across machines.
