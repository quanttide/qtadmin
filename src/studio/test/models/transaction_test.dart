import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/transaction.dart';

void main() {
  group('Transaction Model Tests', () {
    test('Constructor should set correct properties', () {
      final transaction = Transaction(id: 't1', amount: 99.99);
      expect(transaction.id, 't1');
      expect(transaction.amount, 99.99);
    });

    test('Equality check for identical transactions', () {
      final t1 = Transaction(id: 't1', amount: 100);
      final t2 = Transaction(id: 't1', amount: 100);
      expect(t1, equals(t2));
    });

    test('CopyWith should create modified copy', () {
      final original = Transaction(id: 't1', amount: 50);
      final modified = original.copyWith(amount: 75);
      expect(modified.id, 't1');
      expect(modified.amount, 75);
    });

    test('Inequality check for different transactions', () {
      final t1 = Transaction(id: 't1', amount: 100);
      final t2 = Transaction(id: 't2', amount: 200);
      expect(t1, isNot(equals(t2)));
    });
  });
}