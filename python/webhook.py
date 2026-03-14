"""
GitHub Webhook 接收

功能概述
───────────────
本模块提供了一个安全的 GitHub Webhook 端点，用于监听 main 分支的 push 事件，
在验证通过后触发服务器上的自动部署脚本（deploy.sh）。

核心安全措施：
1. GitHub 官方 IP 白名单校验（包含通过 Nginx 转发的内网 IP）
2. X-Hub-Signature-256 签名验证（防止伪造请求）
3. Delivery ID 防重放攻击（最近 100 次缓存）
4. 仅处理 push 事件且 ref 为 refs/heads/main
5. 部署使用线程锁防止并发执行
6. 部署命令后台执行，不阻塞 webhook 响应

配置项（通过环境变量或直接修改）：
    GITHUB_SECRET       用于签名验证的密钥（强烈建议通过环境变量设置）
    DEPLOY_BRANCH       只监听此分支的推送（默认: refs/heads/main）
    DEPLOY_SCRIPT       实际执行的部署命令（默认: bash deploy.sh）
    ALLOWED_IP_PREFIX   GitHub webhook 来源 IP 段（已包含 2026 年最新范围 + 内网转发）

使用方法
───────────────
1. 在 Flask 应用中导入并注册路由：
    from webhook import GithubWebhook

    @app.route("/travel_hook", methods=["POST"])
    @GithubWebhook.verify               # 核心装饰器：完成所有安全校验
    def deploy():
        success, message = GithubWebhook.run_deploy()
        if success:
            return jsonify({"status": "deployed"}), 200
        return jsonify({"error": message}), 500

2. deploy.sh 示例内容：
    1. 拉取最新代码
    2. 安装依赖
    3. 重启服务

安全注意事项
───────────────
- 必须设置 GITHUB_SECRET 环境变量，且与 GitHub 仓库 Webhook 设置中的 Secret 完全一致

常见问题排查
───────────────
- 签名验证失败 → 检查 GITHUB_SECRET 是否一致（注意不要有多余空格或换行）
- IP 被拦截 → 确认是否通过了 Nginx 转发，必要时添加实际来源 IP 到 ALLOWED_IP_PREFIX
- 重复部署未被拦截 → 检查 delivery_cache 是否正常工作（delivery_id 是否正确传递）
- 部署没触发 → 查看日志是否出现 "Ignored ref" 或 "Ignored event type"

开发与维护信息
───────────────
- 开发人员：Adam Lee
- 主要贡献者：Adam Lee
- 首次提交日期：2026-03-14
- 最后更新日期：2026-03-14
- 版本：1.0
- Wiki：https://mwbbs.eu.org/wiki/index.php/GitHub#Webhooks
"""

import hmac
import hashlib
import logging
import functools
import subprocess
import threading
import shlex
import ipaddress
from flask import request, jsonify, abort
from collections import deque

# GitHub webhook secret
GITHUB_SECRET = os.getenv("GITHUB_SECRET", "ldscfe-github-webhook-secre")

# 只允许部署的分支
DEPLOY_BRANCH = "refs/heads/main"

# deploy script
DEPLOY_SCRIPT = "bash deploy.sh"

# 允许的 GitHub IP 前缀
# from https://api.github.com/meta
ALLOWED_IP_PREFIX = [
    ipaddress.ip_network("192.30.252.0/22"),
    ipaddress.ip_network("185.199.108.0/22"),
    ipaddress.ip_network("140.82.112.0/20"),
    ipaddress.ip_network("143.55.64.0/20"),
    ipaddress.ip_network("2a0a:a440::/29"),
    ipaddress.ip_network("2606:50c0::/32"),
    ipaddress.ip_network("192.168.32.155/32")    # 通过 Nginx 转发过来的
]

# webhook replay cache size
MAX_DELIVERY_CACHE = 100


logger = logging.getLogger(__name__)

