import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/friction.dart';
import 'package:qtadmin_studio/models/task.dart';
import 'package:qtadmin_studio/store/app_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('AppStore 任务', () {
    test('新建任务默认绑定角色槽位评审人', () {
      final store = AppStore();
      store.addTask(
        title: '测试任务',
        type: RoleType.policy,
        assignee: '张三',
        deadline: '2026-08-20',
        deliverable: '测试交付物',
      );
      final task = store.tasks.last;
      expect(task.reviewer, '秘书处');
      expect(task.status, TaskStatus.open);
    });

    test('评审闭环：提交 → 通过', () {
      final store = AppStore();
      store.addTask(
        title: '任务A',
        type: RoleType.routine,
        assignee: '李四',
        deadline: '2026-08-20',
        deliverable: '交付物A',
      );
      final id = store.tasks.last.id;

      store.submitForReview(id);
      expect(store.tasks.last.status, TaskStatus.inReview);

      store.approve(id, '符合契约');
      expect(store.tasks.last.status, TaskStatus.approved);
      expect(store.tasks.last.reviewNote, '符合契约');
      expect(store.tasks.last.reviewedAt, isNotNull);
    });

    test('评审闭环：提交 → 打回 → 重开', () {
      final store = AppStore();
      store.addTask(
        title: '任务B',
        type: RoleType.routine,
        assignee: '王五',
        deadline: '2026-08-20',
        deliverable: '交付物B',
      );
      final id = store.tasks.last.id;

      store.submitForReview(id);
      store.reject(id, '交付物不完整');
      final task = store.tasks.last;
      expect(task.status, TaskStatus.rejected);
      expect(task.reviewNote, '交付物不完整');

      store.reopen(id);
      expect(store.tasks.last.status, TaskStatus.open);
      expect(store.tasks.last.reviewNote, isNull);
    });

    test('仅 inReview 状态可评审', () {
      final store = AppStore();
      store.addTask(
        title: '任务C',
        type: RoleType.routine,
        assignee: '赵六',
        deadline: '2026-08-20',
        deliverable: '交付物C',
      );
      final id = store.tasks.last.id;

      store.approve(id, '不应生效');
      expect(store.tasks.last.status, TaskStatus.open);
    });
  });

  group('AppStore 摩擦', () {
    test('登记摩擦默认记录当天日期', () {
      final store = AppStore();
      store.addFriction(
        scene: '测试场景',
        missingRole: '测试角色',
        standardDraft: '条件 + 动作 + 证据',
        handbook: '测试册子',
        kind: FrictionKind.structural,
      );
      final friction = store.frictions.last;
      expect(friction.date, isNotEmpty);
      expect(friction.kind, FrictionKind.structural);
    });

    test('登记摩擦自动生成标准草稿（draft）', () {
      final store = AppStore();
      final before = store.standards.length;
      store.addFriction(
        scene: '测试场景',
        missingRole: '测试角色',
        standardDraft: '条件 + 动作 + 证据',
        handbook: '测试册子',
        kind: FrictionKind.occasional,
      );
      final friction = store.frictions.last;
      final standard = store.standards.last;
      expect(store.standards.length, before + 1);
      expect(standard.sourceFrictionId, friction.id);
      expect(standard.content, '条件 + 动作 + 证据');
      expect(standard.status.name, 'draft');
    });
  });

  group('AppStore 角色槽位', () {
    test('修改评审人后新建任务使用新槽位', () {
      final store = AppStore();
      store.setReviewer(RoleType.major, '董事会');
      store.addTask(
        title: '重大任务',
        type: RoleType.major,
        assignee: '钱七',
        deadline: '2026-08-20',
        deliverable: '交付物',
      );
      expect(store.tasks.last.reviewer, '董事会');
    });
  });

  group('AppStore 持久化', () {
    test('变更后数据可恢复', () async {
      SharedPreferences.setMockInitialValues({});
      final store = AppStore();
      store.addTask(
        title: '持久化任务',
        type: RoleType.routine,
        assignee: '孙八',
        deadline: '2026-08-21',
        deliverable: '交付物',
      );
      store.setReviewer(RoleType.policy, '办公室');
      // 等待异步持久化完成
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final restored = await AppStore.load();
      expect(restored.tasks.any((t) => t.title == '持久化任务'), true);
      expect(restored.roleSlots[RoleType.policy], '办公室');
    });

    test('无历史数据时使用示例数据', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await AppStore.load();
      expect(store.tasks, isNotEmpty);
      expect(store.frictions, isNotEmpty);
      expect(store.standards, isNotEmpty);
    });
  });
}
