"""
飞书知识库集成模块
使用飞书官方SDK (lark-oapi)
"""

import os
import json
import sqlite3
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime

import lark_oapi as lark


class FeishuClient:
    """飞书客户端，使用官方SDK"""

    def __init__(self, app_id: Optional[str] = None, app_secret: Optional[str] = None):
        """
        初始化飞书客户端

        Args:
            app_id: 飞书应用ID，默认从环境变量FEISHU_APP_ID获取
            app_secret: 飞书应用密钥，默认从环境变量FEISHU_APP_SECRET获取
        """
        self.app_id = app_id or os.getenv("FEISHU_APP_ID")
        self.app_secret = app_secret or os.getenv("FEISHU_APP_SECRET")

        # 创建客户端
        self.client = lark.Client.builder() \
            .app_id(self.app_id) \
            .app_secret(self.app_secret) \
            .build()

    def get_wiki_spaces(self) -> List[Dict]:
        """
        获取知识库列表

        Returns:
            知识库列表
        """
        request = lark.api.wiki.v2.ListSpaceRequest.builder() \
            .page_size(50) \
            .build()

        response = self.client.wiki.v2.space.list(request)

        if not response.success():
            raise Exception(f"获取知识库列表失败: {response.code}, {response.msg}")

        spaces = []
        for item in (response.data.items or []):
            spaces.append({
                "space_id": item.space_id,
                "name": item.name,
                "description": item.description or "",
                "visibility": item.visibility,
                "create_time": item.create_time,
                "update_time": item.update_time
            })

        return spaces

    def get_wiki_nodes(self, space_id: str, parent_node_token: str = "") -> List[Dict]:
        """
        获取知识库节点列表

        Args:
            space_id: 知识库ID
            parent_node_token: 父节点token，为空时获取根节点

        Returns:
            节点列表
        """
        request_builder = lark.api.wiki.v2.ListSpaceNodeRequest.builder() \
            .space_id(space_id) \
            .page_size(50)

        # 只在 parent_node_token 不为空时才设置
        if parent_node_token:
            request_builder = request_builder.parent_node_token(parent_node_token)

        request = request_builder.build()

        response = self.client.wiki.v2.space_node.list(request)

        if not response.success():
            raise Exception(f"获取节点列表失败: {response.code}, {response.msg}")

        nodes = []
        for item in (response.data.items or []):
            nodes.append({
                "node_token": item.node_token,
                "node_type": item.node_type,
                "obj_token": item.obj_token,
                "title": item.title,
                "has_child": item.has_child,
                "parent_node_token": parent_node_token
            })

        return nodes

    def get_doc_content(self, doc_token: str) -> Dict:
        """
        获取文档内容

        Args:
            doc_token: 文档token

        Returns:
            文档内容
        """
        request = lark.api.docx.v1.GetDocumentRequest.builder() \
            .document_id(doc_token) \
            .build()

        response = self.client.docx.v1.document.get(request)

        if not response.success():
            raise Exception(f"获取文档内容失败: {response.code}, {response.msg}")

        return {
            "document_id": response.data.document.document_id,
            "title": response.data.document.title,
            "revision_id": response.data.document.revision_id,
            "token": doc_token
        }

    def get_doc_blocks_content(self, doc_token: str) -> str:
        """
        获取文档的所有块内容并转换为Markdown格式

        Args:
            doc_token: 文档token

        Returns:
            Markdown格式的文档内容
        """
        request = lark.api.docx.v1.GetDocumentBlockChildrenRequest.builder() \
            .document_id(doc_token) \
            .block_id(doc_token) \
            .page_size(100) \
            .build()

        response = self.client.docx.v1.document_block_children.get(request)

        if not response.success():
            raise Exception(f"获取文档块失败: {response.code}, {response.msg}")

        markdown_lines = []

        for item in (response.data.items or []):
            block_type = item.block_type

            if block_type == 2:  # 文本段落
                if hasattr(item, 'paragraph') and item.paragraph:
                    for elem in item.paragraph.elements or []:
                        if hasattr(elem, 'text_run') and elem.text_run:
                            markdown_lines.append(elem.text_run.content)
                    markdown_lines.append("")

            elif block_type == 3:  # 一级标题
                if hasattr(item, 'heading1') and item.heading1:
                    heading_text = ""
                    for elem in item.heading1.elements or []:
                        if hasattr(elem, 'text_run') and elem.text_run:
                            heading_text += elem.text_run.content
                    markdown_lines.append(f"# {heading_text}")
                    markdown_lines.append("")

            elif block_type == 4:  # 二级标题
                if hasattr(item, 'heading2') and item.heading2:
                    heading_text = ""
                    for elem in item.heading2.elements or []:
                        if hasattr(elem, 'text_run') and elem.text_run:
                            heading_text += elem.text_run.content
                    markdown_lines.append(f"## {heading_text}")
                    markdown_lines.append("")

            elif block_type == 5:  # 三级标题
                if hasattr(item, 'heading3') and item.heading3:
                    heading_text = ""
                    for elem in item.heading3.elements or []:
                        if hasattr(elem, 'text_run') and elem.text_run:
                            heading_text += elem.text_run.content
                    markdown_lines.append(f"### {heading_text}")
                    markdown_lines.append("")

            elif block_type == 13:  # checklist
                if hasattr(item, 'view') and item.view:
                    markdown_lines.append("```")
                    markdown_lines.append(item.view.content or "[checklist]")
                    markdown_lines.append("```")
                    markdown_lines.append("")

        return "\n".join(markdown_lines)

    def save_wiki_to_db(self, db_path: str) -> int:
        """
        将知识库列表保存到SQLite数据库

        Args:
            db_path: 数据库路径

        Returns:
            保存的知识库数量
        """
        spaces = self.get_wiki_spaces()

        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        # 创建表
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS wiki_spaces (
                id TEXT PRIMARY KEY,
                name TEXT,
                description TEXT,
                visibility TEXT,
                created_at TEXT,
                updated_at TEXT
            )
        """)

        # 插入数据
        count = 0
        for space in spaces:
            cursor.execute("""
                INSERT OR REPLACE INTO wiki_spaces
                (id, name, description, visibility, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (
                space.get("space_id"),
                space.get("name"),
                space.get("description", ""),
                space.get("visibility"),
                space.get("create_time"),
                space.get("update_time")
            ))
            count += 1

        conn.commit()
        conn.close()

        return count

    def export_wiki_docs(self, space_id: str, output_dir: Path) -> int:
        """
        导出知识库所有文档到指定文件夹（JSON格式）

        Args:
            space_id: 知识库ID
            output_dir: 输出目录

        Returns:
            导出的文档数量
        """
        output_dir.mkdir(parents=True, exist_ok=True)
        docs_count = 0

        def traverse_nodes(node_token: str = ""):
            nonlocal docs_count

            try:
                nodes = self.get_wiki_nodes(space_id, node_token)
            except Exception as e:
                print(f"获取节点失败: {e}")
                return

            for node in nodes:
                node_token_current = node.get("node_token")
                node_type = node.get("node_type")
                obj_token = node.get("obj_token")
                title = node.get("title", "untitled")

                # 只要有 obj_token 就尝试导出文档
                if obj_token:
                    try:
                        # 获取文档信息
                        doc_info = self.get_doc_content(obj_token)

                        # 获取文档的Markdown内容
                        markdown_content = self.get_doc_blocks_content(obj_token)

                        # 合并数据
                        doc_data = {
                            **doc_info,
                            "node_token": node_token_current,
                            "node_type": node_type,
                            "markdown_content": markdown_content,
                            "exported_at": datetime.now().isoformat()
                        }

                        # 保存为JSON格式
                        safe_title = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_')).strip()
                        if not safe_title:
                            safe_title = "untitled"
                        file_path = output_dir / f"{safe_title}.json"
                        with open(file_path, "w", encoding="utf-8") as f:
                            json.dump(doc_data, f, ensure_ascii=False, indent=2)
                        docs_count += 1
                        print(f"  ✓ 导出: {title}")
                    except Exception as e:
                        print(f"  ✗ 导出失败 {title}: {e}")

                # 递归处理子节点
                if node.get("has_child") and node_token_current:
                    traverse_nodes(node_token_current)

        traverse_nodes()
        return docs_count
