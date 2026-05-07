import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qtadmin_studio/models/panorama.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/screens/business_detail_screen.dart';
import 'package:qtadmin_studio/screens/function_detail_screen.dart';
import 'package:qtadmin_studio/screens/panorama_screen.dart';
import 'package:qtadmin_studio/screens/qtconsult_screen.dart';
import 'package:qtadmin_studio/services/panorama_loader.dart';
import 'package:qtadmin_studio/services/qtconsult_loader.dart';

void main() async {
  await dotenv.load();
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

class _NavSection {
  final List<_NavItem> items;

  const _NavSection({required this.items});
}

class _TenantConfig {
  final String name;
  final IconData icon;

  const _TenantConfig({
    required this.name,
    required this.icon,
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
  PanoramaData? _founderPanorama;
  PanoramaData? _companyPanorama;
  QtConsultData? _customerConsultData;
  QtConsultData? _internalConsultData;
  List<_NavSection> _sections = [];

  static const _tenants = [
    _TenantConfig(name: '量潮创始人', icon: Icons.person_outline),
    _TenantConfig(name: '量潮科技', icon: Icons.business_outlined),
  ];

  _TenantConfig get _currentTenant => _tenants[_selectedTenant];
  PanoramaData? get _data => _selectedTenant == 0 ? _founderPanorama : _companyPanorama;

  IconData _iconForName(String name) {
    switch (name) {
      case '量潮数据':
        return Icons.storage_outlined;
      case '量潮课堂':
        return Icons.school_outlined;
      case '量潮咨询':
        return Icons.support_agent_outlined;
      case '量潮云':
        return Icons.cloud_outlined;
      case '自身观察':
        return Icons.self_improvement_outlined;
      case '人力资源':
        return Icons.people_outline;
      case '财务管理':
        return Icons.account_balance_outlined;
      case '组织管理':
        return Icons.account_tree_outlined;
      case '战略管理':
        return Icons.track_changes_outlined;
      case '新媒体':
        return Icons.campaign_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  void _buildSections() {
    _sections = [
      _NavSection(items: [
        _NavItem(
          icon: Icons.today_outlined,
          label: '全景图',
          builder: (data, tenantName) =>
              PanoramaScreen(data: data, tenantName: tenantName),
        ),
      ]),
      _NavSection(items: _data!.businessUnits.map((unit) {
        return _NavItem(
          icon: _iconForName(unit.name),
          label: unit.name,
          builder: unit.isConsulting ? (_, __) {
            final consult = unit.consultSource == 'internal' ? _internalConsultData : _customerConsultData;
            return QtConsultScreen(data: consult!);
          } : (_, __) => BusinessDetailScreen(unit: unit),
        );
      }).toList()),
      _NavSection(items: _data!.functionCards.map((card) {
        return _NavItem(
          icon: _iconForName(card.name),
          label: card.name,
          builder: (_, __) => FuncDetailScreen(card: card),
        );
      }).toList()),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      PanoramaLoader.load(tenant: TenantType.internal),
      PanoramaLoader.load(tenant: TenantType.customer),
      QtConsultLoader.load(tenant: TenantType.customer),
      QtConsultLoader.load(tenant: TenantType.internal),
    ]);
    if (mounted) {
      setState(() {
        _founderPanorama = results[0] as PanoramaData;
        _companyPanorama = results[1] as PanoramaData;
        _customerConsultData = results[2] as QtConsultData;
        _internalConsultData = results[3] as QtConsultData;
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
            _buildSidebar(theme),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _buildPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    int flatIndex = 0;

    return Container(
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
          ..._sections.asMap().entries.expand((entry) {
            final i = entry.key;
            final section = entry.value;
            final items = section.items.map((item) {
              final idx = flatIndex++;
              return _NavIcon(
                icon: item.icon,
                label: item.label,
                selected: _selectedIndex == idx,
                onTap: () => setState(() => _selectedIndex = idx),
              );
            }).toList();
            return [
              if (i == 0 && items.isNotEmpty)
                _buildDivider()
              else if (i > 0)
                _buildDivider(),
              ...items,
            ];
          }),
          _buildDivider(),
          const Spacer(),
        ],
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
    final allItems = _sections.expand((s) => s.items).toList();
    if (_selectedIndex >= allItems.length) return const SizedBox.shrink();
    return allItems[_selectedIndex].builder(_data!, _currentTenant.name);
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
