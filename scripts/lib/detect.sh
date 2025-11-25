#!/usr/bin/env bash

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin)
            OS="macos"
            ;;
        Linux)
            if [[ -f /etc/arch-release ]]; then
                OS="arch"
            elif [[ -f /etc/debian_version ]]; then
                OS="ubuntu"
            else
                OS="linux"
            fi
            ;;
        *)
            OS="unknown"
            ;;
    esac
    export OS
}

# Detect architecture
detect_arch() {
    case "$(uname -m)" in
        arm64|aarch64)
            ARCH="arm64"
            HOMEBREW_PREFIX="/opt/homebrew"
            ;;
        x86_64)
            ARCH="x86_64"
            HOMEBREW_PREFIX="/usr/local"
            ;;
        *)
            ARCH="unknown"
            HOMEBREW_PREFIX=""
            ;;
    esac
    export ARCH HOMEBREW_PREFIX
}

# Run both detections
detect_system() {
    detect_os
    detect_arch
    log_info "Detected: $OS on $ARCH"
}
