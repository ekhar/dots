#!/usr/bin/env bash

# Install Oh-my-zsh and Powerlevel10k

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh-my-zsh already installed"
        return 0
    fi

    log_info "Installing Oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

install_powerlevel10k() {
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

    if [[ -d "$p10k_dir" ]]; then
        log_success "Powerlevel10k already installed"
        return 0
    fi

    log_info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
}

install_zsh_plugins() {
    local custom_plugins="$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$custom_plugins"

    # Only install these on Linux where they're not available via package manager
    if [[ "$OS" != "macos" ]]; then
        # zsh-autosuggestions
        if [[ ! -d "$custom_plugins/zsh-autosuggestions" ]] && \
           [[ ! -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
            log_info "Installing zsh-autosuggestions..."
            git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_plugins/zsh-autosuggestions"
        fi

        # zsh-syntax-highlighting
        if [[ ! -d "$custom_plugins/zsh-syntax-highlighting" ]] && \
           [[ ! -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
            log_info "Installing zsh-syntax-highlighting..."
            git clone https://github.com/zsh-users/zsh-syntax-highlighting "$custom_plugins/zsh-syntax-highlighting"
        fi

        # forgit
        if [[ ! -d "$custom_plugins/forgit" ]] && \
           [[ ! -f /usr/share/zsh/plugins/forgit/forgit.plugin.zsh ]]; then
            log_info "Installing forgit..."
            git clone https://github.com/wfxr/forgit "$custom_plugins/forgit"
        fi
    fi
}

install_omz() {
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_plugins
    log_success "Oh-my-zsh setup complete"
}
