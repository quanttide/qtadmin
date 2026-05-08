import 'package:freezed_annotation/freezed_annotation.dart';

part 'org.freezed.dart';
part 'org.g.dart';

enum InstitutionStatus { normal, warning, overdue }

enum RepPerformanceTier { green, yellow, red }

@freezed
abstract class OrgInstitution with _$OrgInstitution {
  const factory OrgInstitution({
    required String id,
    required String name,
    @Default('') String parentId,
    @Default(0) int level,
    required InstitutionStatus status,
    String? lastMeetingDate,
    String? nextMeetingDate,
    @Default('') String expectedFrequency,
    @Default([]) List<String> memberIds,
    @Default(0) int pendingProposalCount,
  }) = _OrgInstitution;

  factory OrgInstitution.fromJson(Map<String, dynamic> json) =>
      _$OrgInstitutionFromJson(json);
}

@freezed
abstract class OrgMeeting with _$OrgMeeting {
  const factory OrgMeeting({
    required String id,
    required String institutionId,
    required String date,
    required String title,
    @Default([]) List<String> agendaItems,
    @Default(0) int attendeeCount,
    @Default(0) int totalMemberCount,
  }) = _OrgMeeting;

  factory OrgMeeting.fromJson(Map<String, dynamic> json) =>
      _$OrgMeetingFromJson(json);
}

@freezed
abstract class OrgRepresentative with _$OrgRepresentative {
  const factory OrgRepresentative({
    required String id,
    required String name,
    required List<String> institutionIds,
    required String rank,
    @Default('') String term,
    @Default(0.0) double attendanceRate,
    @Default(0) int proposalCount,
    @Default(0.0) double voteRate,
    @Default(0) int objectionCount,
    required RepPerformanceTier tier,
    @Default([]) List<OrgMeeting> recentVotes,
  }) = _OrgRepresentative;

  factory OrgRepresentative.fromJson(Map<String, dynamic> json) =>
      _$OrgRepresentativeFromJson(json);
}

@freezed
abstract class OrgRank with _$OrgRank {
  const factory OrgRank({
    required String name,
    @Default(false) bool isManagement,
    @Default(0) int headCount,
  }) = _OrgRank;

  factory OrgRank.fromJson(Map<String, dynamic> json) =>
      _$OrgRankFromJson(json);
}

@freezed
abstract class OrgPromotion with _$OrgPromotion {
  const factory OrgPromotion({
    required String id,
    required String personName,
    required String fromRank,
    required String toRank,
    required String date,
    @Default(false) bool isCrossTrack,
  }) = _OrgPromotion;

  factory OrgPromotion.fromJson(Map<String, dynamic> json) =>
      _$OrgPromotionFromJson(json);
}

@freezed
abstract class OrgDashboard with _$OrgDashboard {
  const factory OrgDashboard({
    required List<OrgInstitution> institutions,
    required List<OrgRepresentative> representatives,
    required List<OrgRank> ranks,
    required List<OrgPromotion> promotions,
  }) = _OrgDashboard;

  factory OrgDashboard.fromJson(Map<String, dynamic> json) =>
      _$OrgDashboardFromJson(json);
}
