"""
飞书客户端单元测试
"""

import os
import json
import sqlite3
import pytest
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock

from feishu_client import FeishuClient


@pytest.fixture
def feishu_client():
    """创建飞书客户端实例"""
    # 使用测试环境变量
    with patch.dict(os.environ, {
        "FEISHU_APP_ID": "test_app_id",
        "FEISHU_APP_SECRET": "test_app_secret"
    }):
        return FeishuClient()


@pytest.fixture
def mock_lark_client():
    """创建模拟的lark客户端"""
    mock = MagicMock()
    return mock


class TestFeishuClient:
    """测试FeishuClient类"""

    def test_init_with_env_vars(self):
        """测试使用环境变量初始化"""
        with patch.dict(os.environ, {
            "FEISHU_APP_ID": "env_app_id",
            "FEISHU_APP_SECRET": "env_app_secret"
        }):
            client = FeishuClient()
            assert client.app_id == "env_app_id"
            assert client.app_secret == "env_app_secret"

    def test_init_with_params(self):
        """测试使用参数初始化"""
        client = FeishuClient(app_id="param_app_id", app_secret="param_app_secret")
        assert client.app_id == "param_app_id"
        assert client.app_secret == "param_app_secret"

    def test_get_wiki_spaces(self, feishu_client):
        """测试获取知识库列表"""
        # 模拟响应数据
        mock_response = MagicMock()
        mock_response.success.return_value = True
        mock_response.data = MagicMock()
        mock_item = MagicMock()
        mock_item.space_id = "space123"
        mock_item.name = "测试知识库"
        mock_item.description = "测试描述"
        mock_item.visibility = "public"
        mock_item.create_time = "2024-01-01"
        mock_item.update_time = "2024-01-02"
        mock_response.data.items = [mock_item]

        # 模拟lark客户端
        with patch.object(feishu_client.client.wiki.v2.wiki_space, 'list', return_value=mock_response):
            spaces = feishu_client.get_wiki_spaces()
            assert len(spaces) == 1
            assert spaces[0]["space_id"] == "space123"
            assert spaces[0]["name"] == "测试知识库"

    def test_get_wiki_spaces_error(self, feishu_client):
        """测试获取知识库列表失败"""
        mock_response = MagicMock()
        mock_response.success.return_value = False
        mock_response.code = 999
        mock_response.msg = "认证失败"

        with patch.object(feishu_client.client.wiki.v2.wiki_space, 'list', return_value=mock_response):
            with pytest.raises(Exception, match="获取知识库列表失败"):
                feishu_client.get_wiki_spaces()

    def test_get_wiki_nodes(self, feishu_client):
        """测试获取节点列表"""
        mock_response = MagicMock()
        mock_response.success.return_value = True
        mock_response.data = MagicMock()

        mock_child = MagicMock()
        mock_child.token = "node123"
        mock_child.node_type = "doc"
        mock_child.obj_token = "obj123"
        mock_child.title = "测试文档"
        mock_child.has_child = False
        mock_response.data.children = [mock_child]

        with patch.object(feishu_client.client.wiki.v2.wiki_node, 'get', return_value=mock_response):
            nodes = feishu_client.get_wiki_nodes("space123")
            assert len(nodes) == 1
            assert nodes[0]["node_token"] == "node123"
            assert nodes[0]["node_type"] == "doc"

    def test_get_doc_content(self, feishu_client):
        """测试获取文档内容"""
        mock_response = MagicMock()
        mock_response.success.return_value = True
        mock_response.data = MagicMock()
        mock_response.data.document = MagicMock()
        mock_response.data.document.document_id = "doc123"
        mock_response.data.document.title = "测试文档"
        mock_response.data.document.revision_id = "rev123"
        mock_response.data.document.token = "token123"

        with patch.object(feishu_client.client.doc.v2.document, 'get', return_value=mock_response):
            content = feishu_client.get_doc_content("doc123")
            assert content["document_id"] == "doc123"
            assert content["title"] == "测试文档"

    def test_get_doc_blocks(self, feishu_client):
        """测试获取文档块内容"""
        mock_response = MagicMock()
        mock_response.success.return_value = True
        mock_response.data = MagicMock()

        mock_block = MagicMock()
        mock_block.block_id = "block123"
        mock_block.block_type = "text"
        mock_block.paragraph = MagicMock()
        mock_block.paragraph.elements = [{"type": "text_run", "text_run": {"content": "测试"}}]
        mock_response.data.children = [mock_block]

        with patch.object(feishu_client.client.doc.v2.document_block, 'get', return_value=mock_response):
            blocks = feishu_client.get_doc_blocks("doc123")
            assert len(blocks) == 1
            assert blocks[0]["block_id"] == "block123"

    def test_save_wiki_to_db(self, feishu_client, tmp_path):
        """测试保存知识库到数据库"""
        # 模拟知识库数据
        mock_response = MagicMock()
        mock_response.success.return_value = True
        mock_response.data = MagicMock()

        mock_item = MagicMock()
        mock_item.space_id = "space123"
        mock_item.name = "测试知识库"
        mock_item.description = "测试描述"
        mock_item.visibility = "public"
        mock_item.create_time = "2024-01-01"
        mock_item.update_time = "2024-01-02"
        mock_response.data.items = [mock_item]

        with patch.object(feishu_client.client.wiki.v2.wiki_space, 'list', return_value=mock_response):
            db_path = tmp_path / "test.db"
            count = feishu_client.save_wiki_to_db(str(db_path))

            assert count == 1

            # 验证数据库内容
            conn = sqlite3.connect(db_path)
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM wiki_spaces")
            assert cursor.fetchone()[0] == 1
            cursor.execute("SELECT name FROM wiki_spaces WHERE id=?", ("space123",))
            result = cursor.fetchone()
            assert result[0] == "测试知识库"
            conn.close()

    def test_export_wiki_docs(self, feishu_client, tmp_path):
        """测试导出知识库文档"""
        # 模拟节点响应
        nodes_response = MagicMock()
        nodes_response.success.return_value = True
        nodes_response.data = MagicMock()

        mock_child = MagicMock()
        mock_child.token = "node123"
        mock_child.node_type = "doc"
        mock_child.obj_token = "doc123"
        mock_child.title = "测试文档"
        mock_child.has_child = False
        nodes_response.data.children = [mock_child]

        # 模拟文档内容响应
        doc_response = MagicMock()
        doc_response.success.return_value = True
        doc_response.data = MagicMock()
        doc_response.data.document = MagicMock()
        doc_response.data.document.document_id = "doc123"
        doc_response.data.document.title = "测试文档"
        doc_response.data.document.revision_id = "rev123"
        doc_response.data.document.token = "token123"

        # 模拟块响应
        blocks_response = MagicMock()
        blocks_response.success.return_value = True
        blocks_response.data = MagicMock()
        blocks_response.data.children = []

        with patch.object(feishu_client.client.wiki.v2.wiki_node, 'get', return_value=nodes_response), \
             patch.object(feishu_client.client.doc.v2.document, 'get', return_value=doc_response), \
             patch.object(feishu_client.client.doc.v2.document_block, 'get', return_value=blocks_response):

            output_dir = tmp_path / "output"
            count = feishu_client.export_wiki_docs("space123", output_dir)

            assert count == 1
            assert (output_dir / "测试文档.json").exists()

            # 验证文件内容
            with open(output_dir / "测试文档.json", "r", encoding="utf-8") as f:
                data = json.load(f)
                assert data["title"] == "测试文档"

    def test_export_wiki_docs_empty_nodes(self, feishu_client, tmp_path):
        """测试导出空知识库"""
        mock_response = MagicMock()
        mock_response.success.return_value = True
        mock_response.data = MagicMock()
        mock_response.data.children = []

        with patch.object(feishu_client.client.wiki.v2.wiki_node, 'get', return_value=mock_response):
            output_dir = tmp_path / "output"
            count = feishu_client.export_wiki_docs("space123", output_dir)

            assert count == 0

    def test_export_wiki_docs_error_handling(self, feishu_client, tmp_path):
        """测试导出时的错误处理"""
        # 模拟失败响应
        mock_response = MagicMock()
        mock_response.success.return_value = False
        mock_response.code = 999
        mock_response.msg = "权限错误"

        with patch.object(feishu_client.client.wiki.v2.wiki_node, 'get', return_value=mock_response):
            output_dir = tmp_path / "output"
            # 不应该抛出异常，而是捕获并打印错误
            count = feishu_client.export_wiki_docs("space123", output_dir)
            assert count == 0
