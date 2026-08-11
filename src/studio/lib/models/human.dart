/// human 领域模型：岗位档案与招聘计划。
///
/// 契约对齐 CLI（src/cli/src/human/）：岗位档案来自 `human/positions.json`，
/// 招聘计划来自 `recruitment.json`。
library;

// ── 岗位档案（对齐 CLI PositionRecord / PositionsFile）──

class HumanPosition {
  final String id;
  final String name;
  final String? department;
  final String? level;
  final String? description;
  final String? responsibilities;
  final String? requirements;
  final bool active;

  const HumanPosition({
    required this.id,
    required this.name,
    this.department,
    this.level,
    this.description,
    this.responsibilities,
    this.requirements,
    this.active = true,
  });

  factory HumanPosition.fromJson(Map<String, dynamic> json) => HumanPosition(
    id: json['id'] as String,
    name: json['name'] as String,
    department: json['department'] as String?,
    level: json['level'] as String?,
    description: json['description'] as String?,
    responsibilities: json['responsibilities'] as String?,
    requirements: json['requirements'] as String?,
    active: (json['active'] as bool?) ?? true,
  );
}

class PositionsFile {
  final Map<String, HumanPosition> records;

  const PositionsFile({required this.records});

  factory PositionsFile.fromJson(Map<String, dynamic> json) => PositionsFile(
    records: (json['records'] as Map<String, dynamic>).map(
      (id, record) =>
          MapEntry(id, HumanPosition.fromJson(record as Map<String, dynamic>)),
    ),
  );

  List<HumanPosition> get all =>
      records.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

// ── 招聘计划（对齐 CLI status.rs / recruitment.json）──

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

  factory RecruitmentPlan.fromJson(Map<String, dynamic> json) =>
      RecruitmentPlan(
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
