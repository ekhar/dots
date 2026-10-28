# Dotfiles repository

Personal interactive configuration managed with GNU Stow. macOS is primary; zsh and tmux also support Ubuntu.

Nothing here is for agents. Agent shells, PATH, and Codex and Pi settings belong to `ekhar/fleet` (`~/.agents`). On fleet machines the login shell is bash, which agents run; Ghostty and tmux start zsh explicitly, so agents never read these zsh files.

## Rules

- Work in a separate Git worktree for substantive changes.
- Never commit credentials, authentication state, sessions, caches, logs, or downloaded plugins.
- Preserve safe defaults. Permission and sandbox bypasses must remain explicit opt-ins.
- Keep one canonical copy of every configuration.
- Do not modify live configuration until changes pass dry-run validation.
- Keep startup light: no shell framework and no network access.
- Do not set the login shell here; fleet keeps it bash.

## Commands

```bash
./install.sh --dry-run
./install.sh --skip-packages
stow --no-folding --simulate --target "$HOME" zsh tmux git nvim opencode pi ghostty
scripts/dots-doctor
```

## Packages

- `zsh`: environment, login PATH, interactive shell, and starship prompt
- `tmux`: default entry point, XDG configuration, and TPM declarations
- `nvim`: LazyVim configuration and lockfile
- `ghostty`: macOS terminal key handling
- `opencode`, `pi`: stable linked settings and themes
- `git`: Git defaults and global ignores

The installer backs up conflicting live files before linking, then installs TPM plugins.
