# Dotfiles Bin & Alias Management

这个目录用于管理个人高频使用的命令的环境别名与常用参数帮助 (`alias/*.sh`)。支持 **macOS (Zsh)** 和 **Linux (Bash/Zsh)** 环境。

---

## 目录结构

建议将文件按以下结构组织在 `$HOME/bin/` 目录下：

```text
~/bin/
├── common.sh          # 公共基础函数库 (包含 die, split_line, parse_kv_args 等)
├── usync.sh           # 自定义独立工具脚本 (如同步脚本)
└── alias/             # 模块化别名与高频参数配置目录
    ├── find.sh        # 查找命令常用参数别名
    ├── git.sh         # Git 常用快捷键与别名, push(Automated commit & push)
    ├── rsync.sh       # Rsync 常用同步参数别名
    └── tmux.sh        # Tmux 会话管理复用别名

```

---

## 安装与启用

要启用该管理机制，请根据你当前使用的 Shell，将以下配置追加到对应的初始化文件中（`~/.zshrc` 或 `~/.bashrc`）。

### 1. 配置加载器

将以下代码复制并粘贴到 `~/.zshrc` 或 `~/.bashrc` 的**末尾**：

```bash
# --- Common Lib ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"

# load ~/bin/alias
CUSTOM_DIR="$HOME/bin/alias"
if [ -d "$CUSTOM_DIR" ]; then
    for config_file in "$CUSTOM_DIR"/*; do
        [[ "$config_file" =~ \.(sh|zsh)$ && -f "$config_file" ]] || continue
        
        source "$config_file"
    done
fi

```

### 2. 立即生效

保存文件后，在终端执行以下命令使其立即生效：

```bash
# 如果使用 Zsh
source ~/.zshrc

# 如果使用 Bash
source ~/.bashrc

```
