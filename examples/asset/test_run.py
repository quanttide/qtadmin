"""
测试运行脚本 - 只测试GitHub部分
"""

import os
import sys
from pathlib import Path

# 添加src目录到路径
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "src" / "provider"))

from feishu_client import FeishuClient
from github_client import GitHubClient

def test_github_only():
    """只测试GitHub功能"""
    print("\n")
    print("╔" + "=" * 58 + "╗")
    print("║" + " " * 15 + "测试GitHub功能" + " " * 29 + "║")
    print("╚" + "=" * 58 + "╝")
    print()

    if not os.getenv("GITHUB_TOKEN"):
        print("⚠ 警告: 未设置GITHUB_TOKEN环境变量")
        print("  将使用只读模式测试公开仓库")
        print()

    client = GitHubClient()

    # 测试获取公开仓库信息
    print("步骤1: 获取公开仓库信息")
    print("-" * 60)
    try:
        # 使用公开仓库测试
        repo_info = client.get_repository_info("octocat", "Hello-World")
        print(f"✓ 仓库名称: {repo_info['name']}")
        print(f"✓ 仓库描述: {repo_info['description']}")
        print(f"✓ 默认分支: {repo_info['default_branch']}")
        print(f"✓ 语言: {repo_info['language']}")
        print(f"✓ Stars: {repo_info['stargazers_count']}")
        print()
    except Exception as e:
        print(f"✗ 失败: {e}")
        print()

    # 测试获取分支
    print("步骤2: 获取分支列表")
    print("-" * 60)
    try:
        branches = client.get_branches("octocat", "Hello-World")
        print(f"✓ 分支数量: {len(branches)}")
        for branch in branches[:5]:  # 只显示前5个
            print(f"  - {branch['name']} ({branch['commit']['sha'][:7]})")
        print()
    except Exception as e:
        print(f"✗ 失败: {e}")
        print()

    # 测试克隆仓库
    print("步骤3: 克隆仓库到本地")
    print("-" * 60)
    try:
        data_dir = Path(__file__).parent.parent.parent / "data" / "asset"
        data_dir.mkdir(parents=True, exist_ok=True)
        github_dir = data_dir / "github"

        repo_dir = client.clone_repo("octocat", "Hello-World", github_dir)
        print(f"✓ 仓库已克隆到: {repo_dir}")
        print()

        # 检查克隆的文件
        if repo_dir.exists():
            files = list(repo_dir.iterdir())
            print(f"✓ 仓库包含 {len(files)} 个文件/目录")
            for f in sorted(files)[:10]:
                print(f"  - {f.name}")
            print()
    except Exception as e:
        print(f"✗ 失败: {e}")
        print()

    print("╔" + "=" * 58 + "╗")
    print("║" + " " * 18 + "测试完成！" + " " * 28 + "║")
    print("╚" + "=" * 58 + "╝")
    print()


if __name__ == "__main__":
    test_github_only()
