import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/transaction.dart';
import 'package:qtadmin_studio/screens/transaction_list_screen.dart';

void main() {
  testWidgets('TransactionListScreen renders basic elements', (WidgetTester tester) async {
    // Build our widget
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionListScreen(),
      ),
    );

    // Verify app bar title
    expect(find.text('Transactions'), findsOneWidget);
    
    // Verify list view existence
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('TransactionListScreen shows loading indicator', (WidgetTester tester) async {
    // Build with simulated loading state
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionListScreen(isLoading: true),
      ),
    );

    // Verify circular progress indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('TransactionListScreen displays transaction items', (WidgetTester tester) async {
    // Build with mock data
    await tester.pumpWidget(
      MaterialApp(
        home: TransactionListScreen(
          transactions: [
            Transaction(id: '1', amount: 100.0),
            Transaction(id: '2', amount: 200.0),
          ],
        ),
      ),
    );

    // Verify items render
    expect(find.text('\$100.00'), findsOneWidget);
    expect(find.text('\$200.00'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}