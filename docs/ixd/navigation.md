# 导航结构规范

## 布局

导航项由各Workspace工作空间的 PanoramaData 驱动，不同Workspace工作空间展示不同内容：

### 公司（量潮科技）

```
┌────────────┐
│  Workspace工作空间切换器  │
├────────────┤
│  全景图      │
├────────────┤
│  量潮数据    │  业务线（businessUnits → 通用/咨询类型）
│  量潮课堂    │
│  量潮咨询    │
│  量潮云      │
├────────────┤
│  人力资源    │  职能线（functionCards）
│  财务管理    │
│  组织管理    │
│  战略管理    │
│  新媒体      │
├────────────┤
│  空白占位    │
└────────────┘
```

### 创始人（量潮创始人）

```
┌────────────┐
│  Workspace工作空间切换器  │
├────────────┤
│  全景图      │
├────────────┤
│  思考        │  个性工具（businessUnits → thinking/writing 类型）
│  写作        │
├────────────┤
│  空白占位    │
└────────────┘
```

## 设计规则

- **数据驱动**：导航项由 PanoramaData 的 `businessUnits` 和 `functionCards` 动态生成
- **所有Workspace工作空间共享同一套代码**，差异仅来自 fixture 数据
- **仅两个区域**：业务线（businessUnits）和职能线（functionCards），不因特殊模块新增区域
- **`screenType` 决定页面类型**：
  - `detail` → `BusinessDetailScreen`
  - `consulting` → `QtConsultScreen`
  - `thinking` → `ThinkingScreen`
  - `writing` → 占位（即将上线）
