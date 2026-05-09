// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrgInstitution _$OrgInstitutionFromJson(
  Map<String, dynamic> json,
) => _OrgInstitution(
  id: json['id'] as String,
  name: json['name'] as String,
  parentId: json['parentId'] as String? ?? '',
  level: (json['level'] as num?)?.toInt() ?? 0,
  status: $enumDecode(_$InstitutionStatusEnumMap, json['status']),
  lastMeetingDate: json['lastMeetingDate'] as String?,
  nextMeetingDate: json['nextMeetingDate'] as String?,
  expectedFrequency: json['expectedFrequency'] as String? ?? '',
  memberIds:
      (json['memberIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  pendingProposalCount: (json['pendingProposalCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrgInstitutionToJson(_OrgInstitution instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentId': instance.parentId,
      'level': instance.level,
      'status': _$InstitutionStatusEnumMap[instance.status]!,
      'lastMeetingDate': instance.lastMeetingDate,
      'nextMeetingDate': instance.nextMeetingDate,
      'expectedFrequency': instance.expectedFrequency,
      'memberIds': instance.memberIds,
      'pendingProposalCount': instance.pendingProposalCount,
    };

const _$InstitutionStatusEnumMap = {
  InstitutionStatus.normal: 'normal',
  InstitutionStatus.warning: 'warning',
  InstitutionStatus.overdue: 'overdue',
};

_OrgMeeting _$OrgMeetingFromJson(Map<String, dynamic> json) => _OrgMeeting(
  id: json['id'] as String,
  institutionId: json['institutionId'] as String,
  date: json['date'] as String,
  title: json['title'] as String,
  agendaItems:
      (json['agendaItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  attendeeCount: (json['attendeeCount'] as num?)?.toInt() ?? 0,
  totalMemberCount: (json['totalMemberCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrgMeetingToJson(_OrgMeeting instance) =>
    <String, dynamic>{
      'id': instance.id,
      'institutionId': instance.institutionId,
      'date': instance.date,
      'title': instance.title,
      'agendaItems': instance.agendaItems,
      'attendeeCount': instance.attendeeCount,
      'totalMemberCount': instance.totalMemberCount,
    };

_OrgRepresentative _$OrgRepresentativeFromJson(Map<String, dynamic> json) =>
    _OrgRepresentative(
      id: json['id'] as String,
      name: json['name'] as String,
      institutionIds: (json['institutionIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rank: json['rank'] as String,
      term: json['term'] as String? ?? '',
      attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 0.0,
      proposalCount: (json['proposalCount'] as num?)?.toInt() ?? 0,
      voteRate: (json['voteRate'] as num?)?.toDouble() ?? 0.0,
      objectionCount: (json['objectionCount'] as num?)?.toInt() ?? 0,
      tier: $enumDecode(_$RepPerformanceTierEnumMap, json['tier']),
      recentVotes:
          (json['recentVotes'] as List<dynamic>?)
              ?.map((e) => OrgMeeting.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OrgRepresentativeToJson(_OrgRepresentative instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'institutionIds': instance.institutionIds,
      'rank': instance.rank,
      'term': instance.term,
      'attendanceRate': instance.attendanceRate,
      'proposalCount': instance.proposalCount,
      'voteRate': instance.voteRate,
      'objectionCount': instance.objectionCount,
      'tier': _$RepPerformanceTierEnumMap[instance.tier]!,
      'recentVotes': instance.recentVotes.map((e) => e.toJson()).toList(),
    };

const _$RepPerformanceTierEnumMap = {
  RepPerformanceTier.green: 'green',
  RepPerformanceTier.yellow: 'yellow',
  RepPerformanceTier.red: 'red',
};

_OrgRank _$OrgRankFromJson(Map<String, dynamic> json) => _OrgRank(
  name: json['name'] as String,
  isManagement: json['isManagement'] as bool? ?? false,
  headCount: (json['headCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrgRankToJson(_OrgRank instance) => <String, dynamic>{
  'name': instance.name,
  'isManagement': instance.isManagement,
  'headCount': instance.headCount,
};

_OrgPromotion _$OrgPromotionFromJson(Map<String, dynamic> json) =>
    _OrgPromotion(
      id: json['id'] as String,
      personName: json['personName'] as String,
      fromRank: json['fromRank'] as String,
      toRank: json['toRank'] as String,
      date: json['date'] as String,
      isCrossTrack: json['isCrossTrack'] as bool? ?? false,
    );

Map<String, dynamic> _$OrgPromotionToJson(_OrgPromotion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'personName': instance.personName,
      'fromRank': instance.fromRank,
      'toRank': instance.toRank,
      'date': instance.date,
      'isCrossTrack': instance.isCrossTrack,
    };

_OrgDashboard _$OrgDashboardFromJson(Map<String, dynamic> json) =>
    _OrgDashboard(
      institutions: (json['institutions'] as List<dynamic>)
          .map((e) => OrgInstitution.fromJson(e as Map<String, dynamic>))
          .toList(),
      representatives: (json['representatives'] as List<dynamic>)
          .map((e) => OrgRepresentative.fromJson(e as Map<String, dynamic>))
          .toList(),
      ranks: (json['ranks'] as List<dynamic>)
          .map((e) => OrgRank.fromJson(e as Map<String, dynamic>))
          .toList(),
      promotions: (json['promotions'] as List<dynamic>)
          .map((e) => OrgPromotion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrgDashboardToJson(
  _OrgDashboard instance,
) => <String, dynamic>{
  'institutions': instance.institutions.map((e) => e.toJson()).toList(),
  'representatives': instance.representatives.map((e) => e.toJson()).toList(),
  'ranks': instance.ranks.map((e) => e.toJson()).toList(),
  'promotions': instance.promotions.map((e) => e.toJson()).toList(),
};
