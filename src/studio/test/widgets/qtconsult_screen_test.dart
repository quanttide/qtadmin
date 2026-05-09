import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_qtconsult/consult.dart';

QtConsult _createTestData() {
  return QtConsult(
    workspace: WorkspaceType.customer,
    projectName: '测试项目',
    phase: '调研',
    industry: '科技',
    scale: '中型',
    maturity: '成长期',
    strategyGoal: '提升市场份额',
    strategyInsight: '需要聚焦',
    strategySteps: ['第一步', '第二步'],
    riskNote: '注意风险',
    discoveries: [
      Discovery(id: 'd1', text: '发现A', type: DiscoveryType.risk, source: '会议', date: '5月1日'),
      Discovery(id: 'd2', text: '发现B', type: DiscoveryType.opportunity, source: '访谈', date: '5月2日', status: DiscoveryStatus.confirmed),
    ],
    communications: [
      Communication(id: 'c1', title: '第一次沟通', date: '5月1日', summary: '沟通内容'),
    ],
    revisions: [],
    stakeholders: [
      Stakeholder(id: 's1', name: '张三', role: 'CEO', stance: StakeStance.support, concern: '成本', detail: '细节'),
    ],
  );
}

Widget _buildApp(QtConsult data) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider(
        create: (_) => ConsultBloc(ConsultState(data: data)),
        child: const QtConsultScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('renders project name', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.text('测试项目'), findsOneWidget);
  });

  testWidgets('renders phase tag', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.text('调研'), findsOneWidget);
  });

  testWidgets('renders discovery items', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.text('发现A'), findsOneWidget);
    expect(find.text('发现B'), findsOneWidget);
  });

  testWidgets('renders stats bar with confirmed count', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.textContaining('已确认发现'), findsOneWidget);
    expect(find.textContaining('1'), findsWidgets);
  });

  testWidgets('renders communication item', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.textContaining('第一次沟通'), findsOneWidget);
  });

  testWidgets('renders stakeholder', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.text('张三'), findsOneWidget);
    expect(find.text('成本'), findsOneWidget);
  });

  testWidgets('renders strategy section', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.text('提升市场份额'), findsOneWidget);
    expect(find.text('第一步'), findsOneWidget);
    expect(find.text('第二步'), findsOneWidget);
  });

  testWidgets('renders risk note', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.text('注意风险'), findsOneWidget);
  });

  testWidgets('shows add discovery button', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.text('添加新发现'), findsOneWidget);
  });

  testWidgets('opens add discovery dialog', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    await tester.tap(find.text('添加新发现'));
    await tester.pumpAndSettle();
    expect(find.text('记录新发现'), findsOneWidget);
  });

  testWidgets('adds discovery via dialog', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    await tester.tap(find.text('添加新发现'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '新发现内容');
    await tester.tap(find.text('提交发现'));
    await tester.pumpAndSettle();
    expect(find.text('新发现内容'), findsOneWidget);
  });

  testWidgets('revision empty state shows placeholder', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.text('暂无策略修正记录'), findsOneWidget);
  });

  testWidgets('renders strategy panel header with no review dot', (tester) async {
    await tester.pumpWidget(_buildApp(_createTestData()));
    expect(find.text('策略看板'), findsOneWidget);
  });
}
