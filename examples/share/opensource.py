#!/usr/bin/env python3
"""Open-source private repos to public repos with LLM-based sanitization.

Usage:
    python3 opensource.py <project> [version]
"""

import configparser
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

from quanttide_agent import LLM, Message

DETECT_PROMPT = """You are reviewing source code that will be published to a public GitHub repository.
Find ANY sensitive information that must be removed before publishing.

Types of sensitive info to detect:
- Email addresses (replace "user@domain.com" with "user@example.com")
- Internal domain names (replace "company.com", "corp.net" with "example.com")
- API keys, tokens, secrets (replace with "sk-xxx")
- Internal server URLs, IP addresses (replace with "https://api.example.com")
- Employee/customer names paired with contact info (replace names with "Example User")
- Internal project codenames (replace with "example-project")
- Real phone numbers (replace with "000-0000-0000")
- Any confidential business logic comments

You are given multiple files below, separated by "--- filename ---" markers.
Respond with a SINGLE JSON array. Each element is:
{
  "file": "relative/path/to/file.rs",
  "findings": [
    {"sensitive": "hr@example.com", "replace_with": "hr@example.com", "reason": "Internal email address"}
  ]
}

If no sensitive info is found in any files, respond with an empty array [].

Be thorough. Check every string literal, comment, config value, and docstring.
"""


COMMIT_DECISION_PROMPT = """You are an AI assistant helping to open-source internal code.

Below is the git diff of changes to be published to a public repository.

Your task:
1. Review the diff carefully
2. Decide if these changes should be committed (they might be empty, trivial, or incomplete)
3. If yes, write a clear commit message
4. If no, explain why

Respond with JSON:
{
  "should_commit": true,
  "commit_message": "feat: add email ETL pipeline\n\nAutomated email fetching, attachment download, and LLM classification for recruitment.",
  "reasoning": "This adds a complete new module with working code."
}

Or if not ready:
{
  "should_commit": false,
  "commit_message": "",
  "reasoning": "The diff only contains placeholder files with no real implementation."
}
"""


DESTINATION_PROMPT = """You decide where to place source code in a public repository.

The public repo has these existing examples:
{existing_examples}

The source code to be open-sourced has this structure:
{source_structure}

Key files and their purposes:
{source_summary}

Decide:
1. Does this code FIT into an existing examples/ subdirectory? If so, which one?
2. Or should it go into a NEW examples/ subdirectory?

Respond with JSON:
{{
  "destination": "examples/connect",
  "reasoning": "...",
  "new_folder_name": null
}}

Or for a new folder:
{{
  "destination": "examples/my-new-module",
  "reasoning": "...",
  "new_folder_name": "my-new-module"
}}

Rules:
- Prefer existing folders if the code is semantically related
- Use `examples/` as the base directory
- The destination should be relative to the public repo root
- If creating new, use kebab-case for folder names
"""


def load_config(project: str) -> dict:
    conf_path = Path(__file__).parent / "opensource.conf"
    parser = configparser.ConfigParser()
    parser.read(conf_path)
    if project not in parser:
        print(f"错误: 配置中找不到项目 [{project}]")
        sys.exit(1)
    cfg = dict(parser[project])
    for key in ("private_src", "public_dst"):
        if key in cfg:
            cfg[key] = os.path.expanduser(cfg[key])
    return cfg


def rsync_copy(
    src: str, dst: str, sync_src: str | None, sync_dst: str | None, exclude: str | None
):
    excludes = [
        ".git",
        ".git/",
        "target/",
        "data/",
        "node_modules/",
        ".cursor",
        ".venv/",
        "__pycache__/",
        "*.pyc",
        ".coverage",
        ".pytest_cache/",
        ".DS_Store",
    ]
    if exclude:
        excludes.extend(exclude.split())

    dst_dir = Path(dst) / sync_dst if sync_dst else Path(dst)
    dst_dir.mkdir(parents=True, exist_ok=True)

    src_path = Path(src)
    rsync_args = ["rsync", "-av"]
    for e in excludes:
        rsync_args.extend(["--exclude", e])

    if sync_src:
        for item in sync_src.split():
            item = item.rstrip("/")
            full_src = src_path / item
            if full_src.exists():
                subprocess.run(
                    [*rsync_args, str(full_src), str(dst_dir) + "/"], check=True
                )
    else:
        subprocess.run(
            [*rsync_args, str(src_path) + "/", str(dst_dir) + "/"], check=True
        )

    return dst_dir


