# EfficientServer

Quick server environment setup via modular shell scripts.

## Usage

```bash
git clone <this-repo>
cd EfficientServer

# List available modules
bash setup.sh --list

# Run a specific module
bash setup.sh zsh
bash setup.sh ohmyzsh

# Run multiple modules
bash setup.sh zsh ohmyzsh

# Run all modules
bash setup.sh --all
```

## Modules

| Module | Description |
|--------|-------------|
| `zsh` | Install zsh and set it as the default shell |
| `ohmyzsh` | Install oh-my-zsh with plugins (autosuggestions, syntax-highlighting) and powerlevel10k theme |
| `conda` | Install Miniconda and configure package cache / envs directories |

### conda — custom cache path

By default conda stores package tarballs in `~/.conda/pkgs` and environments in `~/miniconda3/envs`.
On a server with a dedicated data disk you can redirect both:

```bash
CONDA_PKGS_DIR=/data/conda/pkgs \
CONDA_ENVS_DIR=/data/conda/envs \
bash setup.sh conda
```

This writes the following to `~/.condarc`:

```yaml
pkgs_dirs:
  - /data/conda/pkgs
envs_dirs:
  - /data/conda/envs
auto_activate_base: false
show_channel_urls: true
```

You can also edit `~/.condarc` manually at any time, or use `conda config` commands:

```bash
conda config --set pkgs_dirs /new/path/pkgs
conda config --add envs_dirs /new/path/envs
conda config --show                          # view all settings
```

## Adding a New Module

Create a file `modules/<name>.sh`:

```bash
#!/usr/bin/env bash
# DESC: One-line description shown in --list

set -euo pipefail

# your setup logic here
```

The `# DESC:` comment is displayed by `--list`.
