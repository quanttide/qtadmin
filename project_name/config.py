# -*- coding: utf-8 -*-
"""
配置
"""
import logging
from pathlib import Path

import dynaconf

settings = dynaconf.Dynaconf(
    # note: absolute path so that tests can run correctly.
    # https://docs.python.org/3/library/pathlib.html#pathlib.PurePath.with_name
    settings_files=[Path(__file__).resolve().with_name('settings.yml')],
    # note: split settings_files and secrets.
    # https://www.dynaconf.com/configuration/#secrets
    secrets=Path(__file__).resolve().with_name('.secrets.yml'),
    environments=True,
    env_switcher='DYNACONF_STAGE',
    load_dotenv=True,
)

# 项目根目录设置为仓库根目录
settings.PROJECT_ROOT = Path(__file__).resolve().parent.parent


def init_logging() -> None:
    """
    初始化logging配置
    :return: None
    """
    logging.basicConfig(level=settings.LOGGING_LEVEL, format=settings.LOGGING_FORMAT)
    # 屏蔽不重要的第三方库DEBUG日志
    # logging.getLogger('urllib3.connectionpool').setLevel(max(logging.INFO, settings.LOGGING_LEVEL))