def find_source_files(dst_dir: Path) -> list[Path]:
    files = []
    for ext in (".rs", ".py", ".md", ".toml", ".json", ".yaml", ".yml"):
        files.extend(dst_dir.rglob(f"*{ext}"))
    # Exclude .git, target, node_modules
    return [
        f
        for f in files
        if not any(
            p.name in (".git", "target", "node_modules")
            or p.name.startswith(".")
            and p.is_dir()
            for p in f.relative_to(dst_dir).parents
        )
    ]


def llm_decide_destination(
    src_private: str, dst_public: str, sync_src: str | None, llm: LLM
) -> str:
    """Use LLM to determine where in the public repo the code should go."""
    src_path = Path(src_private)
    dst_path = Path(dst_public)

    # List existing examples/
    examples_dir = dst_path / "examples"
    if examples_dir.exists():
        existing = [
            str(p.relative_to(dst_path)) for p in examples_dir.iterdir() if p.is_dir()
        ]
        existing_examples = (
            "\n".join(f"  {e}/" for e in existing) if existing else "  (none)"
        )
    else:
        existing_examples = "  (no examples/ directory yet)"

    # Summarize source code
    src_items = sync_src.split() if sync_src else ["."]
    structure_lines = []
    summary_lines = []
    for item in src_items[:8]:  # limit
        item = item.rstrip("/")
        full = src_path / item
        if full.is_dir():
            files = list(full.rglob("*"))[:20]
            py_files = [f for f in files if f.suffix == ".py"]
            rs_files = [f for f in files if f.suffix == ".rs"]
            md_files = [f for f in files if f.suffix == ".md"]
            toml_files = [f for f in files if f.name == "Cargo.toml"]

            structure_lines.append(f"  {item}/")
            for f in files[:8]:
                structure_lines.append(f"    {f.name}")

            # Read key files for summary
            for f in py_files[:2] + rs_files[:2] + md_files[:1] + toml_files[:1]:
                try:
                    content = f.read_text(encoding="utf-8", errors="replace")[:800]
                    summary_lines.append(
                        f"\n--- {f.relative_to(src_path)} ---\n{content}"
                    )
                except Exception:
                    pass
        elif full.is_file():
            structure_lines.append(f"  {item}")
            if full.suffix in (".rs", ".py", ".md"):
                try:
                    content = full.read_text(encoding="utf-8", errors="replace")[:500]
                    summary_lines.append(f"\n--- {item} ---\n{content}")
                except Exception:
                    pass

    source_structure = "\n".join(structure_lines)
    source_summary = "\n".join(summary_lines)

    user_content = DESTINATION_PROMPT.format(
        existing_examples=existing_examples,
        source_structure=source_structure,
        source_summary=source_summary[:4000],
    )

    messages = [
        Message(
            role="system",
            content="You decide where code goes in a public repo. Respond with JSON.",
        ),
        Message(role="user", content=user_content),
    ]

    try:
        resp = llm.complete(
            messages, temperature=0.0, response_format={"type": "json_object"}
        )
        decision = json.loads(resp.content)
        dest = decision.get("destination", "")
        if dest:
            print(f"  LLM 决定: {dest}")
            print(f"  理由: {decision.get('reasoning', '')}")
            return dest
    except Exception as e:
        print(f"  LLM 决策失败: {e}，使用默认路径")

    return "examples"


