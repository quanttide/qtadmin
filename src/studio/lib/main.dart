import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/metadata.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/models/qtclass.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/models/thinking.dart';
import 'package:qtadmin_studio/screens/business_detail_screen.dart';
import 'package:qtadmin_studio/screens/function_detail_screen.dart';
import 'package:qtadmin_studio/screens/dashboard_screen.dart';
import 'package:qtadmin_studio/screens/qtclass_screen.dart';
import 'package:qtadmin_studio/screens/qtconsult_screen.dart';
import 'package:qtadmin_studio/screens/thinking_screen.dart';
import 'package:qtadmin_studio/services/metadata_loader.dart';
import 'package:qtadmin_studio/services/dashboard_loader.dart';
import 'package:qtadmin_studio/services/qtclass_loader.dart';
import 'package:qtadmin_studio/services/qtconsult_loader.dart';
import 'package:qtadmin_studio/services/thinking_loader.dart';
import 'package:qtadmin_studio/views/navigation.dart';

void main() async {
  runApp(const QtAdminStudio());
}

class QtAdminStudio extends StatefulWidget {
  const QtAdminStudio({super.key});

  @override
  State<QtAdminStudio> createState() => _QtAdminStudioState();
}

class _QtAdminStudioState extends State<QtAdminStudio> {
  int _selectedWorkspace = 0;
  int _selectedIndex = 0;

  List<WorkspaceInfo> _workspaces = [];
  final Map<String, NavMetadata> _navData = {};
  final Map<String, SectionDef> _sectionDefs = {};
  DashboardData? _founderDashboard;
  DashboardData? _companyDashboard;
  QtConsultData? _consultData;
  QtClassData? _classData;
  ThinkingData? _thinkingData;
  List<NavSection> _sections = [];

  DashboardData? get _data =>
      _selectedWorkspace == 0 ? _founderDashboard : _companyDashboard;

  Widget _buildScreenForItem(NavItemData item) {
    switch (item.pageType) {
      case 'dashboard':
        return DashboardScreen(data: _data!, workspaceName: _workspaces[_selectedWorkspace].name);
      case 'thinking':
        return ThinkingScreen(data: _thinkingData!);
      case 'writing':
        return const Center(child: Text('即将上线'));
      case 'consulting':
        return QtConsultScreen(data: _consultData!);
      case 'classroom':
        return QtClassScreen(data: _classData!);
      case 'business_detail': {
        final unit = _data!.businessUnits.firstWhere(
          (u) => u.name == item.label,
          orElse: () => throw StateError('未找到业务单元: ${item.label}'),
        );
        return BusinessDetailScreen(unit: unit);
      }
      case 'function_detail': {
        final card = _data!.functionCards.firstWhere(
          (c) => c.name == item.label,
          orElse: () => throw StateError('未找到职能卡: ${item.label}'),
        );
        return FuncDetailScreen(card: card);
      }
      default:
        return const SizedBox.shrink();
    }
  }

  void _buildSections() {
    final dir = _workspaces[_selectedWorkspace].dir;
    final nav = _navData[dir]!;
    _sections = nav.sections.map((section) {
      return NavSection(
        dividerBefore: _sectionDefs[section.id]?.dividerBefore ?? true,
        items: section.items.map((item) {
          return NavItem(
            icon: item.resolveIcon(),
            label: item.label,
            builder: () => _buildScreenForItem(item),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final root = await MetadataLoader.loadRoot();
    final results = await Future.wait([
      MetadataLoader.load(root.workspaces[0].dir),
      MetadataLoader.load(root.workspaces[1].dir),
      DashboardLoader.load(workspace: WorkspaceType.internal),
      DashboardLoader.load(workspace: WorkspaceType.customer),
      QtConsultLoader.load(workspace: WorkspaceType.customer),
      QtClassLoader.load(),
      ThinkingLoader.load(),
    ]);
    if (mounted) {
      setState(() {
        _workspaces = root.workspaces;
        for (final section in root.sections) {
          _sectionDefs[section.id] = section;
        }
        _navData[root.workspaces[0].dir] = results[0] as NavMetadata;
        _navData[root.workspaces[1].dir] = results[1] as NavMetadata;
        _founderDashboard = results[2] as DashboardData;
        _companyDashboard = results[3] as DashboardData;
        _consultData = results[4] as QtConsultData;
        _classData = results[5] as QtClassData;
        _thinkingData = results[6] as ThinkingData;
        _buildSections();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      home: Scaffold(
        body: Row(
          children: [
            NavSidebar(
              workspaces: _workspaces,
              selectedWorkspace: _selectedWorkspace,
              onWorkspaceChanged: (index) {
                setState(() {
                  _selectedWorkspace = index;
                  _selectedIndex = 0;
                  _buildSections();
                });
              },
              sections: _sections,
              selectedIndex: _selectedIndex,
              onItemTap: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _buildPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    if (_data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final allItems = _sections.expand((s) => s.items).toList();
    if (_selectedIndex >= allItems.length) return const SizedBox.shrink();
    return allItems[_selectedIndex].builder();
  }
}
