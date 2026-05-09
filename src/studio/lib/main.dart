import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qtadmin_studio/blocs/app_bloc.dart';
import 'package:qtadmin_qtconsult/consult.dart';
import 'package:qtadmin_studio/router.dart';
import 'package:qtadmin_studio/views/navigation.dart';

class _AppStateNotifier extends ChangeNotifier {
  StreamSubscription? _sub;

  _AppStateNotifier(AppBloc bloc) {
    _sub = bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

void main() async {
  final bloc = AppBloc()..add(AppLoad());
  runApp(QtAdminStudio(bloc: bloc));
}

class QtAdminStudio extends StatefulWidget {
  final AppBloc bloc;
  const QtAdminStudio({super.key, required this.bloc});

  @override
  State<QtAdminStudio> createState() => _QtAdminStudioState();
}

class _QtAdminStudioState extends State<QtAdminStudio> {
  late final GoRouter _router;
  late final _AppStateNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = _AppStateNotifier(widget.bloc);
    _router = GoRouter(
      refreshListenable: _notifier,
      initialLocation: '/loading',
      routes: [
        GoRoute(path: '/loading', builder: (context, state) => const _LoadingScreen()),
        GoRoute(
          path: '/error',
          builder: (_, state) => _ErrorScreen(
            message: state.uri.queryParameters['message'] ?? '未知错误',
          ),
        ),
        ShellRoute(
          builder: (context, state, child) {
            final data = (context.read<AppBloc>().state as AppLoaded).data;
            return BlocProvider(
              create: (_) => ConsultBloc(ConsultState(data: data.consultData)),
              child: _SidebarShell(child: child),
            );
          },
          routes: [
            GoRoute(
              path: '/workspace/:workspace/:page',
              builder: (context, state) {
                final data = (context.read<AppBloc>().state as AppLoaded).data;
                final dir = state.pathParameters['workspace']!;
                final page = state.pathParameters['page']!;
                final wsIndex = data.workspaces.indexWhere((w) => w.dir == dir);
                final dashboard = dir == 'founder' ? data.founderDashboard : data.companyDashboard;
                final route = RouteConfig.find(page);
                final ctx = ScreenContext(
                  dashboard: dashboard,
                  workspaceName: data.workspaces[wsIndex >= 0 ? wsIndex : 0].name,
                  selectedWorkspace: wsIndex >= 0 ? wsIndex : 0,
                  thinkingData: data.thinkingData,
                  consultData: data.consultData,
                  classData: data.classData,
                  orgData: data.orgData,
                );
                return route.builder(ctx);
              },
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final appState = widget.bloc.state;
        final location = state.matchedLocation;
        return switch (appState) {
          AppInitial() || AppLoading() when location == '/loading' => null,
          AppInitial() || AppLoading() => '/loading',
          AppError() when location.startsWith('/error') => null,
          AppError(:final message) => '/error?message=${Uri.encodeComponent(message)}',
          AppLoaded() when location == '/loading' || location == '/error' => '/workspace/founder/dashboard',
          AppLoaded() => null,
        };
      },
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: MaterialApp.router(
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

class _SidebarShell extends StatefulWidget {
  final Widget child;

  const _SidebarShell({required this.child});

  @override
  State<_SidebarShell> createState() => _SidebarShellState();
}

class _SidebarShellState extends State<_SidebarShell> {
  String _cachedDir = '';
  List<NavSection> _sections = [];
  List<String> _flatRouteIds = [];

  void _rebuildSections(AppData data, String dir) {
    if (dir == _cachedDir && _sections.isNotEmpty) return;
    _cachedDir = dir;
    final nav = data.navData[dir]!;

    _flatRouteIds = [];
    _sections = nav.sections.map((section) {
      return NavSection(
        dividerBefore: data.sectionDefs[section.id]?.dividerBefore ?? true,
        items: section.items.map((item) {
          _flatRouteIds.add(item.name);
          final route = RouteConfig.find(item.name);
          return NavItem(routeId: item.name, icon: route.icon, label: route.label);
        }).toList(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = (context.read<AppBloc>().state as AppLoaded).data;
    final currentPage = GoRouterState.of(context).pathParameters['page'] ?? 'dashboard';
    final currentDir = GoRouterState.of(context).pathParameters['workspace'] ?? data.workspaces[0].dir;

    _rebuildSections(data, currentDir);

    final selectedIndex = _flatRouteIds.indexOf(currentPage);

    return Scaffold(
      body: Row(
        children: [
          NavSidebar(
            workspaces: data.workspaces,
            selectedWorkspace: data.workspaces.indexWhere((w) => w.dir == currentDir),
            onWorkspaceChanged: (index) {
              final newDir = data.workspaces[index].dir;
              context.go('/workspace/$newDir/$currentPage');
            },
            sections: _sections,
            selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
            onItemTap: (index) {
              context.go('/workspace/$currentDir/${_flatRouteIds[index]}');
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
