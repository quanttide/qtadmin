import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

@freezed
abstract class DecisionAction with _$DecisionAction {
  const factory DecisionAction({
    required String label,
    @Default(false) bool isPrimary,
  }) = _DecisionAction;

  factory DecisionAction.fromJson(Map<String, dynamic> json) =>
      _$DecisionActionFromJson(json);
}

@freezed
abstract class Decision with _$Decision {
  const factory Decision({
    required String fromPerson,
    required String deadline,
    required String title,
    required String context,
    required String teamAdvice,
    @Default(false) bool isUrgent,
    required List<DecisionAction> actions,
  }) = _Decision;

  factory Decision.fromJson(Map<String, dynamic> json) =>
      _$DecisionFromJson(json);
}

@freezed
abstract class BusinessUnit with _$BusinessUnit {
  const factory BusinessUnit({
    required String name,
    required String tag,
    @Default(true) bool isPrimary,
    @Default('detail') String screenType,
    String? consultSource,
    @Default([]) List<Decision> decisions,
    String? emptyMessage,
  }) = _BusinessUnit;

  factory BusinessUnit.fromJson(Map<String, dynamic> json) =>
      _$BusinessUnitFromJson(json);
}

extension BusinessUnitX on BusinessUnit {
  bool get isEmpty => decisions.isEmpty;
  bool get isConsulting => screenType == 'consulting';
}

@freezed
abstract class Metric with _$Metric {
  const factory Metric({
    required String label,
    required String value,
  }) = _Metric;

  factory Metric.fromJson(Map<String, dynamic> json) =>
      _$MetricFromJson(json);
}

enum TrendDirection { up, down, flat }

TrendDirection _parseDirection(dynamic value) {
  switch (value as String?) {
    case 'up':
      return TrendDirection.up;
    case 'down':
      return TrendDirection.down;
    default:
      return TrendDirection.flat;
  }
}

@freezed
abstract class Trend with _$Trend {
  const factory Trend({
    required String text,
    @JsonKey(fromJson: _parseDirection) @Default(TrendDirection.flat)
    TrendDirection direction,
  }) = _Trend;

  factory Trend.fromJson(Map<String, dynamic> json) =>
      _$TrendFromJson(json);
}

@freezed
abstract class FuncCard with _$FuncCard {
  const factory FuncCard({
    required String name,
    required List<Metric> metrics,
    Trend? trend,
    String? warning,
    @Default(false) bool isWarning,
  }) = _FuncCard;

  factory FuncCard.fromJson(Map<String, dynamic> json) =>
      _$FuncCardFromJson(json);
}

@freezed
abstract class Dashboard with _$Dashboard {
  const factory Dashboard({
    required List<BusinessUnit> businessUnits,
    required List<FuncCard> functionCards,
  }) = _Dashboard;

  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);
}
