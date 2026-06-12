import 'package:flutter_test/flutter_test.dart';
import 'package:quanttide_hr_kanban/main.dart';

void main() {
  testWidgets('App renders with three tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const HrKanbanApp());
    await tester.pump();

    expect(find.text('招聘管道看板'), findsOneWidget);
    expect(find.text('看板'), findsOneWidget);
    expect(find.text('确认队列'), findsOneWidget);
    expect(find.text('人才库'), findsOneWidget);
  });
}
