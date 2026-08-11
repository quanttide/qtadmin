import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qtadmin_studio/navigation.dart';
import 'package:qtadmin_studio/router.dart';
import 'package:qtadmin_studio/store/app_store.dart';
import 'package:qtadmin_studio/store/store_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await AppStore.load();
  runApp(QtAdminStudio(store: store));
}

class QtAdminStudio extends StatelessWidget {
  final AppStore store;

  const QtAdminStudio({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      notifier: store,
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/tasks',
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
        GoRouterState.of(context).pathParameters['page'] ?? 'tasks';

    final routes = RouteConfig.all.values.toList();
    final sections = [
      for (final group in NavGroup.values)
        NavSection(
          dividerBefore: true,
          items: [
            for (final route in routes.where((r) => r.group == group))
              NavItem(routeId: route.id, icon: route.icon, label: route.label),
          ],
        ),
    ];

    final flatIds = [
      for (final s in sections)
        for (final i in s.items) i.routeId,
    ];
    final selectedIndex = flatIds.indexOf(currentPage);

    return Scaffold(
      body: Row(
        children: [
          NavSidebar(
            sections: sections,
            selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
            onItemTap: (index) {
              context.go('/${flatIds[index]}');
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
