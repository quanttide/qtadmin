# Finance Integration Plan

## 背景

`quanttide-finance-toolkit` 已经在 `qtadmin` 内形成镜像落点：

- `quanttide-finance-toolkit/packages/fastapi` 对应 `qtadmin/packages/finance/fastapi`
- `quanttide-finance-toolkit/packages/dart` 对应 `qtadmin/packages/finance/dart`
- `quanttide-finance-toolkit/packages/flutter` 对应 `qtadmin/packages/finance/flutter`
- `quanttide-finance-toolkit/demo` 对应 `qtadmin/examples/finance`

当前问题不是“如何把 toolkit 再搬一次”，而是：

1. 哪一侧是唯一开发主线
2. finance 如何进入 `qtadmin` 的 Studio 领域结构
3. 后端、共享 DTO、Studio UI 三层如何分责

## 现状判断

### 已确认事实

- `qtadmin/packages/finance` 与 `quanttide-finance-toolkit/packages` 的核心代码基本一致。
- 差异主要集中在脚本包装、文档位置和仓库外围文件，不在核心业务实现。
- `qtadmin` 主仓已包含 finance demo 与后端测试。
- `src/studio/packages/` 目前没有 finance 领域包，说明 finance 尚未真正进入 Studio 架构。

### 风险

- 若继续双仓双写，finance 会持续分叉。
- 若直接把 `packages/finance/flutter` 当作 Studio 模块使用，会把演示壳和正式客户端耦合在一起。
- 若过早并入 `src/provider`，会在权限、组织、租户模型尚未稳定时放大维护成本。

## 目标

### 目标一：唯一事实来源

将 `qtadmin/packages/finance` 设为 finance 的唯一开发主线。

### 目标二：分层清晰

finance 在 `qtadmin` 内分为三层：

- `packages/finance/fastapi`：独立后端能力
- `packages/finance/dart`：共享 DTO / domain model
- `packages/finance/flutter`：Flutter API adapter
- `src/studio/packages/qtadmin-finance`：Studio 专属页面、状态管理、领域视图

### 目标三：先接主流程，再补外围

Studio 集成优先覆盖：

1. 录入
2. 分类审核
3. 统计看板

凭证层不是第一阶段重点。

## 目标架构

```text
qtadmin/
├── packages/
│   └── finance/
│       ├── fastapi/   # finance backend
│       ├── dart/      # shared DTO and models
│       └── flutter/   # API client and Flutter adapter
├── examples/
│   └── finance/       # demo and manual verification
└── src/
    └── studio/
        └── packages/
            └── qtadmin-finance/
                ├── lib/
                │   ├── finance.dart
                │   └── src/
                │       ├── config/
                │       ├── screens/
                │       └── views/
                └── test/
```

## 决策

### 1. 主线归属

- 日常开发只改 `qtadmin/packages/finance`
- `quanttide-finance-toolkit` 作为过渡仓或发布镜像，不再承担双向手工同步

### 2. Studio 集成方式

- 新建 `src/studio/packages/qtadmin-finance`
- 该包依赖 `packages/finance/flutter` 暴露的 API client
- 该包只承载 Studio 语境下的页面、路由目标、状态管理、交互视图

### 3. 后端接入方式

- 短期：`packages/finance/fastapi` 独立运行，Studio 通过 base URL 调用
- 中期：待权限、组织、租户边界稳定后，再评估是否挂入统一 provider

### 4. demo 定位

- `examples/finance` 保留为联调与产品验证环境
- 不作为 Studio 正式实现的源码来源

## 分期实施

### P0：治理收口

- 明确 `qtadmin/packages/finance` 为唯一主线
- 在 toolkit 仓补迁移说明
- 停止双向手改

### P1：包边界固定

- 明确 `packages/finance/dart` 只做共享 DTO / model
- 明确 `packages/finance/flutter` 只做 adapter，不继续堆页面壳
- 新建 `qtadmin-finance` 占位包

### P2：Studio 最小接入

- 在 Studio 中增加 finance 路由入口
- 建立录入、审核、统计三个页面骨架
- 将现有 finance API client 接入 Studio 层状态管理
- 将 finance API base URL 提升到 Studio 应用配置，避免路由层硬编码

### P3：组织与权限

- 补组织维度筛选
- 补角色权限
- 补统一鉴权注入

### P4：仓库归档

- 评估 `quanttide-finance-toolkit` 是归档、镜像发布，还是作为外部只读仓保留

## 第一阶段工作项

### 必做

- 新增 `qtadmin-finance` 包骨架
- 为 finance Studio 集成建立文档约束
- 保持 finance demo、adapter、backend 三层可独立演进
- 通过 `QTADMIN_FINANCE_API_BASE_URL` 管理 Studio 联调地址

### 暂不做

- 不立即改 `src/studio/lib/router.dart`
- 不立即将 finance 并入 `src/provider`
- 不立即改动凭证层设计

## 验收标准

- finance 只存在一套日常维护源码主线
- `src/studio/packages/qtadmin-finance` 成为后续 Studio 集成落点
- `packages/finance/flutter` 与 Studio UI 边界清晰
- 后续新增 finance 功能不再需要在两个仓库间复制
- Studio finance 不再依赖硬编码 `localhost` API 地址
