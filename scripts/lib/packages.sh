#!/usr/bin/env bash

# Common packages needed on all platforms
COMMON_PACKAGES=(
    git
    curl
    wget
    neovim
    tmux
    fzf
    zoxide
    eza
    bat
    ripgrep
    fd
    stow
    jq
    direnv
)

# macOS-specific packages (via Homebrew)
MACOS_PACKAGES=(
    zsh-autosuggestions
    zsh-syntax-highlighting
    forgit
    fnm
    icalbuddy
    tmuxinator
)

# Arch Linux packages (via pacman)
ARCH_PACKAGES=(
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    ttf-meslo-nerd
)

# Arch AUR packages
ARCH_AUR_PACKAGES=(
    fnm-bin
    forgit
)

install_homebrew() {
    if ! command_exists brew; then
        log_error "Homebrew is required. Review and install it from https://brew.sh, then rerun this installer."
        return 1
    fi
    log_success "Homebrew already installed"
}

install_macos_packages() {
    install_homebrew

    log_info "Installing packages via Homebrew..."
    brew install "${COMMON_PACKAGES[@]}" "${MACOS_PACKAGES[@]}"

    log_info "Installing desktop tools..."
    brew install --cask font-meslo-lg-nerd-font ghostty
}

install_arch_packages() {
    log_info "Installing packages via pacman..."
    sudo pacman -Syu --needed --noconfirm "${COMMON_PACKAGES[@]}" "${ARCH_PACKAGES[@]}"

    # AUR packages (prefer yay, fallback to paru)
    if command_exists yay; then
        log_info "Installing AUR packages via yay..."
        yay -S --needed --noconfirm "${ARCH_AUR_PACKAGES[@]}"
    elif command_exists paru; then
        log_info "Installing AUR packages via paru..."
        paru -S --needed --noconfirm "${ARCH_AUR_PACKAGES[@]}"
    else
        log_warn "No AUR helper found. Please install yay or paru, then install: ${ARCH_AUR_PACKAGES[*]}"
    fi
}

install_ubuntu_packages() {
    log_info "Updating apt..."
    sudo apt update

    log_info "Installing Ubuntu packages..."
    sudo apt install -y git curl wget tmux fzf ripgrep stow jq zsh bat fd-find direnv

    # Ubuntu names these executables differently.
    mkdir -p "$HOME/.local/bin"
    command_exists batcat && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    command_exists fdfind && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"

    # eza (modern ls replacement)
    if ! command_exists eza; then
        log_info "Installing eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
        sudo apt update && sudo apt install -y eza
    fi

    # Do not execute remote installer scripts implicitly.
    command_exists zoxide || log_warn "Install zoxide from https://github.com/ajeetdsouza/zoxide."
    command_exists fnm || log_warn "Install fnm from https://github.com/Schniz/fnm."
    command_exists nvim || log_warn "LazyVim requires Neovim 0.11.2+. Ubuntu's package is too old; install a current release from https://neovim.io."

    # Install Nerd Font
    log_info "Installing Meslo Nerd Font..."
    mkdir -p ~/.local/share/fonts
    for style in Regular Bold Italic "Bold Italic"; do
        local filename="MesloLGS NF ${style}.ttf"
        local url_name="${filename// /%20}"
        if [[ ! -f "$HOME/.local/share/fonts/$filename" ]]; then
            curl -fLo "$HOME/.local/share/fonts/$filename" \
                "https://github.com/romkatv/powerlevel10k-media/raw/master/$url_name" 2>/dev/null || true
        fi
    done
    fc-cache -f -v >/dev/null 2>&1 || true
}

install_packages() {
    case "$OS" in
        macos)
            install_macos_packages
            ;;
        arch)
            install_arch_packages
            ;;
        ubuntu)
            install_ubuntu_packages
            ;;
        *)
            log_error "Unsupported OS: $OS"
            return 1
            ;;
    esac
    log_success "Package installation complete"
}
