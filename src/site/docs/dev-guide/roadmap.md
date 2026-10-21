# ROADMAP

管理后台以 Studio 工作台（Flutter，`../studio`）为客户端载体；Site 为展示层，呈现治理思想与架构分层。部署形态对齐 qtclass-site（静态构建 + OSS 托管），域名与部署管道待定。

## v0.1.0

- [x] 工程初始化：React 19 + TypeScript + Vite，对齐 qtclass-site 技术栈
- [x] 首页：定位 + 业务域 / 职能域架构分层
- [ ] 部署链路：构建产物上传 OSS + CDN，对齐 deploy-site 模式

## v0.2.0

- [ ] 域页：各业务域与职能域的说明页（来源：`docs/user-guide`、各产品线仓库）
- [ ] 首页内容契约化：卡片数据从本地 JSON 契约读取，对齐数据驱动的产品研发方法
