import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/metadata.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/models/qtclass.dart';
import 'package:qtadmin_studio/models/thinking.dart';
import 'package:qtadmin_studio/models/org.dart';
import 'package:qtadmin_studio/router.dart';
import 'package:qtadmin_studio/sources/data_source.dart';
import 'package:qtadmin_studio/views/navigation.dart';

final _source = const FileSource();

final _founderMetaLoader = DataLoader<NavMetadata>(_source, 'data/founder/metadata.json', NavMetadata.fromJson);
final _companyMetaLoader = DataLoader<NavMetadata>(_source, 'data/company/metadata.json', NavMetadata.fromJson);
final _rootMetaLoader = DataLoader<RootMetadata>(_source, 'data/metadata.json', RootMetadata.fromJson);
final _founderDashLoader = DataLoader<Dashboard>(_source, 'data/founder/dashboard.json', Dashboard.fromJson);
final _companyDashLoader = DataLoader<Dashboard>(_source, 'data/company/dashboard.json', Dashboard.fromJson);
final _consultLoader = DataLoader<QtConsult>(_source, 'data/company/qtconsult.json', QtConsult.fromJson);
final _classLoader = DataLoader<QtClass>(_source, 'data/company/qtclass.json', QtClass.fromJson);
final _thinkingLoader = DataLoader<Thinking>(_source, 'data/founder/thinking.json', Thinking.fromJson);
final _orgLoader = DataLoader<OrgDashboard>(_source, 'data/company/org.json', OrgDashboard.fromJson);

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
    final results = await Future.wait([
      _rootMetaLoader.load(),
      _founderMetaLoader.load(),
      _companyMetaLoader.load(),
      _founderDashLoader.load(),
      _companyDashLoader.load(),
      _consultLoader.load(),
      _classLoader.load(),
      _thinkingLoader.load(),
      _orgLoader.load(),
    ]);
    if (!mounted) return;
    setState(() {
      final root = (results[0] as DataSuccess<RootMetadata>).data;
      _workspaces = root.workspaces;
      for (final section in root.sections) {
        _sectionDefs[section.id] = section;
      }
      _navData['founder'] = (results[1] as DataSuccess<NavMetadata>).data;
      _navData['company'] = (results[2] as DataSuccess<NavMetadata>).data;
      _founderDashboard = (results[3] as DataSuccess<Dashboard>).data;
      _companyDashboard = (results[4] as DataSuccess<Dashboard>).data;
      _consultData = (results[5] as DataSuccess<QtConsult>).data;
      _classData = (results[6] as DataSuccess<QtClass>).data;
      _thinkingData = (results[7] as DataSuccess<Thinking>).data;
      _orgData = (results[8] as DataSuccess<OrgDashboard>).data;
      _buildSections();
    });
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
