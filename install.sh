#!/usr/bin/env bash
# Install packages and link this repository's configuration into $HOME with Stow.
# macOS (Homebrew) and Ubuntu (apt). Conflicting live files move to a timestamped
# ~/.dotfiles_backup_* directory first. The login shell is left alone: on fleet
# machines it is bash, for agents, and Ghostty and tmux start zsh.
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh tmux git nvim opencode pi)
BREW=(git neovim tmux fzf zoxide eza bat ripgrep fd stow jq direnv fnm starship zsh-autosuggestions zsh-syntax-highlighting)
APT=(git curl zsh tmux fzf zoxide eza bat fd-find ripgrep stow jq direnv zsh-autosuggestions zsh-syntax-highlighting)

usage() {
  cat <<EOF
Usage: install.sh [-n|--dry-run] [--skip-packages]

  -n, --dry-run     validate syntax and simulate links; change nothing
  --skip-packages   only link configuration and install tmux plugins
EOF
}

say() { printf '\033[0;34m==>\033[0m %s\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

dry=false
skip_packages=false
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) dry=true ;;
    --skip-packages) skip_packages=true ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

case "$(uname -s)" in
  Darwin) os=macos; PACKAGES+=(ghostty) ;;
  Linux) [[ -f /etc/debian_version ]] && os=ubuntu || { echo "Unsupported Linux: only Ubuntu" >&2; exit 1; } ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

install_packages() {
  if [[ "$os" == macos ]]; then
    have brew || { echo "Install Homebrew from https://brew.sh first." >&2; exit 1; }
    brew install "${BREW[@]}"
    brew install --cask ghostty
  else
    sudo apt-get update -q
    sudo apt-get install -y -q "${APT[@]}"
    # Ubuntu renames these executables.
    mkdir -p "$HOME/.local/bin"
    have batcat && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    have fdfind && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    # Not in apt, and remote installer scripts are not run implicitly.
    have starship || say "Install starship: https://starship.rs"
    have fnm || say "Install fnm: https://github.com/Schniz/fnm"
    have nvim || say "LazyVim needs Neovim 0.11.2+, newer than Ubuntu's: https://neovim.io"
  fi
}

# Every path a package would link, relative to $HOME.
package_files() {
  (cd "$DOTS/$1" && find . \( -type f -o -type l \) ! -name .gitignore | sed 's|^\./||')
}

# Move a live path out of the way, into the same relative place under $backup.
move_aside() {
  mkdir -p "$backup/$(dirname "$1")"
  mv "$HOME/$1" "$backup/$1"
  say "Backed up ~/$1"
}

# Move live files that are not already links into this repository out of the way.
# A symlinked parent directory (say ~/.config/nvim pointing at another checkout)
# moves as a whole, so its target is never emptied.
backup_conflicts() {
  local backup="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)" package file parent
  for package in "${PACKAGES[@]}"; do
    while IFS= read -r file; do
      parent=$(dirname "$file")
      while [[ "$parent" != . ]]; do
        [[ -L "$HOME/$parent" ]] && move_aside "$parent"
        parent=$(dirname "$parent")
      done
      [[ -e "$HOME/$file" || -L "$HOME/$file" ]] || continue
      [[ "$(realpath "$HOME/$file" 2>/dev/null)" == "$DOTS/$package/$file" ]] && continue
      move_aside "$file"
    done < <(package_files "$package")
  done
  rmdir "$backup" 2>/dev/null || true
}

validate() {
  local file
  for file in "$DOTS/install.sh" "$DOTS"/scripts/*; do bash -n "$file"; done
  if have zsh; then
    for file in "$DOTS"/zsh/.zsh{env,rc} "$DOTS/zsh/.zprofile"; do zsh -n "$file"; done
  fi
  if have stow; then
    local target
    target=$(mktemp -d)
    stow --simulate --no-folding --dir "$DOTS" --target "$target" "${PACKAGES[@]}"
    rm -rf "$target"
  fi
  say "Syntax and package layout are valid"
}

install_tmux_plugins() {
  local tpm="$HOME/.config/tmux/plugins/tpm"
  [[ -d "$tpm" ]] || git clone -q https://github.com/tmux-plugins/tpm "$tpm"
  "$tpm/bin/install_plugins" >/dev/null
}

if $dry; then
  validate
  say "Would link: ${PACKAGES[*]}"
  exit 0
fi

$skip_packages || install_packages
validate
backup_conflicts
say "Linking ${PACKAGES[*]}"
stow --restow --no-folding --dir "$DOTS" --target "$HOME" "${PACKAGES[@]}"
install_tmux_plugins
say "Done. Open a new shell."
