import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qtadmin_studio/models/metadata.dart';
import 'package:qtadmin_studio/views/navigation.dart';

void main() {
  group('NavIcon rendering', () {
    testWidgets('renders icon and label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavIcon(
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
            body: NavIcon(
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

  group('TenantSwitcher rendering', () {
    testWidgets('renders current tenant name and icon', (tester) async {
      final tenants = [
        TenantInfo(name: '量潮创始人', icon: 'person_outline'),
        TenantInfo(name: '量潮科技', icon: 'business_outlined'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TenantSwitcher(
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
            body: TenantSwitcher(
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
            body: TenantSwitcher(
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
