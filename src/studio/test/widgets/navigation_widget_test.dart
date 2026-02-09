import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:qtadmin_studio/widgets/navigation_widget.dart';

void main() {
  testWidgets('NavigationWidget displays list items', (WidgetTester tester) async {
    // Build our widget
    await tester.pumpWidget(NavigationWidget());

    // Verify list items existence
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3)); // Assuming 3 navigation items
  });

  testWidgets('NavigationWidget handles route navigation', (WidgetTester tester) async {
    // 初始化测试脚手架：
    // - 构建包含路由配置的`MaterialApp`
    // - 注册`/home`路由对应测试页面
    await tester.pumpWidget(MaterialApp(
      home: NavigationWidget(),
      routes: {
         '/home': (context) => const Text('首页'),
      },
    ));

    // 触发导航操作：
    // 1. 通过ListTile组件选择器定位首个可点击元素
    // 2. 执行模拟点击事件
    // 3. 等待路由过渡动画完成
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // 验证导航结果：
    // 检查目标页面是否成功渲染预期文本内容
    expect(find.text('首页'), findsOneWidget);
  });
}