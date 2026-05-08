import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/screens/business_detail_screen.dart';

BusinessUnit _createTestUnit() {
  return BusinessUnit(
    name: '数据产品',
    tag: '孵化',
    decisions: [
      Decision(
        fromPerson: '李四',
        deadline: '5月15日',
        title: '是否投入研发',
        context: '市场需求明确',
        teamAdvice: '建议投入',
        actions: [DecisionAction(label: '批准', isPrimary: true)],
      ),
    ],
  );
}

void main() {
  testWidgets('renders business unit name', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: BusinessDetailScreen(unit: _createTestUnit())),
    ));
    expect(find.text('数据产品'), findsOneWidget);
    expect(find.text('孵化'), findsOneWidget);
  });

  testWidgets('renders decision items', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: BusinessDetailScreen(unit: _createTestUnit())),
    ));
    expect(find.textContaining('是否投入研发'), findsOneWidget);
    expect(find.text('批准'), findsOneWidget);
  });
}
