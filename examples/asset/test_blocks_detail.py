import sys, os
sys.path.insert(0, '/Users/mac/repos/qtadmin/examples/asset')
os.chdir('/Users/mac/repos/qtadmin/examples/asset')
from dotenv import load_dotenv
load_dotenv()
import lark_oapi as lark
from feishu_client import FeishuClient

client = FeishuClient()
doc_token = 'Byxsd9U7ZoIWLEx0skAcqhUJnRh'  # 人力资源标准化

# 获取文档块
req = lark.api.docx.v1.GetDocumentBlockChildrenRequest.builder() \
    .document_id(doc_token) \
    .block_id(doc_token) \
    .page_size(100) \
    .build()

resp = client.client.docx.v1.document_block_children.get(req)

if resp.success():
    items = resp.data.items or []
    print(f'块数量: {len(items)}\n')
    for i, item in enumerate(items):
        print(f'块{i}: type={item.block_type}')
        print()
