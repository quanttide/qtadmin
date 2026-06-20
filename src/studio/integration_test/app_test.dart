import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qtadmin_studio/models/recruitment.dart';
import 'package:qtadmin_studio/screens/recruitment_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RecruitmentScreen (integration)', () {
    final plan = RecruitmentPlan(
      month: '2026-06',
      positions: List.generate(20, (i) => PositionPlan(
        name: '岗位${i + 1}', headcount: 1, filled: 0, inProgress: 0, note: '',
      )),
    );

    testWidgets('no rendering errors with large dataset', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: RecruitmentScreen(data: plan)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders visible positions in table', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: RecruitmentScreen(data: plan)),
      );
      await tester.pumpAndSettle();

      // At least the first few positions are visible
      expect(find.text('岗位1'), findsOneWidget);
      expect(find.text('岗位2'), findsOneWidget);
    });

    testWidgets('summary section is visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: RecruitmentScreen(data: plan)),
      );
      await tester.pumpAndSettle();

      expect(find.text('岗位明细'), findsOneWidget);
      expect(find.text('20'), findsWidgets); // 统计行 + 表格中都有 20
      expect(find.text('0'), findsWidgets); // 多个统计值都是 0
    });
  });

  group('Rendering safety', () {
    testWidgets('empty recruitment plan renders without error', (tester) async {
      final empty = RecruitmentPlan(month: '2026-06', positions: []);
      await tester.pumpWidget(
        MaterialApp(home: RecruitmentScreen(data: empty)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('岗位明细'), findsOneWidget);
      expect(find.text('0'), findsWidgets); // 多个统计值都是 0
    });
  });
}
