import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qtadmin_studio/app_state.dart';
import 'package:qtadmin_studio/router.dart';
import 'package:qtadmin_studio/navigation.dart';

void main() {
  runApp(const QtAdminStudio());
}

class QtAdminStudio extends StatefulWidget {
  const QtAdminStudio({super.key});

  @override
  State<QtAdminStudio> createState() => _QtAdminStudioState();
}

class _QtAdminStudioState extends State<QtAdminStudio> {
  late final ValueNotifier<AppState> _appState;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _appState = ValueNotifier(const AppInitial());
    _router = GoRouter(
      refreshListenable: _appState,
      initialLocation: '/loading',
      routes: [
        GoRoute(
          path: '/loading',
          builder: (context, state) => const _LoadingScreen(),
        ),
        GoRoute(
          path: '/error',
          builder: (_, state) => _ErrorScreen(
            message: state.uri.queryParameters['message'] ?? '未知错误',
          ),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return AppStateScope(
              notifier: _appState,
              child: _SidebarShell(child: child),
            );
          },
          routes: [
            GoRoute(
              path: '/:page',
              builder: (context, state) {
                final data = AppStateScope.of(context);
                final page = state.pathParameters['page']!;
                final route = RouteConfig.find(page);
                final ctx = ScreenContext(
                  orgData: data.orgData,
                  recruitmentData: data.recruitmentData,
                );
                return route.builder(ctx);
              },
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final appState = _appState.value;
        final location = state.matchedLocation;
        return switch (appState) {
          AppInitial() || AppLoading() when location == '/loading' => null,
          AppInitial() || AppLoading() => '/loading',
          AppError() when location.startsWith('/error') => null,
          AppError(:final message) =>
            '/error?message=${Uri.encodeComponent(message)}',
          AppLoaded() when location == '/loading' || location == '/error' =>
            '/writing',
          AppLoaded() => null,
        };
      },
    );
    loadAppData(_appState);
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
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

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('加载失败: $message')));
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
