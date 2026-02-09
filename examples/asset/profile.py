"""
交付：项目根目录的 `data/asset`

步骤：
1. 获取知识库列表并存储到 SQLite。
2. 获取指定知识库"标准化档案"文档的所有文档并存储到`feishu`文件夹。
3. 获取指定 GitHub仓库"量潮标准化档案"并存储到`github`文件夹。
4. 将飞书文档合并为Markdown文档到`quanttide`文件夹。
5. 提交量化内容到GitHub仓库。

工具：
- 飞书官方SDK (lark-oapi)
- GitHub官方SDK (PyGithub)
- JupyterBook
"""

import os
import sys
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv

# 添加src目录到路径
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "src" / "provider"))

from feishu_client import FeishuClient
from github_client import GitHubClient

# 加载环境变量
load_dotenv()


class AssetProfile:
    """资产配置文件处理器"""

    def __init__(self, data_dir: Path):
        """
        初始化

        Args:
            data_dir: 数据目录，默认为 data/asset
        """
        self.data_dir = data_dir
        self.db_path = data_dir / "knowledge_bases.db"
        self.feishu_dir = data_dir / "feishu"
        self.github_dir = data_dir / "github"
        self.jupyterbook_dir = data_dir / "jupyterbook"
        self.quanttide_dir = data_dir / "quanttide"

        # 创建目录
        self.data_dir.mkdir(parents=True, exist_ok=True)
        self.feishu_dir.mkdir(parents=True, exist_ok=True)
        self.github_dir.mkdir(parents=True, exist_ok=True)
        self.jupyterbook_dir.mkdir(parents=True, exist_ok=True)
        self.quanttide_dir.mkdir(parents=True, exist_ok=True)

        # 初始化客户端
        self.feishu_client = FeishuClient()
        self.github_client = GitHubClient()

    def step1_get_knowledge_bases(self):
        """
        步骤1: 获取知识库列表并存储到SQLite
        """
        print("=" * 60)
        print("步骤1: 获取知识库列表并存储到SQLite")
        print("=" * 60)

        count = self.feishu_client.save_wiki_to_db(str(self.db_path))
        print(f"✓ 已保存 {count} 个知识库到 {self.db_path}")

        return count

    def step2_export_feishu_docs(self, space_id: str):
        """
        步骤2: 获取指定知识库"标准化档案"文档的所有文档并存储到feishu文件夹

        Args:
            space_id: 知识库ID
        """
        print("=" * 60)
        print("步骤2: 导出飞书知识库文档")
        print("=" * 60)

        count = self.feishu_client.export_wiki_docs(space_id, self.feishu_dir)
        print(f"✓ 已导出 {count} 个文档到 {self.feishu_dir}")

        return count

    def step3_clone_github_repo(self, owner: str, repo: str, branch: str = None):
        """
        步骤3: 获取指定 GitHub仓库"量潮标准化档案"并存储到github文件夹

        Args:
            owner: 仓库所有者
            repo: 仓库名称
            branch: 分支名称
        """
        print("=" * 60)
        print("步骤3: 克隆GitHub仓库")
        print("=" * 60)

        repo_dir = self.github_client.clone_repo(owner, repo, self.github_dir, branch)
        print(f"✓ 已克隆仓库 {owner}/{repo} 到 {repo_dir}")

        return repo_dir

    def step4_merge_to_markdown(self):
        """
        步骤4: 将飞书文档合并为Markdown文档到quanttide文件夹

        Returns:
            合并的Markdown文件数量
        """
        print("=" * 60)
        print("步骤4: 合并飞书文档为Markdown")
        print("=" * 60)

        import json

        # 读取所有飞书文档
        doc_files = sorted(self.feishu_dir.glob("*.json"))

        if not doc_files:
            print("⚠ 没有找到飞书文档")
            return 0

        # 创建合并后的Markdown文档
        output_file = self.quanttide_dir / "standardization-archive.md"

        with open(output_file, "w", encoding="utf-8") as f:
            # 写入标题
            f.write("# 量潮标准化档案\n\n")
            f.write(f"> 本文档由飞书知识库导出，自动生成于 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write("---\n\n")

            # 遍历所有文档
            for doc_file in doc_files:
                try:
                    with open(doc_file, "r", encoding="utf-8") as df:
                        doc_data = json.load(df)

                    title = doc_data.get("title", "未命名")
                    markdown_content = doc_data.get("markdown_content", "")

                    # 写入文档标题
                    f.write(f"## {title}\n\n")
                    f.write(f"*文档ID: {doc_data.get('document_id', 'N/A')}*\n\n")

                    # 写入文档内容
                    if markdown_content:
                        f.write(markdown_content)
                        f.write("\n")

                    f.write("---\n\n")

                    print(f"  ✓ 合并: {title}")
                except Exception as e:
                    print(f"  ✗ 合并失败 {doc_file.name}: {e}")

        print(f"✓ 已合并 {len(doc_files)} 个文档到 {output_file}")
        return len(doc_files)

    def step5_commit_to_github(self, repo_dir: Path, message: str = "Update from Feishu"):
        """
        步骤5: 提交量化内容到GitHub仓库

        Args:
            repo_dir: 仓库目录
            message: 提交信息
        """
        print("=" * 60)
        print("步骤5: 提交量化内容到GitHub")
        print("=" * 60)

        # 将quanttide内容复制到github仓库
        import shutil

        quanttide_content_dir = repo_dir / "quanttide"
        if quanttide_content_dir.exists():
            shutil.rmtree(quanttide_content_dir)
        shutil.copytree(self.quanttide_dir, quanttide_content_dir)

        # 提交并推送
        success = self.github_client.commit_and_push(repo_dir, message)

        if success:
            print(f"✓ 已提交并推送到GitHub: {message}")
        else:
            print("✗ 提交失败")

        return success

    def generate_jupyterbook(self, source_dir: Path = None):
        """
        生成JupyterBook文档

        Args:
            source_dir: 源内容目录，默认为feishu_dir
        """
        print("=" * 60)
        print("生成JupyterBook文档")
        print("=" * 60)

        source_dir = source_dir or self.feishu_dir

        # 检查是否安装了JupyterBook
        try:
            import subprocess
            subprocess.run(["jupyter-book", "--version"], check=True, capture_output=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("⚠ JupyterBook未安装，正在安装...")
            subprocess.run(
                ["pip", "install", "jupyter-book"],
                check=True,
                capture_output=True
            )

        # 创建JupyterBook项目
        try:
            import subprocess

            # 初始化JupyterBook
            subprocess.run(
                ["jupyter-book", "create", str(self.jupyterbook_dir)],
                check=True,
                capture_output=True
            )

            print(f"✓ JupyterBook项目已创建: {self.jupyterbook_dir}")
        except subprocess.CalledProcessError as e:
            print(f"⚠ JupyterBook创建失败: {e}")

    def run_all(
        self,
        feishu_space_id: str,
        github_owner: str,
        github_repo: str,
        github_branch: str = None
    ):
        """
        运行所有步骤

        Args:
            feishu_space_id: 飞书知识库ID
            github_owner: GitHub仓库所有者
            github_repo: GitHub仓库名称
            github_branch: GitHub分支名称
        """
        print("\n")
        print("╔" + "=" * 58 + "╗")
        print("║" + " " * 10 + "资产配置文件处理流程" + " " * 26 + "║")
        print("╚" + "=" * 58 + "╝")
        print()

        # 步骤1
        self.step1_get_knowledge_bases()
        print()

        # 步骤2
        self.step2_export_feishu_docs(feishu_space_id)
        print()

        # 步骤3
        repo_dir = self.step3_clone_github_repo(github_owner, github_repo, github_branch)
        print()

        # 步骤4: 合并为Markdown
        self.step4_merge_to_markdown()
        print()

        # 步骤5: 提交到GitHub
        self.step5_commit_to_github(repo_dir)
        print()

        # 生成JupyterBook（可选）
        # self.generate_jupyterbook()

        print("\n")
        print("╔" + "=" * 58 + "╗")
        print("║" + " " * 15 + "处理完成！" + " " * 31 + "║")
        print("╚" + "=" * 58 + "╝")
        print()


def main():
    """主函数"""
    # 配置参数
    config = {
        "feishu_space_id": os.getenv("FEISHU_SPACE_ID", ""),
        "github_owner": os.getenv("GITHUB_OWNER", "liangchao"),
        "github_repo": os.getenv("GITHUB_REPO", "standardization-archive"),
        "github_branch": os.getenv("GITHUB_BRANCH", "")
    }

    # 检查必需的配置
    if not config["feishu_space_id"]:
        print("⚠ 警告: 未设置FEISHU_SPACE_ID环境变量")
        print("  飞书步骤将被跳过")

    if not os.getenv("GITHUB_TOKEN"):
        print("⚠ 警告: 未设置GITHUB_TOKEN环境变量")
        print("  步骤4可能会失败")

    # 创建处理器并运行
    data_dir = Path(__file__).parent.parent.parent / "data" / "asset"
    profile = AssetProfile(data_dir)

    try:
        if config["feishu_space_id"]:
            profile.run_all(
                feishu_space_id=config["feishu_space_id"],
                github_owner=config["github_owner"],
                github_repo=config["github_repo"],
                github_branch=config["github_branch"] or None
            )
        else:
            # 仅运行GitHub相关步骤
            print("\n")
            print("╔" + "=" * 58 + "╗")
            print("║" + " " * 15 + "资产配置文件处理流程（仅GitHub）" + " " * 11 + "║")
            print("╚" + "=" * 58 + "╝")
            print()

            # 步骤3: 克隆GitHub仓库
            profile.step3_clone_github_repo(
                config["github_owner"],
                config["github_repo"],
                config["github_branch"] or None
            )
            print()

            # 步骤4: 合并为Markdown（如果有feishu内容）
            feishu_files = list(profile.feishu_dir.glob('*.json'))
            if feishu_files:
                profile.step4_merge_to_markdown()
                print()

                # 步骤5: 提交到GitHub
                repo_dir = profile.github_dir / config["github_repo"]
                profile.step5_commit_to_github(repo_dir)

            print("\n")
            print("╔" + "=" * 58 + "╗")
            print("║" + " " * 15 + "处理完成！" + " " * 31 + "║")
            print("╚" + "=" * 58 + "╝")
            print()
    except Exception as e:
        print(f"\n✗ 错误: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
