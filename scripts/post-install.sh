#!/usr/bin/env bash

# Post-installation tasks

set_default_shell() {
    local zsh_path
    zsh_path=$(command -v zsh)

    if [[ "$SHELL" == "$zsh_path" ]]; then
        log_success "Zsh is already default shell"
        return 0
    fi

    if [[ -z "$zsh_path" ]]; then
        log_error "Zsh not found in PATH"
        return 1
    fi

    # Ensure zsh is in /etc/shells
    if ! grep -q "$zsh_path" /etc/shells; then
        log_info "Adding $zsh_path to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    log_info "Setting zsh as default shell..."
    chsh -s "$zsh_path"
    log_success "Default shell set to zsh (restart your terminal)"
}

run_stow() {
    log_info "Running stow to create symlinks..."
    cd "$DOTFILES_DIR" || exit 1

    # Common packages for all platforms
    local packages="zsh tmux git"

    # Platform-specific packages
    if [[ "$OS" == "arch" ]]; then
        # Add arch-specific configs if they exist
        [[ -d "$DOTFILES_DIR/arch" ]] && packages="$packages arch"
    fi

    # Stow each package
    for pkg in $packages; do
        if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
            log_info "Stowing $pkg..."
            stow -v --restow "$pkg" 2>&1 | grep -v "^LINK:" || true
        fi
    done

    log_success "Symlinks created"
}

cleanup_old_symlinks() {
    # Remove old-style symlinks that point to dots/.zshrc or dots/.config/*
    # These conflict with the new package-based stow structure

    local old_symlinks=(".zshrc" ".p10k.zsh" ".gitconfig" ".gitignore_global")

    for file in "${old_symlinks[@]}"; do
        local target="$HOME/$file"
        if [[ -L "$target" ]]; then
            local link_target
            link_target=$(readlink "$target")
            # Check if it points to old dots structure (not package-based)
            if [[ "$link_target" == dots/.* && "$link_target" != dots/*/.*  ]]; then
                log_info "Removing old symlink: $file -> $link_target"
                rm "$target"
            fi
        fi
    done

    # Handle .config/tmux specially - it might be a symlink or directory
    if [[ -L "$HOME/.config/tmux" ]]; then
        log_info "Removing old .config/tmux symlink"
        rm "$HOME/.config/tmux"
    fi
}

backup_existing() {
    local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    local files_to_backup=(".zshrc" ".p10k.zsh" ".config/tmux" ".gitconfig")
    local need_backup=false

    # Check if any real files (not symlinks) need backing up
    for file in "${files_to_backup[@]}"; do
        local target="$HOME/$file"
        if [[ -e "$target" && ! -L "$target" ]]; then
            need_backup=true
            break
        fi
    done

    if [[ "$need_backup" == "true" ]]; then
        log_info "Backing up existing configs to $backup_dir..."
        mkdir -p "$backup_dir"
        for file in "${files_to_backup[@]}"; do
            local target="$HOME/$file"
            if [[ -e "$target" && ! -L "$target" ]]; then
                log_info "Backing up $file"
                mkdir -p "$(dirname "$backup_dir/$file")"
                cp -r "$target" "$backup_dir/$file"
                rm -rf "$target"
            fi
        done
        log_success "Backup complete: $backup_dir"
    fi

    # Clean up old symlinks
    cleanup_old_symlinks
}

post_install() {
    backup_existing
    run_stow
    set_default_shell
}
