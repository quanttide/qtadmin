# ROADMAP — qtadmin Studio

qtadmin Studio 是治理思想的展示与执行载体（Flutter 客户端）。定位、主题与阶段规划见仓库根目录 `ROADMAP.md`。

## 版本目标

| 版本载体 | 当前版本 | 目标版本 | 就绪条件 |
|:--------:|:--------:|:--------:|----------|
| `pubspec.yaml`、`CHANGELOG.md` | 0.1.3 | studio/v0.1.3 | 已就绪，待发首个 tag |

## 路线

### 清理与起步（0.1.x）

- 清理 router 死引用（dashboard、think、qtclass），确认可构建
- asset 可视化起步：读取 CLI 数据文件，落地双端数据共享
- 补齐 human、connect、asset 领域包，对齐 CLI 规划

### 执行环节可视化（0.2.x）

- 评审闭环 MVP：角色槽位分配、评审节点、评审留痕
- 评审质量视图：打回原因聚类、标准库展示——评审即制度修订的可视化

### 治理可视化扩展（0.3.x）

- knowl 链路展示：acquire / extract / summary，状态承载（settled / evolving / draft）可视化
- delib 议事记录与决策留痕展示
- strategy 战略洞察展示（方向、张力、假设库）
- 责任链看板：分配 → 执行 → 评审 → 负责
