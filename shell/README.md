# Shell 脚本集合

这是一个实用 Shell 脚本和技巧的集合，涵盖系统管理、文件操作、远程执行等常见任务。

## 脚本文件一览表

| 序号 | 名称               | 功能                                                         | 示例                                                                 | 说明                   |
| ---- | ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------------ | ---------------------- |
| 1    | common.sh          | 公共变量、配色与 UI 定义（供其他脚本 source 使用）            | —                                                                    | 定义常用函数与变量     |
| 2    | dup_file_rm.sh     | 查找并删除重复文件（按大小排序 → MD5 比对）                   | `./dup_file_rm.sh /path/to/dir [N]`                                   | 安全删除重复文件       |
| 3    | lrun.sh            | 在本地对多台机器（通过列表）展开命令（本机执行命令生成分发文件） | `./lrun.sh ip_list "scp file %VAR%:/tmp/"`                          | 生成分发脚本并在本机执行 |
| 4    | rrun.sh            | 通过 SSH 对远程机器列表批量执行命令                           | `./rrun.sh servers.txt "systemctl restart nginx"`                    | 逐台执行并记录结果     |
| 5    | port_monitor.sh    | 监控端口存活，不活则执行对应启动脚本（配合 crontab 使用）       | `./port_monitor.sh` 或 `./port_monitor.sh log.txt`                    | 支持日志输出与报警     |
| 6    | pzip.sh            | 项目智能打包（支持灵活的排除/包含规则）                       | `./pzip.sh . backup +tmp|logs`                                         | 默认排除常见临时文件   |
| 7    | tls.sh             | 可过滤/按深度显示的目录树（比 tree 更可控）                    | `./tls.sh 3 . +tmp|logs`                                               | 支持按深度与规则过滤   |
| 8    | search.sh          | 增强型 grep 封装（兼容 macOS/Linux，支持上下文行数）           | `search.sh "error" "~/log" 2`                                      | 自动处理编码与颜色输出 |
| 9    | srds_perf_test.sh  | SRDS(6378) 与 Redis6(6379) 的批量性能基准测试脚本              | `bash srds_perf_test.sh 5`                                             | 支持多并发组测试       |
| 10   | template.sh        | 脚本模板（用于快速创建新脚本的头部与结构）                     | `cp template.sh my_script.sh && vim my_script.sh`                     | 包含 header 与参数解析 |
| 11   | shell_abc.md       | Shell 技巧与代码片段集合                                        | —                                                                    | 文档形式，包含常用命令示例 |
| 12   | claude_check.sh    | Claude 服务相关检查与健康检测脚本                              | `./claude_check.sh`                                                    | 用于本地/容器服务检测  |
| 13   | start_claude.sh    | 启动 Claude 相关服务或容器的脚本                               | `./start_claude.sh`                                                    | 启动并做基础检查       |
| 14   | push.sh            | 推送/发布相关自动化脚本（替代或补充 gitpush 场景）             | `./push.sh . "fix bug"`                                              | 可自定义 commit/message |
| 15   | rep.sh             | 批量替换或模板化操作脚本                                       | `./rep.sh 's/old/new/g' ./path`                                        | 批量替换文件内容       |
| 16   | ugit.sh            | 更友好的 git 操作封装脚本（常用子命令的快捷封装）              | `./ugit.sh status`                                                     | 简化常用 git 操作      |

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
