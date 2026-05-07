import 'package:flutter/material.dart';

class DecisionAction {
  final String label;
  final bool isPrimary;

  const DecisionAction({required this.label, this.isPrimary = false});

  factory DecisionAction.fromJson(Map<String, dynamic> json) {
    return DecisionAction(
      label: json['label'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

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

  factory DecisionData.fromJson(Map<String, dynamic> json) {
    return DecisionData(
      fromPerson: json['fromPerson'] as String,
      deadline: json['deadline'] as String,
      title: json['title'] as String,
      context: json['context'] as String,
      teamAdvice: json['teamAdvice'] as String,
      isUrgent: json['isUrgent'] as bool? ?? false,
      actions: (json['actions'] as List<dynamic>)
          .map((a) => DecisionAction.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BusinessUnitData {
  final String name;
  final String tag;
  final bool isPrimary;
  final String screenType;
  final List<DecisionData> decisions;
  final String? emptyMessage;

  BusinessUnitData({
    required this.name,
    required this.tag,
    this.isPrimary = true,
    this.screenType = 'detail',
    this.decisions = const [],
    this.emptyMessage,
  });

  factory BusinessUnitData.fromJson(Map<String, dynamic> json) {
    return BusinessUnitData(
      name: json['name'] as String,
      tag: json['tag'] as String,
      isPrimary: json['isPrimary'] as bool? ?? true,
      screenType: json['screenType'] as String? ?? 'detail',
      decisions: (json['decisions'] as List<dynamic>?)
              ?.map((d) => DecisionData.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      emptyMessage: json['emptyMessage'] as String?,
    );
  }

  bool get isEmpty => decisions.isEmpty;
  bool get isConsulting => screenType == 'consulting';
}

class MetricData {
  final String label;
  final String value;

  const MetricData({required this.label, required this.value});

  factory MetricData.fromJson(Map<String, dynamic> json) {
    return MetricData(
      label: json['label'] as String,
      value: json['value'] as String,
    );
  }
}

enum TrendDirection { up, down, flat }

class TrendData {
  final String text;
  final TrendDirection direction;

  const TrendData({required this.text, this.direction = TrendDirection.flat});

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      text: json['text'] as String,
      direction: switch (json['direction'] as String?) {
        'up' => TrendDirection.up,
        'down' => TrendDirection.down,
        _ => TrendDirection.flat,
      },
    );
  }
}

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

  factory FuncCardData.fromJson(Map<String, dynamic> json) {
    return FuncCardData(
      name: json['name'] as String,
      metrics: (json['metrics'] as List<dynamic>)
          .map((m) => MetricData.fromJson(m as Map<String, dynamic>))
          .toList(),
      trend: json['trend'] != null
          ? TrendData.fromJson(json['trend'] as Map<String, dynamic>)
          : null,
      warning: json['warning'] as String?,
      isWarning: json['isWarning'] as bool? ?? false,
    );
  }
}

class PanoramaData {
  final List<BusinessUnitData> businessUnits;
  final List<FuncCardData> functionCards;

  PanoramaData({required this.businessUnits, required this.functionCards});

  factory PanoramaData.fromJson(Map<String, dynamic> json) {
    return PanoramaData(
      businessUnits: (json['businessUnits'] as List<dynamic>)
          .map((b) => BusinessUnitData.fromJson(b as Map<String, dynamic>))
          .toList(),
      functionCards: (json['functionCards'] as List<dynamic>)
          .map((f) => FuncCardData.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

Color hexColor(String hex) {
  hex = hex.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}
