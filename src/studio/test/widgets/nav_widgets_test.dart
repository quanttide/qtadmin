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
              label: '仪表盘',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('仪表盘'), findsOneWidget);
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

  group('WorkspaceSwitcher rendering', () {
    testWidgets('renders current workspace name and icon', (tester) async {
      final workspaces = [
        WorkspaceInfo(name: '量潮创始人', icon: 'person_outline', dir: 'founder'),
        WorkspaceInfo(name: '量潮科技', icon: 'business_outlined', dir: 'company'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceSwitcher(
              workspaces: workspaces,
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('量潮创始人'), findsOneWidget);
      expect(find.byIcon(workspaces[0].resolveIcon()), findsOneWidget);
    });

    testWidgets('opens popup menu on tap', (tester) async {
      final workspaces = [
        WorkspaceInfo(name: '量潮创始人', icon: 'person_outline', dir: 'founder'),
        WorkspaceInfo(name: '量潮科技', icon: 'business_outlined', dir: 'company'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceSwitcher(
              workspaces: workspaces,
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

    testWidgets('fires onChanged when a workspace is selected in popup', (tester) async {
      int selectedIndex = -1;
      final workspaces = [
        WorkspaceInfo(name: '量潮创始人', icon: 'person_outline', dir: 'founder'),
        WorkspaceInfo(name: '量潮科技', icon: 'business_outlined', dir: 'company'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceSwitcher(
              workspaces: workspaces,
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

  group('NavSidebar rendering', () {
    testWidgets('renders workspace switcher and nav icons', (tester) async {
      final workspaces = [
        WorkspaceInfo(name: '量潮创始人', icon: 'person_outline', dir: 'founder'),
        WorkspaceInfo(name: '量潮科技', icon: 'business_outlined', dir: 'company'),
      ];
      final sections = [
        NavSection(
          dividerBefore: false,
          items: [
            NavItem(icon: Icons.today_outlined, label: '仪表盘', builder: () => const SizedBox()),
          ],
        ),
        NavSection(
          dividerBefore: true,
          items: [
            NavItem(icon: Icons.storage_outlined, label: '量潮数据', builder: () => const SizedBox()),
            NavItem(icon: Icons.school_outlined, label: '量潮课堂', builder: () => const SizedBox()),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavSidebar(
              workspaces: workspaces,
              selectedWorkspace: 0,
              onWorkspaceChanged: (_) {},
              sections: sections,
              selectedIndex: 0,
              onItemTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('量潮创始人'), findsOneWidget);
      expect(find.text('仪表盘'), findsOneWidget);
      expect(find.text('量潮数据'), findsOneWidget);
      expect(find.text('量潮课堂'), findsOneWidget);
      expect(find.byIcon(workspaces[0].resolveIcon()), findsOneWidget);
      expect(find.byIcon(Icons.today_outlined), findsOneWidget);
      expect(find.byIcon(Icons.storage_outlined), findsOneWidget);
    });

    testWidgets('fires onItemTap when nav icon is tapped', (tester) async {
      int tappedIndex = -1;
      final workspaces = [
        WorkspaceInfo(name: '量潮创始人', icon: 'person_outline', dir: 'founder'),
      ];
      final sections = [
        NavSection(
          dividerBefore: false,
          items: [
            NavItem(icon: Icons.today_outlined, label: '仪表盘', builder: () => const SizedBox()),
            NavItem(icon: Icons.storage_outlined, label: '数据', builder: () => const SizedBox()),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavSidebar(
              workspaces: workspaces,
              selectedWorkspace: 0,
              onWorkspaceChanged: (_) {},
              sections: sections,
              selectedIndex: 0,
              onItemTap: (i) => tappedIndex = i,
            ),
          ),
        ),
      );

      await tester.tap(find.text('数据'));
      expect(tappedIndex, 1);
    });
  });
}
