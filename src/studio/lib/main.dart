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
            NavigationRail(
              extended: false,
              minWidth: 72,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: _navItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.icon),
                  label: Text(item.label),
                );
              }).toList(),
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

  static const _navItems = [
    _NavItem(icon: Icons.today_outlined, label: '全景图'),
    _NavItem(icon: Icons.storage_outlined, label: '数据'),
    _NavItem(icon: Icons.school_outlined, label: '课堂'),
    _NavItem(icon: Icons.support_agent_outlined, label: '咨询'),
    _NavItem(icon: Icons.cloud_outlined, label: '云'),
  ];
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
