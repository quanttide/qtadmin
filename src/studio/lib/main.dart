import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/panorama.dart';
import 'package:qtadmin_studio/screens/business_detail_screen.dart';
import 'package:qtadmin_studio/screens/panorama_screen.dart';
import 'package:qtadmin_studio/screens/thinking_screen.dart';
import 'package:qtadmin_studio/services/panorama_loader.dart';

void main() {
  runApp(const QtAdminStudio());
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget Function(PanoramaData, String tenantName) builder;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.builder,
  });
}

class _TenantConfig {
  final String name;
  final IconData icon;
  final List<_NavItem> navItems;

  const _TenantConfig({
    required this.name,
    required this.icon,
    required this.navItems,
  });
}

class QtAdminStudio extends StatefulWidget {
  const QtAdminStudio({super.key});

  @override
  State<QtAdminStudio> createState() => _QtAdminStudioState();
}

class _QtAdminStudioState extends State<QtAdminStudio> {
  int _selectedTenant = 0;
  int _selectedIndex = 0;
  PanoramaData? _data;

  static final _tenants = [
    _TenantConfig(
      name: '量潮创始人',
      icon: Icons.person_outline,
      navItems: [
        _NavItem(
          icon: Icons.today_outlined,
          label: '全景图',
          builder: _buildPanorama,
        ),
        _NavItem(
          icon: Icons.psychology_outlined,
          label: '思考',
          builder: _buildThinking,
        ),
        _NavItem(
          icon: Icons.edit_outlined,
          label: '写作',
          builder: _buildPlaceholder,
        ),
      ],
    ),
    _TenantConfig(
      name: '量潮科技',
      icon: Icons.business_outlined,
      navItems: [
        _NavItem(
          icon: Icons.today_outlined,
          label: '全景图',
          builder: _buildPanorama,
        ),
        _NavItem(
          icon: Icons.storage_outlined,
          label: '量潮数据',
          builder: (data, _) => BusinessDetailScreen(unit: data.businessUnits[0]),
        ),
        _NavItem(
          icon: Icons.school_outlined,
          label: '量潮课堂',
          builder: (data, _) => BusinessDetailScreen(unit: data.businessUnits[1]),
        ),
        _NavItem(
          icon: Icons.support_agent_outlined,
          label: '量潮咨询',
          builder: (data, _) => BusinessDetailScreen(unit: data.businessUnits[2]),
        ),
        _NavItem(
          icon: Icons.cloud_outlined,
          label: '量潮云',
          builder: (data, _) => BusinessDetailScreen(unit: data.businessUnits[3]),
        ),
      ],
    ),
  ];

  _TenantConfig get _currentTenant => _tenants[_selectedTenant];

  static Widget _buildPanorama(PanoramaData data, String tenantName) {
    return PanoramaScreen(data: data, tenantName: tenantName);
  }

  static Widget _buildThinking(PanoramaData data, String tenantName) {
    return const ThinkingScreen();
  }

  static Widget _buildPlaceholder(PanoramaData data, String tenantName) {
    return const Center(child: Text('即将上线'));
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await PanoramaLoader.load();
    if (mounted) {
      setState(() {
        _data = data;
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
            Container(
              width: 72,
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  _TenantSwitcher(
                    tenants: _tenants,
                    selectedIndex: _selectedTenant,
                    onChanged: (index) {
                      setState(() {
                        _selectedTenant = index;
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  _buildDivider(),
                  ..._currentTenant.navItems.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return _NavIcon(
                      icon: item.icon,
                      label: item.label,
                      selected: _selectedIndex == i,
                      onTap: () => setState(() => _selectedIndex = i),
                    );
                  }),
                  _buildDivider(),
                  const Spacer(),
                ],
              ),
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

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Divider(height: 1, thickness: 1),
    );
  }

  Widget _buildPage() {
    if (_data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _currentTenant.navItems[_selectedIndex].builder(_data!, _currentTenant.name);
  }
}

class _TenantSwitcher extends StatelessWidget {
  final List<_TenantConfig> tenants;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _TenantSwitcher({
    required this.tenants,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tenant = tenants[selectedIndex];
    return PopupMenuButton<int>(
      onSelected: onChanged,
      offset: const Offset(0, 48),
      itemBuilder: (context) => tenants.asMap().entries.map((entry) {
        final i = entry.key;
        final t = entry.value;
        return PopupMenuItem<int>(
          value: i,
          child: Row(
            children: [
              Icon(t.icon, size: 18),
              const SizedBox(width: 8),
              Text(t.name, style: const TextStyle(fontSize: 14)),
              if (i == selectedIndex)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, size: 16, color: Colors.blue),
                ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        width: 72,
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tenant.icon, size: 22, color: const Color(0xFF1A1A1A)),
            const SizedBox(height: 2),
            Text(
              tenant.name,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 64,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? const Color(0xFF1A1A1A) : const Color(0xFF888888),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? const Color(0xFF1A1A1A) : const Color(0xFF888888),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
