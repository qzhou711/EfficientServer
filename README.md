# EfficientServer

服务器环境快速配置手册。

---

## 目录

- [zsh](#zsh)
- [oh-my-zsh](#oh-my-zsh)
- [Conda](#conda)
- [HuggingFace CLI](#huggingface-cli)

---

## zsh

### 安装

```bash
# Ubuntu / Debian
sudo apt-get update && sudo apt-get install -y zsh

# CentOS / RHEL (yum)
sudo yum install -y zsh

# CentOS / RHEL (dnf)
sudo dnf install -y zsh

# macOS
brew install zsh
```

验证安装：

```bash
zsh --version
```

### 设为默认 shell

```bash
# 确认 zsh 路径
which zsh        # 通常是 /usr/bin/zsh 或 /bin/zsh

# 将 zsh 加入合法 shell 列表（如不在其中）
echo "$(which zsh)" | sudo tee -a /etc/shells

# 切换默认 shell
sudo chsh -s "$(which zsh)" "$USER"
```

重新登录后生效。验证：

```bash
echo $SHELL      # 应输出 /usr/bin/zsh 或 /bin/zsh
```

---

## oh-my-zsh

> 依赖 zsh，请先完成上一步。

### 安装

```bash
RUNZSH=no CHSH=no \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

- `RUNZSH=no` — 安装完不自动切换到 zsh（避免脚本中断）
- `CHSH=no` — 不自动修改默认 shell（手动完成更可控）

### 安装常用插件

```bash
# zsh-autosuggestions：根据历史记录自动建议命令
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting：命令语法高亮
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 安装 powerlevel10k 主题

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 配置 ~/.zshrc

编辑 `~/.zshrc`，找到以下两行并修改：

```bash
# 主题
ZSH_THEME="powerlevel10k/powerlevel10k"

# 插件（用空格分隔）
plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)
```

应用配置：

```bash
source ~/.zshrc
# 首次加载 powerlevel10k 会启动交互式配置向导
```

---

## Conda

### 安装 Miniconda

根据系统选择对应的安装脚本：

| 系统 | 架构 | 下载地址 |
|------|------|----------|
| Linux | x86_64 | `https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh` |
| Linux | aarch64 (ARM) | `https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh` |
| macOS | x86_64 | `https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh` |
| macOS | Apple Silicon | `https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh` |

```bash
# 以 Linux x86_64 为例
curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  -o /tmp/miniconda.sh

# 静默安装到 ~/miniconda3
bash /tmp/miniconda.sh -b -p ~/miniconda3
rm /tmp/miniconda.sh
```

初始化 shell：

```bash
~/miniconda3/bin/conda init zsh    # 或 bash
source ~/.zshrc
```

验证：

```bash
conda --version
```

### 修改默认 cache 目录

conda 默认将 package tarballs 缓存在 `~/.conda/pkgs`，环境存放在 `~/miniconda3/envs`。系统盘空间有限时可以迁移到数据盘。

**方法一：`conda config` 命令（推荐）**

```bash
# 修改 package cache 目录
conda config --set pkgs_dirs /data/conda/pkgs

# 修改 envs 目录
conda config --add envs_dirs /data/conda/envs
```

**方法二：直接编辑 `~/.condarc`**

```yaml
pkgs_dirs:
  - /data/conda/pkgs

envs_dirs:
  - /data/conda/envs

auto_activate_base: false   # 不自动激活 base 环境
show_channel_urls: true
```

验证配置：

```bash
conda config --show pkgs_dirs
conda config --show envs_dirs
conda config --show          # 查看全部配置
```

### 常用命令

```bash
conda create -n myenv python=3.11   # 创建环境
conda activate myenv                # 激活环境
conda deactivate                    # 退出环境
conda env list                      # 列出所有环境
conda clean --all                   # 清理 cache（释放磁盘空间）
```

---

## HuggingFace CLI

### 安装

```bash
pip install -U huggingface_hub
```

验证：

```bash
huggingface-cli --version
```

### 登录

在 [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens) 创建一个 Access Token（Read 权限即可），然后：

```bash
huggingface-cli login
# 按提示粘贴 token
```

Token 保存在 `~/.cache/huggingface/token`。

在脚本或 CI 环境中使用环境变量替代交互登录：

```bash
export HF_TOKEN=hf_xxxxxxxxxxxx
```

### 下载模型 / 数据集

#### 下载到默认 cache 目录

```bash
# 下载模型
huggingface-cli download meta-llama/Llama-3.2-1B

# 下载数据集
huggingface-cli download --repo-type dataset wikitext wikitext-103-v1
```

#### 下载到指定目录

使用 `--local-dir` 参数，文件直接保存到该路径，不经过 cache：

```bash
# 下载到当前目录
huggingface-cli download meta-llama/Llama-3.2-1B --local-dir .

# 下载到指定路径
huggingface-cli download meta-llama/Llama-3.2-1B --local-dir /data/models/llama3
```

#### 过滤文件

```bash
# 只下载指定文件
huggingface-cli download meta-llama/Llama-3.2-1B \
  --include "config.json" "tokenizer*" \
  --local-dir /data/models/llama3

# 排除大文件
huggingface-cli download meta-llama/Llama-3.2-1B \
  --exclude "*.safetensors" \
  --local-dir /data/models/llama3
```

#### Python API

```python
from huggingface_hub import snapshot_download, hf_hub_download

# 下载整个仓库
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

### 修改默认 cache 目录

默认 cache 在 `~/.cache/huggingface/hub`，系统盘不足时可迁移。

**方法一：环境变量（推荐）**

写入 `~/.zshrc` 或 `~/.bashrc` 永久生效：

```bash
export HF_HOME=/data/huggingface          # 所有 HF 数据的根目录
export HF_HUB_CACHE=/data/huggingface/hub # 只改 model/dataset cache
```

```bash
source ~/.zshrc
```

**方法二：迁移现有 cache + 软链接**

```bash
mv ~/.cache/huggingface /data/huggingface
ln -s /data/huggingface ~/.cache/huggingface
```

#### 环境变量说明

| 环境变量 | 默认值 | 说明 |
|---|---|---|
| `HF_HOME` | `~/.cache/huggingface` | 所有 HF 数据的根目录 |
| `HF_HUB_CACHE` | `$HF_HOME/hub` | 模型和数据集 cache |
| `HF_ASSETS_CACHE` | `$HF_HOME/assets` | tokenizer 等衍生资产 cache |
| `HF_TOKEN` | — | 登录 token（替代交互式登录） |

> `transformers`、`diffusers`、`datasets` 等库均遵循以上环境变量，无需额外配置。
