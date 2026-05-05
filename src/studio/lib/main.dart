import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/panorama.dart';
import 'package:qtadmin_studio/screens/business_detail_screen.dart';
import 'package:qtadmin_studio/screens/panorama_screen.dart';
import 'package:qtadmin_studio/services/panorama_loader.dart';

void main() {
  runApp(const QtAdminStudio());
}

class QtAdminStudio extends StatefulWidget {
  const QtAdminStudio({super.key});

  @override
  State<QtAdminStudio> createState() => _QtAdminStudioState();
}

class _QtAdminStudioState extends State<QtAdminStudio> {
  int _selectedIndex = 0;
  PanoramaData? _data;

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
                  const SizedBox(height: 8),
                  _NavIcon(
                    icon: Icons.today_outlined,
                    label: '全景图',
                    selected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _buildDivider(),
                  _NavIcon(
                    icon: Icons.storage_outlined,
                    label: '量潮数据',
                    selected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  _NavIcon(
                    icon: Icons.school_outlined,
                    label: '量潮课堂',
                    selected: _selectedIndex == 2,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _NavIcon(
                    icon: Icons.support_agent_outlined,
                    label: '量潮咨询',
                    selected: _selectedIndex == 3,
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                  _NavIcon(
                    icon: Icons.cloud_outlined,
                    label: '量潮云',
                    selected: _selectedIndex == 4,
                    onTap: () => setState(() => _selectedIndex = 4),
                  ),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Divider(height: 1, thickness: 1),
    );
  }

  Widget _buildPage() {
    if (_data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (_selectedIndex) {
      case 0:
        return PanoramaScreen(data: _data!);
      case 1:
        return BusinessDetailScreen(unit: _data!.businessUnits[0]);
      case 2:
        return BusinessDetailScreen(unit: _data!.businessUnits[1]);
      case 3:
        return BusinessDetailScreen(unit: _data!.businessUnits[2]);
      case 4:
        return BusinessDetailScreen(unit: _data!.businessUnits[3]);
      default:
        return const SizedBox.shrink();
    }
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
