import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/thinking.dart';
import 'package:qtadmin_studio/screens/thinking_screen.dart';

Thinking _createTestData() {
  return Thinking(
    title: '认知建构与思维演进',
    subtitle: '基于日志的分析报告',
    period: '46天的心智旅程。',
    awarenessSectionLabel: '情境意识',
    awarenessSectionIcon: 'explore_outlined',
    awarenessSectionColor: 0xFF5B8DEF,
    stages: [
      ThinkingStage(
        iconName: 'construction_outlined',
        title: '奠基期（3月中旬 - 3月底）',
        subtitle: '方法与工具的归档',
        points: ['核心：日志格式、知识库', '有意识地设计思维脚手架'],
        colorValue: 0xFF5B8DEF,
      ),
      ThinkingStage(
        iconName: 'auto_awesome_outlined',
        title: '爆发与深化期（4月）',
        subtitle: '认知内核的建模与重构',
        points: ['4月23日达思想高峰', '触及元认知层面'],
        colorValue: 0xFFE8A838,
      ),
    ],
    emotions: [
      ThinkingEmotion(label: '启发/顿悟', value: '450次', colorValue: 0xFF4CAF50),
      ThinkingEmotion(label: '困惑/混沌', value: '127次', colorValue: 0xFFE8A838),
    ],
    emotionNote: '主导情绪是启发/顿悟——困难是启发的燃料。',
    insightSectionLabel: '心智模型',
    insightSectionIcon: 'psychology_outlined',
    insightSectionColor: 0xFF7C4DFF,
    insights: [
      ThinkingInsight(
        iconName: 'chat_outlined',
        title: 'AI 作为持续对话者与参照系',
        description: 'AI 不只是工具，更是对等的思考伙伴。',
      ),
    ],
    closing: ThinkingClosing(
      title: '感知 — 建模 — 应用',
      description: '46天的日志清晰地构建了一条认知演化路径。',
      quote: '最宝贵的资产，是持续敏锐的思维习惯本身。',
    ),
  );
}

void main() {
  group('ThinkingScreen rendering', () {
    testWidgets('renders header with title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThinkingScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('认知建构与思维演进'), findsOneWidget);
      expect(find.text('基于日志的分析报告'), findsOneWidget);
    });

    testWidgets('renders section labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThinkingScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('情境意识'), findsOneWidget);
      expect(find.text('心智模型'), findsOneWidget);
    });

    testWidgets('renders period summary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThinkingScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('46天的心智旅程。'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    });

    testWidgets('renders all stages with titles and points', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThinkingScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('奠基期（3月中旬 - 3月底）'), findsOneWidget);
      expect(find.text('爆发与深化期（4月）'), findsOneWidget);
      expect(find.text('方法与工具的归档'), findsOneWidget);
      expect(find.text('认知内核的建模与重构'), findsOneWidget);
      expect(find.text('核心：日志格式、知识库'), findsOneWidget);
      expect(find.text('4月23日达思想高峰'), findsOneWidget);
    });

    testWidgets('renders emotion section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThinkingScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('情绪底色'), findsOneWidget);
      expect(find.text('启发/顿悟'), findsOneWidget);
      expect(find.text('450次'), findsOneWidget);
      expect(find.text('困惑/混沌'), findsOneWidget);
      expect(find.text('127次'), findsOneWidget);
      expect(find.textContaining('主导情绪'), findsOneWidget);
    });

    testWidgets('renders insights', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThinkingScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('AI 作为持续对话者与参照系'), findsOneWidget);
      expect(find.text('AI 不只是工具，更是对等的思考伙伴。'), findsOneWidget);
    });

    testWidgets('renders closing section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThinkingScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.text('感知 — 建模 — 应用'), findsOneWidget);
      expect(find.textContaining('认知演化路径'), findsOneWidget);
      expect(find.textContaining('思维习惯本身'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('supports vertical scrolling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThinkingScreen(data: _createTestData()),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
