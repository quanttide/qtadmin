# 问题管理文档

## 业务问题

### Workspace 类型定义模糊

`WorkspaceType` 枚举值为 `internal` 和 `customer`，描述的是「使用者的立场」而非「工作空间的性质」。这导致一个 workspace 的本质是什么、它与另一个 workspace 的关系是什么，只能靠人工理解。

方向：用业务实体本身命名（如 `founder`、`company`、`client_project`），让 workspace 类型反映它在组织中的真实位置。

---

## 技术问题

## Fixture 路径映射分散

`DashboardLoader` 和 `QtConsultLoader` 各自维护一份 `workspace` → 路径的 switch。新增 workspace 需改两处。

- 应将路径映射统一收敛到 `FixtureConfig`，让 loader 只调用不定义

## 图标字符串无校验

`metadata.json` 的 `icon` 是自由字符串，运行时 `resolveIcon()` 遇到未知值静默降级。非法图标在 UI 渲染后才暴露。

- 应在加载时校验或使用 sealed class，让非法值在解析阶段 fail fast

## 页面路由表硬编码

`_buildScreenForItem` 是一个大型 switch，新增 pageType 必须改 `main.dart`。

- 可改为注册表模式，各 Screen 自注册 pageType → builder 映射

## 运行时状态不可观测

所有状态（workspaces、navData、dashboard 数据）是私有字段，无法检查或重置加载了什么。

- 引入 Repository 层或 `ValueNotifier`，让状态可订阅、可检查

## Fixture JSON 缺少构建时校验

JSON 字段缺失或类型错误运行时才暴露，对应页面打开时才崩溃。

- 增加构建时 JSON schema 校验，让 fixture 格式错误在编译期捕获

## Widget 树在数据就绪前渲染

`MaterialApp` 的 `home` 在 `_loadData()` 完成前就构建，依赖子组件防御性判空。

- 应显式等待数据加载完成后再构建主界面