deploy_lock = threading.Lock()
delivery_cache = deque(maxlen=MAX_DELIVERY_CACHE)

class GithubWebhook:

    def verify(self, f):
        @functools.wraps(f)
        def wrapper(*args, **kwargs):
            # ────────────────────────────────────────────────
            # 0. 获取 payload
            # ────────────────────────────────────────────────
            try:
                payload = request.get_data()
                if len(payload) > 1_000_000:                                    # payload < 1MB
                    logger.warning("Payload too large: %d bytes", len(payload))
                    return jsonify({"error": "payload too large"}), 413
            except Exception as e:
                logger.exception("Failed to read payload")
                return jsonify({"error": "bad request"}), 400

            # ────────────────────────────────────────────────
            # 1. IP 白名单
            # ────────────────────────────────────────────────
            ip_str = request.remote_addr or "unknown"
            try:
                ip = ipaddress.ip_address(ip_str)
                if not any(ip in net for net in ALLOWED_IP_PREFIX):
                    logger.warning("Blocked IP: %s (not in GitHub hooks ranges)", ip_str)
                    return jsonify({"error": "forbidden IP"}), 403              # 正式启用时打开
            except ValueError:
                # 无效 IP 格式
                return jsonify({"error": "invalid IP"}), 400

            # ────────────────────────────────────────────────
            # 2. 方法检查 POST
            # ────────────────────────────────────────────────
            if request.method != "POST":
                return jsonify({"error": "method not allowed"}), 405

            # ────────────────────────────────────────────────
            # 3. 签名验证
            # ────────────────────────────────────────────────
            signature = request.headers.get("X-Hub-Signature-256")
            if not signature or not signature.startswith("sha256="):
                return jsonify({"error": "missing or invalid signature"}), 400

            expected = "sha256=" + hmac.new(
                GITHUB_SECRET.encode(),
                payload,
                hashlib.sha256
            ).hexdigest()

            if not hmac.compare_digest(signature, expected):
                logger.warning("Invalid signature from IP: %s", ip)
                return jsonify({"error": "unauthorized"}), 401

            # ────────────────────────────────────────────────
            # 4. 重放攻击防御
            # ────────────────────────────────────────────────
            delivery_id = request.headers.get("X-GitHub-Delivery")
            if delivery_id and delivery_id in delivery_cache:
                logger.info("Duplicate delivery ignored: %s", delivery_id)
                return jsonify({"status": "duplicate"}), 200

            if delivery_id:
                delivery_cache.append(delivery_id)

            # ────────────────────────────────────────────────
            # 5. 事件类型（github 事件类型）
            # ────────────────────────────────────────────────
            event = request.headers.get("X-GitHub-Event")
            if event != "push":
                logger.debug("Ignored event type: %s", event)
                return jsonify({"status": "ignored"}), 200

            # ────────────────────────────────────────────────
            # 6. 分支 + 解析 payload
            # ────────────────────────────────────────────────
            try:
                data = request.json
            except Exception:
                logger.warning("Invalid JSON payload")
                return jsonify({"error": "invalid json"}), 400

            ref = data.get("ref")
            if ref != DEPLOY_BRANCH:
                logger.debug("Ignored ref: %s", ref)
                return jsonify({"status": "ignored"}), 200

            # 相关上下文日志
            repo = data.get("repository", {}).get("full_name", "unknown")
            commit = data.get("head_commit", {}).get("id", "unknown")[:8]
            logger.info("Valid push event: %s @ %s → %s", repo, commit, ref)

            return f(*args, **kwargs)

        return wrapper

    @staticmethod
    def run_deploy():

        with deploy_lock:

            logger.info("Starting deployment...")

            try:

                subprocess.Popen(
                    shlex.split(DEPLOY_SCRIPT),
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    start_new_session=True
                )

                return {"status": "deploy started"}, 200

            except subprocess.TimeoutExpired:

                logger.error("Deployment timeout")

                return False, "timeout"

# class GithubWebhook - End
