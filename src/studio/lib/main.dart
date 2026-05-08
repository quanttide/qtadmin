import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/metadata.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/models/qtclass.dart';
import 'package:qtadmin_studio/models/thinking.dart';
import 'package:qtadmin_studio/models/org.dart';
import 'package:qtadmin_studio/router.dart';
import 'package:qtadmin_studio/services/metadata_loader.dart';
import 'package:qtadmin_studio/services/dashboard_loader.dart';
import 'package:qtadmin_studio/services/qtclass_loader.dart';
import 'package:qtadmin_studio/services/qtconsult_loader.dart';
import 'package:qtadmin_studio/services/thinking_loader.dart';
import 'package:qtadmin_studio/services/org_loader.dart';
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
  Dashboard? _founderDashboard;
  Dashboard? _companyDashboard;
  QtConsult? _consultData;
  QtClass? _classData;
  Thinking? _thinkingData;
  OrgDashboard? _orgData;
  List<NavSection> _sections = [];

  Dashboard? get _data =>
      _selectedWorkspace == 0 ? _founderDashboard : _companyDashboard;

  late AppRouter _router;

  void _buildSections() {
    final dir = _workspaces[_selectedWorkspace].dir;
    final nav = _navData[dir]!;
    _router = AppRouter(
      data: () => _data!,
      thinkingData: _thinkingData,
      consultData: _consultData,
      classData: _classData,
      orgData: _orgData,
      workspaces: _workspaces,
      selectedWorkspace: _selectedWorkspace,
    );
    _sections = nav.sections.map((section) {
      return NavSection(
        dividerBefore: _sectionDefs[section.id]?.dividerBefore ?? true,
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
      OrgLoader.load(),
    ]);
    if (mounted) {
      setState(() {
        _workspaces = root.workspaces;
        for (final section in root.sections) {
          _sectionDefs[section.id] = section;
        }
        _navData[root.workspaces[0].dir] = results[0] as NavMetadata;
        _navData[root.workspaces[1].dir] = results[1] as NavMetadata;
        _founderDashboard = results[2] as Dashboard;
        _companyDashboard = results[3] as Dashboard;
        _consultData = results[4] as QtConsult;
        _classData = results[5] as QtClass;
        _thinkingData = results[6] as Thinking;
        _orgData = results[7] as OrgDashboard;
        _buildSections();
      });
    }
  }

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
