# 文件与目录操作相关实用函数
import os
from pathlib import Path

def read_text_file(filepath):
    """读取文本文件为字符串（UTF-8）。"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return f.read()

def write_text_file(filepath, content):
    """写入字符串到文本文件（UTF-8，覆盖模式）。"""
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

def read_lines(filepath):
    """按行读取文本文件，返回字符串列表。"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return f.readlines()

def list_files(directory, recursive=False):
    """获取目录下所有文件路径。递归时遍历所有子目录。"""
    if recursive:
        return [str(p) for p in Path(directory).rglob('*') if p.is_file()]
    else:
        return [str(p) for p in Path(directory).glob('*') if p.is_file()]

def batch_rename(directory, prefix='', suffix=''):  
    """
    批量重命名目录下文件，支持加前缀/后缀。
    示例：batch_rename('./data', suffix='_bak')
    """
    for filename in os.listdir(directory):
        old_path = os.path.join(directory, filename)
        if os.path.isfile(old_path):
            name, ext = os.path.splitext(filename)
            new_name = f"{prefix}{name}{suffix}{ext}"
            new_path = os.path.join(directory, new_name)
            os.rename(old_path, new_path)

# 以下是用法示例，可按需去除
if __name__ == "__main__":
    # 读文件
    text = read_text_file('test.txt')
    print(text)

    # 写文件
    write_text_file('test2.txt', 'Hello, world!\n这是测试。')

    # 按行读取
    for line in read_lines('test.txt'):
        print(line.strip())

    # 非递归文件遍历
    print(list_files('.', recursive=False))
    # ���归文件遍历
    print(list_files('.', recursive=True))

    # 批量重命名（慎用）
    # batch_rename('./data', suffix='_bak')