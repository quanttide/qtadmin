import sys, os
sys.path.insert(0, '/Users/mac/repos/qtadmin/examples/asset')
os.chdir('/Users/mac/repos/qtadmin/examples/asset')
from dotenv import load_dotenv
load_dotenv()
import lark_oapi as lark
from feishu_client import FeishuClient

client = FeishuClient()
doc_token = 'Byxsd9U7ZoIWLEx0skAcqhUJnRh'  # 人力资源标准化

req = lark.api.docx.v1.GetDocumentBlockChildrenRequest.builder() \
    .document_id(doc_token) \
    .block_id(doc_token) \
    .page_size(100) \
    .build()

resp = client.client.docx.v1.document_block_children.get(req)

if resp.success():
    items = resp.data.items or []
    for item in items:
        block_type = item.block_type
        
        if block_type == 3:  # 一级标题
            if hasattr(item, 'heading1') and item.heading1:
                for elem in item.heading1.elements or []:
                    if hasattr(elem, 'text_run') and elem.text_run:
                        print(f'一级标题: {elem.text_run.content}')
        elif block_type == 2:  # 文本
            if hasattr(item, 'paragraph') and item.paragraph:
                for elem in item.paragraph.elements or []:
                    if hasattr(elem, 'text_run') and elem.text_run:
                        print(f'文本: {elem.text_run.content}')
