import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qtadmin_studio/blocs/app_bloc.dart';
import 'package:qtadmin_studio/router.dart';
import 'package:qtadmin_studio/views/navigation.dart';

void main() async {
  runApp(
    BlocProvider(
      create: (_) => AppBloc()..add(AppLoad()),
      child: const QtAdminStudio(),
    ),
  );
}

class QtAdminStudio extends StatelessWidget {
  const QtAdminStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) => switch (state) {
          AppInitial() => const SizedBox.shrink(),
          AppLoading() => const Scaffold(body: Center(child: CircularProgressIndicator())),
          AppLoaded(:final data) => AppShell(data: data),
          AppError(:final message) => Scaffold(body: Center(child: Text('加载失败: $message'))),
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  final AppData data;
  const AppShell({super.key, required this.data});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final initialWs = widget.data.workspaces[0].dir;
    final flatRouteIds = _buildFlatRouteIds();

    final data = widget.data;
    _router = GoRouter(
      initialLocation: '/workspace/$initialWs/dashboard',
      routes: [
        ShellRoute(
          builder: (context, state, child) => _SidebarShell(
            data: data,
            flatRouteIds: flatRouteIds,
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/workspace/:workspace/:page',
              builder: (context, state) {
                final dir = state.pathParameters['workspace']!;
                final page = state.pathParameters['page']!;
                final wsIndex = data.workspaces.indexWhere((w) => w.dir == dir);
                return buildScreen(
                  dir: dir,
                  page: page,
                  founderDashboard: data.founderDashboard,
                  companyDashboard: data.companyDashboard,
                  thinkingData: data.thinkingData,
                  consultData: data.consultData,
                  classData: data.classData,
                  orgData: data.orgData,
                  workspaceNames: data.workspaces.map((w) => w.name).toList(),
                  selectedWorkspace: wsIndex >= 0 ? wsIndex : 0,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  List<String> _buildFlatRouteIds() {
    final ids = <String>[];
    for (final nav in widget.data.navData.values) {
      for (final section in nav.sections) {
        for (final item in section.items) {
          ids.add(item.name);
        }
      }
    }
    return ids;
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
    );
  }
}

class _SidebarShell extends StatelessWidget {
  final AppData data;
  final List<String> flatRouteIds;
  final Widget child;

  const _SidebarShell({
    required this.data,
    required this.flatRouteIds,
    required this.child,
  });

  int _selectedIndex(String currentPage) {
    final idx = flatRouteIds.indexOf(currentPage);
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = GoRouterState.of(context).pathParameters['page'] ?? 'dashboard';
    final currentDir = GoRouterState.of(context).pathParameters['workspace'] ?? data.workspaces[0].dir;
    final nav = data.navData[currentDir]!;

    final sections = nav.sections.map((section) {
      return NavSection(
        dividerBefore: data.sectionDefs[section.id]?.dividerBefore ?? true,
        items: section.items.map((item) {
          final route = RouteConfig.find(item.name);
          return NavItem(routeId: item.name, icon: route.icon, label: route.label);
        }).toList(),
      );
    }).toList();

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
            sections: sections,
            selectedIndex: _selectedIndex(currentPage),
            onItemTap: (index) {
              final routeId = flatRouteIds[index];
              context.go('/workspace/$currentDir/$routeId');
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
