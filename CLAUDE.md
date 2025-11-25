# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for cross-platform shell and terminal configuration. Uses GNU Stow for symlink management. Supports macOS, Arch Linux, and Ubuntu.

## Commands

```bash
# Full installation
./install.sh

# Preview changes (dry run)
./install.sh --dry-run

# Skip package installation (just symlinks)
./install.sh --skip-packages

# Only install packages
./install.sh --packages-only

# Re-apply symlinks after changes
cd ~/dots && stow --restow zsh tmux git
```

## Structure

The repository uses GNU Stow packages. Each top-level directory (except `scripts/` and `.config/`) is a stow package that gets symlinked to `$HOME`:

- `zsh/` → `.zshrc`, `.p10k.zsh`
- `tmux/` → `.config/tmux/`
- `git/` → `.gitconfig`, `.gitignore_global`

The `.config/` directory contains additional configurations (nvim, alacritty, kitty, hypr, etc.) that are not managed by stow.

## Key Configuration Details

**Tmux**: Prefix is `Ctrl+J`. Main bindings: `H/L` (prev/next window), `h/j/k/l` (pane navigation), `s/v` (splits), `o` (sessionx picker), `p` (floating pane), `R` (reload config). Uses TPM for plugins with catppuccin theme.

**Zsh**: Uses Oh-my-zsh with Powerlevel10k theme. Key tools: fzf, zoxide, fnm. Custom functions include `proj` (project picker), `ff` (file finder), `gbf` (git branch picker), `mark/jump` (directory bookmarks).

**Neovim**: LazyVim configuration in `.config/nvim/`.

## Architecture

The installer (`install.sh`) sources modular scripts from `scripts/lib/` for utilities, OS detection, and package management. Platform-specific tmux configs exist (`tmux.macos.conf`, `tmux.linux.conf`).

Local overrides (not tracked): `~/.zshrc.local`, `~/.gitconfig.local`, `~/.env`
