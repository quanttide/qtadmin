import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/navigation.dart';

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  group('NavIcon rendering', () {
    testWidgets('renders icon and label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          NavIcon(
            icon: Icons.today_outlined,
            label: '仪表盘',
            selected: false,
            onTap: () {},
          ),
        ),
      );
      expect(find.text('仪表盘'), findsOneWidget);
      expect(find.byIcon(Icons.today_outlined), findsOneWidget);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          NavIcon(
            icon: Icons.storage_outlined,
            label: '量潮数据',
            selected: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('量潮数据'));
      expect(tapped, true);
    });
  });

  group('NavSidebar rendering', () {
    testWidgets('renders nav icons', (tester) async {
      final sections = [
        NavSection(
          dividerBefore: false,
          items: [
            NavItem(
              routeId: 'dashboard',
              icon: Icons.today_outlined,
              label: '仪表盘',
            ),
          ],
        ),
        NavSection(
          dividerBefore: true,
          items: [
            NavItem(
              routeId: 'data',
              icon: Icons.storage_outlined,
              label: '量潮数据',
            ),
            NavItem(
              routeId: 'classroom',
              icon: Icons.school_outlined,
              label: '量潮课堂',
            ),
          ],
        ),
      ];
      await tester.pumpWidget(
        _wrap(
          NavSidebar(sections: sections, selectedIndex: 0, onItemTap: (_) {}),
        ),
      );
      expect(find.text('仪表盘'), findsOneWidget);
      expect(find.text('量潮数据'), findsOneWidget);
      expect(find.text('量潮课堂'), findsOneWidget);
      expect(find.byIcon(Icons.today_outlined), findsOneWidget);
    });

    testWidgets('fires onItemTap when nav icon is tapped', (tester) async {
      int tappedIndex = -1;
      final sections = [
        NavSection(
          dividerBefore: false,
          items: [
            NavItem(
              routeId: 'dashboard',
              icon: Icons.today_outlined,
              label: '仪表盘',
            ),
            NavItem(routeId: 'data', icon: Icons.storage_outlined, label: '数据'),
          ],
        ),
      ];
      await tester.pumpWidget(
        _wrap(
          NavSidebar(
            sections: sections,
            selectedIndex: 0,
            onItemTap: (i) => tappedIndex = i,
          ),
        ),
      );
      await tester.tap(find.text('数据'));
      expect(tappedIndex, 1);
    });
  });
}
