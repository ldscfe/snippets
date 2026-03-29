"""
Markdown 引用有效性检查工具

功能概述
───────────────
本模块是一个自动化质量保障工具，用于扫描项目中的 Markdown 文件。
它通过正则表达式提取文档内部的相对路径引用，并验证这些文件在物理磁盘上是否存在，
从而防止文档体系中出现“死链”。

功能特性：
1. 路径自动识别：支持 reports/(active|completed|archives)/ 和 docs/tasks/ 下的 .md 引用。
2. 模板智能排除：自动忽略包含通配符（*）或时间占位符（YYYYMMDD/HHMM）的示例路径。
3. 多平台兼容：基于 pathlib 实现，无缝支持 macOS 与 Linux 环境。
4. 统计模式：提供 --summary 参数，仅输出错误计数，便于集成到 CI/CD 流程或 Git Hooks。
5. 错误定位：默认模式下输出详细的“文件 -> 缺失引用”列表。

配置项（通过代码或目录结构）：
    ROOT_PATH          脚本自动解析至项目根目录（基于脚本位置推断）。
    SCAN_DIRS          默认扫描范围：docs/, reports/, .ai/
    ENCODING           使用 utf-8 读取，并忽略（ignore）无法识别的非法字符，确保鲁棒性。

使用方法
───────────────
1. 直接运行（详细模式）：
    python3 tools/check_doc_links.py

2. 集成到 Git Hooks（计数模式）：
    # 在 .githooks/pre-commit 中调用
    if python3 tools/check_doc_links.py --summary; then
      exit 0
    fi

3. 查看帮助：
    python3 tools/check_doc_links.py --help

开发与维护信息
───────────────
- 开发人员：Adam Lee
- 主要贡献者：Adam Lee
- 首次提交日期：2026-03-29
- 最后更新日期：2026-03-29
- 版本：1.0.0
- 项目地址：https://github.com/ldscfe/snippets/blob/main/python/check_doc_links.py
- Wiki：https://mwbbs.eu.org/wiki/index.php/GitHub#pre-commit
"""

#!/usr/bin/env python3
from __future__ import annotations
import argparse
import re
import sys
from pathlib import Path

REF_PATTERN = re.compile(
    r"(reports/(?:active|completed|archives)/[^)`\s]+\.md|docs/tasks/[^)`\s]+\.md)"
)

def iter_markdown_files(root: Path) -> list[Path]:
    bases = [
        root / "docs",
        root / "reports",
        root / ".ai",
    ]
    files: list[Path] = []
    for base in bases:
        if base.exists():
            files.extend(sorted(base.rglob("*.md")))
    return files

def collect_missing_refs(root: Path) -> dict[Path, list[str]]:
    results: dict[Path, list[str]] = {}
    for file_path in iter_markdown_files(root):
        text = file_path.read_text(encoding="utf-8", errors="ignore")
        refs = sorted(set(REF_PATTERN.findall(text)))
        missing = []
        for ref in refs:
            # Ignore documented path templates used in process guides.
            if "*" in ref or "YYYYMMDD" in ref or "HHMM" in ref:
                continue
            if not (root / ref).exists():
                missing.append(ref)
        if missing:
            results[file_path] = missing
    return results

def main() -> int:
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        add_help=True,
        # description="Check markdown references under docs/, reports/, and .ai/."
        description=__doc__
    )
    parser.add_argument(
        "--summary",
        action="store_true",
        help="Print only summary counts.",
    )
    args = parser.parse_args()

    root = Path(__file__).resolve().parent.parent
    missing_refs = collect_missing_refs(root)

    files_with_missing = len(missing_refs)
    total_missing = sum(len(v) for v in missing_refs.values())

    if args.summary:
        print(f"files_with_missing={files_with_missing}")
        print(f"missing_refs={total_missing}")
        return 1 if total_missing else 0

    if not missing_refs:
        print("No missing markdown references found.")
        return 0

    print(f"Found {total_missing} missing references in {files_with_missing} files.\n")
    for file_path, refs in sorted(missing_refs.items()):
        rel = file_path.relative_to(root)
        print(rel)
        for ref in refs:
            print(f"  MISSING {ref}")
        print()

    return 1

if __name__ == "__main__":
    sys.exit(main())
