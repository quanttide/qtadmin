import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_qtclass/class.dart';

QtClass _createTestData() {
  return QtClass(
    components: [
      QtClassComponent(
        type: QtClassComponentType.schoolEnterprise,
        name: '校企合作',
        description: '与高校合作开展人才培养',
        status: '进行中',
        studentCount: 128,
        projectCount: 6,
        deadline: '2026-Q2',
        highlights: ['杭电Python实训项目进行中', '浙大数据科学课程共建已签约'],
      ),
      QtClassComponent(
        type: QtClassComponentType.trainingBase,
        name: '实训基地',
        description: '提供实战化技能训练',
        status: '运营中',
        studentCount: 256,
        projectCount: 12,
        highlights: ['数据分析实训营第4期即将开营'],
      ),
    ],
  );
}

void main() {
  group('QtClassScreen rendering', () {
    testWidgets('renders header with title and tag', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QtClassScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('量潮课堂'), findsOneWidget);
      expect(find.text('主营'), findsOneWidget);
    });

    testWidgets('renders stats bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QtClassScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('总学员'), findsOneWidget);
      expect(find.text('384'), findsOneWidget);
      expect(find.text('总项目'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('组成部分'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders component cards with names and statuses', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QtClassScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('校企合作'), findsOneWidget);
      expect(find.text('实训基地'), findsOneWidget);
      expect(find.text('进行中'), findsOneWidget);
      expect(find.text('运营中'), findsOneWidget);
      expect(find.text('与高校合作开展人才培养'), findsOneWidget);
      expect(find.text('提供实战化技能训练'), findsOneWidget);
    });

    testWidgets('renders stats inside each component card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QtClassScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('128人'), findsOneWidget);
      expect(find.text('6个项目'), findsOneWidget);
      expect(find.text('256人'), findsOneWidget);
      expect(find.text('12个项目'), findsOneWidget);
    });

    testWidgets('renders component icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QtClassScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.byIcon(Icons.business_outlined), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsWidgets);
      expect(find.byIcon(Icons.folder_outlined), findsWidgets);
    });

    testWidgets('renders highlights for each component', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QtClassScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('杭电Python实训项目进行中'), findsOneWidget);
      expect(find.text('浙大数据科学课程共建已签约'), findsOneWidget);
      expect(find.text('数据分析实训营第4期即将开营'), findsOneWidget);
    });

    testWidgets('supports vertical scrolling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QtClassScreen(data: _createTestData()),
          ),
        ),
      );

      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);
    });
  });

  group('QtClassScreen with 4 components', () {
    testWidgets('renders all 4 components from fixture-like data', (tester) async {
      final fullData = QtClass(
        components: [
          QtClassComponent(
            type: QtClassComponentType.schoolEnterprise,
            name: '校企合作',
            description: '与高校合作',
            status: '进行中',
            studentCount: 128,
            projectCount: 6,
            highlights: [],
          ),
          QtClassComponent(
            type: QtClassComponentType.trainingBase,
            name: '实训基地',
            description: '实战训练',
            status: '运营中',
            studentCount: 256,
            projectCount: 12,
            highlights: [],
          ),
          QtClassComponent(
            type: QtClassComponentType.internalTeaching,
            name: '内部教学',
            description: '知识分享',
            status: '常态化',
            studentCount: 24,
            projectCount: 4,
            highlights: [],
          ),
          QtClassComponent(
            type: QtClassComponentType.oneOnOne,
            name: '一对一',
            description: '个性化辅导',
            status: '可预约',
            studentCount: 18,
            projectCount: 8,
            highlights: [],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QtClassScreen(data: fullData),
          ),
        ),
      );

      expect(find.text('校企合作'), findsOneWidget);
      expect(find.text('实训基地'), findsOneWidget);
      expect(find.text('内部教学'), findsOneWidget);
      expect(find.text('一对一'), findsOneWidget);
      expect(find.text('426'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });
  });
}
