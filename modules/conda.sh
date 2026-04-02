#!/usr/bin/env bash
# DESC: Install Miniconda and configure package cache / envs directories

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
CONDA_INSTALL_DIR="${CONDA_INSTALL_DIR:-$HOME/miniconda3}"
# Override these env vars to redirect cache / envs to a different disk/path:
#   CONDA_PKGS_DIR   — where downloaded package tarballs are cached
#   CONDA_ENVS_DIR   — where conda environments are stored
CONDA_PKGS_DIR="${CONDA_PKGS_DIR:-}"
CONDA_ENVS_DIR="${CONDA_ENVS_DIR:-}"
# ─────────────────────────────────────────────────────────────────────────────

detect_installer_url() {
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os" in
        Linux)
            case "$arch" in
                x86_64)  echo "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" ;;
                aarch64) echo "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh" ;;
                *)       echo "ERROR: Unsupported Linux arch: $arch" >&2; exit 1 ;;
            esac ;;
        Darwin)
            case "$arch" in
                x86_64)  echo "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh" ;;
                arm64)   echo "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh" ;;
                *)       echo "ERROR: Unsupported macOS arch: $arch" >&2; exit 1 ;;
            esac ;;
        *)  echo "ERROR: Unsupported OS: $os" >&2; exit 1 ;;
    esac
}

install_conda() {
    if [[ -x "$CONDA_INSTALL_DIR/bin/conda" ]]; then
        echo "Miniconda already installed at $CONDA_INSTALL_DIR"
        echo "Version: $("$CONDA_INSTALL_DIR/bin/conda" --version)"
        return 0
    fi

    local url
    url="$(detect_installer_url)"
    local installer="/tmp/miniconda_installer.sh"

    echo "Downloading Miniconda installer..."
    curl -fsSL "$url" -o "$installer"
    chmod +x "$installer"

    echo "Installing Miniconda to $CONDA_INSTALL_DIR ..."
    bash "$installer" -b -p "$CONDA_INSTALL_DIR"
    rm -f "$installer"

    echo "Miniconda installed: $("$CONDA_INSTALL_DIR/bin/conda" --version)"
}

init_shell() {
    local conda_bin="$CONDA_INSTALL_DIR/bin/conda"
    local shell_name
    shell_name="$(basename "${SHELL:-bash}")"

    # Check if already initialised
    local rc_file
    case "$shell_name" in
        zsh)  rc_file="$HOME/.zshrc" ;;
        bash) rc_file="$HOME/.bashrc" ;;
        *)    rc_file="$HOME/.bashrc" ;;
    esac

    if grep -q "conda initialize" "$rc_file" 2>/dev/null; then
        echo "conda shell init already present in $rc_file"
        return 0
    fi

    echo "Initialising conda for $shell_name ..."
    "$conda_bin" init "$shell_name"
    echo "Shell init added to $rc_file"
}

configure_condarc() {
    local conda_bin="$CONDA_INSTALL_DIR/bin/conda"
    local condarc="$HOME/.condarc"
    local changed=0

    # ── Package cache directory ──────────────────────────────────────────────
    if [[ -n "$CONDA_PKGS_DIR" ]]; then
        mkdir -p "$CONDA_PKGS_DIR"
        echo "Setting package cache dir: $CONDA_PKGS_DIR"
        "$conda_bin" config --set pkgs_dirs "$CONDA_PKGS_DIR"
        changed=1
    fi

    # ── Environments directory ───────────────────────────────────────────────
    if [[ -n "$CONDA_ENVS_DIR" ]]; then
        mkdir -p "$CONDA_ENVS_DIR"
        echo "Setting envs dir: $CONDA_ENVS_DIR"
        "$conda_bin" config --add envs_dirs "$CONDA_ENVS_DIR"
        changed=1
    fi

    # ── Sensible defaults ────────────────────────────────────────────────────
    "$conda_bin" config --set auto_activate_base false   # don't pollute every shell
    "$conda_bin" config --set show_channel_urls true

    if [[ $changed -eq 1 ]]; then
        echo ""
        echo "Current .condarc:"
        cat "$condarc"
    fi
}

install_conda
init_shell
configure_condarc

echo ""
echo "Done. Re-login (or 'source ~/.zshrc') then run: conda activate"
echo ""
echo "Tip — to customise cache/envs paths, re-run with env vars:"
echo "  CONDA_PKGS_DIR=/data/conda/pkgs CONDA_ENVS_DIR=/data/conda/envs bash setup.sh conda"
