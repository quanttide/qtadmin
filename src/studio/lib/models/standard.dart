/// 标准承载状态：草稿随实践演进，模糊是演进中的合法状态。
enum StandardStatus {
  draft('草稿'),
  evolving('演进中'),
  settled('已定型');

  final String label;

  const StandardStatus(this.label);
}

/// 评审标准。要素：条件（什么情况适用）+ 动作（做到什么算过）+ 证据（怎么验证）。
/// 由摩擦登记生成草稿，经评审打回聚类后修订（质量飞轮）。
class Standard {
  final String id;
  final String title;
  final String content; // 条件 + 动作 + 证据
  final String handbook; // 所属册子
  final String sourceFrictionId;
  StandardStatus status;
  final String date;

  Standard({
    required this.id,
    required this.title,
    required this.content,
    required this.handbook,
    required this.sourceFrictionId,
    this.status = StandardStatus.draft,
    required this.date,
  });

  factory Standard.fromJson(Map<String, dynamic> json) => Standard(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    handbook: json['handbook'] as String,
    sourceFrictionId: json['sourceFrictionId'] as String,
    status: StandardStatus.values.byName(json['status'] as String),
    date: json['date'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'handbook': handbook,
    'sourceFrictionId': sourceFrictionId,
    'status': status.name,
    'date': date,
  };
}
