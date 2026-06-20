---
name: docs-deploy
description: 使用 MyST Markdown 构建文档站并部署到 GitHub Pages。覆盖主仓库和子仓库两种场景。
---

# docs-deploy

使用 MyST Markdown 构建文档站并部署到 GitHub Pages。

## 规则

- 文档源码在 `docs/` 目录，MyST 配置为 `docs/myst.yml`
- GitHub Pages 使用 workflow 模式（`build_type=workflow`），非 branch 模式
- 构建产物输出到 `docs/_build/html`，artifact 上传此目录
- 站点地址为 `https://quanttide.github.io/<仓库名>/`
- 主仓库与子仓库配置方式相同，但主仓库 checkout 时不可拉子模块

## 工作流

### 1. 配置 MyST

创建 `docs/myst.yml`：

```yaml
version: 1
project:
  title: <站点标题>
  description: <站点描述>
  toc:
    - file: index.md
    - title: <分组标题>
      children:
        - file: <相对路径>
site:
  template: book-theme
```

### 2. 配置 gitignore

创建 `docs/.gitignore`，内容为 `_build/`。

### 3. 创建 GitHub Actions 工作流

创建 `.github/workflows/deploy-docs.yml`：

```yaml
name: Deploy docs to GitHub Pages

on:
  push:
    branches: [main]
    paths:
      - docs/**
      - .github/workflows/deploy-docs.yml

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install mystmd
      - run: myst build --html
        working-directory: docs
        env:
          BASE_URL: /<仓库名>/
      - run: cp docs/_build/html/index.html docs/_build/html/404.html
      - uses: actions/upload-pages-artifact@v3
        with:
          path: docs/_build/html

  deploy:
    needs: build
    runs-on: ubuntu-latest
    permissions:
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/deploy-pages@v4
```

### 4. 启用 GitHub Pages

**必须在推送之前执行**，否则第一次 deploy workflow 触发时 Pages 尚未开启，部署会失败且浪费一次运行。

```bash
gh api repos/<owner>/<repo>/pages -X POST -f build_type=workflow
```

### 5. 提交推送

两段式提交（仅子仓库需执行此步骤）：
1. 子仓库内 `git push`
2. 主仓库更新子模块引用并推送

### 6. 验证

```bash
# 确认 Actions 运行成功
gh run list -L1 --workflow deploy-docs.yml --json name,status,conclusion

# 查看 deploy 日志确认 "Reported success!"
gh run view <run-id> --log 2>&1 | grep "Reported success"
```

## 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| Artifact path 指向 `_build/` 而非 `_build/html` | 构建产物的实际站点文件在 `html/` 子目录 | 改为 `path: docs/_build/html` |
| `BASE_URL` 未设置 | 站点从子路径访问时 CSS/JS 路径错误 | 设为 `/<仓库名>/` |
| SPA 路由 404 | Remix SPA 的客户端路由无 fallback | `cp index.html 404.html` |
| checkout 拉子模块失败 | 主仓库子模块多且部分不可访问 | 移除 `submodules: recursive` |
| 本机 curl 返回 000 | 网络环境阻断 GitHub Pages | Actions 日志确认 `Reported success!` 即可 |
| 首次 push 后 deploy 失败 | Pages 未在推送前启用 | 先 `gh api .../pages -X POST`，再 trigger workflow |

## 经验记录

- qtcloud-hr：首个试点，建立了完整模板
- qtcloud-asset：验证模板可复用，BASE_URL 改为 `/qtcloud-asset/`
- quanttide-platform：主仓库首次部署，踩坑 recursive submodules
- qtcloud-product / qtcloud-write：本机 myst build 因模板下载超时失败，直接推至 GitHub Actions 验证通过。教训：本机网络不稳定时无需死磕本地构建，配置推上去让 Actions 跑，日志确认 `Reported success!` 即可。
