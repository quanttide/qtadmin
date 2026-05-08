// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DecisionAction _$DecisionActionFromJson(Map<String, dynamic> json) =>
    _DecisionAction(
      label: json['label'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );

Map<String, dynamic> _$DecisionActionToJson(_DecisionAction instance) =>
    <String, dynamic>{'label': instance.label, 'isPrimary': instance.isPrimary};

_Decision _$DecisionFromJson(Map<String, dynamic> json) => _Decision(
  fromPerson: json['fromPerson'] as String,
  deadline: json['deadline'] as String,
  title: json['title'] as String,
  context: json['context'] as String,
  teamAdvice: json['teamAdvice'] as String,
  isUrgent: json['isUrgent'] as bool? ?? false,
  actions: (json['actions'] as List<dynamic>)
      .map((e) => DecisionAction.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DecisionToJson(_Decision instance) => <String, dynamic>{
  'fromPerson': instance.fromPerson,
  'deadline': instance.deadline,
  'title': instance.title,
  'context': instance.context,
  'teamAdvice': instance.teamAdvice,
  'isUrgent': instance.isUrgent,
  'actions': instance.actions.map((e) => e.toJson()).toList(),
};

_BusinessUnit _$BusinessUnitFromJson(Map<String, dynamic> json) =>
    _BusinessUnit(
      name: json['name'] as String,
      tag: json['tag'] as String,
      isPrimary: json['isPrimary'] as bool? ?? true,
      screenType: json['screenType'] as String? ?? 'detail',
      consultSource: json['consultSource'] as String?,
      decisions:
          (json['decisions'] as List<dynamic>?)
              ?.map((e) => Decision.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      emptyMessage: json['emptyMessage'] as String?,
    );

Map<String, dynamic> _$BusinessUnitToJson(_BusinessUnit instance) =>
    <String, dynamic>{
      'name': instance.name,
      'tag': instance.tag,
      'isPrimary': instance.isPrimary,
      'screenType': instance.screenType,
      'consultSource': instance.consultSource,
      'decisions': instance.decisions.map((e) => e.toJson()).toList(),
      'emptyMessage': instance.emptyMessage,
    };

_Metric _$MetricFromJson(Map<String, dynamic> json) =>
    _Metric(label: json['label'] as String, value: json['value'] as String);

Map<String, dynamic> _$MetricToJson(_Metric instance) => <String, dynamic>{
  'label': instance.label,
  'value': instance.value,
};

_Trend _$TrendFromJson(Map<String, dynamic> json) => _Trend(
  text: json['text'] as String,
  direction: json['direction'] == null
      ? TrendDirection.flat
      : _parseDirection(json['direction']),
);

Map<String, dynamic> _$TrendToJson(_Trend instance) => <String, dynamic>{
  'text': instance.text,
  'direction': _$TrendDirectionEnumMap[instance.direction]!,
};

const _$TrendDirectionEnumMap = {
  TrendDirection.up: 'up',
  TrendDirection.down: 'down',
  TrendDirection.flat: 'flat',
};

_FuncCard _$FuncCardFromJson(Map<String, dynamic> json) => _FuncCard(
  name: json['name'] as String,
  metrics: (json['metrics'] as List<dynamic>)
      .map((e) => Metric.fromJson(e as Map<String, dynamic>))
      .toList(),
  trend: json['trend'] == null
      ? null
      : Trend.fromJson(json['trend'] as Map<String, dynamic>),
  warning: json['warning'] as String?,
  isWarning: json['isWarning'] as bool? ?? false,
);

Map<String, dynamic> _$FuncCardToJson(_FuncCard instance) => <String, dynamic>{
  'name': instance.name,
  'metrics': instance.metrics.map((e) => e.toJson()).toList(),
  'trend': instance.trend?.toJson(),
  'warning': instance.warning,
  'isWarning': instance.isWarning,
};

_Dashboard _$DashboardFromJson(Map<String, dynamic> json) => _Dashboard(
  businessUnits: (json['businessUnits'] as List<dynamic>)
      .map((e) => BusinessUnit.fromJson(e as Map<String, dynamic>))
      .toList(),
  functionCards: (json['functionCards'] as List<dynamic>)
      .map((e) => FuncCard.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DashboardToJson(_Dashboard instance) =>
    <String, dynamic>{
      'businessUnits': instance.businessUnits.map((e) => e.toJson()).toList(),
      'functionCards': instance.functionCards.map((e) => e.toJson()).toList(),
    };