def llm_sanitize(dst_dir: Path, llm: LLM):
    files = find_source_files(dst_dir)
    if not files:
        return

    # Batch files to avoid overwhelming LLM context
    batch_size = 5
    all_replacements = []

    for i in range(0, len(files), batch_size):
        batch = files[i : i + batch_size]
        user_content_parts = []

        for f in batch:
            rel = f.relative_to(dst_dir)
            try:
                content = f.read_text(encoding="utf-8", errors="replace")
            except Exception:
                continue

            # Skip binary/generated files and large files
            if f.suffix in (".json", ".lock") and f.name == "Cargo.lock":
                continue
            if len(content) > 50000:
                continue

            # Truncate very long files
            if len(content) > 15000:
                content = content[:15000] + "\n... [truncated]"

            user_content_parts.append(f"--- {rel} ---\n{content}")

        if not user_content_parts:
            continue

        user_content = "\n".join(user_content_parts)

        messages = [
            Message(role="system", content=DETECT_PROMPT),
            Message(role="user", content=user_content),
        ]

        try:
            resp = llm.complete(
                messages, temperature=0.0, response_format={"type": "json_object"}
            )
            result = json.loads(resp.content)
            if not isinstance(result, list):
                result = result.get("results", result.get("files", []))
                if isinstance(result, dict):
                    result = [result]

            findings_list = []
            for item in result if isinstance(result, list) else []:
                findings_list.extend(item.get("findings", []))

            for finding in findings_list:
                sensitive = finding.get("sensitive", "").strip()
                replacement = finding.get("replace_with", "").strip()
                if sensitive and replacement and sensitive != replacement:
                    all_replacements.append(
                        (sensitive, replacement, finding.get("reason", ""))
                    )
        except Exception as e:
            print(f"  [注意] LLM 分析批次 {i // batch_size + 1} 失败: {e}")
            continue

    # Deduplicate by (sensitive, replacement) pair
    seen = set()
    unique_repl = []
    for s, r, reason in all_replacements:
        key = (s.lower(), r.lower())
        if key not in seen:
            seen.add(key)
            unique_repl.append((s, r, reason))

    if not unique_repl:
        print("  未检测到敏感内容")
        return

    print(f"  LLM 检测到 {len(unique_repl)} 个敏感模式:")
    for sensitive, replacement, reason in unique_repl:
        print(f"    '{sensitive}' → '{replacement}'  ({reason})")

    # Apply replacements across all files
    count_files = set()
    for sensitive, replacement, _ in unique_repl:
        for f in files:
            try:
                content = f.read_text(encoding="utf-8", errors="replace")
                new_content = content.replace(sensitive, replacement)
                if new_content != content:
                    f.write_text(new_content, encoding="utf-8")
                    count_files.add(f)
            except Exception:
                continue

    print(f"  ✓ 已脱敏 {len(count_files)} 个文件")


def run_build(build_cmd: str, work_dir: Path):
    print(f"\n=== 编译验证: {build_cmd} ===")
    result = subprocess.run(
        build_cmd, shell=True, cwd=work_dir, capture_output=True, text=True
    )
    if result.returncode != 0:
        print(result.stderr)
        print("  ✗ 编译失败，发布中止")
        sys.exit(1)
    # Print last line of output
    lines = result.stdout.strip().split("\n")
    if lines:
        print(f"  {lines[-1]}")
    print("  ✓ 编译通过")


