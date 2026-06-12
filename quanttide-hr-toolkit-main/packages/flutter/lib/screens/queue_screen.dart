import 'package:flutter/material.dart';
import '../models/queue_item.dart';
import '../services/api_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/state_views.dart';

class QueueScreen extends StatefulWidget {
  final ApiService api;
  const QueueScreen({super.key, required this.api});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  List<QueueItem> _items = [];
  Map<String, int> _stats = {};
  bool _loading = true;
  String? _error;
  String? _filter;

  static const _filters = ['pending', 'confirmed', 'ignored'];
  static const _statuses = ['new', 'contacted', 'exam_sent', 'exam_received', 'evaluating', 'interview', 'offer', 'closed'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _items = await widget.api.getQueueItems(hrStatus: _filter);
      _stats = await widget.api.getQueueStats();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _confirm(QueueItem item, {String action = 'confirmed'}) async {
    final statusCtl = TextEditingController();
    final effectiveName = item.extractedName ?? item.senderName ?? '';
    final effectiveEmail = item.extractedEmail ?? item.senderEmail;
    final nameCtl = TextEditingController(text: effectiveName);
    final emailCtl = TextEditingController(text: effectiveEmail);
    final recTitleCtl = TextEditingController(text: item.suggestedRecruitmentTitle ?? '');

    final theme = Theme.of(context);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(action == 'adjusted' ? '调整' : '确认', style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtl, style: TextStyle(color: theme.colorScheme.onSurface), decoration: InputDecoration(labelText: '姓名', labelStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)))),
            TextField(controller: emailCtl, style: TextStyle(color: theme.colorScheme.onSurface), decoration: InputDecoration(labelText: '邮箱', labelStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)))),
            TextField(controller: recTitleCtl, style: TextStyle(color: theme.colorScheme.onSurface), decoration: InputDecoration(labelText: '招聘名称', labelStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)))),
            DropdownButtonFormField(
              initialValue: _statuses.contains(item.suggestedStatus) ? item.suggestedStatus : null,
              items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => statusCtl.text = v ?? '',
              dropdownColor: theme.colorScheme.surface,
              decoration: InputDecoration(labelText: '状态', labelStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)))),
          TextButton(onPressed: () => Navigator.pop(ctx, {'name': nameCtl.text, 'email': emailCtl.text, 'status': statusCtl.text, 'recruitmentTitle': recTitleCtl.text}), child: Text('确认', style: TextStyle(color: theme.colorScheme.secondary))),
        ],
      ),
    );
    if (result == null) return;
    await widget.api.confirmQueueItem(item.queueId, action: action, status: result['status'] ?? '', realName: result['name'] ?? '', email: result['email'] ?? '', recruitmentTitle: result['recruitmentTitle'] ?? '');
    _load();
  }

  Future<void> _ignore(QueueItem item) async {
    await widget.api.ignoreQueueItem(item.queueId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('确认队列'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '待处理 ${_stats['pending'] ?? 0}',
                style: TextStyle(color: Colors.orange, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(error: _error!, onRetry: _load);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('全部', null),
              for (final f in _filters)
                _buildFilterChip('${QueueItem.statusLabels[f] ?? f} (${_stats[f] ?? 0})', f),
            ],
          ),
        ),
        Expanded(
          child: _items.isEmpty
              ? EmptyState(icon: Icons.inbox, message: '暂无邮件')
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (ctx, i) => _buildCard(_items[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final theme = Theme.of(context);
    final active = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: active ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withAlpha(180))),
        selected: active,
        selectedColor: theme.colorScheme.onSurface.withAlpha(50),
        backgroundColor: theme.colorScheme.surface,
        onSelected: (_) {
          setState(() => _filter = value);
          _load();
        },
      ),
    );
  }

  Widget _buildCard(QueueItem item) {
    final theme = Theme.of(context);
    final done = item.hrStatus != 'pending';
    final onSurface = theme.colorScheme.onSurface;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: done
          ? theme.colorScheme.surface.withAlpha(180)
          : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.subject, style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: done ? onSurface.withAlpha(120) : onSurface,
            )),
            const SizedBox(height: 2),
            Text('${item.senderName ?? ''} <${item.senderEmail}>', style: TextStyle(fontSize: 12, color: onSurface.withAlpha(150))),
            const SizedBox(height: 6),
            Row(
              children: [
                StatusBadge(status: item.confidence),
                if (item.suggestedStatus != null) ...[
                  const SizedBox(width: 4),
                  StatusBadge(status: item.suggestedStatus!),
                ],
              ],
            ),
            if (!done) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => _confirm(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('确认', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 28,
                    child: OutlinedButton(
                      onPressed: () => _confirm(item, action: 'adjusted'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        foregroundColor: onSurface.withAlpha(180),
                        side: BorderSide(color: onSurface.withAlpha(60)),
                      ),
                      child: const Text('调整', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 28,
                    child: TextButton(
                      onPressed: () => _ignore(item),
                      child: Text('忽略', style: TextStyle(fontSize: 12, color: onSurface.withAlpha(120))),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
