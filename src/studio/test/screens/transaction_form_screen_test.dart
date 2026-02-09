import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:qtadmin_studio/screens/transaction_form_screen.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('TransactionFormScreen Tests', () {
    // 分组：表单元素渲染测试

    testWidgets('Renders all form elements correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: TransactionFormScreen(),
      ));

      // 验证表单字段存在性
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.byType(ElevatedButton), findsNWidgets(2));

      // 验证标签文本
      expect(find.text('交易类型'), findsOneWidget);
      expect(find.text('金额'), findsOneWidget);
      expect(find.text('日期'), findsOneWidget);

      // 验证按钮文本
      expect(find.text('保存'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
    });
  });
}