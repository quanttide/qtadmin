import 'package:flutter/material.dart';
import 'package:flutter_quanttide_finance/api/client.dart';
import 'package:quanttide_finance/quanttide_finance.dart';

import '../config/finance_module_config.dart';

const _expenseCategories = <String>[
  '办公用品',
  '差旅',
  '采购',
  '工资',
  '其他',
];

class FinanceWorkspaceScreen extends StatefulWidget {
  const FinanceWorkspaceScreen({
    super.key,
    required this.config,
    this.client,
  });

  final FinanceModuleConfig config;
  final FinanceApiClient? client;

  @override
  State<FinanceWorkspaceScreen> createState() => _FinanceWorkspaceScreenState();
}

class _FinanceWorkspaceScreenState extends State<FinanceWorkspaceScreen> {
  late Future<_FinanceWorkspaceData> _future;
  final Set<int> _selectedReviewRecordIds = <int>{};

  final _rawTextController = TextEditingController();
  final _dateController = TextEditingController(text: '2026-06-12');
  final _amountController = TextEditingController();
  final _departmentController = TextEditingController();
  final _personController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _recordType = 'expense';
  String _direction = 'outflow';
  int? _editingNormalizedRecordId;

  FinanceApiClient get _client =>
      widget.client ?? FinanceApiClient(widget.config.apiBaseUrl);

  @override
  void initState() {
    super.initState();
    _future = _loadWorkspace();
  }

  @override
  void dispose() {
    _rawTextController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _departmentController.dispose();
    _personController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<_FinanceWorkspaceData> _loadWorkspace() async {
    final summaryFuture = _client.getStatisticsSummary();
    final breakdownFuture = _client.getStatisticsBreakdown(
      dimension: 'department',
    );
    final trendFuture = _client.getStatisticsTrend();
    final normalizedFuture = _client.listNormalizedRecords(limit: 50);

    final summary = await summaryFuture;
    final breakdown = await breakdownFuture;
    final trend = await trendFuture;
    final normalized = await normalizedFuture;

    final reviewItems = <_ReviewItem>[];
    for (final record in normalized) {
      final classifications = await _client.listClassifications(record.id);
      ClassificationResultDto? latest;
      if (classifications.isNotEmpty) {
        latest = classifications.first;
      }
      reviewItems.add(
        _ReviewItem(
          record: record,
          latestClassification: latest,
          sourceHint: record.description,
        ),
      );
    }

    return _FinanceWorkspaceData(
      summary: summary,
      breakdown: breakdown,
      trend: trend,
      reviewItems: reviewItems,
    );
  }

  void _reload() {
    setState(() {
      _future = _loadWorkspace();
      _selectedReviewRecordIds.clear();
    });
  }

  Future<void> _submitManualRecord() async {
    final validationMessage = _validateEntryForm();
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }
    final amount = int.parse(_amountController.text.trim());

    try {
      if (_editingNormalizedRecordId != null) {
        await _client.updateNormalizedRecord(
          _editingNormalizedRecordId!,
          recordType: _recordType,
          businessDate: _dateController.text.trim(),
          amountCents: amount,
          direction: _direction,
          department: _departmentController.text.trim(),
          person: _personController.text.trim(),
          description: _descriptionController.text.trim(),
          normalizationStatus: 'reviewed',
        );
        _showMessage('记录已更新。');
      } else {
        final source = await _client.createSourceRecord(
          sourceType: 'manual',
          rawText: _rawTextController.text.trim(),
        );

        await _client.createNormalizedRecord(
          primarySourceId: source.id,
          recordType: _recordType,
          businessDate: _dateController.text.trim(),
          amountCents: amount,
          direction: _direction,
          department: _departmentController.text.trim(),
          person: _personController.text.trim(),
          description: _descriptionController.text.trim(),
          normalizationStatus: 'normalized',
        );
        _showMessage('录入成功。');
      }

      _resetEntryForm();
      _reload();
    } on ApiException catch (error) {
      final action = _editingNormalizedRecordId != null ? '更新失败' : '录入失败';
      _showMessage('$action: ${error.message}');
    }
  }

