#!/usr/bin/env bash
set -euo pipefail

# Cross-platform dotfiles installer
# Supports: macOS, Arch Linux, Ubuntu

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# Source library functions
source "$DOTFILES_DIR/scripts/lib/utils.sh"
source "$DOTFILES_DIR/scripts/lib/detect.sh"
source "$DOTFILES_DIR/scripts/lib/packages.sh"
source "$DOTFILES_DIR/scripts/install-omz.sh"
source "$DOTFILES_DIR/scripts/install-tpm.sh"
source "$DOTFILES_DIR/scripts/post-install.sh"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Cross-platform dotfiles installer

Options:
    -h, --help          Show this help message
    -n, --dry-run       Show what would be done without making changes
    --skip-packages     Skip package installation
    --skip-omz          Skip Oh-my-zsh installation
    --skip-tpm          Skip TPM installation
    --skip-stow         Skip stow (symlink creation)
    --packages-only     Only install packages, skip everything else

Examples:
    $(basename "$0")                    # Full installation
    $(basename "$0") --skip-packages    # Skip package installation
    $(basename "$0") --dry-run          # Preview changes
EOF
}

# Default options
DRY_RUN=false
SKIP_PACKAGES=false
SKIP_OMZ=false
SKIP_TPM=false
SKIP_STOW=false
PACKAGES_ONLY=false

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-packages)
                SKIP_PACKAGES=true
                shift
                ;;
            --skip-omz)
                SKIP_OMZ=true
                shift
                ;;
            --skip-tpm)
                SKIP_TPM=true
                shift
                ;;
            --skip-stow)
                SKIP_STOW=true
                shift
                ;;
            --packages-only)
                PACKAGES_ONLY=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

validate_configuration() {
    /bin/bash -n "$DOTFILES_DIR/install.sh"
    find "$DOTFILES_DIR/scripts" -type f -exec /bin/bash -n {} +
    /bin/zsh -n "$DOTFILES_DIR/zsh/.zshrc" "$DOTFILES_DIR/zsh/.zprofile"

    if command_exists stow; then
        local target
        local package
        target=$(mktemp -d)
        while IFS= read -r package; do
            [[ -d "$DOTFILES_DIR/$package" ]] || continue
            stow --simulate --no-folding --target "$target" --dir "$DOTFILES_DIR" "$package"
        done < <(stow_packages)
        rm -rf "$target"
    else
        log_warn "Stow is not installed, so link simulation was skipped"
    fi

    log_success "Configuration syntax and package layout validated"
}

dry_run_info() {
    echo ""
    log_info "=== DRY RUN MODE ==="
    log_info "Would perform the following actions:"
    echo ""
    log_info "1. Detect system: $OS on $ARCH"
    [[ "$SKIP_PACKAGES" != "true" ]] && log_info "2. Install packages via ${OS} package manager"
    [[ "$SKIP_OMZ" != "true" ]] && log_info "3. Install Oh-my-zsh and Powerlevel10k"
    [[ "$SKIP_STOW" != "true" ]] && log_info "4. Link shell, terminal, editor, Git, and agent configs with Stow"
    [[ "$SKIP_TPM" != "true" ]] && log_info "5. Install TPM and tmux plugins"
    log_info "6. Set zsh as default shell"
    echo ""
    validate_configuration
    log_info "Conflicting live files will be moved to a timestamped ~/.dotfiles_backup_* directory."
    log_info "Run without --dry-run to execute"
}

main() {
    echo ""
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║     Cross-Platform Dotfiles Setup    ║"
    echo "  ╚══════════════════════════════════════╝"
    echo ""

    parse_args "$@"

    # Detect system
    detect_system

    if [[ "$DRY_RUN" == "true" ]]; then
        dry_run_info
        exit 0
    fi

    # Packages only mode
    if [[ "$PACKAGES_ONLY" == "true" ]]; then
        install_packages
        log_success "Package installation complete!"
        exit 0
    fi

    # Full installation
    [[ "$SKIP_PACKAGES" != "true" ]] && install_packages
    [[ "$SKIP_OMZ" != "true" ]] && install_omz
    [[ "$SKIP_STOW" != "true" ]] && post_install
    [[ "$SKIP_TPM" != "true" ]] && install_tpm

    echo ""
    log_success "Installation complete!"
    echo ""
    log_info "Next steps:"
    log_info "  1. Restart your terminal (or run: exec zsh)"
    log_info "  2. Powerlevel10k will prompt for configuration on first run"
    log_info "  3. In tmux, press prefix + I to install plugins (if not auto-installed)"
    echo ""
}

main "$@"
