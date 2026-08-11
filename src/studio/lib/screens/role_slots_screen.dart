import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/task.dart';
import 'package:qtadmin_studio/store/store_scope.dart';

/// 角色槽位：任务类型 → 默认评审人。
/// 常规 = 直接指导者，政策类 = 秘书处，重大 = 创始人。
class RoleSlotsScreen extends StatelessWidget {
  const RoleSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('角色槽位')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '任务分配绑定角色槽位而非具体人，评审人随槽位变化。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final type in RoleType.values)
            Card(
              child: ListTile(
                title: Text(type.label),
                subtitle: Text('任务类型：${type.label}'),
                trailing: SizedBox(
                  width: 160,
                  child: TextField(
                    controller: TextEditingController(
                      text: store.roleSlots[type],
                    ),
                    decoration: const InputDecoration(
                      labelText: '默认评审人',
                      isDense: true,
                    ),
                    onSubmitted: (value) => store.setReviewer(type, value),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
