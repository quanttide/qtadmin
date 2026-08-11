import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:qtadmin_studio/models/friction.dart';
import 'package:qtadmin_studio/models/standard.dart';
import 'package:qtadmin_studio/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 治理数据仓库。数据以 JSON 持久化到本地（SharedPreferences），
/// 后续可迁移为 FileSource 本地 JSON 实现与 CLI 双端共享。
class AppStore extends ChangeNotifier {
  static const _keyTasks = 'qtadmin.tasks';
  static const _keyFrictions = 'qtadmin.frictions';
  static const _keyStandards = 'qtadmin.standards';
  static const _keyRoleSlots = 'qtadmin.roleSlots';

  final List<Task> _tasks;
  final List<Friction> _frictions;
  final List<Standard> _standards;
  final Map<RoleType, String> _roleSlots;

  AppStore({
    List<Task>? tasks,
    List<Friction>? frictions,
    List<Standard>? standards,
    Map<RoleType, String>? roleSlots,
  }) : _tasks = tasks ?? _seedTasks(),
       _frictions = frictions ?? _seedFrictions(),
       _standards = standards ?? _seedStandards(),
       _roleSlots = roleSlots ?? _seedRoleSlots();

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Friction> get frictions => List.unmodifiable(_frictions);
  List<Standard> get standards => List.unmodifiable(_standards);
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

  static List<Standard> _seedStandards() => [
    Standard(
      id: 's-1',
      title: '任务评审直通执行人',
      content: '条件：任务已分配并有明确评审人时；动作：执行人直接对接评审人，创始人不再介入；证据：飞书对话记录',
      handbook: '沟通章程',
      sourceFrictionId: 'f-1',
      date: '2026-08-11',
    ),
  ];

  static Map<RoleType, String> _seedRoleSlots() => {
    for (final t in RoleType.values) t: t.defaultReviewer,
  };

  /// 从本地存储恢复数据；无历史数据时使用示例数据。
  static Future<AppStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = _decodeList(prefs.getString(_keyTasks), Task.fromJson);
    final frictions = _decodeList(
      prefs.getString(_keyFrictions),
      Friction.fromJson,
    );
    final standards = _decodeList(
      prefs.getString(_keyStandards),
      Standard.fromJson,
    );
    final roleSlotsJson = prefs.getString(_keyRoleSlots);
    Map<RoleType, String>? roleSlots;
    if (roleSlotsJson != null) {
      final raw = jsonDecode(roleSlotsJson) as Map<String, dynamic>;
      roleSlots = {
        for (final e in raw.entries)
          RoleType.values.byName(e.key): e.value as String,
      };
    }
    return AppStore(
      tasks: tasks,
      frictions: frictions,
      standards: standards,
      roleSlots: roleSlots,
    );
  }

  /// 返回 null 表示无历史数据（使用 seed）。
  static List<T>? _decodeList<T>(
    String? jsonStr,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (jsonStr == null) return null;
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return [for (final e in list) fromJson(e as Map<String, dynamic>)];
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyTasks,
      jsonEncode([for (final t in _tasks) t.toJson()]),
    );
    await prefs.setString(
      _keyFrictions,
      jsonEncode([for (final f in _frictions) f.toJson()]),
    );
    await prefs.setString(
      _keyStandards,
      jsonEncode([for (final s in _standards) s.toJson()]),
    );
    await prefs.setString(
      _keyRoleSlots,
      jsonEncode({for (final e in _roleSlots.entries) e.key.name: e.value}),
    );
  }

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
    _persist();
  }

  /// 执行人提交评审：open → inReview
  void submitForReview(String id) {
    final task = _findTask(id);
    if (task != null && task.status == TaskStatus.open) {
      task.status = TaskStatus.inReview;
      task.reviewer ??= _roleSlots[task.type];
      notifyListeners();
      _persist();
    }
  }

  /// 评审通过：inReview → approved
  void approve(String id, String note) {
    final task = _findTask(id);
    if (task != null && task.status == TaskStatus.inReview) {
      task.status = TaskStatus.approved;
      task.reviewNote = note;
      task.reviewedAt = _today();
      notifyListeners();
      _persist();
    }
  }

  /// 评审打回：inReview → rejected
  void reject(String id, String reason) {
    final task = _findTask(id);
    if (task != null && task.status == TaskStatus.inReview) {
      task.status = TaskStatus.rejected;
      task.reviewNote = reason;
      task.reviewedAt = _today();
      notifyListeners();
      _persist();
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
      _persist();
    }
  }

  Task? _findTask(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  // 摩擦操作

  /// 登记摩擦并自动生成标准草稿（draft），经实践与打回聚类后演进。
  void addFriction({
    required String scene,
    required String missingRole,
    required String standardDraft,
    required String handbook,
    required FrictionKind kind,
    String? date,
  }) {
    final today = date ?? _today();
    final friction = Friction(
      id: _nextId('f'),
      scene: scene,
      missingRole: missingRole,
      standardDraft: standardDraft,
      handbook: handbook,
      kind: kind,
      date: today,
    );
    _frictions.add(friction);
    _standards.add(
      Standard(
        id: _nextId('s'),
        title: scene.length > 20 ? '${scene.substring(0, 20)}…' : scene,
        content: standardDraft,
        handbook: handbook,
        sourceFrictionId: friction.id,
        date: today,
      ),
    );
    notifyListeners();
    _persist();
  }

  // 角色槽位操作

  void setReviewer(RoleType type, String reviewer) {
    _roleSlots[type] = reviewer;
    notifyListeners();
    _persist();
  }

  static String _today() => DateTime.now().toString().substring(0, 10);
}
