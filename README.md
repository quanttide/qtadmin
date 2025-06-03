# 量潮Python项目示例

## 示例使用说明（使用时请按本部分操作后删除本部分内容）

- 用法：创建`Github`仓库时可以选择为模板，已经创建仓库的可以手动参照调整。

- 目录结构说明：`pdm` 配置（`pyproject.toml`）、文档（`README.md`、`CHANGELOG.md`、`docs`（用户文档））、代码（`project_name`（业务代码）、`tests`（单元测试）、`integrated_tests`（集成测试））、`.gitignore`、`LICENSE`

- 需要注意修改的：`pyproject.toml` 与本 `README.md` 文件中的项目名称和描述；`project_name` 文件夹重命名为具体项目名

## 环境配置

1. 安装 Python 环境：

   前往 [https://www.python.org/](https://www.python.org/) 下载安装 Python (>= 3.10)，然后在命令行中执行：

    ```shell
    pip install pdm
    pdm install
    ```

   若下载缓慢，可换源：

    ```shell
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple
    ```

2. 在`项目根目录`下执行以下命令安装依赖项：

   ```shell
   pdm install
   ```

## 运行

1. 在`项目根目录`下执行以下命令：

   ```shell
   pdm run python project_name/__main__.py
   ```
