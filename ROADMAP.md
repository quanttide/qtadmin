# ROADMAP — qtadmin

qtadmin 是量潮体系的**对内监控面板**——以各种数据指标和验收方式为准。定位与四分边界见 [AGENTS.md](AGENTS.md)；旧业务域已全部迁移至各产品线仓库，制度与身份的档案归各主体仓。

## 现状

- Studio（Flutter，当前 0.1.3）：现存任务 / 评审 / 摩擦 / 角色四屏，为旧治理操作台实体，与监控面板定位不同物，去留未定
- CLI（Rust）：空壳，去留待决策
- Provider（Go）：空壳，仅 `GET /health`
- Site（React）：展示站，自述已随定位修正

## 路线

- [ ] 数据活水源：先定指标与验收结论的来源管道——没有稳定指标来源不立面板（仪表盘前车之鉴，见 `src/studio/CHANGELOG.md`）
- [ ] 面板形态与指标清单：**首指标已定**（见下节），余项待各自数据源

## 指标清单

1. **线上端点可用性**（2026-11-02 选定，第一个指标）
   - **判定**：靶单内 GET 端点返回 200 即过；非 200 或连接失败即挂
   - **数据活水源**：HTTP 探测，零新基建——按"水源先于面板"的顺序，第一个指标必须今天就有稳定水源
   - **验收方式**：线上复核（site 验收流程的最后一步）
   - **靶单 v1**（GET，六站）：`class`、`lite.class`、`quanttide.com`、`www`、`data`、`studio.data`
   - **基线（2026-11-02 二跑）**：**6 过 0 挂**
     - `www.quanttide.com` 首跑挂（指向 AWS S3 website，无 TLS，HTTP 亦 404），当日修复：新建 CDN 实例（源站 qtweb-site OSS、复用 `*.quanttide.com` 通配证书至 2027-01-31、闽 ICP 同案）+ DNS CNAME 改指 `www.quanttide.com.w.kunlunaq.com`，复跑 200
     - 遗留：`api.quanttide.com/qtclass/healthz` 404（网关映射待核，auth-pay 评审遗留；不入靶单，单列）
     - 注：`POST` 端点（如 oauth/token）按方法返回 404 属正常路由行为，不入 v1 GET 靶单
     - 待办：www 的 HTTP→HTTPS 强跳未配——CLI/SDK 无该 API，裸调动作名与配置函数名均被服务端白名单拒（force_redirect/https_config 等候选全数 Invalid）；两条路：控制台手动开（CDN→www→强制跳转→301），或维持与 apex 同规（apex HTTP 亦不跳，实测 200 直出）；HTTPS 本身 200 不受影响
- [ ] 四屏去留：待裁
