class PositionPlan {
  final String name;
  final int headcount;
  final int filled;
  final int inProgress;
  final String note;

  const PositionPlan({
    required this.name,
    required this.headcount,
    required this.filled,
    required this.inProgress,
    required this.note,
  });

  factory PositionPlan.fromJson(Map<String, dynamic> json) => PositionPlan(
        name: json['name'] as String,
        headcount: json['headcount'] as int,
        filled: json['filled'] as int,
        inProgress: json['in_progress'] as int,
        note: (json['note'] as String?) ?? '',
      );
}

class RecruitmentPlan {
  final String month;
  final List<PositionPlan> positions;

  const RecruitmentPlan({required this.month, required this.positions});

  factory RecruitmentPlan.fromJson(Map<String, dynamic> json) => RecruitmentPlan(
        month: json['month'] as String,
        positions: (json['positions'] as List)
            .map((e) => PositionPlan.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  int get totalHeadcount => positions.fold(0, (s, p) => s + p.headcount);
  int get totalFilled => positions.fold(0, (s, p) => s + p.filled);
  int get totalInProgress => positions.fold(0, (s, p) => s + p.inProgress);
  int get vacancies => totalHeadcount - totalFilled;
}
