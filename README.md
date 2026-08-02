# Dotfiles

A small, reproducible development environment centered on Ghostty, zsh, tmux, Neovim, Pi, OpenCode, and Codex. macOS is the primary target; the shell and tmux packages also support Arch Linux and Ubuntu.

## Principles

- GNU Stow owns configuration links.
- Authentication, sessions, caches, plugins, and generated application state stay local.
- Agent permission bypasses are explicit opt-ins, never defaults.
- Terminal keyboard protocols are preserved from Ghostty through tmux to terminal UIs.
- Startup does not clone repositories or perform other network operations.

## Install

```bash
git clone git@github.com:ekhar/dots.git ~/dots
cd ~/dots
./install.sh --dry-run
./install.sh
```

Useful options:

```text
--skip-packages   only configure installed software
--skip-omz        keep an existing Oh My Zsh installation
--skip-tpm        do not install tmux plugins
--skip-stow       install software without linking configuration
--packages-only   install packages and stop
```

Existing configuration files are moved to a timestamped `~/.dotfiles_backup_*` directory before Stow links are created.

On Ubuntu, the installer installs safe distribution packages and links the configuration, but intentionally does not install an outdated Neovim. Install Neovim 0.11.2 or newer separately. tmux 3.2-3.4 uses its xterm extended-key format; tmux 3.5+ uses CSI-u.

## Packages

| Package | Managed target |
| --- | --- |
| `zsh` | `~/.zshrc`, `~/.zprofile`, `~/.p10k.zsh` |
| `tmux` | `~/.tmux.conf`, `~/.config/tmux/` |
| `nvim` | `~/.config/nvim/` |
| `ghostty` | macOS Ghostty configuration under `~/Library/Application Support/` |
| `opencode` | stable OpenCode and TUI settings |
| `pi` | Pi theme |
| `agent-config` | curated Pi and Codex settings copied into mutable runtime directories |
| `git` | Git configuration and global ignore rules |

Pi and Codex rewrite their settings files with runtime state, so the installer copies curated templates rather than symlinking those files into Git. Log in to Pi, OpenCode, Codex, GitHub, and other services after installation.

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

## Agent commands

Normal agent commands retain their built-in approval and sandbox behavior:

```bash
pi
opencode
codex
```

Permission-bypassing modes must be requested explicitly:

```bash
codex-yolo
claude-yolo
```

Global Pi defaults use medium reasoning; raise the level for difficult tasks rather than paying high-reasoning latency for every request.

## Shell workflow

| Command | Purpose |
| --- | --- |
| `doctor` | Validate links, permissions, commands, syntax, tmux, and obvious secrets |
| `zshbench [runs]` | Profile interactive zsh startup |
| `proj` | Pick and enter a project under `~/code` |
| `tproj` | Pick a project and attach or create its tmux session |
| `gbf` | Pick and switch Git branches |
| `ff` | Pick and edit a file |
| `de` / `da` / `dr` / `ds` | Common direnv operations |

Machine-specific shell settings belong in `~/.zshrc.local` with mode `600`. Use `zsh/.zshrc.local.example` as a template.

## Updating

```bash
cd ~/dots
git pull
./install.sh --skip-packages --skip-omz --skip-tpm
pi update --all
```

Review and commit `nvim/.config/nvim/lazy-lock.json` whenever Neovim plugins change.

## Security

Never commit generated authentication files. In particular:

- `~/.config/stripe/config.toml`
- `~/.config/gh/hosts.yml`
- `~/.pi/agent/auth.json`
- `~/.codex/auth.json`
- API-key `.env` files

If a credential is committed, removing the current file is insufficient. Rotate the credential and purge the path from every published Git ref before force-pushing rewritten history.

After committing or stashing all work and removing extra worktrees, the guarded helper rewrites local refs:

```bash
CONFIRM_HISTORY_REWRITE='.config/stripe/config.toml' \
  scripts/purge-secret-history '.config/stripe/config.toml'
```

`git-filter-repo` may remove the `origin` remote as a safety measure. Verify the rewritten repository and coordinate the required force-push before restoring it.
