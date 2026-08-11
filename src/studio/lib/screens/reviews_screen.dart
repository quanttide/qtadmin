import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/task.dart';
import 'package:qtadmin_studio/store/app_store.dart';
import 'package:qtadmin_studio/store/store_scope.dart';

/// 评审工作台：执行完成后必须有明确评审人接收结果。
/// 对照执行契约检查（交付物、截止时间、范围），结论必留痕。
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final pending = store.tasks
        .where((t) => t.status == TaskStatus.inReview)
        .toList();
    final done = store.tasks
        .where(
          (t) =>
              t.status == TaskStatus.approved ||
              t.status == TaskStatus.rejected,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('评审工作台')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '待评审（${pending.length}）',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('暂无待评审任务'),
            ),
          for (final task in pending) _PendingCard(task: task, store: store),
          const SizedBox(height: 24),
          Text(
            '已评审（${done.length}）',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final task in done) _DoneCard(task: task),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final Task task;
  final AppStore store;

  const _PendingCard({required this.task, required this.store});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('执行人：${task.assignee}　截止：${task.deadline}'),
            Text('交付物：${task.deliverable}'),
            Text('评审人：${task.reviewer ?? '未定'}'),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('通过'),
                  onPressed: () =>
                      _showReviewDialog(context, store, task, approve: true),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('打回'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                  onPressed: () =>
                      _showReviewDialog(context, store, task, approve: false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(
    BuildContext context,
    AppStore store,
    Task task, {
    required bool approve,
  }) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? '通过：${task.title}' : '打回：${task.title}'),
        content: TextField(
          controller: noteCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: approve ? '通过备注' : '打回原因（制度修订的输入）',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (approve) {
                store.approve(task.id, noteCtrl.text);
              } else {
                store.reject(task.id, noteCtrl.text);
              }
              Navigator.pop(context);
            },
            child: Text(approve ? '确认通过' : '确认打回'),
          ),
        ],
      ),
    );
  }
}

class _DoneCard extends StatelessWidget {
  final Task task;

  const _DoneCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final approved = task.status == TaskStatus.approved;
    return Card(
      child: ListTile(
        leading: Icon(
          approved ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: approved ? colorScheme.primary : colorScheme.error,
        ),
        title: Text(task.title),
        subtitle: Text(
          '${task.reviewedAt}　${task.reviewer}：${task.reviewNote ?? '无意见'}',
        ),
      ),
    );
  }
}
