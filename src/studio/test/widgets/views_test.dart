import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/views/biz_unit_widget.dart';
import 'package:qtadmin_studio/views/business_section_widget.dart';
import 'package:qtadmin_studio/views/decision_card_widget.dart';
import 'package:qtadmin_studio/views/func_card_widget.dart';
import 'package:qtadmin_studio/views/function_section_widget.dart';
import 'package:qtadmin_studio/views/section_header.dart';
import 'package:qtadmin_studio/views/stat_item.dart';

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  group('SectionHeader', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(const SectionHeader(title: '测试标题')));
      expect(find.text('测试标题'), findsOneWidget);
    });
  });

  group('StatItem', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatItem(dotColor: Colors.red, label: '总数', value: '42'),
      ));
      expect(find.text('总数'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });
  });

  group('DecisionCardWidget', () {
    Decision _decision({bool urgent = false}) => Decision(
          fromPerson: '张三',
          deadline: '5月10日',
          title: '是否投入',
          context: '背景说明',
          teamAdvice: '建议投入',
          isUrgent: urgent,
          actions: [
            const DecisionAction(label: '批准', isPrimary: true),
            const DecisionAction(label: '驳回'),
          ],
        );

    testWidgets('renders pending decision', (tester) async {
      await tester.pumpWidget(_wrap(DecisionCardWidget(data: _decision())));
      expect(find.text('是否投入'), findsOneWidget);
      expect(find.text('张三'), findsOneWidget);
      expect(find.text('5月10日'), findsOneWidget);
      expect(find.text('批准'), findsOneWidget);
      expect(find.text('驳回'), findsOneWidget);
    });

    testWidgets('tapping action resolves decision', (tester) async {
      await tester.pumpWidget(_wrap(DecisionCardWidget(data: _decision())));
      await tester.tap(find.text('批准'));
      await tester.pumpAndSettle();
      expect(find.textContaining('已批准'), findsOneWidget);
    });

    testWidgets('shows urgent border for urgent decisions', (tester) async {
      await tester.pumpWidget(_wrap(DecisionCardWidget(data: _decision(urgent: true))));
      expect(find.text('是否投入'), findsOneWidget);
    });
  });

  group('BizUnitWidget', () {
    testWidgets('renders name and tag', (tester) async {
      await tester.pumpWidget(_wrap(BizUnitWidget(
        data: BusinessUnit(name: '业务线A', tag: '核心', decisions: []),
      )));
      expect(find.text('业务线A'), findsOneWidget);
      expect(find.text('核心'), findsOneWidget);
    });

    testWidgets('renders empty message when no decisions', (tester) async {
      await tester.pumpWidget(_wrap(BizUnitWidget(
        data: BusinessUnit(name: '业务线A', tag: '核心', decisions: [], emptyMessage: '暂无待办'),
      )));
      expect(find.text('暂无待办'), findsOneWidget);
    });

    testWidgets('renders decision cards when decisions exist', (tester) async {
      await tester.pumpWidget(_wrap(BizUnitWidget(
        data: BusinessUnit(name: '业务线A', tag: '核心', decisions: [
          Decision(fromPerson: '李四', deadline: '5月12日', title: '决策事项', context: '说明', teamAdvice: '建议', actions: []),
        ]),
      )));
      expect(find.text('决策事项'), findsOneWidget);
    });
  });

  group('FuncCardWidget', () {
    testWidgets('renders name and metrics', (tester) async {
      await tester.pumpWidget(_wrap(FuncCardWidget(
        data: FuncCard(name: '财务', metrics: [
          Metric(label: '营收', value: '¥100万'),
        ]),
      )));
      expect(find.text('财务'), findsOneWidget);
      expect(find.text('营收'), findsOneWidget);
      expect(find.text('¥100万'), findsOneWidget);
    });

    testWidgets('renders trend', (tester) async {
      await tester.pumpWidget(_wrap(FuncCardWidget(
        data: FuncCard(name: '财务', metrics: [], trend: Trend(text: '↑12%', direction: TrendDirection.up)),
      )));
      expect(find.text('↑12%'), findsOneWidget);
    });

    testWidgets('renders warning', (tester) async {
      await tester.pumpWidget(_wrap(FuncCardWidget(
        data: FuncCard(name: '财务', metrics: [], warning: '注意', isWarning: true),
      )));
      expect(find.text('注意'), findsOneWidget);
    });
  });

  group('BusinessSectionWidget', () {
    testWidgets('renders section title and business units', (tester) async {
      await tester.pumpWidget(_wrap(BusinessSectionWidget(
        units: [
          BusinessUnit(name: '业务A', tag: '核心', decisions: []),
          BusinessUnit(name: '业务B', tag: '孵化', decisions: []),
        ],
        isMobile: false,
      )));
      expect(find.text('业务A'), findsOneWidget);
      expect(find.text('业务B'), findsOneWidget);
    });
  });

  group('FunctionSectionWidget', () {
    testWidgets('renders section title and cards', (tester) async {
      await tester.pumpWidget(_wrap(FunctionSectionWidget(
        cards: [
          FuncCard(name: '人力', metrics: [Metric(label: '人数', value: '10')]),
          FuncCard(name: '财务', metrics: [Metric(label: '营收', value: '¥100万')]),
        ],
        isMobile: false,
      )));
      expect(find.text('人力'), findsOneWidget);
      expect(find.text('财务'), findsOneWidget);
    });
  });
}
