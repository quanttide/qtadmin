import 'package:flutter/foundation.dart';
import 'package:qtadmin_studio/models/friction.dart';
import 'package:qtadmin_studio/models/task.dart';

/// 治理数据的内存仓库。MVP 阶段承载状态与交互，
/// 后续接入 FileSource 本地 JSON 实现双端共享。
class AppStore extends ChangeNotifier {
  final List<Task> _tasks;
  final List<Friction> _frictions;
  final Map<RoleType, String> _roleSlots;

  AppStore({
    List<Task>? tasks,
    List<Friction>? frictions,
    Map<RoleType, String>? roleSlots,
  }) : _tasks = tasks ?? _seedTasks(),
       _frictions = frictions ?? _seedFrictions(),
       _roleSlots = roleSlots ?? _seedRoleSlots();

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Friction> get frictions => List.unmodifiable(_frictions);
  Map<RoleType, String> get roleSlots => Map.unmodifiable(_roleSlots);

  static List<Task> _seedTasks() => [
    Task(
      id: 't-1',
      title: '发布六月份招聘计划',
      type: RoleType.policy,
      assignee: 'HR 小张',
      deadline: '2026-08-14',
      deliverable: '招聘计划文档 + 岗位明细表，进度群广播',
      status: TaskStatus.inReview,
    ),
    Task(
      id: 't-2',
      title: '整理客户交接清单',
      type: RoleType.routine,
      assignee: 'PM 小李',
      deadline: '2026-08-16',
      deliverable: '客户清单 + 责任人 + 交接状态',
      status: TaskStatus.open,
    ),
  ];

  static List<Friction> _seedFrictions() => [
    Friction(
      id: 'f-1',
      scene: 'HR 往人力资源群发邮件模板，创始人回复后 HR 单独再发一次，汇报链条回到创始人',
      missingRole: '评审人缺位',
      standardDraft: '条件：任务已分配并有明确评审人时；动作：执行人直接对接评审人，创始人不再介入；证据：飞书对话记录',
      handbook: '沟通章程',
      kind: FrictionKind.structural,
      date: '2026-08-11',
    ),
  ];

  static Map<RoleType, String> _seedRoleSlots() => {
    for (final t in RoleType.values) t: t.defaultReviewer,
  };

  String _nextId(String prefix) {
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}';
  }

  // 任务操作

  void addTask({
    required String title,
    required RoleType type,
    required String assignee,
    required String deadline,
    required String deliverable,
  }) {
    _tasks.add(
      Task(
        id: _nextId('t'),
        title: title,
        type: type,
        assignee: assignee,
        deadline: deadline,
        deliverable: deliverable,
        reviewer: _roleSlots[type],
      ),
    );
    notifyListeners();
  }

  /// 执行人提交评审：open → inReview
  void submitForReview(String id) {
    final task = _findTask(id);
    if (task != null && task.status == TaskStatus.open) {
      task.status = TaskStatus.inReview;
      task.reviewer ??= _roleSlots[task.type];
      notifyListeners();
    }
  }

  /// 评审通过：inReview → approved
  void approve(String id, String note) {
    final task = _findTask(id);
    if (task != null && task.status == TaskStatus.inReview) {
      task.status = TaskStatus.approved;
      task.reviewNote = note;
      task.reviewedAt = DateTime.now().toString().substring(0, 10);
      notifyListeners();
    }
  }

  /// 评审打回：inReview → rejected
  void reject(String id, String reason) {
    final task = _findTask(id);
    if (task != null && task.status == TaskStatus.inReview) {
      task.status = TaskStatus.rejected;
      task.reviewNote = reason;
      task.reviewedAt = DateTime.now().toString().substring(0, 10);
      notifyListeners();
    }
  }

  /// 打回重开：rejected → open
  void reopen(String id) {
    final task = _findTask(id);
    if (task != null && task.status == TaskStatus.rejected) {
      task.status = TaskStatus.open;
      task.reviewNote = null;
      task.reviewedAt = null;
      notifyListeners();
    }
  }

  Task? _findTask(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  // 摩擦操作

  void addFriction({
    required String scene,
    required String missingRole,
    required String standardDraft,
    required String handbook,
    required FrictionKind kind,
    String? date,
  }) {
    _frictions.add(
      Friction(
        id: _nextId('f'),
        scene: scene,
        missingRole: missingRole,
        standardDraft: standardDraft,
        handbook: handbook,
        kind: kind,
        date: date ?? DateTime.now().toString().substring(0, 10),
      ),
    );
    notifyListeners();
  }

  // 角色槽位操作

  void setReviewer(RoleType type, String reviewer) {
    _roleSlots[type] = reviewer;
    notifyListeners();
  }
}
