"""
知识获取程序：使用 LLM 从原始文件中提取结构化知识。

输入：assets/business/（章程/手册/教程/档案原始文件）
参考：assets/acquisition.md（输出格式参考样例）
输出：data/extracted.yaml
"""

import os
import json
import yaml
from pathlib import Path
from openai import OpenAI


ROOT = Path(__file__).resolve().parent.parent
ASSETS_DIR = ROOT / "assets"
OUTPUT_DIR = ROOT / "data"

SYSTEM_PROMPT = """你是一个知识提取工具。从原始文档中提取业务规则并评估其可编码性。

输出 JSON，包含：
1. rules: 逐条规则（name, source, score, reason），score 为 1-5
2. rate: 可编码率（≥4分的规则占比）
3. ambiguities: 文档中的模糊点（category, description）
4. issues: 影响编码的具体问题（title, source, problem, suggestion）
5. observations: 值得记录的分析观察

评分标准：5=直接可编码，4=微调后可编码，3=需补充信息，2=模糊需重写，1=无法编码"""


def extract_with_llm(text: str) -> dict:
    api_key = os.environ.get("DEEPSEEK_API_KEY")
    if not api_key:
        raise ValueError("DEEPSEEK_API_KEY 未设置")
    client = OpenAI(api_key=api_key, base_url="https://api.deepseek.com")
    resp = client.chat.completions.create(
        model="deepseek-chat",
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": f"从以下原始文档中提取知识：\n\n{text}"},
        ],
        response_format={"type": "json_object"},
    )
    return json.loads(resp.choices[0].message.content)


def main():
    sources = {
        "bylaw": ASSETS_DIR / "business" / "bylaw.md",
        "handbook": ASSETS_DIR / "business" / "handbook.md",
        "tutorial": ASSETS_DIR / "business" / "tutorial.md",
        "profile": ASSETS_DIR / "business" / "profile" / "index.md",
    }

    combined = ""
    for name, path in sources.items():
        if path.exists():
            combined += f"=== {name} ===\n{path.read_text(encoding='utf-8')}\n\n"

    print(f"读取 {len(sources)} 份原始文件，共 {len(combined)} 字符")

    data = extract_with_llm(combined)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_DIR / "extracted.yaml", "w", encoding="utf-8") as f:
        yaml.dump(data, f, allow_unicode=True, indent=2, sort_keys=False)

    print(f"规则数: {len(data.get('rules', []))}")
    print(f"可编码率: {data.get('rate', 'N/A')}%")
    print(f"模糊点: {len(data.get('ambiguities', []))} 条")
    print(f"编码问题: {len(data.get('issues', []))} 个")
    print(f"\n输出: {OUTPUT_DIR / 'extracted.yaml'}")


if __name__ == "__main__":
    main()