  String? _validateEntryForm() {
    final rawText = _rawTextController.text.trim();
    final date = _dateController.text.trim();
    final amountText = _amountController.text.trim();
    final description = _descriptionController.text.trim();

    if (_editingNormalizedRecordId == null && rawText.isEmpty) {
      return 'Raw Text 不能为空。';
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      return 'Business Date 必须是 YYYY-MM-DD。';
    }
    final amount = int.tryParse(amountText);
    if (amount == null) {
      return '金额必须是整数分。';
    }
    if (amount < 0) {
      return '金额不能为负数。';
    }
    if (description.isEmpty) {
      return 'Description 不能为空。';
    }
    return null;
  }

  void _startEditingRecord(_ReviewItem item) {
    final record = item.record;
    setState(() {
      _editingNormalizedRecordId = record.id;
      _rawTextController.text = item.sourceHint;
      _dateController.text = record.businessDate;
      _amountController.text = record.amountCents.toString();
      _departmentController.text = record.department ?? '';
      _personController.text = record.person ?? '';
      _descriptionController.text = record.description;
      _recordType = record.recordType.name;
      _direction = record.direction.name;
    });
    _showMessage('已载入编辑表单。');
  }

  void _resetEntryForm() {
    setState(() {
      _editingNormalizedRecordId = null;
      _rawTextController.clear();
      _dateController.text = '2026-06-12';
      _amountController.clear();
      _departmentController.clear();
      _personController.clear();
      _descriptionController.clear();
      _recordType = 'expense';
      _direction = 'outflow';
    });
  }

  Future<void> _applyReview(
    _ReviewItem item, {
    required String category,
    required String reviewStatus,
  }) async {
    try {
      final current = item.latestClassification;
      if (current == null) {
        final created = await _client.createClassification(
          item.record.id,
          category: category,
          classifierKind: 'manual',
        );
        await _client.reviewClassification(
          created.id,
          reviewStatus: reviewStatus,
        );
      } else {
        if (current.category != category) {
          final created = await _client.createClassification(
            item.record.id,
            category: category,
            classifierKind: 'manual',
          );
          await _client.reviewClassification(
            created.id,
            reviewStatus: reviewStatus,
          );
        } else {
          await _client.reviewClassification(
            current.id,
            reviewStatus: reviewStatus,
          );
        }
      }

      _showMessage('审核已更新。');
      _reload();
    } on ApiException catch (error) {
      _showMessage('审核失败: ${error.message}');
    }
  }

  Future<void> _applyBulkReview({
    required List<_ReviewItem> items,
    required String category,
    required String reviewStatus,
  }) async {
    if (items.isEmpty) {
      _showMessage('请先选择记录。');
      return;
    }

    try {
      for (final item in items) {
        final current = item.latestClassification;
        if (current == null || current.category != category) {
          final created = await _client.createClassification(
            item.record.id,
            category: category,
            classifierKind: 'manual',
          );
          await _client.reviewClassification(
            created.id,
            reviewStatus: reviewStatus,
          );
        } else {
          await _client.reviewClassification(
            current.id,
            reviewStatus: reviewStatus,
          );
        }
      }

      _showMessage('批量审核完成。');
      _reload();
    } on ApiException catch (error) {
      _showMessage('批量审核失败: ${error.message}');
    }
  }

