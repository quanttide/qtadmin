import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qtadmin_studio/models/metadata.dart';

void main() {
  group('_NavIcon rendering', () {
    testWidgets('renders icon and label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _NavIcon(
              icon: Icons.today_outlined,
              label: '全景图',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('全景图'), findsOneWidget);
      expect(find.byIcon(Icons.today_outlined), findsOneWidget);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _NavIcon(
              icon: Icons.storage_outlined,
              label: '量潮数据',
              selected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('量潮数据'));
      expect(tapped, true);
    });
  });

  group('_TenantSwitcher rendering', () {
    testWidgets('renders current tenant name and icon', (tester) async {
      final tenants = [
        TenantInfo(name: '量潮创始人', icon: 'person_outline'),
        TenantInfo(name: '量潮科技', icon: 'business_outlined'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TenantSwitcher(
              tenants: tenants,
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('量潮创始人'), findsOneWidget);
      expect(find.byIcon(tenants[0].resolveIcon()), findsOneWidget);
    });

    testWidgets('opens popup menu on tap', (tester) async {
      final tenants = [
        TenantInfo(name: '量潮创始人', icon: 'person_outline'),
        TenantInfo(name: '量潮科技', icon: 'business_outlined'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TenantSwitcher(
              tenants: tenants,
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('量潮创始人'));
      await tester.pumpAndSettle();

      expect(find.text('量潮科技'), findsOneWidget);
    });

    testWidgets('fires onChanged when a tenant is selected in popup', (tester) async {
      int selectedIndex = -1;
      final tenants = [
        TenantInfo(name: '量潮创始人', icon: 'person_outline'),
        TenantInfo(name: '量潮科技', icon: 'business_outlined'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TenantSwitcher(
              tenants: tenants,
              selectedIndex: 0,
              onChanged: (index) => selectedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('量潮创始人'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('量潮科技').last);
      await tester.pumpAndSettle();

      expect(selectedIndex, 1);
    });
  });
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
