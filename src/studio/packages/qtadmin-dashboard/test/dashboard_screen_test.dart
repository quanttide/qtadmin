import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_dashboard/dashboard_barrel.dart';

Dashboard _createTestData() {
  return Dashboard(
    businessUnits: [
      BusinessUnit(name: '业务A', tag: '核心', decisions: [
        Decision(fromPerson: '张三', deadline: '5月10日', title: '决策1', context: '背景', teamAdvice: '建议', actions: [
          DecisionAction(label: '批准', isPrimary: true),
        ]),
      ]),
    ],
    functionCards: [
      FuncCard(name: '人力', metrics: [Metric(label: '人数', value: '10')]),
    ],
  );
}

void main() {
  testWidgets('renders workspace name and date', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DashboardScreen(data: _createTestData(), workspaceName: '量潮科技')),
    ));
    expect(find.text('量潮科技'), findsOneWidget);
  });

  testWidgets('renders business unit', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DashboardScreen(data: _createTestData())),
    ));
    expect(find.text('业务A'), findsOneWidget);
    expect(find.text('核心'), findsOneWidget);
  });

  testWidgets('renders function card', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DashboardScreen(data: _createTestData())),
    ));
    expect(find.text('人力'), findsOneWidget);
    expect(find.text('人数'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('renders bottom note', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DashboardScreen(data: _createTestData())),
    ));
    expect(find.textContaining('无需你介入'), findsOneWidget);
  });
}
