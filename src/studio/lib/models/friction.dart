/// 摩擦类型：偶发摩擦不立制度，结构性缺位才立。
enum FrictionKind {
  occasional('偶发'),
  structural('结构性');

  final String label;

  const FrictionKind(this.label);
}

/// 摩擦登记。复盘四问：谁缺位、缺什么标准、标准怎么写、进哪本册子。
class Friction {
  final String id;
  final String scene; // 场景描述
  final String missingRole; // 谁缺位
  final String standardDraft; // 缺什么标准 + 怎么写（条件 + 动作 + 证据草稿）
  final String handbook; // 进哪本册子
  final FrictionKind kind; // 偶发 / 结构性
  final String date;

  Friction({
    required this.id,
    required this.scene,
    required this.missingRole,
    required this.standardDraft,
    required this.handbook,
    required this.kind,
    required this.date,
  });
}