  void _showReviewDialog(_ReviewItem item) {
    String selectedCategory =
        item.latestClassification?.category ?? _expenseCategories.first;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('审核分类'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.record.description.isEmpty
                      ? '无描述'
                      : item.record.description),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: '分类'),
                    items: _expenseCategories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyReview(
                      item,
                      category: selectedCategory,
                      reviewStatus: 'rejected',
                    );
                  },
                  child: const Text('驳回'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyReview(
                      item,
                      category: selectedCategory,
                      reviewStatus: 'accepted',
                    );
                  },
                  child: const Text('确认'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBulkReviewDialog(List<_ReviewItem> selectedItems) {
    String selectedCategory = _expenseCategories.first;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('批量审核 ${selectedItems.length} 条'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('统一设置分类并批量确认。'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: '分类'),
                    items: _expenseCategories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyBulkReview(
                      items: selectedItems,
                      category: selectedCategory,
                      reviewStatus: 'accepted',
                    );
                  },
                  child: const Text('批量确认'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E8),
      body: SafeArea(
        child: FutureBuilder<_FinanceWorkspaceData>(
          future: _future,
          builder: (context, snapshot) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 32,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _WorkspaceHeader(
                            config: widget.config,
                            apiBaseUrl: _client.baseUrl,
                            onReload: _reload,
                          ),
                          const SizedBox(height: 20),
                          if (snapshot.connectionState == ConnectionState.waiting)
                            const _LoadingPanel()
                          else if (snapshot.hasError)
                            _ErrorPanel(
                              message: snapshot.error.toString(),
                              onRetry: _reload,
                            )
                          else if (!snapshot.hasData)
                            _ErrorPanel(
                              message: 'Finance workspace returned no data.',
                              onRetry: _reload,
                            )
                          else
                            _WorkspaceBody(
                              data: snapshot.data!,
                              rawTextController: _rawTextController,
                              dateController: _dateController,
                              amountController: _amountController,
                              departmentController: _departmentController,
                              personController: _personController,
                              descriptionController: _descriptionController,
                              recordType: _recordType,
                              direction: _direction,
                              onRecordTypeChanged: (value) {
                                setState(() {
                                  _recordType = value;
                                });
                              },
                              onDirectionChanged: (value) {
                                setState(() {
                                  _direction = value;
                                });
                              },
                              onSubmitManualRecord: _submitManualRecord,
                              editingNormalizedRecordId: _editingNormalizedRecordId,
                              onCancelEditing: _resetEntryForm,
                              onOpenReviewDialog: _showReviewDialog,
                              onStartEditingRecord: _startEditingRecord,
                              selectedReviewRecordIds: _selectedReviewRecordIds,
                              onToggleReviewSelection: (recordId, selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedReviewRecordIds.add(recordId);
                                  } else {
                                    _selectedReviewRecordIds.remove(recordId);
                                  }
                                });
                              },
                              onOpenBulkReviewDialog: _showBulkReviewDialog,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FinanceWorkspaceData {
  const _FinanceWorkspaceData({
    required this.summary,
    required this.breakdown,
    required this.trend,
    required this.reviewItems,
  });

  final StatisticsSummaryResponse summary;
  final StatisticsBreakdownResponse breakdown;
  final StatisticsTrendResponse trend;
  final List<_ReviewItem> reviewItems;
}

class _ReviewItem {
  const _ReviewItem({
    required this.record,
    required this.latestClassification,
    required this.sourceHint,
  });

  final NormalizedRecordDto record;
  final ClassificationResultDto? latestClassification;
  final String sourceHint;
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.config,
    required this.apiBaseUrl,
    required this.onReload,
  });

  final FinanceModuleConfig config;
  final String apiBaseUrl;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Finance',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: Color(0xFF1E2A24),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manual entry, review queue, and live statistics for normalized finance records.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF55615B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.tonalIcon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('刷新'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricChip(label: 'API Base URL', value: apiBaseUrl),
            _MetricChip(
              label: 'Review Queue',
              value: config.enableReviewQueue ? 'enabled' : 'disabled',
            ),
            _MetricChip(
              label: 'Statistics',
              value: config.enableStatistics ? 'enabled' : 'disabled',
            ),
          ],
        ),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Loading finance workspace...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFC6452D)),
              const SizedBox(height: 12),
              const Text(
                'Finance workspace load failed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF735B53)),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceBody extends StatelessWidget {
  const _WorkspaceBody({
    required this.data,
    required this.rawTextController,
    required this.dateController,
    required this.amountController,
    required this.departmentController,
    required this.personController,
    required this.descriptionController,
    required this.recordType,
    required this.direction,
    required this.onRecordTypeChanged,
    required this.onDirectionChanged,
    required this.onSubmitManualRecord,
    required this.editingNormalizedRecordId,
    required this.onCancelEditing,
    required this.onOpenReviewDialog,
    required this.onStartEditingRecord,
    required this.selectedReviewRecordIds,
    required this.onToggleReviewSelection,
    required this.onOpenBulkReviewDialog,
  });

  final _FinanceWorkspaceData data;
  final TextEditingController rawTextController;
  final TextEditingController dateController;
  final TextEditingController amountController;
  final TextEditingController departmentController;
  final TextEditingController personController;
  final TextEditingController descriptionController;
  final String recordType;
  final String direction;
  final ValueChanged<String> onRecordTypeChanged;
  final ValueChanged<String> onDirectionChanged;
  final Future<void> Function() onSubmitManualRecord;
  final int? editingNormalizedRecordId;
  final VoidCallback onCancelEditing;
  final void Function(_ReviewItem item) onOpenReviewDialog;
  final void Function(_ReviewItem item) onStartEditingRecord;
  final Set<int> selectedReviewRecordIds;
  final void Function(int recordId, bool selected) onToggleReviewSelection;
  final void Function(List<_ReviewItem> items) onOpenBulkReviewDialog;

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;
    final breakdownRows = data.breakdown.rows.take(5).toList();
    final trendRows = data.trend.rows.take(6).toList();

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(
                  title: 'Records',
                  value: '${summary.recordCount}',
                  note: 'Normalized records in current scope',
                  accent: const Color(0xFFE3EEE8),
                ),
                _StatCard(
                  title: 'Amount',
                  value: _formatCurrency(summary.amountCents),
                  note: 'Aggregated from statistics summary',
                  accent: const Color(0xFFF3E8D7),
                ),
                _StatCard(
                  title: 'Classified',
                  value: '${summary.classifiedCount}',
                  note: 'Accepted classifications in reporting scope',
                  accent: const Color(0xFFE7EEF8),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Panel(
                    title: 'Manual Entry',
                    subtitle: 'Create a source record and normalized record together',
                    child: _EntryForm(
                      rawTextController: rawTextController,
                      dateController: dateController,
                      amountController: amountController,
                      departmentController: departmentController,
                      personController: personController,
                      descriptionController: descriptionController,
                      recordType: recordType,
                      direction: direction,
                      onRecordTypeChanged: onRecordTypeChanged,
                      onDirectionChanged: onDirectionChanged,
                      onSubmit: onSubmitManualRecord,
                      editingNormalizedRecordId: editingNormalizedRecordId,
                      onCancelEditing: onCancelEditing,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Panel(
                    title: 'Review Queue',
                    subtitle: 'Review normalized records and accept manual categories',
                    child: _ReviewQueue(
                      items: data.reviewItems,
                      onOpenReviewDialog: onOpenReviewDialog,
                      onStartEditingRecord: onStartEditingRecord,
                      selectedReviewRecordIds: selectedReviewRecordIds,
                      onToggleSelection: onToggleReviewSelection,
                      onOpenBulkReviewDialog: onOpenBulkReviewDialog,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Panel(
                    title: 'Department Breakdown',
                    subtitle: 'Top departments by amount',
                    child: breakdownRows.isEmpty
                        ? const Text('No breakdown data available.')
                        : Column(
                            children: [
                              for (final row in breakdownRows)
                                _BreakdownRowTile(row: row),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Panel(
                    title: 'Monthly Trend',
                    subtitle: 'Recent amount and count movement',
                    child: trendRows.isEmpty
                        ? const Text('No trend data available.')
                        : Column(
                            children: [
                              for (final row in trendRows)
                                _TrendRowTile(row: row),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Panel(
              title: 'Reporting Scope',
              subtitle: 'Validated backend filter payload',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final entry in data.summary.filters.entries)
                    _FilterPill(label: entry.key, value: '${entry.value}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryForm extends StatelessWidget {
  const _EntryForm({
    required this.rawTextController,
    required this.dateController,
    required this.amountController,
    required this.departmentController,
    required this.personController,
    required this.descriptionController,
    required this.recordType,
    required this.direction,
    required this.onRecordTypeChanged,
    required this.onDirectionChanged,
    required this.onSubmit,
    required this.editingNormalizedRecordId,
    required this.onCancelEditing,
  });

  final TextEditingController rawTextController;
  final TextEditingController dateController;
  final TextEditingController amountController;
  final TextEditingController departmentController;
  final TextEditingController personController;
  final TextEditingController descriptionController;
  final String recordType;
  final String direction;
  final ValueChanged<String> onRecordTypeChanged;
  final ValueChanged<String> onDirectionChanged;
  final Future<void> Function() onSubmit;
  final int? editingNormalizedRecordId;
  final VoidCallback onCancelEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (editingNormalizedRecordId != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  'Editing #$editingNormalizedRecordId',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7B5C28),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onCancelEditing,
                  child: const Text('取消编辑'),
                ),
              ],
            ),
          ),
        TextField(
          controller: rawTextController,
          decoration: const InputDecoration(
            labelText: 'Raw Text',
            hintText: '打车到机场，188 元，王琳提交',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Business Date'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount Cents'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: recordType,
                decoration: const InputDecoration(labelText: 'Record Type'),
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('expense')),
                  DropdownMenuItem(value: 'income', child: Text('income')),
                  DropdownMenuItem(value: 'transfer', child: Text('transfer')),
                  DropdownMenuItem(
                    value: 'reimbursement',
                    child: Text('reimbursement'),
                  ),
                  DropdownMenuItem(value: 'other', child: Text('other')),
                ],
                onChanged: (value) {
                  if (value != null) onRecordTypeChanged(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: direction,
                decoration: const InputDecoration(labelText: 'Direction'),
                items: const [
                  DropdownMenuItem(value: 'outflow', child: Text('outflow')),
                  DropdownMenuItem(value: 'inflow', child: Text('inflow')),
                ],
                onChanged: (value) {
                  if (value != null) onDirectionChanged(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: personController,
                decoration: const InputDecoration(labelText: 'Person'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: '差旅打车费用',
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onSubmit,
            icon: Icon(
              editingNormalizedRecordId == null
                  ? Icons.add_card_outlined
                  : Icons.save_outlined,
            ),
            label: Text(
              editingNormalizedRecordId == null ? '提交录入' : '保存修改',
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewQueue extends StatelessWidget {
  const _ReviewQueue({
    required this.items,
    required this.onOpenReviewDialog,
    required this.onStartEditingRecord,
    required this.selectedReviewRecordIds,
    required this.onToggleSelection,
    required this.onOpenBulkReviewDialog,
  });

  final List<_ReviewItem> items;
  final void Function(_ReviewItem item) onOpenReviewDialog;
  final void Function(_ReviewItem item) onStartEditingRecord;
  final Set<int> selectedReviewRecordIds;
  final void Function(int recordId, bool selected) onToggleSelection;
  final void Function(List<_ReviewItem> items) onOpenBulkReviewDialog;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('No normalized records available for review.');
    }

    final selectedItems = items
        .where((item) => selectedReviewRecordIds.contains(item.record.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '已选 ${selectedItems.length} 条',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF55615B),
              ),
            ),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: selectedItems.isEmpty
                  ? null
                  : () => onOpenBulkReviewDialog(selectedItems),
              icon: const Icon(Icons.done_all_outlined, size: 18),
              label: const Text('批量确认'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final item in items.take(8))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E1D6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: selectedReviewRecordIds.contains(item.record.id),
                        onChanged: (value) {
                          onToggleSelection(item.record.id, value ?? false);
                        },
                      ),
                      Expanded(
                        child: Text(
                          item.record.description.isEmpty
                              ? 'Record #${item.record.id}'
                              : item.record.description,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E2A24),
                          ),
                        ),
                      ),
                      Text(
                        _reviewStatusLabel(item.latestClassification?.reviewStatus),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A736E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.record.businessDate} · ${_formatCurrency(item.record.amountCents)} · ${item.record.department ?? '未分配部门'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF55615B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Current category: ${item.latestClassification?.category ?? '未分类'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF55615B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => onStartEditingRecord(item),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('编辑'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => onOpenReviewDialog(item),
                          icon: const Icon(Icons.fact_check_outlined, size: 18),
                          label: const Text('审核'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8D7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A7558),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D352F),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.note,
    required this.accent,
  });

  final String title;
  final String value;
  final String note;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5B635F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E2A24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF5B635F),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2A24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6A736E),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BreakdownRowTile extends StatelessWidget {
  const _BreakdownRowTile({
    required this.row,
  });

  final StatisticsRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.key ?? 'Unassigned',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF27312B),
              ),
            ),
          ),
          Text(
            '${row.count} records',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6A736E),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _formatCurrency(row.amountCents),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF27312B),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendRowTile extends StatelessWidget {
  const _TrendRowTile({
    required this.row,
  });

  final StatisticsTrendRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              row.date,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF27312B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${row.count} records',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6A736E),
              ),
            ),
          ),
          Text(
            _formatCurrency(row.amountCents),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF27312B),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2DDD4)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4B554F),
        ),
      ),
    );
  }
}

String _reviewStatusLabel(ReviewStatus? status) {
  switch (status) {
    case ReviewStatus.accepted:
      return 'accepted';
    case ReviewStatus.rejected:
      return 'rejected';
    case ReviewStatus.candidate:
      return 'candidate';
    case ReviewStatus.unknown:
      return 'unknown';
    case null:
      return 'unreviewed';
  }
}

String _formatCurrency(int? amountCents) {
  final cents = amountCents ?? 0;
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final yuan = absolute ~/ 100;
  final remainder = absolute % 100;
  final yuanString = yuan.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  final decimal = remainder.toString().padLeft(2, '0');
  return '$sign¥$yuanString.$decimal';
}
