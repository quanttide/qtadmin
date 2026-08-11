import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/friction.dart';
import 'package:qtadmin_studio/store/app_store.dart';
import 'package:qtadmin_studio/store/store_scope.dart';

/// 摩擦登记：一次摩擦一条标准。
/// 复盘四问：谁缺位、缺什么标准、标准怎么写、进哪本册子。
class FrictionsScreen extends StatelessWidget {
  const FrictionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final frictions = store.frictions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('摩擦登记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '登记摩擦',
            onPressed: () => _showCreateDialog(context, store),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: frictions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final friction = frictions[index];
          final standard = store.standards
              .where((s) => s.sourceFrictionId == friction.id)
              .firstOrNull;
          return Card(
            child: ListTile(
              title: Text(friction.scene),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('缺位：${friction.missingRole}'),
                  Text('标准草稿：${friction.standardDraft}'),
                  Text('册子：${friction.handbook}　${friction.date}'),
                  if (standard != null)
                    Text('标准草稿已入库（${standard.status.label}）'),
                ],
              ),
              trailing: Chip(
                label: Text(friction.kind.label),
                visualDensity: VisualDensity.compact,
                backgroundColor: friction.kind == FrictionKind.structural
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context, AppStore store) {
    final sceneCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final draftCtrl = TextEditingController();
    final handbookCtrl = TextEditingController();
    var kind = FrictionKind.structural;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('登记摩擦'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sceneCtrl,
                  decoration: const InputDecoration(labelText: '场景（发生了什么）'),
                ),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(labelText: '谁缺位'),
                ),
                TextField(
                  controller: draftCtrl,
                  decoration: const InputDecoration(
                    labelText: '标准怎么写（条件 + 动作 + 证据）',
                  ),
                ),
                TextField(
                  controller: handbookCtrl,
                  decoration: const InputDecoration(labelText: '进哪本册子'),
                ),
                DropdownButtonFormField<FrictionKind>(
                  initialValue: kind,
                  decoration: const InputDecoration(labelText: '类型'),
                  items: [
                    for (final k in FrictionKind.values)
                      DropdownMenuItem(value: k, child: Text(k.label)),
                  ],
                  onChanged: (v) => setState(() => kind = v!),
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
                store.addFriction(
                  scene: sceneCtrl.text,
                  missingRole: roleCtrl.text,
                  standardDraft: draftCtrl.text,
                  handbook: handbookCtrl.text,
                  kind: kind,
                );
                Navigator.pop(context);
              },
              child: const Text('登记'),
            ),
          ],
        ),
      ),
    );
  }
}
