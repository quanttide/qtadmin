import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qtadmin_studio/router.dart';
import 'package:qtadmin_studio/models/recruitment.dart';
import 'package:qtadmin_studio/screens/recruitment_screen.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RouteConfig', () {
    test('all routes resolve without errors', () {
      for (final entry in RouteConfig.all.entries) {
        expect(
          () => RouteConfig.find(entry.key),
          returnsNormally,
          reason: '路由 ${entry.key} 应能正常解析',
        );
      }
    });

    test('route ids include key navigation targets', () {
      final ids = RouteConfig.all.keys.toSet();
      expect(ids, contains('recruitment'));
      expect(ids, contains('dashboard'));
      expect(ids, contains('hr'));
      expect(ids, contains('consulting'));
      expect(ids, contains('org'));
    });
  });

  group('RecruitmentScreen', () {
    testWidgets('renders with contract data', (tester) async {
      final plan = RecruitmentPlan(
        month: '2026-06',
        positions: [
          PositionPlan(name: '数据工程师', headcount: 2, filled: 1, inProgress: 1, note: '试用期'),
          PositionPlan(name: '新媒体运营', headcount: 1, filled: 0, inProgress: 0, note: ''),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RecruitmentScreen(data: plan),
        ),
      );

      expect(find.text('2026-06 招聘计划'), findsOneWidget);
      expect(find.text('数据工程师'), findsOneWidget);
      expect(find.text('新媒体运营'), findsOneWidget);
      expect(find.text('试用期'), findsOneWidget);
    });

    testWidgets('stats row reflects plan data', (tester) async {
      final plan = RecruitmentPlan(
        month: '2026-06',
        positions: [
          PositionPlan(name: '数据工程师', headcount: 2, filled: 1, inProgress: 0, note: ''),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RecruitmentScreen(data: plan),
        ),
      );

      expect(find.text('2'), findsWidgets);   // totalHeadcount 2 + headcount column
      expect(find.text('1'), findsWidgets);   // totalFilled 1 + table value
    });
  });
}
