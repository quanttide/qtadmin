# qtadmin-site

量潮管理后台展示站，基于 React + TypeScript + Vite 构建。展示管理后台的定位与业务域 / 职能域架构分层。

## 开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览生产版本
npm run preview
```

## 技术栈

- React 19
- TypeScript
- Vite
- React Router（预留，多页面后引入）

## 项目结构

```
src/
├── App.tsx              # 主应用组件（首页：定位 + 架构分层）
├── App.css              # 应用样式
├── index.css            # 全局样式
├── main.tsx             # 入口文件
└── vite-env.d.ts        # Vite 类型声明
```
