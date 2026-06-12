"""飞书邮件分类 + HR 确认队列 CLI 工具。

新架构（CLI-based）：
    lark-cli（飞书官方 CLI） ←── qtadmin human ──POST /ingest──→ qtadmin provider

- qtadmin human 封装 lark-cli，拉取邮件 → 关键字分类 → 推结构化数据
- 服务端不碰飞书 API，不需要 App ID/Secret
- 服务端提供 POST /ingest、GET /queue、PATCH /queue/{id}/confirm 等接口
"""

from feishu_integration.classifier import ClassificationResult, classify

__all__ = [
    "ClassificationResult",
    "classify",
]
