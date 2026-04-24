# Shell 脚本集合

这是一个实用 Shell 脚本和技巧的集合，涵盖系统管理、文件操作、远程执行等常见任务。

## 脚本文件一览表

| 序号 | 名称               | 功能                                                         | 示例                                                                 | 说明                                                           | 依赖                 |
| ---- | ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------------ | -------------------------------------------------------------- | -------------------- |
| 1    | common.sh          | 公共变量、配色与 UI 定义（供其他脚本 source 使用）            | —                                                                    | 定义颜色、日志格式等通用常量，供其它脚本引用                  | 无（作为库被引用）   |
| 2    | dup_file_rm.sh     | 查找并删除重复文件（按大小排序 → MD5 比对）                   | `./dup_file_rm.sh /path/to/dir [N]`                                   | 安全删除重复文件，保留首个匹配项                               | md5sum/coreutils     |
| 3    | git_pull.sh        | 批量对指定目录列表执行 git pull（可选择以指定用户运行）       | `git_pull.sh` 或 `git_pull.sh nouser`                                 | 适用于本地仓库批量更新                                         | git、sudo（可选）    |
| 4    | gitpush.sh         | 自动化 git add/commit/push 流程                                | `./gitpush.sh . "fix bug"`                                           | 交互式确认，自动拼接时间戳到 commit message                    | git                  |
| 5    | lrun.sh            | 在本地对多台机器（通过列表）展开命令（本机执行命令生成分发文件） | `./lrun.sh ip_list "scp file %VAR%:/tmp/"`                           | %VAR% 占位符替换，适用于将命令展开到多主机的场景               | bash                |
| 6    | rrun.sh            | 通过 SSH 对远程机器列表批量执行命令                           | `./rrun.sh servers.txt "systemctl restart nginx"`                    | 逐台执行并显示主机名，适合远程维护                             | ssh、ssh-key         |
| 7    | port_monitor.sh    | 监控端口存活，不活则执行对应启动脚本（配合 crontab 使用）       | `./port_monitor.sh` 或 `./port_monitor.sh log.txt`                    | 支持彩色输出和静默日志模式，可自定义端口与启动脚本映射         | netcat/ss/nc         |
| 8    | pzip.sh            | 项目智能打包（支持灵活的排除/包含规则）                       | `./pzip.sh . backup +tmp|logs`                                         | 默认排除常见垃圾目录，支持追加或替换规则                       | tar、zip、grep       |
| 9    | tls.sh             | 可过滤/按深度显示的目录树（比 tree 更可控）                    | `./tls.sh 3 . +tmp|logs`                                               | 支持基于正则的过滤和目录优先显示                               | bash、ls、sort       |
| 10   | search.sh          | 增强型 grep 封装（兼容 macOS/Linux，支持上下文行数）           | `search.sh "error" "~/log" 2`                                      | 自动处理文件/目录与通配符，输出带颜色的匹配结果               | grep                 |
| 11   | srds_perf_test.sh  | SRDS(6378) 与 Redis6(6379) 的批量性能基准测试脚本              | `bash srds_perf_test.sh 5`                                             | 组合多组 redis-benchmark 命令，支持多并发/管道并输出 CSV      | redis-benchmark      |
| 12   | template.sh        | 脚本模板（用于快速创建新脚本的头部与结构）                     | `cp template.sh my_script.sh && vim my_script.sh`                     | 包含 header、帮助信息与兼容性注记                             | 无                   |
| 13   | shell_abc.md       | Shell 技巧与代码片段集合                                        | —                                                                    | 文档形式，包含常用函数、技巧与示例代码                         | 无                   |

### 模式参数对比（pzip.sh & tls.sh 逻辑）

| 模式写法       | 含义                          | 示例                             | 实际过滤规则                            |
| -------------- | ----------------------------- | -------------------------------- | --------------------------------------- |
| （空）         | 使用内置默认规则               | `./pzip.sh . backup`             | *.DS_Store .git node_modules 等         |
| +规则          | 默认规则 + 额外排除            | `./pzip.sh . bak +tmp|cache`     | 默认规则 ∪ {tmp, cache}                 |
| 具体规则字符串 | 完全替换默认规则，只排除这些    | `./pzip.sh . bak "log|dist"`    | 只排除 log 和 dist 目录                 |

## 🚀 快速开始

1. **克隆仓库**：

```bash
git clone https://github.com/ldscfe/snippets.git
```

## 👤 贡献者

- Adam Lee (ldscfe@gmail.com)

## 📄 许可证

Apache License 2.0

© 2026 Adam Lee