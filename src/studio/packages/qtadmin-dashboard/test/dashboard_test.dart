import 'dart:ui' show Color;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_dashboard/dashboard_barrel.dart';

Color hexColor(String hex) {
  hex = hex.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

void main() {
  group('DecisionAction', () {
    test('fromJson parses correctly', () {
      final json = {'label': '批准', 'isPrimary': true};
      final action = DecisionAction.fromJson(json);

      expect(action.label, '批准');
      expect(action.isPrimary, true);
    });

    test('fromJson defaults isPrimary to false', () {
      final json = {'label': '驳回'};
      final action = DecisionAction.fromJson(json);

      expect(action.label, '驳回');
      expect(action.isPrimary, false);
    });
  });

  group('Decision', () {
    test('fromJson parses correctly with actions', () {
      final json = {
        'fromPerson': '陈小明',
        'deadline': '本周内回复',
        'title': '华为数据清洗',
        'context': '回头客 ¥12,000',
        'teamAdvice': '小明倾向：接',
        'isUrgent': true,
        'actions': [
          {'label': '批准', 'isPrimary': true},
          {'label': '驳回', 'isPrimary': false},
        ],
      };
      final decision = Decision.fromJson(json);

      expect(decision.fromPerson, '陈小明');
      expect(decision.title, '华为数据清洗');
      expect(decision.isUrgent, true);
      expect(decision.actions.length, 2);
      expect(decision.actions[0].label, '批准');
      expect(decision.actions[0].isPrimary, true);
    });

    test('fromJson defaults isUrgent to false', () {
      final json = {
        'fromPerson': '测试',
        'deadline': '本周',
        'title': '测试项',
        'context': '测试上下文',
        'teamAdvice': '测试建议',
        'actions': [],
      };
      final decision = Decision.fromJson(json);

      expect(decision.isUrgent, false);
    });
  });

  group('BusinessUnit', () {
    test('fromJson parses default business unit', () {
      final json = {
        'name': '量潮数据',
        'tag': '主营',
        'isPrimary': true,
      };
      final unit = BusinessUnit.fromJson(json);

      expect(unit.name, '量潮数据');
      expect(unit.tag, '主营');
      expect(unit.isPrimary, true);
      expect(unit.screenType, 'detail');
      expect(unit.decisions, isEmpty);
      expect(unit.emptyMessage, isNull);
    });

    test('fromJson parses consulting business unit', () {
      final json = {
        'name': '量潮咨询',
        'tag': '主营',
        'isPrimary': true,
        'screenType': 'consulting',
        'consultSource': 'customer',
        'decisions': [],
      };
      final unit = BusinessUnit.fromJson(json);

      expect(unit.screenType, 'consulting');
      expect(unit.consultSource, 'customer');
      expect(unit.isConsulting, true);
    });

    test('fromJson parses empty business unit with emptyMessage', () {
      final json = {
        'name': '量潮云',
        'tag': '孵化中',
        'isPrimary': false,
        'decisions': [],
        'emptyMessage': '暂无待决策事项',
      };
      final unit = BusinessUnit.fromJson(json);

      expect(unit.isPrimary, false);
      expect(unit.isEmpty, true);
      expect(unit.emptyMessage, '暂无待决策事项');
    });

    test('isEmpty returns true when decisions is empty', () {
      final unit = BusinessUnit(
        name: '测试',
        tag: '',
        decisions: [],
      );
      expect(unit.isEmpty, true);
    });

    test('isEmpty returns false when decisions is not empty', () {
      final unit = BusinessUnit(
        name: '测试',
        tag: '',
        decisions: [
          Decision(
            fromPerson: '某人',
            deadline: '本周',
            title: '测试',
            context: '上下文',
            teamAdvice: '建议',
            actions: [],
          ),
        ],
      );
      expect(unit.isEmpty, false);
    });
  });

  group('Metric', () {
    test('fromJson parses correctly', () {
      final json = {'label': '团队', 'value': '8人'};
      final metric = Metric.fromJson(json);

      expect(metric.label, '团队');
      expect(metric.value, '8人');
    });
  });

  group('Trend', () {
    test('fromJson parses up direction', () {
      final json = {'text': '↑5%', 'direction': 'up'};
      final trend = Trend.fromJson(json);

      expect(trend.text, '↑5%');
      expect(trend.direction, TrendDirection.up);
    });

    test('fromJson parses down direction', () {
      final json = {'text': '↓5%', 'direction': 'down'};
      final trend = Trend.fromJson(json);

      expect(trend.direction, TrendDirection.down);
    });

    test('fromJson defaults to flat for unknown direction', () {
      final json = {'text': '稳定', 'direction': 'unknown'};
      final trend = Trend.fromJson(json);

      expect(trend.direction, TrendDirection.flat);
    });

    test('fromJson defaults to flat when direction is null', () {
      final json = {'text': '稳定'};
      final trend = Trend.fromJson(json);

      expect(trend.direction, TrendDirection.flat);
    });
  });

  group('FuncCard', () {
    test('fromJson parses basic card', () {
      final json = {
        'name': '人力资源',
        'metrics': [
          {'label': '团队', 'value': '8人'},
        ],
      };
      final card = FuncCard.fromJson(json);

      expect(card.name, '人力资源');
      expect(card.metrics.length, 1);
      expect(card.trend, isNull);
      expect(card.warning, isNull);
      expect(card.isWarning, false);
    });

    test('fromJson parses card with warning', () {
      final json = {
        'name': '组织管理',
        'isWarning': true,
        'metrics': [
          {'label': '决策委托率', 'value': '42%'},
        ],
        'trend': {'text': '↓5%', 'direction': 'down'},
        'warning': '连续2月下降',
      };
      final card = FuncCard.fromJson(json);

      expect(card.isWarning, true);
      expect(card.warning, '连续2月下降');
      expect(card.trend!.direction, TrendDirection.down);
    });
  });

  group('Dashboard', () {
    test('fromJson parses complete dashboard', () {
      final json = {
        'businessUnits': [
          {'name': '量潮数据', 'tag': '主营'},
          {'name': '量潮咨询', 'tag': '主营', 'screenType': 'consulting'},
        ],
        'functionCards': [
          {'name': '人力资源', 'metrics': []},
          {'name': '财务管理', 'metrics': []},
        ],
      };
      final data = Dashboard.fromJson(json);

      expect(data.businessUnits.length, 2);
      expect(data.functionCards.length, 2);
      expect(data.businessUnits[0].name, '量潮数据');
      expect(data.businessUnits[1].screenType, 'consulting');
      expect(data.functionCards[0].name, '人力资源');
    });

    test('fromJson parses founder dashboard with empty functionCards', () {
      final json = {
        'businessUnits': [
          {'name': '思考', 'tag': '', 'screenType': 'thinking'},
          {'name': '写作', 'tag': '', 'screenType': 'writing'},
        ],
        'functionCards': [],
      };
      final data = Dashboard.fromJson(json);

      expect(data.businessUnits.length, 2);
      expect(data.functionCards, isEmpty);
    });
  });

  group('hexColor', () {
    test('converts hex string to Color', () {
      final color = hexColor('#B71C1C');
      expect(color, const Color(0xFFB71C1C));
    });

    test('handles hex without hash', () {
      final color = hexColor('1A7F37');
      expect(color, const Color(0xFF1A7F37));
    });
  });
}
