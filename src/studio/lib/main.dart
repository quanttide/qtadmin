import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qtadmin_studio/models/metadata.dart';
import 'package:qtadmin_studio/models/panorama.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/screens/business_detail_screen.dart';
import 'package:qtadmin_studio/screens/function_detail_screen.dart';
import 'package:qtadmin_studio/screens/panorama_screen.dart';
import 'package:qtadmin_studio/screens/qtconsult_screen.dart';
import 'package:qtadmin_studio/screens/thinking_screen.dart';
import 'package:qtadmin_studio/services/metadata_loader.dart';
import 'package:qtadmin_studio/services/panorama_loader.dart';
import 'package:qtadmin_studio/services/qtconsult_loader.dart';

void main() async {
  await dotenv.load();
  runApp(const QtAdminStudio());
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget Function() builder;

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

class QtAdminStudio extends StatefulWidget {
  const QtAdminStudio({super.key});

  @override
  State<QtAdminStudio> createState() => _QtAdminStudioState();
}

class _QtAdminStudioState extends State<QtAdminStudio> {
  int _selectedTenant = 0;
  int _selectedIndex = 0;

  NavMetadata? _founderMetadata;
  NavMetadata? _companyMetadata;
  PanoramaData? _founderPanorama;
  PanoramaData? _companyPanorama;
  QtConsultData? _consultData;
  List<_NavSection> _sections = [];

  NavMetadata get _currentMetadata =>
      _selectedTenant == 0 ? _founderMetadata! : _companyMetadata!;
  PanoramaData? get _data =>
      _selectedTenant == 0 ? _founderPanorama : _companyPanorama;

  Widget _buildScreenForItem(NavItemData item) {
    switch (item.pageType) {
      case 'panorama':
        return PanoramaScreen(data: _data!, tenantName: _currentMetadata.tenant.name);
      case 'thinking':
        return const ThinkingScreen();
      case 'writing':
        return const Center(child: Text('即将上线'));
      case 'consulting':
        return QtConsultScreen(data: _consultData!);
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
    _sections = _currentMetadata.sections.map((section) {
      return _NavSection(
        items: section.items.map((item) {
          return _NavItem(
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
    final results = await Future.wait([
      MetadataLoader.load(tenant: TenantType.internal),
      MetadataLoader.load(tenant: TenantType.customer),
      PanoramaLoader.load(tenant: TenantType.internal),
      PanoramaLoader.load(tenant: TenantType.customer),
      QtConsultLoader.load(tenant: TenantType.customer),
    ]);
    if (mounted) {
      setState(() {
        _founderMetadata = results[0] as NavMetadata;
        _companyMetadata = results[1] as NavMetadata;
        _founderPanorama = results[2] as PanoramaData;
        _companyPanorama = results[3] as PanoramaData;
        _consultData = results[4] as QtConsultData;
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
            tenants: [_founderMetadata!.tenant, _companyMetadata!.tenant],
            selectedIndex: _selectedTenant,
            onChanged: (index) {
              setState(() {
                _selectedTenant = index;
                _selectedIndex = 0;
                _buildSections();
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
    final allItems = _currentMetadata.allItems;
    if (_selectedIndex >= allItems.length) return const SizedBox.shrink();
    return _sections.expand((s) => s.items).toList()[_selectedIndex].builder();
  }
}

class _TenantSwitcher extends StatelessWidget {
  final List<TenantInfo> tenants;
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
              Icon(t.resolveIcon(), size: 18),
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
            Icon(tenant.resolveIcon(), size: 22, color: const Color(0xFF1A1A1A)),
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
