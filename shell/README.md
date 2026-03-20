# Shell 脚本集合

这是一个实用 Shell 脚本和技巧的集合，涵盖系统管理、文件操作、远程执行等常见任务。

## 快速列表

| 场景               | 脚本            | 说明                              |
|------------------------|---------------------|-----------------------------------------|
| 清理重复文件           | dup_file_rm.sh      | 安全删除重复文件（MD5 + 大小排序）      |
| git 提交    | gitpush.sh          | 快速提交 & 推送 git                        |
| 本地批量操作       | lrun.sh             | 命令在本地机器展开                    |
| 远程批量操作     | rrun.sh             | 命令在远程机器展开                 |
| 保持端口服务       | port_monitor.sh     | 配合 crontab 实现端口自愈                   |
| 打包目录     | pzip.sh             | 灵活排除规则，防止打包无用文件          |
| 查看项目结构       | tls.sh              | 比 tree 更可控的过滤版及目录优先                  |
| Shell 技巧     | shell_abc.md        | Shell 技巧与代码片段集             |

## 脚本文件一览表

| 序号  | 名称              | 功能                         | 示例                                                               | 说明                                 | 依赖                       |
| --- | --------------- | -------------------------- | ---------------------------------------------------------------- | ---------------------------------- | ------------------------ |
| 1   | dup_file_rm.sh  | 查找并删除重复文件                  | `./dup_file_rm.sh /path/to/dir [N]`                              | 按大小排序 → MD5 比对 → 保留第一个，彩色输出，支持碰撞检测 | md5sum, find, sort, stat |
| 2   | gitpush.sh      | 自动化 git add/commit/push 流程 | `./gitpush.sh . "fix bug"`                                       | 显示状态需确认、自动加时间戳、彩色交互提示              | git                      |
| 3   | lrun.sh         | 本地批量对多台机器（列表）执行命令          | `./lrun.sh ip_list "scp file %VAR%:/tmp/"`                       | %VAR% 占位符替换，支持本地命令批量分发             |                          |
| 4   | rrun.sh         | 通过 SSH 批量对远程机器列表执行命令       | `./rrun.sh servers.txt "systemctl restart nginx"`                | SSH root 执行，逐台显示主机名                | ssh（需免密或有密钥）             |
| 5   | port_monitor.sh | 监控端口存活，不活则执行对应启动脚本         | `./port_monitor.sh` 或 `./port_monitor.sh log.txt`                | 支持彩色/静默日志模式，macOS/Linux 通用         | lsof                     |
| 6   | pzip.sh         | 项目智能打包（灵活排除/包含规则）          | `./pzip.sh . backup +tmp\|logs`<br>`./pzip.sh . bak "src\|docs"` | 默认排除常见垃圾目录，支持 +追加 / 完全替换模式         | zip                      |
| 7   | tls.sh          | 树形显示项目目录结构（可过滤、可深度）        | `./tls.sh 3 . +tmp\|logs`<br>`./tls.sh 2 . "src\|docs"`          | 目录优先排序、显示文件类型符号、支持过滤规则             |                          |

### 模式参数对比（pzip.sh & tls.sh 逻辑）

| 模式写法    | 含义                 | 示例                            | 实际过滤规则                         |
| ------- | ------------------ | ----------------------------- | ------------------------------ |
| （空）     | 使用内置默认规则           | `./pzip.sh . backup`          | *.DS_Store .git node_modules 等 |
| +规则     | 默认规则 + 额外排除        | `./pzip.sh . bak +tmp\|cache` | 默认规则 ∪ {tmp, cache}            |
| 具体规则字符串 | **完全替换**默认规则，只排除这些 | `./pzip.sh . bak "log\|dist"` | 只排除 log 和 dist 目录              |


## 🚀 快速开始

1. **克隆仓库**：
   ```bash
   git clone https://github.com/ldscfe/snippets.git
   ```

## 👤 贡献者

- Adam Lee (ldscfe@gmail.com)

## 📄 许可证

MIT
