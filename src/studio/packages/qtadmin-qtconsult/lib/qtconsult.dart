import 'package:freezed_annotation/freezed_annotation.dart';

part 'qtconsult.freezed.dart';
part 'qtconsult.g.dart';

enum WorkspaceType { customer, internal }

enum DiscoveryType { risk, concern, opportunity, neutral }

enum DiscoveryStatus { pending, confirmed, dismissed }

enum StakeStance { support, neutral, oppose }

@freezed
abstract class Discovery with _$Discovery {
  const factory Discovery({
    required String id,
    required String text,
    required DiscoveryType type,
    @Default(DiscoveryStatus.pending) DiscoveryStatus status,
    required String source,
    required String date,
    @Default(false) bool linkedToStrategy,
  }) = _Discovery;

  factory Discovery.fromJson(Map<String, dynamic> json) =>
      _$DiscoveryFromJson(json);
}

@freezed
abstract class Communication with _$Communication {
  const factory Communication({
    required String id,
    required String title,
    required String date,
    required String summary,
  }) = _Communication;

  factory Communication.fromJson(Map<String, dynamic> json) =>
      _$CommunicationFromJson(json);
}

@freezed
abstract class Stakeholder with _$Stakeholder {
  const factory Stakeholder({
    required String id,
    required String name,
    required String role,
    required StakeStance stance,
    required String concern,
    required String detail,
  }) = _Stakeholder;

  factory Stakeholder.fromJson(Map<String, dynamic> json) =>
      _$StakeholderFromJson(json);
}

extension StakeholderX on Stakeholder {
  String get stanceLabel {
    switch (stance) {
      case StakeStance.support:
        return '支持';
      case StakeStance.neutral:
        return '中立';
      case StakeStance.oppose:
        return '反对';
    }
  }
}

@freezed
abstract class StrategyRevision with _$StrategyRevision {
  const factory StrategyRevision({
    required String id,
    required String date,
    required String reason,
    String? relatedDiscoveryId,
    @Default(false) bool isReviewed,
  }) = _StrategyRevision;

  factory StrategyRevision.fromJson(Map<String, dynamic> json) =>
      _$StrategyRevisionFromJson(json);
}

@freezed
abstract class QtConsult with _$QtConsult {
  const factory QtConsult({
    @Default(WorkspaceType.customer) WorkspaceType workspace,
    required String projectName,
    required String phase,
    required String industry,
    required String scale,
    required String maturity,
    required String strategyGoal,
    required String strategyInsight,
    required List<String> strategySteps,
    required String riskNote,
    required List<Discovery> discoveries,
    @Default([]) List<Communication> communications,
    required List<StrategyRevision> revisions,
    required List<Stakeholder> stakeholders,
  }) = _QtConsult;

  factory QtConsult.fromJson(Map<String, dynamic> json) =>
      _$QtConsultFromJson(json);
}

extension QtConsultX on QtConsult {
  bool get isInternal => workspace == WorkspaceType.internal;
}


