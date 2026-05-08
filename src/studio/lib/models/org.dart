enum InstitutionStatus { normal, warning, overdue }

enum RepPerformanceTier { green, yellow, red }

class OrgInstitutionData {
  final String id;
  final String name;
  final String parentId;
  final int level;
  final InstitutionStatus status;
  final String? lastMeetingDate;
  final String? nextMeetingDate;
  final String expectedFrequency;
  final List<String> memberIds;
  final int pendingProposalCount;

  const OrgInstitutionData({
    required this.id,
    required this.name,
    required this.parentId,
    required this.level,
    required this.status,
    this.lastMeetingDate,
    this.nextMeetingDate,
    required this.expectedFrequency,
    this.memberIds = const [],
    this.pendingProposalCount = 0,
  });

  factory OrgInstitutionData.fromJson(Map<String, dynamic> json) {
    return OrgInstitutionData(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      status: InstitutionStatus.values.byName(json['status'] as String),
      lastMeetingDate: json['lastMeetingDate'] as String?,
      nextMeetingDate: json['nextMeetingDate'] as String?,
      expectedFrequency: json['expectedFrequency'] as String? ?? '',
      memberIds: (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      pendingProposalCount: json['pendingProposalCount'] as int? ?? 0,
    );
  }
}

class OrgMeetingData {
  final String id;
  final String institutionId;
  final String date;
  final String title;
  final List<String> agendaItems;
  final int attendeeCount;
  final int totalMemberCount;

  const OrgMeetingData({
    required this.id,
    required this.institutionId,
    required this.date,
    required this.title,
    this.agendaItems = const [],
    this.attendeeCount = 0,
    this.totalMemberCount = 0,
  });

  factory OrgMeetingData.fromJson(Map<String, dynamic> json) {
    return OrgMeetingData(
      id: json['id'] as String,
      institutionId: json['institutionId'] as String,
      date: json['date'] as String,
      title: json['title'] as String,
      agendaItems: (json['agendaItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      attendeeCount: json['attendeeCount'] as int? ?? 0,
      totalMemberCount: json['totalMemberCount'] as int? ?? 0,
    );
  }
}

class OrgRepresentativeData {
  final String id;
  final String name;
  final String institutionId;
  final String rank;
  final String term;
  final double attendanceRate;
  final int proposalCount;
  final double voteRate;
  final int objectionCount;
  final RepPerformanceTier tier;
  final List<OrgMeetingData> recentVotes;

  const OrgRepresentativeData({
    required this.id,
    required this.name,
    required this.institutionId,
    required this.rank,
    required this.term,
    this.attendanceRate = 0,
    this.proposalCount = 0,
    this.voteRate = 0,
    this.objectionCount = 0,
    required this.tier,
    this.recentVotes = const [],
  });

  factory OrgRepresentativeData.fromJson(Map<String, dynamic> json) {
    return OrgRepresentativeData(
      id: json['id'] as String,
      name: json['name'] as String,
      institutionId: json['institutionId'] as String,
      rank: json['rank'] as String,
      term: json['term'] as String? ?? '',
      attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 0,
      proposalCount: json['proposalCount'] as int? ?? 0,
      voteRate: (json['voteRate'] as num?)?.toDouble() ?? 0,
      objectionCount: json['objectionCount'] as int? ?? 0,
      tier: RepPerformanceTier.values.byName(json['tier'] as String),
      recentVotes: (json['recentVotes'] as List<dynamic>?)
              ?.map((v) => OrgMeetingData.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OrgRankData {
  final String name;
  final bool isManagement;
  final int headCount;

  const OrgRankData({
    required this.name,
    required this.isManagement,
    required this.headCount,
  });

  factory OrgRankData.fromJson(Map<String, dynamic> json) {
    return OrgRankData(
      name: json['name'] as String,
      isManagement: json['isManagement'] as bool? ?? false,
      headCount: json['headCount'] as int? ?? 0,
    );
  }
}

class OrgPromotionData {
  final String id;
  final String personName;
  final String fromRank;
  final String toRank;
  final String date;
  final bool isCrossTrack;

  const OrgPromotionData({
    required this.id,
    required this.personName,
    required this.fromRank,
    required this.toRank,
    required this.date,
    this.isCrossTrack = false,
  });

  factory OrgPromotionData.fromJson(Map<String, dynamic> json) {
    return OrgPromotionData(
      id: json['id'] as String,
      personName: json['personName'] as String,
      fromRank: json['fromRank'] as String,
      toRank: json['toRank'] as String,
      date: json['date'] as String,
      isCrossTrack: json['isCrossTrack'] as bool? ?? false,
    );
  }
}

class OrgDashboardData {
  final List<OrgInstitutionData> institutions;
  final List<OrgRepresentativeData> representatives;
  final List<OrgRankData> ranks;
  final List<OrgPromotionData> promotions;

  const OrgDashboardData({
    required this.institutions,
    required this.representatives,
    required this.ranks,
    required this.promotions,
  });

  factory OrgDashboardData.fromJson(Map<String, dynamic> json) {
    return OrgDashboardData(
      institutions: (json['institutions'] as List<dynamic>)
          .map((i) => OrgInstitutionData.fromJson(i as Map<String, dynamic>))
          .toList(),
      representatives: (json['representatives'] as List<dynamic>)
          .map((r) => OrgRepresentativeData.fromJson(r as Map<String, dynamic>))
          .toList(),
      ranks: (json['ranks'] as List<dynamic>)
          .map((r) => OrgRankData.fromJson(r as Map<String, dynamic>))
          .toList(),
      promotions: (json['promotions'] as List<dynamic>)
          .map((p) => OrgPromotionData.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
