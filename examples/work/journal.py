#!/usr/bin/env python3
"""
Journal Event Extraction Module

Extract structured event memories from raw founder journal entries,
and generate cleaned diary entries in MYST markdown format.

Usage:
    python examples/work/journal.py
"""

import os
import re
import json
import time
import logging
from pathlib import Path
from uuid import UUID, uuid4
from collections import defaultdict

from dotenv import load_dotenv
from openai import OpenAI
from pydantic import BaseModel

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger(__name__)

BASE_DIR = Path("data/asset/quanttide-journal-of-founder")
RAW_DIR = BASE_DIR / "raw"
EVENT_DIR = BASE_DIR / "memory" / "event"
DIARY_DIR = BASE_DIR / "journal" / "diary"

DASHSCOPE_BASE_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1"
DEFAULT_MODEL = "deepseek-v3"
MAX_RETRIES = 3


class Event(BaseModel):
    id: UUID = uuid4()
    title: str
    description: str


class JournalProcessor:
    def __init__(self, model: str = DEFAULT_MODEL):
        api_key = os.getenv("DASHSCOPE_API_KEY") or os.getenv("LLM_API_KEY")
        if not api_key:
            raise ValueError("DASHSCOPE_API_KEY or LLM_API_KEY not found in .env")
        
        self.client = OpenAI(
            api_key=api_key,
            base_url=DASHSCOPE_BASE_URL,
        )
        self.model = model
        logger.info(f"Using model: {self.model}")

    def group_files_by_date(self) -> dict[str, list[Path]]:
        """Group raw files by date."""
        files = sorted(RAW_DIR.glob("*.md"))
        groups = defaultdict(list)
        
        for f in files:
            match = re.match(r"(\d{4}-\d{2}-\d{2})_\d+", f.stem)
            if match:
                date = match.group(1)
                groups[date].append(f)
        
        return dict(groups)

    def load_raw_content(self, files: list[Path]) -> str:
        """Load and merge raw content from multiple files."""
        contents = []
        for f in sorted(files):
            content = f.read_text(encoding="utf-8")
            contents.append(content)
        return "\n\n---\n\n".join(contents)

    def extract_events(self, content: str) -> list[Event]:
        """Extract events from raw journal content using LLM."""
        prompt = f"""这是原始文件，我们现在要提取其中的事件记忆。

要求：
1. 返回多行JSONL格式（每行一个JSON对象）
2. 每个事件必须包含 id（使用UUID格式）、title、description
3. 不要有其他内容，不要有markdown代码块标记

日志内容：
{content}

请直接返回JSONL格式："""

        response = self._call_llm(prompt)
        return self._parse_events_jsonl(response)

    def clean_journal(self, content: str, date: str) -> str:
        """Clean and restructure journal content using LLM in MYST format."""
        prompt = f"""使用以下事件生成一个新的工作日志。

要求：
1. 使用MYST Markdown格式
2. 开头必须有YAML frontmatter，包含date和title字段
3. 使用层级标题（# ## ###）组织内容
4. 保持原始语义，去除噪音
5. 结尾使用---分隔线
6. 用中文撰写

日期：{date}

事件内容：
{content}

请直接返回MYST Markdown格式："""

        response = self._call_llm(prompt)
        return self._extract_markdown(response)

    def _call_llm(self, prompt: str) -> str:
        """Call LLM with retry logic and exponential backoff."""
        for attempt in range(1, MAX_RETRIES + 1):
            try:
                response = self.client.chat.completions.create(
                    model=self.model,
                    messages=[{"role": "user", "content": prompt}],
                    temperature=0.7,
                )
                content = response.choices[0].message.content
                if content is None:
                    raise ValueError("Empty response from LLM")
                return content
            except Exception as e:
                logger.warning(f"Attempt {attempt}/{MAX_RETRIES} failed: {e}")
                if attempt < MAX_RETRIES:
                    sleep_time = 2 ** attempt
                    logger.info(f"Retrying in {sleep_time}s...")
                    time.sleep(sleep_time)
                else:
                    raise
        return ""

    def _parse_events_jsonl(self, response: str) -> list[Event]:
        """Parse JSONL response into Event objects."""
        if not response or not response.strip():
            logger.warning("Empty response from LLM")
            return []

        content = response.strip()
        if content.startswith("```"):
            lines = content.split("```")[1].split("\n")
            content = "\n".join(line for line in lines if line.strip())

        events = []
        for line in content.strip().split("\n"):
            line = line.strip()
            if not line:
                continue
            try:
                item = json.loads(line)
                events.append(Event(
                    id=uuid4(),
                    title=item.get("title", ""),
                    description=item.get("description", ""),
                ))
            except json.JSONDecodeError:
                logger.warning(f"Failed to parse line: {line[:50]}...")
                continue

        if not events:
            logger.warning("No events parsed from response")
        return events

    def _extract_markdown(self, response: str) -> str:
        """Extract markdown content from LLM response."""
        content = response.strip()
        if content.startswith("```markdown"):
            content = content[11:]
        elif content.startswith("```myst"):
            content = content[8:]
        elif content.startswith("```"):
            content = content[3:]
        if content.endswith("```"):
            content = content[:-3]
        return content.strip()

    def save_day(self, date: str, events: list[Event], diary: str):
        """Save events and diary for a single day."""
        EVENT_DIR.mkdir(parents=True, exist_ok=True)
        DIARY_DIR.mkdir(parents=True, exist_ok=True)

        event_path = EVENT_DIR / f"{date}.jsonl"
        with open(event_path, "w", encoding="utf-8") as f:
            for event in events:
                f.write(json.dumps(event.model_dump(mode="json"), ensure_ascii=False) + "\n")
        logger.info(f"Saved {len(events)} events to {event_path}")

        diary_path = DIARY_DIR / f"{date}.md"
        diary_path.write_text(diary, encoding="utf-8")
        logger.info(f"Saved diary to {diary_path}")

    def process_date(self, date: str, files: list[Path]) -> bool:
        """Process all files for a single date."""
        logger.info(f"Processing date: {date} ({len(files)} files)")

        content = self.load_raw_content(files)
        if not content.strip():
            logger.warning(f"Empty content for date: {date}")
            return False

        try:
            events = self.extract_events(content)
            if not events:
                logger.warning(f"No events extracted for {date}")
            
            diary = self.clean_journal(content, date)
            if not diary:
                logger.warning(f"No diary generated for {date}")

            self.save_day(date, events, diary)
            return True

        except Exception as e:
            logger.error(f"Failed to process date {date}: {e}")
            return False

    def process_all(self) -> int:
        """Process all files grouped by date."""
        date_groups = self.group_files_by_date()
        logger.info(f"Found {len(date_groups)} dates to process")

        success_count = 0
        for date, files in sorted(date_groups.items()):
            if self.process_date(date, files):
                success_count += 1

        logger.info(f"Processed {success_count}/{len(date_groups)} dates successfully")
        return success_count


def main():
    processor = JournalProcessor()
    processor.process_all()


if __name__ == "__main__":
    main()
