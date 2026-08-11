import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/task.dart';
import 'package:qtadmin_studio/store/app_store.dart';
import 'package:qtadmin_studio/store/store_scope.dart';

/// 任务页：分配工作。任务绑定角色槽位而非具体评审人，
/// 解决「谁来接」的归属问题。
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final tasks = store.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('任务分配'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新建任务',
            onPressed: () => _showCreateDialog(context, store),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _TaskCard(task: task, store: store);
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context, AppStore store) {
    final titleCtrl = TextEditingController();
    final assigneeCtrl = TextEditingController();
    final deadlineCtrl = TextEditingController();
    final deliverableCtrl = TextEditingController();
    var type = RoleType.routine;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('新建任务'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: '任务标题'),
                ),
                DropdownButtonFormField<RoleType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: '任务类型'),
                  items: [
                    for (final t in RoleType.values)
                      DropdownMenuItem(value: t, child: Text(t.label)),
                  ],
                  onChanged: (v) => setState(() => type = v!),
                ),
                TextField(
                  controller: assigneeCtrl,
                  decoration: const InputDecoration(labelText: '执行人'),
                ),
                TextField(
                  controller: deadlineCtrl,
                  decoration: const InputDecoration(labelText: '截止日期'),
                ),
                TextField(
                  controller: deliverableCtrl,
                  decoration: const InputDecoration(labelText: '交付物（执行契约）'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                store.addTask(
                  title: titleCtrl.text,
                  type: type,
                  assignee: assigneeCtrl.text,
                  deadline: deadlineCtrl.text,
                  deliverable: deliverableCtrl.text,
                );
                Navigator.pop(context);
              },
              child: const Text('分配'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final AppStore store;

  const _TaskCard({required this.task, required this.store});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('执行人：${task.assignee}　截止：${task.deadline}'),
            Text('交付物：${task.deliverable}'),
            Text('评审人：${task.reviewer ?? '未定'}（${task.type.label}）'),
            if (task.reviewNote != null) Text('评审意见：${task.reviewNote}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Chip(
              label: Text(task.status.label),
              visualDensity: VisualDensity.compact,
              backgroundColor: switch (task.status) {
                TaskStatus.approved => colorScheme.primaryContainer,
                TaskStatus.rejected => colorScheme.errorContainer,
                _ => colorScheme.surfaceContainerHighest,
              },
            ),
            if (task.status == TaskStatus.open)
              TextButton(
                onPressed: () => store.submitForReview(task.id),
                child: const Text('提交评审'),
              ),
            if (task.status == TaskStatus.rejected)
              TextButton(
                onPressed: () => store.reopen(task.id),
                child: const Text('重开'),
              ),
          ],
        ),
      ),
    );
  }
}