def git_commit(dst_dir: Path, sync_dst: str | None, version: str | None, llm: LLM):
    print(f"\n=== git: {dst_dir} ===")
    os.chdir(dst_dir)

    # Fix .git pointer if needed
    git_file = dst_dir / ".git"
    if git_file.is_file():
        gitdir_content = git_file.read_text().strip()
        if gitdir_content.startswith("gitdir:"):
            gitdir_path = gitdir_content.split("gitdir:", 1)[1].strip()
            if not Path(gitdir_path).exists():
                print("  .git 指针损坏，重新修复")
                git_file.unlink()
                subprocess.run(["git", "init"], capture_output=True)

    # Stage changes
    add_path = sync_dst or "."
    subprocess.run(["git", "add", "-A", add_path], check=True)

    # Check if there are staged changes
    result = subprocess.run(["git", "diff", "--cached", "--quiet"], capture_output=True)
    if result.returncode == 0:
        print("  无变更，跳过 commit")
        return

    # Get the diff for LLM to review
    diff_result = subprocess.run(
        ["git", "diff", "--cached", "--stat"], capture_output=True, text=True
    )
    diff_stat = diff_result.stdout.strip()

    diff_full = subprocess.run(
        ["git", "diff", "--cached"], capture_output=True, text=True
    )
    diff_content = diff_full.stdout
    # Truncate very long diffs
    if len(diff_content) > 12000:
        diff_content = diff_content[:12000] + "\n... [diff truncated]"

    # Ask LLM to decide
    user_content = f"Repository: {dst_dir.name}\nSync path: {add_path}\n\nDiff stat:\n{diff_stat}\n\nFull diff:\n{diff_content}"
    if version:
        user_content += f"\n\nRequested version tag: {version}"

    messages = [
        Message(role="system", content=COMMIT_DECISION_PROMPT),
        Message(role="user", content=user_content),
    ]

    decision = {}
    try:
        resp = llm.complete(
            messages, temperature=0.0, response_format={"type": "json_object"}
        )
        decision = json.loads(resp.content)
    except Exception as e:
        print(f"  LLM 决策失败: {e}，使用默认行为")

    if decision.get("should_commit") is False:
        print(f"  LLM 决定不提交: {decision.get('reasoning', '')}")
        subprocess.run(["git", "reset", "HEAD"], capture_output=True)
        return

    commit_msg = (
        decision.get("commit_message", "")
        or f"opensource: 同步 {sync_dst or dst_dir.name}"
    )
    if version and "版本" not in commit_msg:
        commit_msg += f"\n\n版本: {version}"

    subprocess.run(["git", "commit", "-m", commit_msg], check=True)
    print(f"  ✓ 已提交: {commit_msg.split(chr(10))[0]}")

    # Tag
    if version:
        result = subprocess.run(["git", "rev-parse", version], capture_output=True)
        if result.returncode == 0:
            print(f"  tag {version} 已存在，跳过")
        else:
            subprocess.run(["git", "tag", version], check=True)
            print(f"  ✓ 已打 tag: {version}")


def main():
    if len(sys.argv) < 2:
        print(__doc__.strip())
        sys.exit(1)

    project = sys.argv[1]
    version = sys.argv[2] if len(sys.argv) > 2 else None

    cfg = load_config(project)
    src_private = cfg.get("private_src", "")
    dst_public = cfg.get("public_dst", "")
    sync_src = cfg.get("sync_src")
    sync_dst = cfg.get("sync_dst")
    build_cmd = cfg.get("build_cmd")
    exclude = cfg.get("exclude")

    if not src_private or not dst_public:
        print("错误: private_src 和 public_dst 为必填")
        sys.exit(1)

    # Init LLM
    llm = LLM(
        model=os.getenv("AI_REVIEW_MODEL"),
        base_url=os.getenv("AI_REVIEW_BASE_URL"),
        api_key=os.getenv("AI_REVIEW_API_KEY") or os.getenv("OPENAI_API_KEY"),
    )

    # Step 0: Determine destination (LLM decides if not hardcoded)
    if not sync_dst:
        print("\n=== LLM 判断目标位置 ===")
        sync_dst = llm_decide_destination(src_private, dst_public, sync_src, llm)

    # Step 1: Copy
    print(f"=== 复制: {src_private} → {dst_public} ===")
    dst_dir = rsync_copy(src_private, dst_public, sync_src, sync_dst, exclude)
    if sync_dst:
        dst_dir = Path(dst_public) / sync_dst

    # Step 2: LLM sanitize
    print("\n=== LLM 脱敏 ===")
    llm_sanitize(dst_dir, llm)

    # Step 3: Build
    if build_cmd:
        run_build(build_cmd, Path(dst_public))

    # Step 4: Git commit
    git_commit(Path(dst_public), sync_dst, version, llm)

    print(f"\n=== 完成 ===")
    print(f"目标: {dst_dir}")
    print(f"\n下一步:")
    print(f"  cd {dst_public} && git push --tags")


if __name__ == "__main__":
    main()
