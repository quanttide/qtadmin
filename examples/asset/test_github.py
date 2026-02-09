"""
GitHub客户端单元测试
"""

import os
import pytest
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock
from github import GithubException

from github_client import GitHubClient


@pytest.fixture
def github_client():
    """创建GitHub客户端实例"""
    with patch.dict(os.environ, {"GITHUB_TOKEN": "test_token"}):
        return GitHubClient()


@pytest.fixture
def mock_github_client():
    """创建模拟的Github客户端"""
    mock = MagicMock()
    return mock


@pytest.fixture
def mock_repository():
    """创建模拟的仓库对象"""
    mock = MagicMock()
    mock.id = 123456
    mock.name = "test-repo"
    mock.full_name = "test/test-repo"
    mock.description = "测试仓库"
    mock.private = False
    mock.created_at = MagicMock()
    mock.created_at.isoformat.return_value = "2024-01-01T00:00:00"
    mock.updated_at = MagicMock()
    mock.updated_at.isoformat.return_value = "2024-01-02T00:00:00"
    mock.default_branch = "main"
    mock.language = "Python"
    mock.stargazers_count = 10
    mock.forks_count = 5
    return mock


@pytest.fixture
def mock_branch():
    """创建模拟的分支对象"""
    mock = MagicMock()
    mock.name = "main"
    mock.commit = MagicMock()
    mock.commit.sha = "abc123"
    mock.commit.url = "https://api.github.com/repos/test/test-repo/commits/abc123"
    return mock


