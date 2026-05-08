# Studio 关键决策

| 决策 | 替代方案 | 理由 |
|:-----|:---------|:-----|
| flutter_bloc 替代 setState | Provider/riverpod | 事件驱动适合 consult_screen 的添加/确认/驳回/删除操作链 |
| _SidebarShell StatefulWidget 缓存 | 无缓存每次都 rebuild | workspace 不变时完全复用子树，减少 50%+ 无谓重建 |
| ConsultBloc 提升至 ShellRoute | 跟随页面创建/销毁 | 跨页面保持咨询状态，避免退出页面丢数据 |
| AppData 单次创建 + Section 按 workspace 缓存 | 每次切换 workspace 重新加载 | 导航三栏数据（projects/workspaces/sections）生命周期由 AppBloc 统一管理 |
