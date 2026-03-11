"""
网络诊断模块单元测试
"""
import pytest
from unittest.mock import patch, MagicMock
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'examples', 'infra'))
from network import (
    run_cmd,
    get_wifi_interface,
    check_wifi_signal,
    list_wifi_networks,
    active_connections,
    networkmanager_logs,
    check_common_issues,
    parse_signal_info,
    diagnose,
    main,
)


class TestRunCmd:
    def test_run_cmd_success(self):
        stdout, stderr, code = run_cmd(["echo", "hello"])
        assert stdout.strip() == "hello"
        assert code == 0

    def test_run_cmd_failure(self):
        stdout, stderr, code = run_cmd(["ls", "/nonexistent_path_12345"])
        assert code != 0

    def test_run_cmd_timeout(self):
        stdout, stderr, code = run_cmd(["sleep", "5"], timeout=1)
        assert code == 1
        assert "timeout" in stderr


class TestGetWifiInterface:
    @patch('psutil.net_if_addrs')
    def test_returns_connected_wireless_interface(self, mock_net_if_addrs):
        mock_net_if_addrs.return_value = {'wlp0s20f3': MagicMock()}
        with patch('subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(
                returncode=0,
                stdout="wlp0s20f3:connected\n"
            )
            result = get_wifi_interface()
            assert result == "wlp0s20f3"

    @patch('psutil.net_if_addrs')
    def test_returns_first_wireless_if_no_connection(self, mock_net_if_addrs):
        mock_net_if_addrs.return_value = {'wlp0s20f3': MagicMock()}
        with patch('subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(
                returncode=0,
                stdout="lo:unmanaged\n"
            )
            result = get_wifi_interface()
            assert result == "wlp0s20f3"

    @patch('psutil.net_if_addrs')
    def test_returns_empty_when_no_wireless(self, mock_net_if_addrs):
        mock_net_if_addrs.return_value = {'eth0': MagicMock()}
        result = get_wifi_interface()
        assert result == ""


class TestCheckWifiSignal:
    @patch('network.get_wifi_interface')
    def test_returns_no_wireless_message(self, mock_get_interface):
        mock_get_interface.return_value = ""
        result = check_wifi_signal()
        assert result == "未检测到无线网卡"

    @patch('network.get_wifi_interface')
    @patch('network.run_cmd')
    def test_returns_signal_info(self, mock_run_cmd, mock_get_interface):
        mock_get_interface.return_value = "wlp0s20f3"
        mock_run_cmd.return_value = (
            "wlp0s20f3  IEEE 802.11  ESSID:\"TestNetwork\"",
            "",
            0
        )
        result = check_wifi_signal()
        assert "TestNetwork" in result


class TestListWifiNetworks:
    @patch('network.run_cmd')
    def test_lists_networks(self, mock_run_cmd):
        mock_run_cmd.return_value = ("MyNetwork1\nMyNetwork2\n", "", 0)
        result = list_wifi_networks()
        assert "MyNetwork1" in result


class TestActiveConnections:
    @patch('network.run_cmd')
    def test_shows_active(self, mock_run_cmd):
        mock_run_cmd.return_value = ("Wired connection 1\n", "", 0)
        result = active_connections()
        assert "Wired connection 1" in result


class TestNetworkmanagerLogs:
    @patch('network.run_cmd')
    def test_gets_logs(self, mock_run_cmd):
        mock_run_cmd.return_value = ("Log line 1\nLog line 2\n", "", 0)
        result = networkmanager_logs(30)
        assert "Log line" in result


class TestCheckCommonIssues:
    @patch('network.get_wifi_interface')
    def test_no_wireless_returns_message(self, mock_get_interface):
        mock_get_interface.return_value = ""
        result = check_common_issues()
        assert "未检测到无线网卡" in result

    @patch('network.get_wifi_interface')
    @patch('network.run_cmd')
    def test_high_retry_issue(self, mock_run_cmd, mock_get_interface):
        mock_get_interface.return_value = "wlp0s20f3"
        mock_run_cmd.return_value = (
            "wlp0s20f3  IEEE 802.11  Retry short limit:15",
            "",
            0
        )
        result = check_common_issues()
        assert any("高重试次数" in issue for issue in result)

    @patch('network.get_wifi_interface')
    @patch('network.run_cmd')
    def test_weak_signal_issue(self, mock_run_cmd, mock_get_interface):
        mock_get_interface.return_value = "wlp0s20f3"
        mock_run_cmd.return_value = (
            "wlp0s20f3  IEEE 802.11  Signal level=-75 dBm",
            "",
            0
        )
        result = check_common_issues()
        assert any("弱信号" in issue for issue in result)


class TestParseSignalInfo:
    @patch('network.get_wifi_interface')
    def test_returns_empty_when_no_interface(self, mock_get_interface):
        mock_get_interface.return_value = ""
        result = parse_signal_info()
        assert result == {}

    @patch('network.get_wifi_interface')
    @patch('network.run_cmd')
    def test_parses_all_fields(self, mock_run_cmd, mock_get_interface):
        mock_get_interface.return_value = "wlp0s20f3"
        mock_run_cmd.return_value = (
            'wlp0s20f3  IEEE 802.11  ESSID:"TestNet"  Frequency:5.2 GHz  '
            'Bit Rate=130 Mb/s  Link Quality=70/70  Signal level=-50 dBm  '
            'Tx excessive retries:5',
            "",
            0
        )
        result = parse_signal_info()
        assert result["ssid"] == "TestNet"
        assert result["frequency"] == "5.2"
        assert result["bitrate"] == "130"
        assert result["link_quality"] == "70/70"
        assert result["signal_dbm"] == -50
        assert result["tx_retries"] == 5


class TestDiagnose:
    @patch('network.parse_signal_info')
    def test_diagnose_output(self, mock_parse):
        mock_parse.return_value = {
            "ssid": "TestNet",
            "frequency": "5.0",
            "signal_dbm": -60,
            "link_quality": "70/70",
            "bitrate": "130",
            "tx_retries": 5,
        }
        diagnose()


class TestMain:
    @patch('network.diagnose')
    def test_default_calls_diagnose(self, mock_diagnose):
        with patch('sys.argv', ['network.py']):
            main()
        mock_diagnose.assert_called_once()

    @patch('network.check_wifi_signal')
    def test_signal_flag(self, mock_signal):
        with patch('sys.argv', ['network.py', '-s']):
            main()
        mock_signal.assert_called_once()

    @patch('network.list_wifi_networks')
    def test_list_flag(self, mock_list):
        with patch('sys.argv', ['network.py', '--list']):
            main()
        mock_list.assert_called_once()

    @patch('network.active_connections')
    def test_active_flag(self, mock_active):
        with patch('sys.argv', ['network.py', '-a']):
            main()
        mock_active.assert_called_once()

    @patch('network.networkmanager_logs')
    def test_logs_flag(self, mock_logs):
        with patch('sys.argv', ['network.py', '-L', '15']):
            main()
        mock_logs.assert_called_once_with(15)
