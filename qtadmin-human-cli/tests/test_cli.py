"""Integration tests for the CLI entry point using Click's CliRunner."""

from unittest.mock import MagicMock, patch

from click.testing import CliRunner

from qtadmin.cli import cli


def test_version():
    """qtadmin --version prints version number."""
    runner = CliRunner()
    result = runner.invoke(cli, ["--version"])
    assert result.exit_code == 0
    assert "2.0.0" in result.output


def test_config_show_defaults():
    """qtadmin config show displays default values."""
    runner = CliRunner()
    with patch("qtadmin.cli.ConfigManager") as MockCfg:
        mock_cfg = MagicMock()
        mock_cfg.show.return_value = {
            "provider_url": "http://127.0.0.1:8000",
            "lark_path": "lark-cli",
        }
        MockCfg.return_value = mock_cfg
        result = runner.invoke(cli, ["config", "show"])
        assert result.exit_code == 0
        assert "http://127.0.0.1:8000" in result.output
        assert "lark-cli" in result.output


def test_config_set_provider():
    """qtadmin config set-provider updates and shows confirmation."""
    runner = CliRunner()
    with patch("qtadmin.cli.ConfigManager") as MockCfg:
        mock_cfg = MagicMock()
        MockCfg.return_value = mock_cfg
        result = runner.invoke(cli, ["config", "set-provider", "http://new:8001"])
        assert result.exit_code == 0
        mock_cfg.set.assert_called_once_with("provider_url", "http://new:8001")


def test_config_set_lark_path():
    """qtadmin config set-lark-path updates and shows confirmation."""
    runner = CliRunner()
    with patch("qtadmin.cli.ConfigManager") as MockCfg:
        mock_cfg = MagicMock()
        MockCfg.return_value = mock_cfg
        result = runner.invoke(cli, ["config", "set-lark-path", "/usr/local/bin/lark"])
        assert result.exit_code == 0
        mock_cfg.set.assert_called_once_with("lark_path", "/usr/local/bin/lark")


def test_human_mail_list():
    """qtadmin human mail list calls lark_client and shows table."""
    runner = CliRunner()
    fake_emails = [
        MagicMock(mail_id="m1", sender_name="张三", subject="应聘前端", date="2026-06-01"),
        MagicMock(mail_id="m2", sender_name="李四", subject="笔试答案", date="2026-06-02"),
    ]
    with (
        patch("qtadmin.cli.ConfigManager") as MockCfg,
        patch("qtadmin.cli.LarkClient") as MockLark,
        patch("qtadmin.cli.classify") as MockClassify,
    ):
        MockCfg.return_value = MagicMock()
        MockCfg.return_value.get.return_value = "lark-cli"
        MockLark.return_value.list_emails.return_value = fake_emails
        MockClassify.side_effect = lambda subject, **kw: MagicMock(
            suggested_status="contacted", confidence="high",
        )

        result = runner.invoke(cli, ["human", "mail", "list", "--limit", "5"])
        assert result.exit_code == 0
        assert "张三" in result.output
        assert "李四" in result.output
        assert "contacted" in result.output


def test_human_mail_classify():
    """qtadmin human mail classify reads one email and shows classification."""
    runner = CliRunner()
    fake_email = MagicMock(
        mail_id="m1", sender_name="张三", sender_email="z@b.com",
        subject="应聘前端", body="hello",
    )
    with (
        patch("qtadmin.cli.ConfigManager") as MockCfg,
        patch("qtadmin.cli.LarkClient") as MockLark,
        patch("qtadmin.cli.classify") as MockClassify,
    ):
        MockCfg.return_value = MagicMock()
        MockCfg.return_value.get.return_value = "lark-cli"
        MockLark.return_value.read_email.return_value = fake_email
        MockClassify.return_value = MagicMock(
            suggested_status="contacted", confidence="high",
        )

        result = runner.invoke(cli, ["human", "mail", "classify", "m1"])
        assert result.exit_code == 0
        assert "contacted" in result.output
        assert "high" in result.output


def test_human_mail_ingest_dry_run():
    """qtadmin human mail ingest --dry-run shows preview without pushing."""
    runner = CliRunner()
    fake_emails = [
        MagicMock(mail_id="m1", sender_name="张三", subject="应聘前端", body="", date=""),
    ]
    with (
        patch("qtadmin.cli.ConfigManager") as MockCfg,
        patch("qtadmin.cli.LarkClient") as MockLark,
        patch("qtadmin.cli.ApiClient") as MockApi,
        patch("qtadmin.cli.classify") as MockClassify,
    ):
        MockCfg.return_value = MagicMock()
        MockCfg.return_value.get.return_value = "lark-cli"
        MockLark.return_value.list_emails.return_value = fake_emails
        MockClassify.return_value = MagicMock(
            suggested_status="contacted", confidence="high",
        )

        result = runner.invoke(cli, ["human", "mail", "ingest", "--dry-run"])
        assert result.exit_code == 0
        assert "张三" in result.output
        assert "预览" in result.output
        MockApi.return_value.ingest.assert_not_called()


def test_human_mail_ingest():
    """qtadmin human mail ingest pushes to server."""
    runner = CliRunner()
    fake_emails = [
        MagicMock(mail_id="m1", sender_name="张三", subject="应聘前端", body="", date=""),
    ]
    with (
        patch("qtadmin.cli.ConfigManager") as MockCfg,
        patch("qtadmin.cli.LarkClient") as MockLark,
        patch("qtadmin.cli.ApiClient") as MockApi,
        patch("qtadmin.cli.classify") as MockClassify,
    ):
        MockCfg.return_value = MagicMock()
        MockCfg.return_value.get.return_value = "lark-cli"
        MockLark.return_value.list_emails.return_value = fake_emails
        MockClassify.return_value = MagicMock(
            suggested_status="contacted", confidence="high",
        )
        MockApi.return_value.ingest.return_value = {
            "queued": 1, "skipped": 0, "errors": [], "items": [],
        }

        result = runner.invoke(cli, ["human", "mail", "ingest", "--limit", "5"])
        assert result.exit_code == 0
        MockApi.return_value.ingest.assert_called_once()


def test_human_status_pending():
    """qtadmin human status pending calls queue stats."""
    runner = CliRunner()
    with (
        patch("qtadmin.cli.ConfigManager") as MockCfg,
        patch("qtadmin.cli.ApiClient") as MockApi,
    ):
        MockCfg.return_value = MagicMock()
        MockCfg.return_value.get.return_value = "http://test:8000"
        MockApi.return_value.get_queue_stats.return_value = {
            "pending": 5, "confirmed": 3, "ignored": 1,
        }

        result = runner.invoke(cli, ["human", "status", "pending"])
        assert result.exit_code == 0
        assert "5" in result.output
