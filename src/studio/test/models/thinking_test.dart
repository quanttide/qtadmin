import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/thinking.dart';

void main() {
  group('ThinkingEmotion', () {
    test('fromJson parses correctly', () {
      final json = {
        'label': '启发/顿悟',
        'value': '450次',
        'color': '#4CAF50',
      };
      final emotion = ThinkingEmotion.fromJson(json);

      expect(emotion.label, '启发/顿悟');
      expect(emotion.value, '450次');
      expect(emotion.color, const Color(0xFF4CAF50));
    });
  });

  group('ThinkingStage', () {
    test('fromJson parses correctly', () {
      final json = {
        'icon': 'construction_outlined',
        'title': '奠基期',
        'subtitle': '方法与工具的归档',
        'points': ['核心：日志格式', '有意识地设计'],
        'color': '#5B8DEF',
      };
      final stage = ThinkingStage.fromJson(json);

      expect(stage.iconName, 'construction_outlined');
      expect(stage.title, '奠基期');
      expect(stage.subtitle, '方法与工具的归档');
      expect(stage.points.length, 2);
      expect(stage.points[1], '有意识地设计');
      expect(stage.color, const Color(0xFF5B8DEF));
    });
  });

  group('ThinkingInsight', () {
    test('fromJson parses correctly', () {
      final json = {
        'icon': 'chat_outlined',
        'title': 'AI 作为持续对话者与参照系',
        'description': 'AI 不只是工具',
      };
      final insight = ThinkingInsight.fromJson(json);

      expect(insight.iconName, 'chat_outlined');
      expect(insight.title, 'AI 作为持续对话者与参照系');
      expect(insight.description, 'AI 不只是工具');
    });
  });

  group('ThinkingClosing', () {
    test('fromJson parses correctly', () {
      final json = {
        'title': '感知 — 建模 — 应用',
        'description': '46天的日志清晰地构建',
        'quote': '最宝贵的资产',
      };
      final closing = ThinkingClosing.fromJson(json);

      expect(closing.title, '感知 — 建模 — 应用');
      expect(closing.description, '46天的日志清晰地构建');
      expect(closing.quote, '最宝贵的资产');
    });
  });

  group('Thinking', () {
    test('fromJson parses full thinking data', () {
      final json = {
        'title': '认知建构与思维演进',
        'subtitle': '基于日志的分析报告',
        'period': '46天的心智旅程。',
        'awarenessSection': {
          'label': '情境意识',
          'icon': 'explore_outlined',
          'color': '#5B8DEF',
        },
        'stages': [
          {
            'icon': 'construction_outlined',
            'title': '奠基期',
            'subtitle': '方法与工具',
            'points': ['核心：日志格式'],
            'color': '#5B8DEF',
          },
        ],
        'emotions': [
          {'label': '启发/顿悟', 'value': '450次', 'color': '#4CAF50'},
        ],
        'emotionNote': '主导情绪是启发/顿悟',
        'insightSection': {
          'label': '心智模型',
          'icon': 'psychology_outlined',
          'color': '#7C4DFF',
        },
        'insights': [
          {
            'icon': 'chat_outlined',
            'title': 'AI 作为持续对话者',
            'description': 'AI 不只是工具',
          },
        ],
        'closing': {
          'title': '感知 — 建模 — 应用',
          'description': '46天的日志',
          'quote': '最宝贵的资产',
        },
      };
      final data = Thinking.fromJson(json);

      expect(data.title, '认知建构与思维演进');
      expect(data.stages.length, 1);
      expect(data.emotions.length, 1);
      expect(data.insights.length, 1);
      expect(data.awarenessSectionLabel, '情境意识');
      expect(data.insightSectionLabel, '心智模型');
      expect(data.closing.title, '感知 — 建模 — 应用');
    });
  });

  group('resolveThinkingIcon', () {
    test('returns correct icons for known names', () {
      expect(resolveThinkingIcon('explore_outlined'), Icons.explore_outlined);
      expect(resolveThinkingIcon('construction_outlined'), Icons.construction_outlined);
      expect(resolveThinkingIcon('auto_awesome_outlined'), Icons.auto_awesome_outlined);
      expect(resolveThinkingIcon('rocket_launch_outlined'), Icons.rocket_launch_outlined);
      expect(resolveThinkingIcon('psychology_outlined'), Icons.psychology_outlined);
      expect(resolveThinkingIcon('chat_outlined'), Icons.chat_outlined);
      expect(resolveThinkingIcon('transform_outlined'), Icons.transform_outlined);
      expect(resolveThinkingIcon('touch_app_outlined'), Icons.touch_app_outlined);
      expect(resolveThinkingIcon('short_text_outlined'), Icons.short_text_outlined);
    });

    test('returns circle_outlined for unknown name', () {
      expect(resolveThinkingIcon('nonexistent'), Icons.circle_outlined);
    });
  });
}
