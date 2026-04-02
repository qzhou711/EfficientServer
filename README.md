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

## Adding a New Module

Create a file `modules/<name>.sh`:

```bash
#!/usr/bin/env bash
# DESC: One-line description shown in --list

set -euo pipefail

# your setup logic here
```

The `# DESC:` comment is displayed by `--list`.
