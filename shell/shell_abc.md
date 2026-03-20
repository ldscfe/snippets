# Shell 常用技巧与片段

## 1. 环境变量与初始化

```bash
# 加载用户环境变量（常用在脚本开头）
. ~/.bash_profile
```

## 2. 转义规则

```bash
# 单引号：硬转义，所有 shell 元字符/通配符失效
# 注意：单引号内部不允许再出现单引号
'never $expand never `cmd` never'

# 双引号：软转义，只转义 $, `, \ 和 " 本身
"today is $(date) - $USER"

# 反斜杠：转义单个字符
echo line1 \
     line2
```

**注意**：在双引号中使用变量时，通常再套一层双引号（防止空格问题）：

```bash
c="a * b"
echo "$c"          # 输出：a * b
echo $c            # 输出：a b（通配符展开了）
```

## 3. 条件分支与 grep 判断

```bash
# 根据 grep 结果分支（-q 安静模式）
grep -q sse4_2 /proc/cpuinfo && echo "SSE 4.2 supported" || echo "SSE 4.2 not supported"
```

## 4. 重定向与错误处理

```bash
# stderr → stdout
somecommand 2>&1

# stdout → 文件（覆盖）
command > /tmp/log.txt

# stdout → 文件（追加）
command >> /tmp/log.txt

# 同时重定向 stdout 和 stderr
command >output.log 2>&1
```

## 5. 日期处理

```bash
# 完整时间戳
DT=$(date '+%Y/%m/%d %H:%M:%S')

# 年月日
DAYID=$(date +%Y%m%d)

# 昨天、明天
DAYIDY=$(date -d yesterday +%Y%m%d)
DAYIDT=$(date -d tomorrow   +%Y%m%d)
```

## 6. 获取主机信息

```bash
HOST=$(hostname)
IP=$(ping -c1 "$HOST" | xargs | awk -F')' '{print $1}' | awk -F'(' '{print $2}')
echo "$HOST ($IP)"
```

## 7. 逻辑运算符（find / test 命令中）

```bash
# 与（-a）、或（-o）、非（!）
find . -type f -name "*.log" -mtime +7 -a -size +10M
```

## 8. 命令行参数判断

```bash
# 方式1：算术比较
if (( $# >= 1 )); then
    YM=$1
else
    echo "$0 YM=yyyymm"
    exit 1
fi

# 方式2：字符串比较
if [ "$1" = "" ]; then
    echo "No parameter provided"
    exit 1
fi

# 方式3：带 else-if
if [ "$1" = "" ]; then
    CS=1
else
    CS=$1
fi
```

## 9. 数值比较

```bash
if (( PS > 0 )); then
    echo "Task: $CMD exist."
    exit 1
else
    echo "OK"
fi
```

## 10. 字符串比较

```bash
if [ "$HASH_FN" = "$HASH_FN_OLD" ]; then
    echo "${FN} & ${FN_OLD} Hash Same."
else
    echo "Backup ${HASH_FN} Finished."
fi
```

## 11. 文件/路径存在判断

```bash
# 文件存在 → 执行
[ -f /etc/profile ] && . /etc/profile

# 目录不存在 → 创建
[ ! -d "$VPATH" ] && mkdir -p "$VPATH"

# 常用 test 选项
# -e 存在（文件/目录）
# -d 是目录
# -f 是普通文件
# -L 是符号链接
# -r 可读 / -w 可写 / -x 可执行 / -s 非空
```

## 12. 按行读取文件

```bash
# 方式1：推荐（保留空格、换行）
while read -r LN; do
    echo "$LN"
done < "$LN_NAME"

# 方式2：管道方式（较少使用）
cat "$LN_NAME" | while read -r LN; do
    echo "$LN"
done
```

## 13. 遍历文件/目录

```bash
# 当前目录下所有以 FILENAME 开头的文件
for FN in "${FILENAME}"*; do
    echo "$FN"
done

# 只当前层目录（不递归）
find . -maxdepth 1 -type d   # 目录
find . -maxdepth 1 -type f   # 文件
```

## 14. 字符串匹配与截取

```bash
# 正则包含
[[ $string =~ $sub ]]

# 开头匹配
[[ $string == "$sub"* ]]

# 结尾匹配
[[ $string == *"$sub" ]]

# 参数扩展截取
STR="a bc 1"
echo "${STR% *}"     # a bc     （从右删最短空格后内容）
echo "${STR%% *}"    # a        （从右删最长空格后内容）
echo "${STR#* }"     # bc 1     （从左删最短空格前内容）
echo "${STR##* }"    # 1        （从左删最长空格前内容）
```

## 15. 其他常用片段

```bash
# 计算
let V1=$1-$2
V2=$(expr $1 - $2)          # 注意空格

# 主机逻辑核心数 -10
threads=$(($(nproc) - 10))

# 特殊字符
PA=$(echo -ne '\004')

# 循环
for (( i=1; i<=${CS}; i++ )); do
    echo "$i"
done
```

## LOG Format 示例

![LOG Format 示例](https://user-images.githubusercontent.com/116426901/206650104-e8873d01-9785-4915-b74a-2f008bd42709.png)
