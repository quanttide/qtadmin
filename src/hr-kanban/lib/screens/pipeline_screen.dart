import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/application_materials.dart';
import '../models/mail_message.dart';
import '../theme/hr_theme.dart';
import '../widgets/info_row.dart';
import '../widgets/state_views.dart';

class PipelineScreen extends StatefulWidget {
  final ApiService api;
  const PipelineScreen({super.key, required this.api});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  Map<String, dynamic>? _pipeline;
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _statusLabels = {
    'new': '新进入', 'contacted': '已联系', 'exam_sent': '笔试已发送',
    'exam_received': '笔试已提交', 'evaluating': '评估中', 'interview': '面试',
    'offer': '已发Offer', 'closed': '已结束',
  };
  static const _statusOrder = ['new', 'contacted', 'exam_sent', 'exam_received', 'evaluating', 'interview', 'offer', 'closed'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.trim().toLowerCase()));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _waitDays(Map<String, dynamic> t) {
    final updated = t['updated_at'] as String?;
    if (updated == null) return -1;
    try {
      final dt = DateTime.parse(updated.replaceAll(' ', 'T'));
      return DateTime.now().difference(dt).inDays;
    } catch (_) {
      return -1;
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _pipeline = await widget.api.getPipeline();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('招聘管道看板'),
        actions: [
          if (_pipeline != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '总数 ${_pipeline!['summary']['total']}  待关注 ${_pipeline!['summary']['need_attention']}',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withAlpha(150)),
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
    if (_pipeline == null) return EmptyState(icon: Icons.view_column, message: '暂无数据');

    final theme = Theme.of(context);
    final stages = _pipeline!['stages'] as Map<String, dynamic>;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
            decoration: InputDecoration(
              hintText: '搜索姓名或邮箱...',
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(120), fontSize: 13),
              prefixIcon: Icon(Icons.search, size: 18, color: theme.colorScheme.onSurface.withAlpha(120)),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _statusOrder.map((status) {
                      var items = List<Map<String, dynamic>>.from(stages[status] ?? []);
                      if (_searchQuery.isNotEmpty) {
                        items = items.where((t) {
                          final name = (t['real_name'] as String? ?? '').toLowerCase();
                          final email = (t['email'] as String? ?? '').toLowerCase();
                          return name.contains(_searchQuery) || email.contains(_searchQuery);
                        }).toList();
                      }
                      return _buildColumn(status, items);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(String status, List<Map<String, dynamic>> items) {
    final theme = Theme.of(context);
    final statusColor = context.statusColor(status);

    Color waitColor(int wd) {
      if (wd < 0) return theme.colorScheme.onSurface.withAlpha(100);
      if (wd >= 14) return Colors.orange;
      if (wd >= 7) return Colors.yellow;
      return theme.colorScheme.onSurface.withAlpha(120);
    }

    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.onSurface.withAlpha(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 3, height: 14, color: statusColor, margin: const EdgeInsets.only(right: 6)),
                    Text(_statusLabels[status] ?? status, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(color: statusColor.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                  child: Text('${items.length}', style: TextStyle(fontSize: 11, color: statusColor)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text('空', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(80))))
                : ListView(
                    children: items.map((t) {
                      final wd = _waitDays(t);
                      final wc = waitColor(wd);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: InkWell(
                          onTap: () => _showDetail(t),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(t['real_name'] ?? '', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: theme.colorScheme.onSurface))),
                                    if (t['quality'] == 'excellent')
                                      Icon(Icons.star, size: 14, color: Colors.amber),
                                  ],
                                ),
                                Text(t['email'] ?? '', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(150))),
                                if (t['sub_stage'] != null)
                                  Text('子阶段: ${t['sub_stage']}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(120))),
                                if (wd >= 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: wc.withAlpha(25),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text('停留 $wd 天', style: TextStyle(fontSize: 10, color: wc, fontWeight: wd >= 14 ? FontWeight.w700 : FontWeight.normal)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _transition(Map<String, dynamic> talent, String targetStatus) async {
    final id = talent['id'];
    if (id is! int && id is! num) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('状态更新失败: id 类型异常 (${id.runtimeType}: $id)'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
      return;
    }
    final applicationId = (id as num).toInt();
    try {
      await widget.api.transitionApplication(applicationId, targetStatus);
      if (mounted) {
        Navigator.of(context).pop();
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('状态更新失败: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  void _showDetail(Map<String, dynamic> talent) async {
    final email = talent['email'] as String;
    final candidateId = talent['candidate_id'] as int?;
    Map<String, dynamic>? queueData;
    ApplicationMaterials? materials;
    List<MailMessage> messages = [];
    List<TimelineItem> timeline = [];
    try {
      queueData = await widget.api.getQueueByEmail(email);
      final appId = talent['id'];
      if (appId is int) {
        materials = await widget.api.getApplicationMaterials(appId);
      }
      if (candidateId != null) {
        messages = await widget.api.getCandidateMessages(candidateId);
        timeline = await widget.api.getCandidateTimeline(candidateId);
      }
    } catch (_) {}

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => _DetailPanel(
        api: widget.api,
        talent: talent,
        queueData: queueData,
        materials: materials,
        messages: messages,
        timeline: timeline,
        onTransition: (target) => _transition(talent, target),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final ApiService api;
  final Map<String, dynamic> talent;
  final Map<String, dynamic>? queueData;
  final ApplicationMaterials? materials;
  final List<MailMessage> messages;
  final List<TimelineItem> timeline;
  final void Function(String targetStatus)? onTransition;

  const _DetailPanel({
    required this.api,
    required this.talent,
    this.queueData,
    this.materials,
    this.messages = const [],
    this.timeline = const [],
    this.onTransition,
  });

  String _classifierLabel(String? source) {
    return switch (source) {
      'rule' => '规则分类',
      'llm' => 'AI 分类',
      _ => source ?? '未知',
    };
  }

  void _showReplyDialog(BuildContext context) {
    final theme = Theme.of(context);
    final subjectCtl = TextEditingController();
    final bodyCtl = TextEditingController();
    final candidateId = talent['candidate_id'] as int?;
    final applicationId = talent['id'] as int?;
    if (candidateId == null || applicationId == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('回复候选人', style: TextStyle(color: theme.colorScheme.onSurface)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectCtl,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: '主题',
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bodyCtl,
                style: TextStyle(color: theme.colorScheme.onSurface),
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: '正文',
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150))),
          ),
          TextButton(
            onPressed: () async {
              if (subjectCtl.text.trim().isEmpty || bodyCtl.text.trim().isEmpty) return;
              try {
                await api.replyToCandidate(candidateId, applicationId, subjectCtl.text, bodyCtl.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('回复已发送'), backgroundColor: theme.colorScheme.secondary),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('发送失败: $e'), backgroundColor: theme.colorScheme.error),
                  );
                }
              }
            },
            child: Text('发送', style: TextStyle(color: theme.colorScheme.secondary)),
          ),
        ],
      ),
    );
  }

  static const _statusLabels = {
    'new': '新进入', 'contacted': '已联系', 'exam_sent': '笔试已发送',
    'exam_received': '笔试已提交', 'evaluating': '评估中', 'interview': '面试',
    'offer': '已发Offer', 'closed': '已结束',
  };

  static const _transitions = {
    'new': ['contacted', 'closed'],
    'contacted': ['exam_sent', 'closed'],
    'exam_sent': ['exam_received', 'closed'],
    'exam_received': ['evaluating', 'closed'],
    'evaluating': ['interview', 'exam_sent', 'closed'],
    'interview': ['offer', 'closed'],
    'offer': ['closed'],
    'closed': [],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStatus = talent['status'] as String? ?? '';
    final availableTargets = _transitions[currentStatus] ?? <String>[];
    final onSurface = theme.colorScheme.onSurface;
    final m = materials;
    final qi = m?.queueItem;
    final ci = m?.classifierInfo;
    final corrections = m?.corrections;
    final atts = qi?.attachments;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (ctx, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: onSurface.withAlpha(50), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            Text(talent['real_name'] ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: onSurface)),
            const SizedBox(height: 12),
            InfoRow(label: '邮箱', value: talent['email'] ?? ''),
            InfoRow(label: '阶段', value: _statusLabels[currentStatus] ?? currentStatus),
            if (talent['sub_stage'] != null) InfoRow(label: '子阶段', value: talent['sub_stage']),
            if (talent['quality'] != null) InfoRow(label: '质量', value: talent['quality'] == 'excellent' ? '优秀' : talent['quality'] == 'closed' ? '淘汰' : '普通'),
            if (talent['created_at'] != null) InfoRow(label: '创建时间', value: talent['created_at']),

            if (availableTargets.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('推进状态', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurface.withAlpha(180))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: availableTargets.map((target) {
                  final isClose = target == 'closed';
                  return ElevatedButton(
                    onPressed: onTransition != null ? () => onTransition!(target) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isClose ? theme.colorScheme.error : theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(_statusLabels[target] ?? target, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
              ),
            ],

            Divider(height: 24, color: onSurface.withAlpha(30)),

            Text('飞书邮件材料', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurface.withAlpha(180))),
            const SizedBox(height: 8),
            if (queueData != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('主题: ${queueData!['subject'] ?? ''}', style: TextStyle(fontSize: 13, color: onSurface.withAlpha(180))),
                    const SizedBox(height: 4),
                    Text('发件人: ${queueData!['sender_name'] ?? ''} <${queueData!['sender_email'] ?? ''}>', style: TextStyle(fontSize: 13, color: onSurface.withAlpha(180))),
                    const SizedBox(height: 4),
                    if (queueData!['suggested_status'] != null)
                      Text('分类建议: ${queueData!['suggested_status']}', style: TextStyle(fontSize: 13, color: onSurface.withAlpha(180))),
                    Text('置信度: ${queueData!['confidence'] ?? ''}', style: TextStyle(fontSize: 13, color: onSurface.withAlpha(180))),
                    if (queueData!['hr_notes'] != null)
                      Text('HR 备注: ${queueData!['hr_notes']}', style: TextStyle(fontSize: 13, color: onSurface.withAlpha(180))),

                    // Email body
                    if (qi != null) ...[
                      const SizedBox(height: 8),
                      if (qi.bodyText != null && qi.bodyText!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: onSurface.withAlpha(10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(qi.bodyText!, style: TextStyle(fontSize: 12, color: onSurface.withAlpha(200))),
                        )
                      else if (qi.body != null && qi.body!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: onSurface.withAlpha(10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(qi.body!, style: TextStyle(fontSize: 12, color: onSurface.withAlpha(200))),
                        )
                      else
                        Text('该邮件无正文内容', style: TextStyle(fontSize: 12, color: onSurface.withAlpha(120))),
                    ],

                    // Attachments
                    if (atts != null && atts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('附件 (${atts.length})', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: onSurface.withAlpha(180))),
                      ...atts.map((a) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: GestureDetector(
                          onTap: a.storagePath != null ? () => api.openAttachmentPreview(a.storagePath!, a.filename) : null,
                          child: Row(
                            children: [
                              Icon(Icons.attach_file, size: 14, color: a.storagePath != null ? theme.colorScheme.secondary : onSurface.withAlpha(80)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${a.filename} (${a.size > 0 ? "${(a.size / 1024).toStringAsFixed(0)} KB" : "?"})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: a.storagePath != null ? theme.colorScheme.secondary : onSurface.withAlpha(120),
                                    decoration: a.storagePath != null ? TextDecoration.underline : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],

                    // Classifier info
                    if (ci != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: onSurface.withAlpha(8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('分类来源: ${_classifierLabel(ci['classifier_source'] as String?)}', style: TextStyle(fontSize: 12, color: onSurface.withAlpha(150))),
                            if (ci['classifier_reason'] != null)
                              Text('分类理由: ${ci['classifier_reason']}', style: TextStyle(fontSize: 12, color: onSurface.withAlpha(150))),
                          ],
                        ),
                      ),
                    ],

                    // Corrections
                    if (corrections != null && corrections.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('修正记录 (${corrections.length})', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: onSurface.withAlpha(180))),
                      ...corrections.map((c) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${c.fieldName}: ${c.originalValue ?? ""} → ${c.correctedValue ?? ""}', style: TextStyle(fontSize: 12, color: onSurface.withAlpha(150))),
                            if (c.createdAt.isNotEmpty)
                              Text(c.createdAt, style: TextStyle(fontSize: 10, color: onSurface.withAlpha(100))),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ] else ...[
              Text('该候选人无关联的飞书邮件记录', style: TextStyle(fontSize: 13, color: onSurface.withAlpha(120))),
            ],

            Divider(height: 24, color: onSurface.withAlpha(30)),

            Text('阶段结果', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurface.withAlpha(180))),
            const SizedBox(height: 8),
            if (talent['stage_results'] != null && (talent['stage_results'] as Map).isNotEmpty)
              ...(talent['stage_results'] as Map<String, dynamic>).entries.map((e) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(width: 80, child: Text(_statusLabels[e.key] ?? e.key, style: TextStyle(fontSize: 13, color: onSurface.withAlpha(150)))),
                      Text(e.value == 'pass' ? '通过' : '淘汰', style: TextStyle(fontSize: 13, color: e.value == 'pass' ? theme.colorScheme.secondary : theme.colorScheme.error)),
                    ],
                  ),
                ),
              )
            else
              Text('暂无阶段结果', style: TextStyle(fontSize: 13, color: onSurface.withAlpha(120))),

            // Messages
            if (messages.isNotEmpty) ...[
              Divider(height: 24, color: onSurface.withAlpha(30)),
              Text('消息记录 (${messages.length})', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurface.withAlpha(180))),
              const SizedBox(height: 8),
              ...messages.map((m) {
                List<Map<String, dynamic>> msgAtts = [];
                if (m.attachmentsJson != null && m.attachmentsJson!.isNotEmpty) {
                  try {
                    final parsed = json.decode(m.attachmentsJson!);
                    if (parsed is List) {
                      msgAtts = parsed.cast<Map<String, dynamic>>();
                    }
                  } catch (_) {}
                }
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: onSurface.withAlpha(15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: m.direction == 'outbound' ? Colors.green.withAlpha(25) : Colors.blue.withAlpha(25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              m.direction == 'outbound' ? '发出' : '收到',
                              style: TextStyle(fontSize: 10, color: m.direction == 'outbound' ? Colors.green : Colors.blue, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(m.subject, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (m.senderEmail != null)
                        Text(m.senderEmail!, style: TextStyle(fontSize: 11, color: onSurface.withAlpha(120))),
                      if (m.bodyText != null && m.bodyText!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(m.bodyText!, style: TextStyle(fontSize: 12, color: onSurface.withAlpha(180)), maxLines: 5, overflow: TextOverflow.ellipsis),
                      ],
                      if (msgAtts.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        ...msgAtts.map((a) => GestureDetector(
                          onTap: a['storage_path'] != null ? () => api.openAttachmentPreview(a['storage_path'], a['filename'] ?? 'attachment') : null,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                Icon(Icons.attach_file, size: 12, color: a['storage_path'] != null ? theme.colorScheme.secondary : onSurface.withAlpha(80)),
                                const SizedBox(width: 4),
                                Text(
                                  a['filename'] ?? '附件',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: a['storage_path'] != null ? theme.colorScheme.secondary : onSurface.withAlpha(120),
                                    decoration: a['storage_path'] != null ? TextDecoration.underline : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                      const SizedBox(height: 4),
                      Text(m.occurredAt.length >= 16 ? m.occurredAt.substring(0, 16) : m.occurredAt, style: TextStyle(fontSize: 10, color: onSurface.withAlpha(80))),
                    ],
                  ),
                );
              }),
            ],

            // Timeline
            if (timeline.isNotEmpty) ...[
              Divider(height: 24, color: onSurface.withAlpha(30)),
              Text('时间线', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurface.withAlpha(180))),
              const SizedBox(height: 8),
              ...timeline.map((t) {
                IconData icon;
                Color color;
                switch (t.type) {
                  case 'transition':
                    icon = Icons.swap_horiz;
                    color = Colors.blue;
                  case 'reply':
                    icon = Icons.reply;
                    color = Colors.green;
                  case 'note':
                    icon = Icons.note;
                    color = Colors.orange;
                  case 'system':
                    icon = Icons.settings;
                    color = onSurface.withAlpha(120);
                  default:
                    icon = Icons.circle;
                    color = onSurface.withAlpha(80);
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 14, color: color),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.description, style: TextStyle(fontSize: 13, color: onSurface)),
                            Text(t.timestamp.length >= 16 ? t.timestamp.substring(0, 16) : t.timestamp, style: TextStyle(fontSize: 11, color: onSurface.withAlpha(100))),
                            if (t.detail != null && t.detail!.isNotEmpty)
                              Text(t.detail!.toString(), style: TextStyle(fontSize: 11, color: onSurface.withAlpha(120))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Reply
            if (talent['candidate_id'] != null) ...[
              Divider(height: 24, color: onSurface.withAlpha(30)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showReplyDialog(context),
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('回复候选人', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
