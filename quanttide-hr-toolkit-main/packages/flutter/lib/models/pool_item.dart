class PoolItem {
  final int id;
  final int candidateId;
  final int recruitmentId;
  final String status;
  final String? subStage;
  final String quality;
  final String source;
  final String? pooledAt;
  final String? deactivatedAt;
  final String createdAt;
  final String updatedAt;
  final String candidateEmail;
  final String candidateName;

  PoolItem({
    required this.id,
    required this.candidateId,
    required this.recruitmentId,
    required this.status,
    this.subStage,
    required this.quality,
    required this.source,
    this.pooledAt,
    this.deactivatedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.candidateEmail,
    required this.candidateName,
  });

  factory PoolItem.fromJson(Map<String, dynamic> json) {
    return PoolItem(
      id: json['id'] ?? 0,
      candidateId: json['candidate_id'] ?? 0,
      recruitmentId: json['recruitment_id'] ?? 0,
      status: json['status'] ?? '',
      subStage: json['sub_stage'],
      quality: json['quality'] ?? 'normal',
      source: json['source'] ?? '',
      pooledAt: json['pooled_at'],
      deactivatedAt: json['deactivated_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      candidateEmail: json['candidate_email'] ?? '',
      candidateName: json['candidate_name'] ?? '',
    );
  }
}

class Headcount {
  final int recruitmentId;
  final int totalOffers;
  final int accepted;

  Headcount({
    required this.recruitmentId,
    required this.totalOffers,
    required this.accepted,
  });

  factory Headcount.fromJson(Map<String, dynamic> json) {
    return Headcount(
      recruitmentId: json['recruitment_id'] ?? 0,
      totalOffers: json['total_offers'] ?? 0,
      accepted: json['accepted'] ?? 0,
    );
  }
}