class TestGitHubClient:
    """测试GitHubClient类"""

    def test_init_with_env_vars(self):
        """测试使用环境变量初始化"""
        with patch.dict(os.environ, {"GITHUB_TOKEN": "env_token"}):
            client = GitHubClient()
            assert client.token == "env_token"

    def test_init_with_params(self):
        """测试使用参数初始化"""
        client = GitHubClient(token="param_token")
        assert client.token == "param_token"

    def test_init_without_token(self):
        """测试不带token初始化"""
        client = GitHubClient()
        assert client.token is None
        assert client.client is not None  # 现在支持无token访问公开仓库

    def test_get_repository(self, github_client, mock_repository):
        """测试获取仓库"""
        with patch.object(github_client.client, 'get_repo', return_value=mock_repository):
            repo = github_client.get_repository("test/test-repo")
            assert repo == mock_repository

    def test_get_repository_error(self, github_client):
        """测试获取仓库失败"""
        with patch.object(github_client.client, 'get_repo', side_effect=GithubException(404, "Not Found")):
            with pytest.raises(Exception, match="获取仓库失败"):
                github_client.get_repository("nonexistent/repo")

    def test_get_repository_no_token(self):
        """测试没有token时获取仓库（公开仓库）"""
        client = GitHubClient()
        # 现在可以访问公开仓库
        repo = client.get_repository("octocat/Hello-World")
        assert repo.name == "Hello-World"

    def test_get_repository_info(self, github_client, mock_repository):
        """测试获取仓库信息"""
        with patch.object(github_client.client, 'get_repo', return_value=mock_repository):
            info = github_client.get_repository_info("test", "test-repo")
            assert info["id"] == 123456
            assert info["name"] == "test-repo"
            assert info["full_name"] == "test/test-repo"
            assert info["default_branch"] == "main"
            assert info["language"] == "Python"

    def test_get_branches(self, github_client, mock_repository, mock_branch):
        """测试获取分支列表"""
        mock_repository.get_branches.return_value = [mock_branch]

        with patch.object(github_client.client, 'get_repo', return_value=mock_repository):
            branches = github_client.get_branches("test", "test-repo")
            assert len(branches) == 1
            assert branches[0]["name"] == "main"
            assert branches[0]["commit"]["sha"] == "abc123"

    def test_get_contents(self, github_client, mock_repository):
        """测试获取目录内容"""
        # 模拟ContentFile对象
        mock_file = MagicMock()
        mock_file.name = "README.md"
        mock_file.path = "README.md"
        mock_file.size = 100
        mock_file.download_url = "https://raw.githubusercontent.com/..."

        mock_dir = MagicMock()
        mock_dir.name = "src"
        mock_dir.path = "src"
        mock_dir.size = 0
        mock_dir.download_url = None

        mock_repository.get_contents.return_value = [mock_file, mock_dir]

        with patch.object(github_client.client, 'get_repo', return_value=mock_repository):
            contents = github_client.get_contents("test", "test-repo")
            assert len(contents) == 2
            assert contents[0]["type"] == "file"

    def test_get_file_content(self, github_client, mock_repository):
        """测试获取文件内容"""
        # 模拟ContentFile对象
        mock_file = MagicMock()
        mock_file.decoded_content = b"Hello, World!"

        mock_repository.get_contents.return_value = mock_file

        with patch.object(github_client.client, 'get_repo', return_value=mock_repository):
            content = github_client.get_file_content("test", "test-repo", "README.md")
            assert content == "Hello, World!"

    def test_clone_repo_existing_dir(self, github_client, mock_repository, tmp_path):
        """测试克隆已存在的仓库（拉取）"""
        repo_dir = tmp_path / "test-repo"
        repo_dir.mkdir()

        # 初始化git仓库
        import subprocess
        subprocess.run(["git", "init"], cwd=repo_dir, check=True, capture_output=True)

        mock_repository.default_branch = "main"
        with patch.object(github_client.client, 'get_repo', return_value=mock_repository), \
             patch('github_client.subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(capture_output=True)
            result = github_client.clone_repo("test", "test-repo", tmp_path)

            assert result == repo_dir
            # 应该执行git pull而不是clone
            calls = mock_run.call_args_list
            assert any("pull" in str(call) for call in calls)

    def test_clone_repo_new_dir(self, github_client, mock_repository, tmp_path):
        """测试克隆新仓库"""
        mock_repository.default_branch = "main"

        with patch.object(github_client.client, 'get_repo', return_value=mock_repository), \
             patch('github_client.subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(capture_output=True)
            result = github_client.clone_repo("test", "test-repo", tmp_path)

            assert result == tmp_path / "test-repo"
            # 应该执行git clone
            calls = mock_run.call_args_list
            assert any("clone" in str(call) for call in calls)

    def test_download_repository(self, github_client, mock_repository, tmp_path):
        """测试下载仓库内容"""
        # 模拟ContentFile对象
        mock_file = MagicMock()
        mock_file.name = "README.md"
        mock_file.path = "README.md"
        mock_file.decoded_content = b"# Test\n"

        mock_repository.get_contents.return_value = [mock_file]

        with patch.object(github_client.client, 'get_repo', return_value=mock_repository):
            output_dir = tmp_path / "downloaded"
            count = github_client.download_repository("test", "test-repo", output_dir)

            assert count == 1
            assert (output_dir / "README.md").exists()

    def test_download_repository_nested(self, github_client, mock_repository, tmp_path):
        """测试下载嵌套目录"""
        # 模拟目录
        mock_dir = MagicMock()
        mock_dir.name = "src"
        mock_dir.path = "src"

        # 模拟文件
        mock_file = MagicMock()
        mock_file.name = "main.py"
        mock_file.path = "src/main.py"
        mock_file.decoded_content = b"print('hello')"

        mock_repository.get_contents.side_effect = [[mock_dir], [mock_file]]

        with patch.object(github_client.client, 'get_repo', return_value=mock_repository):
            output_dir = tmp_path / "downloaded"
            count = github_client.download_repository("test", "test-repo", output_dir)

            assert count == 1
            assert (output_dir / "src" / "main.py").exists()

    def test_commit_and_push_success(self, github_client, tmp_path):
        """测试成功提交和推送"""
        repo_dir = tmp_path / "test-repo"
        repo_dir.mkdir()

        with patch('github_client.subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(capture_output=True)
            result = github_client.commit_and_push(repo_dir, "Test commit")

            assert result is True
            # 验证调用了配置、add、commit、push
            assert len(mock_run.call_args_list) >= 4

    def test_commit_and_push_with_files(self, github_client, tmp_path):
        """测试提交指定文件"""
        repo_dir = tmp_path / "test-repo"
        repo_dir.mkdir()

        with patch('github_client.subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(capture_output=True)
            result = github_client.commit_and_push(
                repo_dir, "Test commit", files=["file1.txt", "file2.txt"]
            )

            assert result is True
            # 验证调用了add指定文件
            add_calls = [call for call in mock_run.call_args_list if "add" in str(call)]
            assert len(add_calls) >= 2  # 至少调用两次add

    def test_commit_and_push_failure(self, github_client, tmp_path):
        """测试提交推送失败"""
        repo_dir = tmp_path / "test-repo"
        repo_dir.mkdir()

        import subprocess
        with patch('github_client.subprocess.run', side_effect=subprocess.CalledProcessError(1, "git")):
            result = github_client.commit_and_push(repo_dir, "Test commit")

            assert result is False

    def test_create_pull_request(self, github_client, mock_repository):
        """测试创建PR"""
        mock_pr = MagicMock()
        mock_pr.id = 1
        mock_pr.number = 123
        mock_pr.title = "Test PR"
        mock_pr.state = "open"
        mock_pr.html_url = "https://github.com/test/test-repo/pull/123"

        mock_repository.create_pull.return_value = mock_pr

        with patch.object(github_client.client, 'get_repo', return_value=mock_repository):
            pr = github_client.create_pull_request(
                "test", "test-repo",
                "Test PR", "feature-branch",
                "main", "Test description"
            )

            assert pr["number"] == 123
            assert pr["title"] == "Test PR"
            mock_repository.create_pull.assert_called_once()

    def test_get_repository_exception(self, github_client):
        """测试获取仓库异常"""
        with patch.object(github_client.client, 'get_repo', side_effect=GithubException(404, "Not Found")):
            with pytest.raises(Exception):
                github_client.get_repository("test", "test-repo")

    def test_download_repository_error_handling(self, github_client, mock_repository, tmp_path):
        """测试下载时的错误处理"""
        mock_repository.get_contents.side_effect = GithubException(404, "Not Found")

        with patch.object(github_client.client, 'get_repo', return_value=mock_repository):
            output_dir = tmp_path / "downloaded"
            # 异常应该被捕获并打印，不抛出
            count = github_client.download_repository("test", "test-repo", output_dir)
            assert count == 0
