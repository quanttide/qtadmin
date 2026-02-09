"""
GitHub仓库集成模块
使用PyGithub官方SDK
"""

import os
import json
import subprocess
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime

from github import Github, GithubException, Repository
from github.ContentFile import ContentFile


class GitHubClient:
    """GitHub客户端，使用PyGithub SDK"""

    def __init__(self, token: Optional[str] = None):
        """
        初始化GitHub客户端

        Args:
            token: GitHub personal access token，默认从环境变量GITHUB_TOKEN获取
                   如果不提供，将使用匿名访问（仅限公开仓库）
        """
        self.token = token or os.getenv("GITHUB_TOKEN")
        # 无token也可以访问公开仓库
        self.client = Github(self.token) if self.token else Github()

    def get_repository(self, full_name: str) -> Repository:
        """
        获取仓库

        Args:
            full_name: 仓库全名，格式为 owner/repo

        Returns:
            仓库对象
        """
        try:
            return self.client.get_repo(full_name)
        except GithubException as e:
            raise Exception(f"获取仓库失败: {e}")

    def get_repository_info(self, owner: str, repo: str) -> Dict:
        """
        获取仓库信息

        Args:
            owner: 仓库所有者
            repo: 仓库名称

        Returns:
            仓库信息字典
        """
        repository = self.get_repository(f"{owner}/{repo}")

        return {
            "id": repository.id,
            "name": repository.name,
            "full_name": repository.full_name,
            "description": repository.description,
            "private": repository.private,
            "created_at": repository.created_at.isoformat() if repository.created_at else None,
            "updated_at": repository.updated_at.isoformat() if repository.updated_at else None,
            "default_branch": repository.default_branch,
            "language": repository.language,
            "stargazers_count": repository.stargazers_count,
            "forks_count": repository.forks_count
        }

    def get_branches(self, owner: str, repo: str) -> List[Dict]:
        """
        获取仓库所有分支

        Args:
            owner: 仓库所有者
            repo: 仓库名称

        Returns:
            分支列表
        """
        repository = self.get_repository(f"{owner}/{repo}")
        branches = []

        for branch in repository.get_branches():
            branches.append({
                "name": branch.name,
                "commit": {
                    "sha": branch.commit.sha,
                    "url": branch.commit.url
                }
            })

        return branches

    def get_contents(self, owner: str, repo: str, path: str = "", ref: str = None) -> List[Dict]:
        """
        获取仓库目录内容

        Args:
            owner: 仓库所有者
            repo: 仓库名称
            path: 路径
            ref: 分支或commit

        Returns:
            文件/目录列表
        """
        repository = self.get_repository(f"{owner}/{repo}")
        contents = []

        try:
            for item in repository.get_contents(path, ref=ref):
                content_type = "file" if isinstance(item, ContentFile) else "dir"
                contents.append({
                    "name": item.name,
                    "type": content_type,
                    "path": item.path,
                    "size": getattr(item, 'size', 0),
                    "download_url": getattr(item, 'download_url', None)
                })
        except GithubException as e:
            raise Exception(f"获取目录内容失败: {e}")

        return contents

    def get_file_content(self, owner: str, repo: str, path: str, ref: str = None) -> str:
        """
        获取文件内容

        Args:
            owner: 仓库所有者
            repo: 仓库名称
            path: 文件路径
            ref: 分支或commit

        Returns:
            文件内容
        """
        repository = self.get_repository(f"{owner}/{repo}")

        try:
            content_file = repository.get_contents(path, ref=ref)
            if isinstance(content_file, ContentFile):
                return content_file.decoded_content.decode("utf-8")
        except GithubException as e:
            raise Exception(f"获取文件内容失败: {e}")

        return ""

    def clone_repo(self, owner: str, repo: str, output_dir: Path, branch: str = None) -> Path:
        """
        克隆仓库到本地目录

        Args:
            owner: 仓库所有者
            repo: 仓库名称
            output_dir: 输出目录
            branch: 分支名称

        Returns:
            克隆后的目录路径
        """
        import subprocess

        output_dir.mkdir(parents=True, exist_ok=True)
        repo_dir = output_dir / repo

        # 获取默认分支
        repository = self.get_repository(f"{owner}/{repo}")
        if not branch:
            branch = repository.default_branch

        repo_url = f"https://github.com/{owner}/{repo}.git"

        if repo_dir.exists():
            # 如果目录已存在，拉取最新代码
            subprocess.run(
                ["git", "-C", str(repo_dir), "pull", "origin", branch],
                check=True,
                capture_output=True
            )
        else:
            # 克隆仓库
            subprocess.run(
                ["git", "clone", "-b", branch, repo_url, str(repo_dir)],
                check=True,
                capture_output=True
            )

        return repo_dir

    def download_repository(self, owner: str, repo: str, output_dir: Path) -> int:
        """
        下载仓库内容到本地

        Args:
            owner: 仓库所有者
            repo: 仓库名称
            output_dir: 输出目录

        Returns:
            下载的文件数量
        """
        output_dir.mkdir(parents=True, exist_ok=True)
        file_count = 0

        def download_recursive(path: str = ""):
            nonlocal file_count
            try:
                repository = self.get_repository(f"{owner}/{repo}")
                contents = repository.get_contents(path)

                if isinstance(contents, list):
                    for item in contents:
                        if isinstance(item, ContentFile):
                            # 文件
                            file_path = output_dir / item.path
                            file_path.parent.mkdir(parents=True, exist_ok=True)
                            content = item.decoded_content.decode("utf-8")
                            with open(file_path, "w", encoding="utf-8") as f:
                                f.write(content)
                            file_count += 1
                        else:
                            # 目录
                            download_recursive(item.path)
                else:
                    # 单个文件
                    if isinstance(contents, ContentFile):
                        file_path = output_dir / contents.path
                        file_path.parent.mkdir(parents=True, exist_ok=True)
                        content = contents.decoded_content.decode("utf-8")
                        with open(file_path, "w", encoding="utf-8") as f:
                            f.write(content)
                        file_count += 1
            except Exception as e:
                print(f"下载失败 {path}: {e}")

        download_recursive()
        return file_count

    def commit_and_push(
        self,
        repo_dir: Path,
        message: str,
        branch: str = None,
        files: List[str] = None
    ) -> bool:
        """
        提交并推送代码

        Args:
            repo_dir: 仓库目录
            message: 提交信息
            branch: 分支名称
            files: 要提交的文件列表，None表示所有文件

        Returns:
            是否成功
        """
        import subprocess

        try:
            # 配置git
            subprocess.run(
                ["git", "-C", str(repo_dir), "config", "user.email", "bot@lark-github.com"],
                check=True,
                capture_output=True
            )
            subprocess.run(
                ["git", "-C", str(repo_dir), "config", "user.name", "Lark GitHub Bot"],
                check=True,
                capture_output=True
            )

            # 添加文件
            if files:
                for file in files:
                    subprocess.run(
                        ["git", "-C", str(repo_dir), "add", file],
                        check=True,
                        capture_output=True
                    )
            else:
                subprocess.run(
                    ["git", "-C", str(repo_dir), "add", "."],
                    check=True,
                    capture_output=True
                )

            # 提交
            subprocess.run(
                ["git", "-C", str(repo_dir), "commit", "-m", message],
                check=True,
                capture_output=True
            )

            # 获取当前分支
            if not branch:
                result = subprocess.run(
                    ["git", "-C", str(repo_dir), "rev-parse", "--abbrev-ref", "HEAD"],
                    check=True,
                    capture_output=True,
                    text=True
                )
                branch = result.stdout.strip()

            # 推送
            subprocess.run(
                ["git", "-C", str(repo_dir), "push", "origin", branch],
                check=True,
                capture_output=True
            )

            return True
        except subprocess.CalledProcessError as e:
            stderr = e.stderr.decode() if e.stderr else str(e)
            print(f"Git操作失败: {stderr}")
            return False

    def create_pull_request(
        self,
        owner: str,
        repo: str,
        title: str,
        head: str,
        base: str = "main",
        body: str = ""
    ) -> Dict:
        """
        创建Pull Request

        Args:
            owner: 仓库所有者
            repo: 仓库名称
            title: PR标题
            head: 源分支
            base: 目标分支
            body: PR描述

        Returns:
            PR信息
        """
        repository = self.get_repository(f"{owner}/{repo}")

        try:
            pr = repository.create_pull(
                title=title,
                body=body,
                head=head,
                base=base
            )
            return {
                "id": pr.id,
                "number": pr.number,
                "title": pr.title,
                "state": pr.state,
                "html_url": pr.html_url
            }
        except GithubException as e:
            raise Exception(f"创建PR失败: {e}")
