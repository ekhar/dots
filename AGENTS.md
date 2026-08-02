# Dotfiles repository

Personal configuration managed with GNU Stow. macOS is primary; zsh and tmux also support Arch Linux and Ubuntu.

## Rules

- Work in a separate Git worktree for substantive changes.
- Never commit credentials, authentication state, sessions, caches, logs, or downloaded plugins.
- Preserve safe defaults. Permission and sandbox bypasses must remain explicit opt-ins.
- Keep one canonical copy of every configuration.
- Do not modify live configuration until changes pass dry-run validation.

## Commands

```bash
./install.sh --dry-run
./install.sh --skip-packages
stow --no-folding --simulate --target "$HOME" zsh tmux git nvim opencode pi ghostty
scripts/dots-doctor
```

## Packages

- `zsh`: shell, prompt, and local workflow functions
- `tmux`: default entry point, XDG configuration, platform overrides, and TPM declarations
- `nvim`: LazyVim configuration and lockfile
- `ghostty`: macOS terminal key handling
- `opencode`, `pi`: stable linked settings and themes
- `agent-config`: curated Pi and Codex templates copied into mutable runtime directories
- `git`: Git defaults and global ignores

The installer backs up conflicting live files before applying links. TPM performs plugin installation after tmux configuration has been linked.
