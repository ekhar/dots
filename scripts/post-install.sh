#!/usr/bin/env bash

# Post-installation tasks. The parent installer enables strict mode.

set_default_shell() {
    local zsh_path
    zsh_path=$(command -v zsh || true)

    if [[ -z "$zsh_path" ]]; then
        log_error "Zsh not found in PATH"
        return 1
    fi

    if [[ "$SHELL" == */zsh ]]; then
        log_success "Zsh is already the default shell"
        return 0
    fi

    if ! grep -Fxq "$zsh_path" /etc/shells; then
        log_info "Adding $zsh_path to /etc/shells..."
        printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    log_info "Setting zsh as the default shell..."
    chsh -s "$zsh_path"
}

stow_packages() {
    local packages=(zsh tmux git nvim opencode pi)
    [[ "$OS" == macos ]] && packages+=(ghostty)
    [[ "$OS" == arch && -d "$DOTFILES_DIR/arch" ]] && packages+=(arch)
    printf '%s\n' "${packages[@]}"
}

install_agent_configs() {
    mkdir -p "$HOME/.pi/agent" "$HOME/.codex"
    install -m 600 "$DOTFILES_DIR/agent-config/pi-settings.json" "$HOME/.pi/agent/settings.json"
    install -m 600 "$DOTFILES_DIR/agent-config/codex-config.toml" "$HOME/.codex/config.toml"
    log_success "Mutable agent settings installed from curated templates"
}

run_stow() {
    local package
    cd "$DOTFILES_DIR" || return 1

    while IFS= read -r package; do
        [[ -d "$DOTFILES_DIR/$package" ]] || continue
        log_info "Stowing $package..."
        stow --restow --no-folding --target "$HOME" "$package"
    done < <(stow_packages)

    log_success "Dotfile links created"
}

is_managed_link() {
    local path="$1"
    local resolved
    [[ -L "$path" ]] || return 1
    resolved=$(realpath "$path" 2>/dev/null || true)
    [[ "$resolved" == "$DOTFILES_DIR"/* ]]
}

backup_path() {
    local relative="$1"
    local backup_dir="$2"
    local target="$HOME/$relative"

    [[ -e "$target" || -L "$target" ]] || return 0

    # Stow can safely recreate links that already point into this repository.
    if is_managed_link "$target"; then
        rm "$target"
        return 0
    fi

    mkdir -p "$backup_dir/$(dirname "$relative")"
    mv "$target" "$backup_dir/$relative"
    log_info "Backed up ~/$relative"
}

backup_mutable_config() {
    local relative="$1"
    local template="$2"
    local backup_dir="$3"
    local target="$HOME/$relative"

    if [[ -f "$target" ]] && cmp -s "$target" "$DOTFILES_DIR/$template"; then
        return 0
    fi
    backup_path "$relative" "$backup_dir"
}

prepare_directory() {
    local relative="$1"
    local marker="$2"
    local backup_dir="$3"
    local target="$HOME/$relative"

    [[ -e "$target" || -L "$target" ]] || return 0
    if [[ -d "$target" && ! -L "$target" ]] && is_managed_link "$target/$marker"; then
        return 0
    fi
    backup_path "$relative" "$backup_dir"
}

prepare_existing_configs() {
    local backup_dir
    backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    local paths=(
        .zshrc
        .zprofile
        .p10k.zsh
        .tmux.conf
        .gitconfig
        .gitignore_global
        .config/opencode/opencode.json
        .config/opencode/tui.json
        .pi/agent/themes/github-dark-default.json
    )

    if [[ "$OS" == macos ]]; then
        paths+=("Library/Application Support/com.mitchellh.ghostty/config")
    fi

    prepare_directory .config/tmux tmux.conf "$backup_dir"
    prepare_directory .config/nvim init.lua "$backup_dir"
    backup_mutable_config .pi/agent/settings.json agent-config/pi-settings.json "$backup_dir"
    backup_mutable_config .codex/config.toml agent-config/codex-config.toml "$backup_dir"

    local relative
    for relative in "${paths[@]}"; do
        backup_path "$relative" "$backup_dir"
    done

    # Remove an empty backup directory when nothing needed migration.
    rmdir "$backup_dir" 2>/dev/null || true
}

post_install() {
    prepare_existing_configs
    run_stow
    install_agent_configs
    set_default_shell

    log_info "Authenticate Pi, OpenCode, and Codex separately; credentials are never stored in this repository."
}
