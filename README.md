# Dotfiles

Cross-platform dotfiles for zsh and tmux. Supports macOS, Arch Linux, and Ubuntu.

## Features

- **zsh** with Oh-my-zsh, Powerlevel10k, and platform-aware plugins
- **tmux** with TPM, catppuccin theme, session management, and more
- **Automated installer** with OS detection and package management
- **GNU Stow** for symlink management

## Quick Start

```bash
git clone https://github.com/yourusername/dots.git ~/dots
cd ~/dots
./install.sh
```

## What Gets Installed

### Packages

| Tool | macOS | Arch | Ubuntu |
|------|-------|------|--------|
| neovim, tmux, fzf, zoxide, eza, bat, ripgrep | Homebrew | pacman | apt |
| zsh-autosuggestions | Homebrew | pacman | omz plugin |
| zsh-syntax-highlighting | Homebrew | pacman | omz plugin |
| forgit | Homebrew | AUR | omz plugin |
| fnm (Node) | Homebrew | AUR | curl script |
| Nerd Fonts | brew cask | pacman | manual |

### Configurations

- `zsh/` - Shell configuration with platform conditionals
- `tmux/` - Tmux with TPM plugins and catppuccin theme
- `git/` - Git configuration and global gitignore

## Installation Options

```bash
# Full installation
./install.sh

# Preview what would be done
./install.sh --dry-run

# Skip package installation (just symlinks)
./install.sh --skip-packages

# Only install packages
./install.sh --packages-only

# Skip specific components
./install.sh --skip-omz --skip-tpm
```

## Manual Installation

If you prefer to install manually:

```bash
# 1. Install stow
# macOS:  brew install stow
# Arch:   sudo pacman -S stow
# Ubuntu: sudo apt install stow

# 2. Clone and stow
git clone https://github.com/yourusername/dots.git ~/dots
cd ~/dots
stow zsh tmux git
```

## Structure

```
~/dots/
├── install.sh              # Main installer
├── scripts/                # Installation scripts
│   ├── lib/               # Shared functions
│   ├── install-omz.sh     # Oh-my-zsh setup
│   ├── install-tpm.sh     # TPM setup
│   └── post-install.sh    # Stow and shell setup
├── zsh/                    # Stow package
│   ├── .zshrc
│   └── .p10k.zsh
├── tmux/                   # Stow package
│   └── .config/tmux/
│       ├── tmux.conf
│       ├── tmux.macos.conf
│       ├── tmux.linux.conf
│       └── scripts/
└── git/                    # Stow package
    ├── .gitconfig
    └── .gitignore_global
```

## Platform-Specific Notes

### macOS

- Calendar integration in tmux status bar (requires `icalBuddy`)
- Homebrew paths auto-detected (ARM and Intel)

### Arch Linux

- AUR packages require `yay` or `paru`
- Window manager configs can be added to `arch/` stow package

### Ubuntu

- Some packages installed via alternative methods (eza, fnm)
- Zsh plugins installed via oh-my-zsh custom plugins

## Customization

### Local Overrides

Create these files for machine-specific settings (not tracked in git):

- `~/.zshrc.local` - Additional zsh configuration
- `~/.gitconfig.local` - Git user settings
- `~/.env` - Environment variables

### Adding New Stow Packages

```bash
mkdir -p ~/dots/newpackage/.config/newpackage
# Add your config files
cd ~/dots && stow newpackage
```

## Updating

```bash
cd ~/dots
git pull
stow --restow zsh tmux git
```

## Tmux Key Bindings

Prefix: `Ctrl+J`

| Key | Action |
|-----|--------|
| `H`/`L` | Previous/next window |
| `h`/`j`/`k`/`l` | Navigate panes |
| `s` | Split horizontal |
| `v` | Split vertical |
| `o` | Session picker (sessionx) |
| `p` | Floating pane (floax) |
| `z` | Zoom pane |
| `R` | Reload config |
