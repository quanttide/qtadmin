import 'package:flutter/material.dart';

class DecisionData {
  final String fromPerson;
  final String deadline;
  final String title;
  final String context;
  final String teamAdvice;
  final bool isUrgent;
  final List<DecisionAction> actions;

  DecisionData({
    required this.fromPerson,
    required this.deadline,
    required this.title,
    required this.context,
    required this.teamAdvice,
    this.isUrgent = false,
    required this.actions,
  });
}

class DecisionAction {
  final String label;
  final bool isPrimary;

  const DecisionAction({required this.label, this.isPrimary = false});
}

class BusinessUnitData {
  final String name;
  final String tag;
  final bool isPrimary;
  final List<DecisionData> decisions;
  final String? emptyMessage;

  BusinessUnitData({
    required this.name,
    required this.tag,
    this.isPrimary = true,
    this.decisions = const [],
    this.emptyMessage,
  });

  bool get isEmpty => decisions.isEmpty;
}

class MetricData {
  final String label;
  final String value;

  const MetricData({required this.label, required this.value});
}

class TrendData {
  final String text;
  final TrendDirection direction;

  const TrendData({required this.text, this.direction = TrendDirection.flat});
}

enum TrendDirection { up, down, flat }

class FuncCardData {
  final String name;
  final List<MetricData> metrics;
  final TrendData? trend;
  final String? warning;
  final bool isWarning;

  FuncCardData({
    required this.name,
    required this.metrics,
    this.trend,
    this.warning,
    this.isWarning = false,
  });
}

Color hexColor(String hex) {
  hex = hex.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}
