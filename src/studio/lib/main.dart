import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtadmin_studio/blocs/app_bloc.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
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
          AppLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          AppLoaded(:final data) => AppShell(data: data),
          AppError(:final message) => Scaffold(
              body: Center(
                child: Text('加载失败: $message'),
              ),
            ),
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
  int _selectedWorkspace = 0;
  int _selectedIndex = 0;

  String get _dir => widget.data.workspaces[_selectedWorkspace].dir;
  Dashboard get _dashboard => widget.data.dashboard(_dir);
  late AppRouter _router;

  void _buildRouter() {
    _router = AppRouter(
      data: () => _dashboard,
      thinkingData: widget.data.thinkingData,
      consultData: widget.data.consultData,
      classData: widget.data.classData,
      orgData: widget.data.orgData,
      workspaces: widget.data.workspaces,
      selectedWorkspace: _selectedWorkspace,
    );
  }

  List<NavSection> get _sections {
    final nav = widget.data.navData[_dir]!;
    return nav.sections.map((section) {
      return NavSection(
        dividerBefore:
            widget.data.sectionDefs[section.id]?.dividerBefore ?? true,
        items: section.items.map((item) {
          final route = RouteConfig.find(item.name);
          return NavItem(
            icon: route.icon,
            label: route.label,
            builder: () => _router.buildScreen(route),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _buildRouter();
  }

  @override
  void didUpdateWidget(AppShell old) {
    super.didUpdateWidget(old);
    _buildRouter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavSidebar(
            workspaces: widget.data.workspaces,
            selectedWorkspace: _selectedWorkspace,
            onWorkspaceChanged: (index) {
              setState(() {
                _selectedWorkspace = index;
                _selectedIndex = 0;
              });
            },
            sections: _sections,
            selectedIndex: _selectedIndex,
            onItemTap: (index) => setState(() => _selectedIndex = index),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildPage()),
        ],
      ),
    );
  }

  Widget _buildPage() {
    final allItems = _sections.expand((s) => s.items).toList();
    if (_selectedIndex >= allItems.length) return const SizedBox.shrink();
    return allItems[_selectedIndex].builder();
  }
}
