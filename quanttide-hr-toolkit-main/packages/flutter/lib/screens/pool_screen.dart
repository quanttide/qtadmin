import 'package:flutter/material.dart';
import '../models/pool_item.dart';
import '../services/api_service.dart';
import '../widgets/info_row.dart';
import '../widgets/status_badge.dart';
import '../widgets/state_views.dart';

class PoolScreen extends StatefulWidget {
  final ApiService api;
  const PoolScreen({super.key, required this.api});

  @override
  State<PoolScreen> createState() => _PoolScreenState();
}

class _PoolScreenState extends State<PoolScreen> {
  List<PoolItem> _items = [];
  List<Map<String, dynamic>> _recruitments = [];
  Headcount? _headcount;
  int? _selectedRecruitmentId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final recs = await widget.api.getRecruitments();
      if (recs.isNotEmpty && _selectedRecruitmentId == null) {
        _selectedRecruitmentId = recs.last['id'] as int;
      }
      _recruitments = recs;

      final results = await Future.wait([
        widget.api.getPool(),
        if (_selectedRecruitmentId != null) widget.api.getHeadcount(_selectedRecruitmentId!) else Future.value(null),
      ]);
      _items = results[0] as List<PoolItem>;
      _headcount = results.length > 1 ? results[1] as Headcount? : null;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _unpool(PoolItem item) async {
    final theme = Theme.of(context);
    final idCtl = TextEditingController(text: _selectedRecruitmentId?.toString() ?? '');
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text('出池', style: TextStyle(color: theme.colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('将 ${item.candidateName} 出池到新的招聘批次', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(180))),
              const SizedBox(height: 8),
              if (_recruitments.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: int.tryParse(idCtl.text),
                  items: _recruitments.map((r) => DropdownMenuItem(value: r['id'] as int, child: Text('招聘 #${r['id']}', style: TextStyle(color: theme.colorScheme.onSurface)))).toList(),
                  onChanged: (v) { idCtl.text = v.toString(); setDialogState(() {}); },
                  dropdownColor: theme.colorScheme.surface,
                  decoration: InputDecoration(labelText: '目标招聘批次', labelStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150))),
                )
              else
                TextField(
                  controller: idCtl,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(labelText: '招聘批次 ID', labelStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150))),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)))),
            TextButton(onPressed: () => Navigator.pop(ctx, {'recruitment_id': idCtl.text}), child: Text('确认出池', style: TextStyle(color: theme.colorScheme.secondary))),
          ],
        ),
      ),
    );
    if (result == null) return;
    final rid = int.tryParse(result['recruitment_id'] ?? '');
    if (rid == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('无效的招聘批次 ID'), backgroundColor: theme.colorScheme.error));
      return;
    }
    try {
      await widget.api.unpoolApplication(item.id, rid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('出池成功'), backgroundColor: theme.colorScheme.secondary));
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('出池失败: $e'), backgroundColor: theme.colorScheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('人才库'),
        actions: [
          if (_headcount != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '已接受 ${_headcount!.accepted} / 总 Offer ${_headcount!.totalOffers}',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(150)),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_recruitments.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                children: _recruitments.map((r) {
                  final id = r['id'] as int;
                  final active = id == _selectedRecruitmentId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text('招聘 #$id', style: TextStyle(fontSize: 12, color: active ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withAlpha(180))),
                      selected: active,
                      selectedColor: theme.colorScheme.secondary,
                      backgroundColor: theme.colorScheme.surface,
                      onSelected: (_) {
                        setState(() => _selectedRecruitmentId = id);
                        _load();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(error: _error!, onRetry: _load);
    if (_items.isEmpty) return EmptyState(icon: Icons.person_off, message: '人才库为空');

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        itemBuilder: (ctx, i) => _buildCard(_items[i]),
      ),
    );
  }

  void _showDetail(PoolItem item) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withAlpha(50), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(item.candidateName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              const SizedBox(height: 12),
              InfoRow(label: '邮箱', value: item.candidateEmail, labelWidth: 80),
              InfoRow(label: '原状态', value: item.status, labelWidth: 80),
              InfoRow(label: '质量', value: item.quality == 'excellent' ? '优秀' : item.quality == 'closed' ? '淘汰' : '普通', labelWidth: 80),
              if (item.pooledAt != null) InfoRow(label: '入池日期', value: item.pooledAt!.substring(0, 10), labelWidth: 80),
              if (item.subStage != null) InfoRow(label: '子阶段', value: item.subStage!, labelWidth: 80),
              const SizedBox(height: 12),
              Text('入池信息', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withAlpha(180))),
              const SizedBox(height: 8),
              InfoRow(label: '来源', value: item.source, labelWidth: 80),
              if (item.deactivatedAt != null) InfoRow(label: '停用日期', value: item.deactivatedAt!.substring(0, 10), labelWidth: 80),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () { Navigator.pop(ctx); _unpool(item); },
                  icon: const Icon(Icons.unarchive, size: 16),
                  label: const Text('出池', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.secondary, side: BorderSide(color: theme.colorScheme.secondary)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(PoolItem item) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showDetail(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 20, color: onSurface.withAlpha(150)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.candidateName,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: onSurface),
                    ),
                  ),
                  if (item.quality == 'excellent')
                    Icon(Icons.star, size: 16, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 4),
              Text(item.candidateEmail, style: TextStyle(fontSize: 12, color: onSurface.withAlpha(150))),
              const SizedBox(height: 8),
              Row(
                children: [
                  StatusBadge(status: item.status, label: '原状态: ${item.status}'),
                  if (item.pooledAt != null) ...[
                    const SizedBox(width: 4),
                    StatusBadge(status: 'offer', label: '入池: ${item.pooledAt!.substring(0, 10)}'),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: () => _unpool(item),
                  icon: const Icon(Icons.unarchive, size: 16),
                  label: const Text('出池', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                    side: BorderSide(color: theme.colorScheme.secondary.withAlpha(150)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
