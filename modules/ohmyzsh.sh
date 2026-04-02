#!/usr/bin/env bash
# DESC: Install oh-my-zsh with useful plugins and a theme

set -euo pipefail

OH_MY_ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
CUSTOM_DIR="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"

install_ohmyzsh() {
    if [[ -d "$OH_MY_ZSH_DIR" ]]; then
        echo "oh-my-zsh is already installed at $OH_MY_ZSH_DIR"
        return 0
    fi

    if ! command -v zsh &>/dev/null; then
        echo "ERROR: zsh is required. Run: bash setup.sh zsh" >&2
        exit 1
    fi

    echo "Installing oh-my-zsh..."
    RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "oh-my-zsh installed."
}

install_plugin() {
    local name="$1"
    local repo="$2"
    local dest="$CUSTOM_DIR/plugins/$name"
    if [[ -d "$dest" ]]; then
        echo "Plugin already installed: $name"
    else
        echo "Installing plugin: $name"
        git clone --depth=1 "$repo" "$dest"
    fi
}

install_theme() {
    local name="$1"
    local repo="$2"
    local dest="$CUSTOM_DIR/themes/$name"
    if [[ -d "$dest" ]]; then
        echo "Theme already installed: $name"
    else
        echo "Installing theme: $name"
        git clone --depth=1 "$repo" "$dest"
    fi
}

configure_zshrc() {
    local zshrc="$HOME/.zshrc"
    [[ -f "$zshrc" ]] || cp "$OH_MY_ZSH_DIR/templates/zshrc.zsh-template" "$zshrc"

    # Set theme to powerlevel10k if installed, else agnoster
    if [[ -d "$CUSTOM_DIR/themes/powerlevel10k" ]]; then
        sed -i.bak 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$zshrc"
    else
        sed -i.bak 's|^ZSH_THEME=.*|ZSH_THEME="agnoster"|' "$zshrc"
    fi

    # Enable plugins
    sed -i.bak 's|^plugins=.*|plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)|' "$zshrc"

    rm -f "${zshrc}.bak"
    echo ".zshrc configured."
}

install_ohmyzsh
install_plugin "zsh-autosuggestions"   "https://github.com/zsh-users/zsh-autosuggestions"
install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
install_theme  "powerlevel10k"          "https://github.com/romkatv/powerlevel10k"
configure_zshrc

echo "Done. Run 'exec zsh' or re-login to apply changes."
