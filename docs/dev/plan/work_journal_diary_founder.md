# Journal Event Extraction Plan

## Overview

Extract structured event memories from raw founder journal entries and generate cleaned diary entries.

## Input/Output

- **Input**: `data/asset/quanttide-journal-of-founder/raw/*.md` (e.g., `2026-03-12_0.md`)
- **Output**:
  - Events: `data/asset/quanttide-journal-of-founder/memory/event/2026-03-12.jsonl`
  - Diary: `data/asset/quanttide-journal-of-founder/journal/diary/2026-03-12.md`

## Processing Steps

1. **Group files by date**: Merge files with same date (e.g., `2026-03-12_0.md`, `2026-03-12_1.md` → `2026-03-12`)
2. **Extract events**: Use LLM to extract structured events in JSONL format
3. **Clean journal**: Use LLM to generate MYST-formatted diary
4. **Batch process**: Process all dates in one run
5. **Retry on failure**: Retry up to 3 times with exponential backoff

## Configuration

- API: Aliyun DashScope (DeepSeek model)
- Env vars: `DASHSCOPE_API_KEY` or `LLM_API_KEY`

## Event Model

```json
{
  "id": "uuid",
  "title": "事件标题",
  "description": "事件描述"
}
