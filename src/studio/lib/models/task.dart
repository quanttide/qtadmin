/// 任务类型，对应角色槽位的键。
///
/// 对齐「评审环节可行路径」：常规任务由直接指导者评审，
/// 政策类由秘书处评审，重大事项由创始人评审。
enum RoleType {
  routine('常规', '直接指导者'),
  policy('政策类', '秘书处'),
  major('重大', '创始人');

  final String label;
  final String defaultReviewer;

  const RoleType(this.label, this.defaultReviewer);
}

/// 任务状态流转：open（已分配）→ inReview（已提交待评审）
/// → approved（通过）/ rejected（打回），打回可重开回 open。
enum TaskStatus {
  open('待执行'),
  inReview('待评审'),
  approved('已通过'),
  rejected('已打回');

  final String label;

  const TaskStatus(this.label);
}

/// 分配的工作。评审结果直接承载在任务上（MVP 简化，不建独立评审实体）。
class Task {
  final String id;
  final String title;
  final RoleType type;
  final String assignee;
  final String deadline;
  final String deliverable; // 执行契约：交付物
  TaskStatus status;
  String? reviewer; // 默认取角色槽位，可覆盖
  String? reviewNote; // 评审原因（通过备注 / 打回原因）
  String? reviewedAt;

  Task({
    required this.id,
    required this.title,
    required this.type,
    required this.assignee,
    required this.deadline,
    required this.deliverable,
    this.status = TaskStatus.open,
    this.reviewer,
    this.reviewNote,
    this.reviewedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    type: RoleType.values.byName(json['type'] as String),
    assignee: json['assignee'] as String,
    deadline: json['deadline'] as String,
    deliverable: json['deliverable'] as String,
    status: TaskStatus.values.byName(json['status'] as String),
    reviewer: json['reviewer'] as String?,
    reviewNote: json['reviewNote'] as String?,
    reviewedAt: json['reviewedAt'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'assignee': assignee,
    'deadline': deadline,
    'deliverable': deliverable,
    'status': status.name,
    'reviewer': reviewer,
    'reviewNote': reviewNote,
    'reviewedAt': reviewedAt,
  };
}
