import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/screens/function_detail_screen.dart';

FuncCard _createTestCard() {
  return FuncCard(
    name: '财务',
    metrics: [
      Metric(label: '营收', value: '¥120万'),
      Metric(label: '支出', value: '¥80万'),
    ],
    trend: Trend(text: '环比+12%', direction: TrendDirection.up),
  );
}

void main() {
  testWidgets('renders function card name and metrics', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: FuncDetailScreen(card: _createTestCard())),
    ));
    expect(find.text('财务'), findsOneWidget);
    expect(find.text('营收'), findsOneWidget);
    expect(find.text('¥120万'), findsOneWidget);
  });

  testWidgets('renders trend', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: FuncDetailScreen(card: _createTestCard())),
    ));
    expect(find.textContaining('环比+12%'), findsOneWidget);
  });
}
