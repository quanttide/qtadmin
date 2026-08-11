import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qtadmin_studio/router.dart';
import 'package:qtadmin_studio/navigation.dart';

void main() {
  runApp(const QtAdminStudio());
}

class QtAdminStudio extends StatelessWidget {
  const QtAdminStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/writing',
        routes: [
          ShellRoute(
            builder: (context, state, child) => _SidebarShell(child: child),
            routes: [
              GoRoute(
                path: '/:page',
                builder: (context, state) {
                  final page = state.pathParameters['page']!;
                  return RouteConfig.find(page).builder();
                },
              ),
            ],
          ),
        ],
      ),
      title: '量潮管理后台',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
    );
  }
}

class _SidebarShell extends StatelessWidget {
  final Widget child;

  const _SidebarShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final currentPage =
        GoRouterState.of(context).pathParameters['page'] ?? 'writing';

    final routeIds = RouteConfig.all.keys.toList();
    final sections = [
      NavSection(
        items: [
          for (final id in routeIds)
            NavItem(
              routeId: id,
              icon: RouteConfig.find(id).icon,
              label: RouteConfig.find(id).label,
            ),
        ],
      ),
    ];
    final selectedIndex = routeIds.indexOf(currentPage);

    return Scaffold(
      body: Row(
        children: [
          NavSidebar(
            sections: sections,
            selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
            onItemTap: (index) {
              context.go('/${routeIds[index]}');
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
