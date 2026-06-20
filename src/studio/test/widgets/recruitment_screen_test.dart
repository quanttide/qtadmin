import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/recruitment.dart';
import 'package:qtadmin_studio/screens/recruitment_screen.dart';

RecruitmentPlan _createTestData() {
  return RecruitmentPlan(
    month: '2026-06',
    positions: [
      PositionPlan(name: '数据工程师', headcount: 2, filled: 1, inProgress: 1, note: '试用期'),
      PositionPlan(name: '新媒体运营', headcount: 1, filled: 0, inProgress: 0, note: ''),
    ],
  );
}

void main() {
  group('RecruitmentScreen', () {
    testWidgets('displays month title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecruitmentScreen(data: _createTestData()),
        ),
      );

      expect(find.text('2026-06 招聘计划'), findsOneWidget);
    });

    testWidgets('displays stats row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecruitmentScreen(data: _createTestData()),
        ),
      );

      expect(find.text('编制'), findsWidgets);
      expect(find.text('已入职'), findsWidgets);
      expect(find.text('进行中'), findsWidgets);
      expect(find.text('空缺'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);  // totalHeadcount
      expect(find.text('2'), findsWidgets);    // vacancies(2) + headcount(2)
    });

    testWidgets('displays position table', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecruitmentScreen(data: _createTestData()),
        ),
      );

      expect(find.text('岗位明细'), findsOneWidget);
      expect(find.text('数据工程师'), findsOneWidget);
      expect(find.text('新媒体运营'), findsOneWidget);
      expect(find.text('试用期'), findsOneWidget);
    });

    testWidgets('displays empty note as dash', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecruitmentScreen(data: _createTestData()),
        ),
      );

      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('displays table headers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecruitmentScreen(data: _createTestData()),
        ),
      );

      expect(find.text('岗位'), findsOneWidget);
      expect(find.text('已入职'), findsWidgets);
      expect(find.text('进行中'), findsWidgets);
      expect(find.text('备注'), findsOneWidget);
    });
  });
}
