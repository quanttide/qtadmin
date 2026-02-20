# 量潮创始人档案分析报告

## 1. 项目概述

- **仓库**: quanttide/quanttide-profile-of-founder
- **描述**: 量潮创始人档案
- **技术栈**: MYST Markdown + Jupyter Book
- **许可证**: CC BY 4.0

## 2. 目录结构

### 2.1 一级目录 (10个)

| 目录 | 含义 | 描述 |
|------|------|------|
| `think/` | 思考 | 思考过程、决策记录 |
| `agent/` | 智能体工程 | Agent 相关知识 |
| `knowl/` | 知识工程 | 知识管理、本体论 |
| `learn/` | 学习 | 学习记录、笔记 |
| `stdn/` | 标准化 | 标准、规范文档 |
| `write/` | 写作 | 写作内容、手册 |
| `code/` | 编程 | 代码相关 |
| `brand/` | 品牌管理 | 品牌建设 |
| `acad/` | 学术研究 | 学术研究 |
| `product/` | 产品研发 | 产品路线图 |

### 2.2 二级结构

```
think/
├── README.md
├── agent.md
├── asset.md
├── code.md
├── course.md
├── delim/issue/          # 决策issues
├── devops.md
├── health.md
├── hr.md
├── iam.md
├── index.md
├── ip.md
├── knowl.md
├── org.md
├── pr.md
├── product.md
├── self.md
├── stdn.md
├── think.md
└── write.md

write/
├── content/              # 写作内容
│   ├── handbook_*.md     # 手册
│   ├── report_*.md       # 报告
│   └── index.md
├── style/
│   ├── fiction.md
│   └── index.md
└── index.md

learn/
├── channel/              # 学习渠道
│   ├── bilibili_一杯氢气H2.yaml
│   └── github_quanttide.yaml
├── note/                 # 学习笔记
│   ├── code/
│   ├── connect.md
│   ├── index.md
│   ├── infra.md
│   ├── llm.md
│   ├── meta.md
│   └── write.md
└── channel/README.md

product/
├── qtadmin/              # qtadmin产品
├── qtcloud/              # 云产品
├── qtcloud_media/        # 媒体基础设施
└── qtcloud_think/        # 思考产品

knowl/
├── README.md
├── instance/             # 知识实例
│   └── brand_founder.yaml
└── ontology/             # 本体论
    └── brand.yaml

stdn/
├── README.md
├── agent.md
├── brand.md
├── data.md
├── index.md
├── knowl.md
├── meta/
│   └── think_vs_connect.md
├── product.md
├── think/
│   └── think.md
└── write.md
```

## 3. 核心概念

### 3.1 知识管理 (knowl/)

- **本体论 (ontology/)**: 定义概念模型，如 `brand.yaml`
- **实例 (instance/)**: 具体知识实例，如 `brand_founder.yaml`

### 3.2 标准化 (stdn/)

- 定义各领域的标准规范
- 包含元认知文档 (meta/)

### 3.3 决策管理 (delib/)

- `issue/` 目录管理具体决策
- 文件: share.md, think.md

## 4. 命名规范

### 4.1 文件命名

- 小写字母
- 单词间用连字符 `-` 分隔
- 示例: `agent.md`, `product-roadmap.md`

### 4.2 目录命名

- 小写字母
- 复数形式
- 示例: `think/`, `write/`

## 5. 记忆类型分类

| 类型 | 描述 | 示例文件 |
|------|------|----------|
| 陈述性记忆 | 事实性、概念性知识 | `*/index.md`, `knowl/` |
| 程序性记忆 | 流程、步骤、规范 | `ROADMAP.md`, `CHANGELOG.md` |
| 元认知 | 关于认知的认知 | `AGENTS.md`, `stdn/meta/` |

## 6. 关键文件

| 文件 | 用途 |
|------|------|
| `README.md` | 格式规范与构建命令 |
| `_config.yml` | Jupyter Book 配置 |
| `_toc.yml` | 目录结构 |
| `AGENTS.md` | Agent 工作指南 |
| `ROADMAP.md` | 产品路线图 |
| `CHANGELOG.md` | 版本变更记录 |
| `index.md` | 首页（内容总览） |

## 7. 工作习惯分析

### 7.1 知识管理方式

1. **结构化**: 按主题划分目录，层次清晰
2. **标准化**: 严格的命名规范和格式要求
3. **知识化**: 区分本体论与实例，强调知识工程

### 7.2 学习与记录

- 多渠道学习记录 (bilibili, github)
- 分类详细的笔记系统
- 持续更新的知识库

### 7.3 产品思维

- 多产品线并行 (qtadmin, qtcloud, qtcloud_media, qtcloud_think)
- 清晰的 roadmap 和 changelog
- 标准化思维贯穿产品开发

### 7.4 决策记录

- 专门的 delib 板块
- issue 形式的决策追踪
- 公开档案制度

## 8. 构建命令

```bash
# 构建 HTML
jupyter-book build .

# 构建并预览
jupyter-book build . --builder htmlserve

# 清理构建文件
jupyter-book clean .
```

## 9. 质量检查

- [ ] markdownlint 检查
- [ ] 内部链接验证
- [ ] _toc.yml 引用检查
- [ ] YAML 语法验证
