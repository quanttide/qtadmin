// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qtconsult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Discovery _$DiscoveryFromJson(Map<String, dynamic> json) => _Discovery(
  id: json['id'] as String,
  text: json['text'] as String,
  type: $enumDecode(_$DiscoveryTypeEnumMap, json['type']),
  status:
      $enumDecodeNullable(_$DiscoveryStatusEnumMap, json['status']) ??
      DiscoveryStatus.pending,
  source: json['source'] as String,
  date: json['date'] as String,
  linkedToStrategy: json['linkedToStrategy'] as bool? ?? false,
);

Map<String, dynamic> _$DiscoveryToJson(_Discovery instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'type': _$DiscoveryTypeEnumMap[instance.type]!,
      'status': _$DiscoveryStatusEnumMap[instance.status]!,
      'source': instance.source,
      'date': instance.date,
      'linkedToStrategy': instance.linkedToStrategy,
    };

const _$DiscoveryTypeEnumMap = {
  DiscoveryType.risk: 'risk',
  DiscoveryType.concern: 'concern',
  DiscoveryType.opportunity: 'opportunity',
  DiscoveryType.neutral: 'neutral',
};

const _$DiscoveryStatusEnumMap = {
  DiscoveryStatus.pending: 'pending',
  DiscoveryStatus.confirmed: 'confirmed',
  DiscoveryStatus.dismissed: 'dismissed',
};

_Communication _$CommunicationFromJson(Map<String, dynamic> json) =>
    _Communication(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      summary: json['summary'] as String,
    );

Map<String, dynamic> _$CommunicationToJson(_Communication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'date': instance.date,
      'summary': instance.summary,
    };

_Stakeholder _$StakeholderFromJson(Map<String, dynamic> json) => _Stakeholder(
  id: json['id'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
  stance: $enumDecode(_$StakeStanceEnumMap, json['stance']),
  concern: json['concern'] as String,
  detail: json['detail'] as String,
);

Map<String, dynamic> _$StakeholderToJson(_Stakeholder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'stance': _$StakeStanceEnumMap[instance.stance]!,
      'concern': instance.concern,
      'detail': instance.detail,
    };

const _$StakeStanceEnumMap = {
  StakeStance.support: 'support',
  StakeStance.neutral: 'neutral',
  StakeStance.oppose: 'oppose',
};

_StrategyRevision _$StrategyRevisionFromJson(Map<String, dynamic> json) =>
    _StrategyRevision(
      id: json['id'] as String,
      date: json['date'] as String,
      reason: json['reason'] as String,
      relatedDiscoveryId: json['relatedDiscoveryId'] as String?,
      isReviewed: json['isReviewed'] as bool? ?? false,
    );

Map<String, dynamic> _$StrategyRevisionToJson(_StrategyRevision instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'reason': instance.reason,
      'relatedDiscoveryId': instance.relatedDiscoveryId,
      'isReviewed': instance.isReviewed,
    };

_QtConsult _$QtConsultFromJson(Map<String, dynamic> json) => _QtConsult(
  workspace:
      $enumDecodeNullable(_$WorkspaceTypeEnumMap, json['workspace']) ??
      WorkspaceType.customer,
  projectName: json['projectName'] as String,
  phase: json['phase'] as String,
  industry: json['industry'] as String,
  scale: json['scale'] as String,
  maturity: json['maturity'] as String,
  strategyGoal: json['strategyGoal'] as String,
  strategyInsight: json['strategyInsight'] as String,
  strategySteps: (json['strategySteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskNote: json['riskNote'] as String,
  discoveries: (json['discoveries'] as List<dynamic>)
      .map((e) => Discovery.fromJson(e as Map<String, dynamic>))
      .toList(),
  communications:
      (json['communications'] as List<dynamic>?)
          ?.map((e) => Communication.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  revisions: (json['revisions'] as List<dynamic>)
      .map((e) => StrategyRevision.fromJson(e as Map<String, dynamic>))
      .toList(),
  stakeholders: (json['stakeholders'] as List<dynamic>)
      .map((e) => Stakeholder.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QtConsultToJson(_QtConsult instance) =>
    <String, dynamic>{
      'workspace': _$WorkspaceTypeEnumMap[instance.workspace]!,
      'projectName': instance.projectName,
      'phase': instance.phase,
      'industry': instance.industry,
      'scale': instance.scale,
      'maturity': instance.maturity,
      'strategyGoal': instance.strategyGoal,
      'strategyInsight': instance.strategyInsight,
      'strategySteps': instance.strategySteps,
      'riskNote': instance.riskNote,
      'discoveries': instance.discoveries.map((e) => e.toJson()).toList(),
      'communications': instance.communications.map((e) => e.toJson()).toList(),
      'revisions': instance.revisions.map((e) => e.toJson()).toList(),
      'stakeholders': instance.stakeholders.map((e) => e.toJson()).toList(),
    };

const _$WorkspaceTypeEnumMap = {
  WorkspaceType.customer: 'customer',
  WorkspaceType.internal: 'internal',
};
