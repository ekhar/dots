# Dotfiles

My interactive environment: Ghostty, zsh, tmux, Neovim, Git, and the OpenCode and Pi themes. macOS is primary; zsh and tmux also work on Ubuntu.

Nothing here is for agents. Agent shells and settings live in my private fleet repository, which keeps the login shell bash because Claude Code and Codex run it. Ghostty (`command = /bin/zsh -l`) and tmux (`default-shell`) start zsh explicitly, so agents never read these zsh files. On a machine whose login shell is zsh, everything works the same.

## Principles

- GNU Stow owns configuration links.
- Light: no framework, and an interactive shell starts in about 50 ms.
- Authentication, sessions, caches, and plugin installs stay local.
- Agent permission bypasses are explicit opt-ins, never defaults.
- Startup does no network access.

## Install

```bash
git clone git@github.com:ekhar/dots.git ~/dots
cd ~/dots
./install.sh --dry-run
./install.sh                 # or --skip-packages to only link
```

Conflicting live files move to a timestamped `~/.dotfiles_backup_*` directory before linking. On Ubuntu, install starship, fnm, and Neovim 0.11.2+ separately; apt lacks them or ships an old version.

## Packages

| Package | Managed target |
| --- | --- |
| `zsh` | `~/.zshenv`, `~/.zprofile`, `~/.zshrc`, `~/.config/starship.toml` |
| `tmux` | `~/.tmux.conf`, `~/.config/tmux/` |
| `nvim` | `~/.config/nvim/` |
| `ghostty` | Ghostty configuration under `~/Library/Application Support/` (macOS) |
| `opencode` | OpenCode and TUI settings |
| `pi` | Pi theme |
| `git` | Git configuration and global ignore rules |

## zsh

No Oh My Zsh. `.zshrc` sets history, completion (cache rebuilt at most daily), vi keys with the usual insert-mode Emacs keys, and prefix history search on the arrows, then loads fzf, zoxide, fnm, direnv, starship, autosuggestions, and syntax highlighting. Machine-specific settings go in `~/.zshrc.local` (mode `600`), loaded last; see `zsh/.zshrc.local.example`.

## Terminal keyboard handling

Ghostty reports modified keys directly. Do not map Shift+Enter to a raw newline. tmux 3.5 or newer forwards modified keys using CSI-u:

```tmux
set -g extended-keys on
set -g extended-keys-format csi-u
```

This keeps Shift+Enter, Alt+Enter, Ctrl+Enter, and Alt+Backspace distinct inside Pi and other terminal applications.

## tmux

Prefix: `Ctrl+J`

| Key | Action |
| --- | --- |
| `H` / `L` | Previous / next window |
| `h` / `j` / `k` / `l` | Navigate panes |
| `s` / `v` | Split in the current directory |
| `o` | Session picker |
| `p` | Floating pane |
| `z` | Zoom pane |
| `R` | Reload configuration |
| `X` | Kill pane |

TPM plugins are installed by `install.sh`, not while tmux is starting.

## Neovim

The active editor is a focused LazyVim setup. Snacks provides both picking and file exploration, and language extras configure TypeScript, Rust, Docker, JSON, Markdown, SQL, and YAML tooling.

```bash
nvim --headless '+Lazy! sync' +qa
nvim --headless '+checkhealth' +qa
```

The lockfile is committed for reproducible plugin installs. Mason packages and editor state remain under `~/.local` and are not tracked.

## Commands

| Command | Purpose |
| --- | --- |
| `doctor` | Check links, commands, syntax, startup time, tmux, obvious secrets, and uncommitted drift |
| `zshbench [runs]` | Profile interactive zsh startup |
| `codex-yolo`, `claude-yolo` | Permission-bypassing agent modes, only when asked for explicitly |

Installers sometimes append PATH lines to `~/.zshrc` or `~/.zprofile`, which are links into this repository. `doctor` reports them as uncommitted changes; delete them, since `.zshrc` already puts `~/.local/bin` on PATH.

## Updating

```bash
cd ~/dots
git pull
./install.sh --skip-packages
```

Review and commit `nvim/.config/nvim/lazy-lock.json` whenever Neovim plugins change.

## Security

Never commit authentication files (`~/.config/gh/hosts.yml`, `~/.codex/auth.json`, `~/.pi/agent/auth.json`, `.env` files). If a credential is committed, rotate it, then purge the path from every published ref with `git filter-repo` and force-push.
