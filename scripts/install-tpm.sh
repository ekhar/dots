#!/usr/bin/env bash

# Install TPM (Tmux Plugin Manager) and plugins

install_tpm() {
    local tpm_dir="$HOME/.config/tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        log_success "TPM already installed"
    else
        log_info "Installing TPM..."
        mkdir -p "$HOME/.config/tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi

    # Install plugins (non-interactive)
    if [[ -x "$tpm_dir/bin/install_plugins" ]]; then
        log_info "Installing tmux plugins..."
        "$tpm_dir/bin/install_plugins"
        log_success "Tmux plugins installed"
    fi
}
