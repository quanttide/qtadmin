"""
完整功能测试 - 使用.env中的配置
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv

# 添加src目录到路径
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "src" / "provider"))

from feishu_client import FeishuClient
from github_client import GitHubClient

# 加载环境变量
load_dotenv()

def test_full_functionality():
    """测试完整功能"""
    print("\n")
    print("╔" + "=" * 58 + "╗")
    print("║" + " " * 12 + "完整功能测试" + " " * 34 + "║")
    print("╚" + "=" * 58 + "╝")
    print()

    # 检查环境变量
    github_token = os.getenv("GITHUB_ACCESS_TOKEN")
    feishu_app_id = os.getenv("FEISHU_APP_ID")
    feishu_app_secret = os.getenv("FEISHU_APP_SECRET")

    print("📋 环境变量检查:")
    print("-" * 60)
    print(f"  GitHub Token: {'✓ 已配置' if github_token else '✗ 未配置'}")
    print(f"  飞书 App ID: {'✓ 已配置' if feishu_app_id else '✗ 未配置'}")
    print(f"  飞书 App Secret: {'✓ 已配置' if feishu_app_secret else '✗ 未配置'}")
    print()

    # 测试GitHub功能
    print("=" * 60)
    print("GitHub 功能测试")
    print("=" * 60)
    print()

    client = GitHubClient(token=github_token)

    # 从URL解析仓库信息
    repo_url = os.getenv("GITHUB_REPOSITORY_URL", "")
    if repo_url:
        # 解析URL: https://github.com/quanttide/quanttide-profile-of-standardization
        parts = repo_url.rstrip('/').split('/')
        owner = parts[-2] if len(parts) >= 2 else None
        repo_name = parts[-1] if len(parts) >= 1 else None

        print(f"📍 目标仓库: {owner}/{repo_name}")
        print()

        if owner and repo_name:
            # 测试获取仓库信息
            print("步骤1: 获取仓库信息")
            print("-" * 60)
            try:
                repo_info = client.get_repository_info(owner, repo_name)
                print(f"✓ 仓库名称: {repo_info['name']}")
                print(f"✓ 仓库描述: {repo_info.get('description', 'N/A')}")
                print(f"✓ 默认分支: {repo_info['default_branch']}")
                print(f"✓ 语言: {repo_info.get('language', 'N/A')}")
                print(f"✓ Stars: {repo_info['stargazers_count']}")
                print(f"✓ Forks: {repo_info['forks_count']}")
                print()
            except Exception as e:
                print(f"✗ 失败: {e}")
                print()

            # 测试获取分支
            print("步骤2: 获取分支列表")
            print("-" * 60)
            try:
                branches = client.get_branches(owner, repo_name)
                print(f"✓ 分支数量: {len(branches)}")
                for branch in branches[:10]:
                    print(f"  - {branch['name']} ({branch['commit']['sha'][:7]})")
                if len(branches) > 10:
                    print(f"  ... 还有 {len(branches) - 10} 个分支")
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

                repo_dir = client.clone_repo(owner, repo_name, github_dir)
                print(f"✓ 仓库已克隆到: {repo_dir}")

                # 统计文件
                all_files = list(repo_dir.rglob('*'))
                files = [f for f in all_files if f.is_file() and not str(f).startswith(str(repo_dir / '.git'))]
                print(f"✓ 文件总数: {len(files)}")

                # 显示前10个文件
                print(f"  前10个文件:")
                for f in sorted(files)[:10]:
                    rel_path = f.relative_to(repo_dir)
                    print(f"    - {rel_path}")
                if len(files) > 10:
                    print(f"    ... 还有 {len(files) - 10} 个文件")
                print()
            except Exception as e:
                print(f"✗ 失败: {e}")
                print()
        else:
            print("⚠ 无法解析仓库URL")
            print()
    else:
        print("⚠ 未设置 GITHUB_REPOSITORY_URL")
        print()

    # 测试飞书功能
    print("=" * 60)
    print("飞书 功能测试")
    print("=" * 60)
    print()

    if feishu_app_id and feishu_app_secret:
        feishu_client = FeishuClient(
            app_id=feishu_app_id,
            app_secret=feishu_app_secret
        )

        # 测试获取知识库列表
        print("步骤1: 获取知识库列表")
        print("-" * 60)
        try:
            spaces = feishu_client.get_wiki_spaces()
            print(f"✓ 知识库数量: {len(spaces)}")
            for space in spaces:
                print(f"  - {space['name']} (ID: {space['space_id']})")
            print()
        except Exception as e:
            print(f"✗ 失败: {e}")
            print()

        # 从URL解析space_id
        wiki_url = os.getenv("FEISHU_WIKI_SPACE_URL", "")
        if wiki_url:
            # 解析URL: https://quanttide.feishu.cn/wiki/space/7597327435423615929
            space_id = wiki_url.split('/')[-1]
            print(f"📍 目标知识库 ID: {space_id}")
            print()

            # 测试导出知识库文档
            print("步骤2: 导出知识库文档")
            print("-" * 60)
            try:
                data_dir = Path(__file__).parent.parent.parent / "data" / "asset"
                feishu_dir = data_dir / "feishu"

                count = feishu_client.export_wiki_docs(space_id, feishu_dir)
                print(f"✓ 已导出 {count} 个文档到 {feishu_dir}")
                print()

                # 显示导出的文件
                exported_files = list(feishu_dir.glob('*.json'))
                print(f"  导出的文档:")
                for f in sorted(exported_files)[:10]:
                    print(f"    - {f.name}")
                if len(exported_files) > 10:
                    print(f"    ... 还有 {len(exported_files) - 10} 个文档")
                print()
            except Exception as e:
                print(f"✗ 失败: {e}")
                print()
        else:
            print("⚠ 未设置 FEISHU_WIKI_SPACE_URL")
            print()
    else:
        print("⚠ 未配置飞书应用凭证")
        print()

    print("╔" + "=" * 58 + "╗")
    print("║" + " " * 18 + "测试完成！" + " " * 28 + "║")
    print("╚" + "=" * 58 + "╝")
    print()


if __name__ == "__main__":
    test_full_functionality()
