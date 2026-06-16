class PoolItem {
  final int id;
  final String candidateName;
  final String candidateEmail;
  final String status;
  final String quality;
  final String? pooledAt;
  final String? subStage;
  final String source;
  final String? deactivatedAt;

  const PoolItem({
    required this.id,
    required this.candidateName,
    required this.candidateEmail,
    required this.status,
    required this.quality,
    this.pooledAt,
    this.subStage,
    required this.source,
    this.deactivatedAt,
  });

  factory PoolItem.fromJson(Map<String, dynamic> json) {
    return PoolItem(
      id: json['id'] as int,
      candidateName: json['candidate_name'] as String,
      candidateEmail: json['candidate_email'] as String,
      status: json['status'] as String,
      quality: json['quality'] as String,
      pooledAt: json['pooled_at'] as String?,
      subStage: json['sub_stage'] as String?,
      source: json['source'] as String,
      deactivatedAt: json['deactivated_at'] as String?,
    );
  }
}

class Headcount {
  final int totalOffers;
  final int accepted;

  const Headcount({required this.totalOffers, required this.accepted});

  factory Headcount.fromJson(Map<String, dynamic> json) {
    return Headcount(
      totalOffers: json['total_offers'] as int,
      accepted: json['accepted'] as int,
    );
  }
}
