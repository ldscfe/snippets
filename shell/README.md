# Shell 脚本集合

这是一个实用 Shell 脚本和技巧的集合，涵盖系统管理、文件操作、远程执行等常见任务。

## 脚本文件一览表

| 序号 | 名称                     | 功能描述                                                     | 示例                                                     | 说明                          |
| ---- | ------------------------ | ------------------------------------------------------------ | -------------------------------------------------------- | ----------------------------- |
| 1    | common.sh                | 公共变量、配色与 UI 定义，供其他脚本 source 使用              | —                                                        | 定义常量及辅助函数            |
| 2    | dup_file_rm.sh           | 查找并删除重复文件（按大小排序 → MD5 比对）                   | ./dup_file_rm.sh /path/to/dir [N]                        | 安全删除重复文件              |
| 3    | lrun.sh                  | 本地对多台机器（通过列表）展开命令（本机执行/分发批处理）       | ./lrun.sh ip_list "scp file %VAR%:/tmp/"                 | 生成分发命令                  |
| 4    | rrun.sh                  | 通过 SSH 对远程机器列表批量执行命令                           | ./rrun.sh servers.txt "systemctl restart nginx"          | 逐台执行远程命令              |
| 5    | port_monitor.sh          | 监控端口存活，不活自动调用启动脚本，适合 crontab 配合           | ./port_monitor.sh 或 ./port_monitor.sh log.txt           | 可定时检测并自启动            |
| 6    | pzip.sh                  | 项目智能打包（灵活的排除/包含规则）                           | ./pzip.sh . backup +tmp\|logs                            | 支持自定义过滤                |
| 7    | tls.sh                   | 可过滤/按深度显示的目录树（比 tree 更可控）                    | ./tls.sh 3 . +tmp\|logs                                  | 支持按规则过滤目录            |
| 8    | search.sh                | 增强型 grep（兼容 macOS/Linux，支持上下文行数）               | ./search.sh "error" "~/log" 2                            | 自动处理编码等问题            |
| 9    | srds_perf_test.sh        | SRDS(6378) 与 Redis6(6379) 的批量性能基准测试脚本              | bash srds_perf_test.sh 5                                 | 支持多并发/多次测试           |
| 10   | template.sh              | 脚本模板（快速创建新脚本的头部与结构）                         | cp template.sh my_script.sh                              | 推荐 copy 后二次开发          |
| 11   | shell_abc.md             | Shell 技巧与代码片段集合                                      | —                                                        | 文档形式归纳常用技巧          |
| 12   | claude_check.sh          | Claude 服务相关检查与健康检测脚本                             | ./claude_check.sh                                        | 服务健康巡检                  |
| 13   | start_claude_screen.sh   | 启动 Claude 相关服务/容器（screen 后台模式）                   | ./start_claude_screen.sh                                 | 后台守护式启动                |
| 14   | push.sh                  | 推送/发布自动化脚本，适用 git 以外场景                        | ./push.sh . "fix bug"                                    | 灵活化批量发布                |
| 15   | rpl.sh                   | 当前目录及子目录下，批量正则替换操作脚本                      | ./rpl.sh 'old' 'new'                                     | 替换内容支持递归与正则         |
| 16   | ugit.sh                  | git 批量操作指定目录（status, pull）                          | ./ugit.sh [pull]                                         | 简化 git 日常批量处理          |
| 17   | snip.sh                  | 本仓库脚本一键下载工具（通用脚本分发实现）                    | bash snip.sh common.sh                                   | 在线拉取指定脚本到本地         |
| 18   | tups.sh                  | 利用 tmux 托管后台进程的轻量级管理器。 | ./tups.sh rc-agent    | 后台启动 rc-agent  |
| 19   | usync.sh                 | 将 ${LPATH}/ALDS/.AI/ 下的内容，同步给指定目录   | ./usync.sh rc-agent  | ALDS/.AI/ -> rc-agent/.AI/  |

### 模式参数对比（pzip.sh & tls.sh 逻辑）

| 模式写法       | 含义                          | 示例                             | 实际过滤规则                            |
| -------------- | ----------------------------- | -------------------------------- | --------------------------------------- |
| （空）         | 使用内置默认规则               | `./pzip.sh . backup`             | *.DS_Store .git node_modules 等         |
| +规则          | 默认规则 + 额外排除            | `./pzip.sh . bak +tmp|cache`     | 默认规则 ∪ {tmp, cache}                 |
| 具体规则字符串 | 完全替换默认规则，只排除这些    | `./pzip.sh . bak "log|dist"`    | 只排除 log 和 dist 目录                 |

## 🚀 快速开始

```bash
curl -L https://raw.githubusercontent.com/ldscfe/snippets/refs/heads/main/shell/snip.sh -o ~/bin/snip

snip common.sh
snip ugit.sh
```

## 👤 贡献者

- Adam Lee (ldscfe@gmail.com)

## 📄 许可证

Apache License 2.0

© 2026 Adam Lee
