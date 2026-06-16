import 'package:flutter/material.dart';
import 'screens/pipeline_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/pool_screen.dart';
import 'screens/settings_screen.dart';
import 'services/api_service.dart';
import 'theme/hr_theme.dart';

void main() {
  runApp(const HrKanbanApp());
}

class HrKanbanApp extends StatelessWidget {
  const HrKanbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '招聘管道验收看板',
      debugShowCheckedModeBanner: false,
      theme: buildHrTheme(),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _api = ApiService();
  int _tab = 0;

  static const _railDestinations = <NavigationRailDestination>[
    NavigationRailDestination(icon: Icon(Icons.view_column), label: Text('看板')),
    NavigationRailDestination(icon: Icon(Icons.inbox), label: Text('确认队列')),
    NavigationRailDestination(icon: Icon(Icons.person_search), label: Text('人才库')),
    NavigationRailDestination(icon: Icon(Icons.settings), label: Text('AI 设置')),
  ];

  static const _barDestinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.view_column), label: '看板'),
    NavigationDestination(icon: Icon(Icons.inbox), label: '确认队列'),
    NavigationDestination(icon: Icon(Icons.person_search), label: '人才库'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'AI 设置'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final body = IndexedStack(
          index: _tab,
          children: [
            PipelineScreen(api: _api),
            QueueScreen(api: _api),
            PoolScreen(api: _api),
            SettingsScreen(api: _api),
          ],
        );

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _tab,
                  onDestinationSelected: (i) => setState(() => _tab = i),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Icon(Icons.people, size: 24),
                  ),
                  destinations: _railDestinations,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: _barDestinations,
          ),
        );
      },
    );
  }
}
