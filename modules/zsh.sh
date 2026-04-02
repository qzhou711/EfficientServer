#!/usr/bin/env bash
# DESC: Install zsh and set it as the default shell

set -euo pipefail

install_zsh() {
    if command -v zsh &>/dev/null; then
        echo "zsh is already installed: $(zsh --version)"
        return 0
    fi

    echo "Installing zsh..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y zsh
    elif command -v yum &>/dev/null; then
        sudo yum install -y zsh
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y zsh
    elif command -v brew &>/dev/null; then
        brew install zsh
    else
        echo "ERROR: No supported package manager found (apt/yum/dnf/brew)" >&2
        exit 1
    fi
    echo "zsh installed: $(zsh --version)"
}

set_default_shell() {
    local zsh_path
    zsh_path=$(command -v zsh)

    if [[ "$SHELL" == "$zsh_path" ]]; then
        echo "zsh is already the default shell."
        return 0
    fi

    # Ensure zsh is in /etc/shells
    if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    echo "Setting zsh as default shell for $USER..."
    sudo chsh -s "$zsh_path" "$USER"
    echo "Default shell set to $zsh_path (re-login to take effect)"
}

install_zsh
set_default_shell
