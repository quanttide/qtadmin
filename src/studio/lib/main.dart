import 'package:flutter/material.dart';
import 'package:qtadmin_studio/screens/panorama_screen.dart';

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

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.today_outlined, label: '今日'),
    _NavItem(icon: Icons.lightbulb_outline, label: 'Think'),
    _NavItem(icon: Icons.edit_outlined, label: 'Write'),
    _NavItem(icon: Icons.people_outline, label: 'Team'),
    _NavItem(icon: Icons.auto_stories_outlined, label: 'Meta'),
    _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
  ];

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
    switch (_selectedIndex) {
      case 0:
        return const PanoramaScreen();
      default:
        return Center(
          child: Text(
            _navItems[_selectedIndex].label,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
