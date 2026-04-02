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

---

## HuggingFace CLI

### 安装

```bash
pip install -U huggingface_hub
```

验证安装：

```bash
huggingface-cli --version
```

---

### 登录

在 [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens) 创建一个 Access Token（建议选 **Read** 权限），然后：

```bash
huggingface-cli login
# 按提示粘贴 token，选择是否写入 git credential
```

Token 会保存到 `~/.cache/huggingface/token`。

如果是在脚本或 CI 中使用，通过环境变量传入，无需交互登录：

```bash
export HF_TOKEN=hf_xxxxxxxxxxxx
```

---

### 下载模型 / 数据集

#### 下载到默认 cache 目录

```bash
# 下载模型（自动缓存到 ~/.cache/huggingface/hub）
huggingface-cli download meta-llama/Llama-3.2-1B

# 下载数据集
huggingface-cli download --repo-type dataset wikitext wikitext-103-v1
```

#### 下载到指定目录（当前文件夹或自定义路径）

使用 `--local-dir` 参数，文件直接保存到该目录，不经过 cache：

```bash
# 下载到当前目录
huggingface-cli download meta-llama/Llama-3.2-1B --local-dir .

# 下载到指定路径
huggingface-cli download meta-llama/Llama-3.2-1B --local-dir /data/models/llama3
```

> `--local-dir` 模式下文件直接落盘，不会在 `~/.cache` 中创建副本，适合服务器上大模型的管理。

#### 只下载特定文件

```bash
# 只下载 config 和 tokenizer
huggingface-cli download meta-llama/Llama-3.2-1B \
    --include "config.json" "tokenizer*" \
    --local-dir /data/models/llama3

# 排除大文件（如 safetensors 权重）
huggingface-cli download meta-llama/Llama-3.2-1B \
    --exclude "*.safetensors" \
    --local-dir /data/models/llama3
```

#### 在 Python 中下载到指定目录

```python
from huggingface_hub import snapshot_download, hf_hub_download

# 下载整个仓库到指定目录
snapshot_download(
    repo_id="meta-llama/Llama-3.2-1B",
    local_dir="/data/models/llama3",
)

# 下载单个文件
hf_hub_download(
    repo_id="meta-llama/Llama-3.2-1B",
    filename="config.json",
    local_dir="/data/models/llama3",
)
```

---

### 修改默认 cache 目录

默认 cache 路径为 `~/.cache/huggingface/hub`，在系统盘空间有限时需要迁移到数据盘。

#### 方法一：环境变量（推荐，临时或持久均可）

```bash
export HF_HOME=/data/huggingface          # 主目录，hub/cache 均在此下
export HF_HUB_CACHE=/data/huggingface/hub # 只改 model/dataset cache
```

写入 `~/.zshrc` 或 `~/.bashrc` 使其永久生效：

```bash
echo 'export HF_HOME=/data/huggingface' >> ~/.zshrc
source ~/.zshrc
```

#### 方法二：迁移已有 cache 并建软链接

```bash
# 1. 移动现有 cache 到新位置
mv ~/.cache/huggingface /data/huggingface

# 2. 建软链接，对旧路径透明兼容
ln -s /data/huggingface ~/.cache/huggingface
```

#### 目录结构说明

| 环境变量 | 默认值 | 说明 |
|---|---|---|
| `HF_HOME` | `~/.cache/huggingface` | HuggingFace 所有数据的根目录 |
| `HF_HUB_CACHE` | `$HF_HOME/hub` | 模型和数据集的 cache |
| `HF_ASSETS_CACHE` | `$HF_HOME/assets` | tokenizer 等衍生资产的 cache |
| `HF_TOKEN` | — | 登录 token（替代交互式登录） |

> 以上环境变量在 `transformers`、`diffusers`、`datasets` 等库中同样生效，无需额外配置。

---

## Adding a New Module

Create a file `modules/<name>.sh`:

```bash
#!/usr/bin/env bash
# DESC: One-line description shown in --list

set -euo pipefail

# your setup logic here
```

The `# DESC:` comment is displayed by `--list`.
