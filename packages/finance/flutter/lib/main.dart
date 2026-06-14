import 'package:flutter/material.dart';
import 'package:quanttide_finance/quanttide_finance.dart';

import 'api/client.dart';

void main() {
  runApp(const QuanttideFinanceApp());
}

class QuanttideFinanceApp extends StatelessWidget {
  const QuanttideFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quanttide Finance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DataViewerPage(),
    );
  }
}

class DataViewerPage extends StatefulWidget {
  const DataViewerPage({super.key});

  @override
  State<DataViewerPage> createState() => _DataViewerPageState();
}

class _DataViewerPageState extends State<DataViewerPage> {
  final _client = FinanceApiClient('http://localhost:8000');

  final _sourceTypeCtrl = TextEditingController(text: 'manual');
  final _rawTextCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  int _refreshKey = 0;

  @override
  void dispose() {
    _sourceTypeCtrl.dispose();
    _rawTextCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() => _refreshKey++);

  Future<void> _createSourceRecord() async {
    try {
      await _client.createSourceRecord(
        sourceType: _sourceTypeCtrl.text,
        rawText: _rawTextCtrl.text,
      );
      _rawTextCtrl.clear();
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Source record created')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  Future<void> _normalize(int id) async {
    try {
      await _client.normalizeSourceRecord(id);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Normalized successfully')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  Future<void> _classify(int normalizedRecordId) async {
    final category = _categoryCtrl.text.trim();
    if (category.isEmpty) return;
    try {
      await _client.createClassification(
        normalizedRecordId,
        category: category,
        classifierKind: 'manual',
      );
      _categoryCtrl.clear();
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Classification created')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  Future<void> _review(int classificationId, String reviewStatus) async {
    try {
      await _client.reviewClassification(
        classificationId,
        reviewStatus: reviewStatus,
      );
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review: $reviewStatus')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quanttide Finance'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CreateForm(
            sourceTypeCtrl: _sourceTypeCtrl,
            rawTextCtrl: _rawTextCtrl,
            onCreate: _createSourceRecord,
          ),
          const SizedBox(height: 24),
          _SourceRecordsSection(
            client: _client,
            refreshKey: _refreshKey,
            onNormalize: _normalize,
          ),
          const SizedBox(height: 24),
          _NormalizedRecordsSection(
            client: _client,
            refreshKey: _refreshKey,
            onClassify: (id) => _showClassifyDialog(id),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showClassifyDialog(int normalizedRecordId) {
    _categoryCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Classification'),
        content: TextField(
          controller: _categoryCtrl,
          decoration: const InputDecoration(
            labelText: 'Category',
            hintText: 'e.g. office_supplies',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _classify(normalizedRecordId);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// ─── Create Form ────────────────────────────────────────────────────────────

class _CreateForm extends StatelessWidget {
  const _CreateForm({
    required this.sourceTypeCtrl,
    required this.rawTextCtrl,
    required this.onCreate,
  });

  final TextEditingController sourceTypeCtrl;
  final TextEditingController rawTextCtrl;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Source Record',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: sourceTypeCtrl.text,
              decoration: const InputDecoration(labelText: 'Source Type'),
              items: const [
                DropdownMenuItem(value: 'manual', child: Text('manual')),
                DropdownMenuItem(value: 'image', child: Text('image')),
                DropdownMenuItem(value: 'chat', child: Text('chat')),
                DropdownMenuItem(value: 'csv_row', child: Text('csv_row')),
                DropdownMenuItem(value: 'bank_tx', child: Text('bank_tx')),
                DropdownMenuItem(value: 'api', child: Text('api')),
                DropdownMenuItem(value: 'form', child: Text('form')),
                DropdownMenuItem(value: 'other', child: Text('other')),
              ],
              onChanged: (v) {
                if (v != null) sourceTypeCtrl.text = v;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: rawTextCtrl,
              decoration: const InputDecoration(
                labelText: 'Raw Text',
                hintText: 'Enter record content...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Source Records Section ─────────────────────────────────────────────────

class _SourceRecordsSection extends StatelessWidget {
  const _SourceRecordsSection({
    required this.client,
    required this.refreshKey,
    required this.onNormalize,
  });

  final FinanceApiClient client;
  final int refreshKey;
  final Future<void> Function(int id) onNormalize;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SourceRecordDto>>(
      key: ValueKey('src-$refreshKey'),
      future: client.listSourceRecords(),
      builder: (context, snapshot) {
        final title = 'Source Records';
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _sectionHeader(title, child: const LinearProgressIndicator());
        }
        if (snapshot.hasError) {
          return _errorSection(context, title, snapshot.error);
        }
        final records = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title, count: records.length),
            const SizedBox(height: 8),
            if (records.isEmpty) _emptyCard(title)
            else ...records.map((r) => _sourceRecordCard(context, r)),
          ],
        );
      },
    );
  }

  Widget _sourceRecordCard(BuildContext context, SourceRecordDto r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kvRow('id', r.id.toString()),
            _kvRow('source_type', r.sourceType.name),
            _kvRow('raw_text', r.rawText.length > 80
                ? '${r.rawText.substring(0, 80)}...'
                : r.rawText),
            _kvRow('ingestion_status', r.ingestionStatus.name),
            _kvRow('created_at', r.createdAt.toIso8601String()),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => onNormalize(r.id),
                icon: const Icon(Icons.transform, size: 18),
                label: const Text('Normalize'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Normalized Records Section ─────────────────────────────────────────────

class _NormalizedRecordsSection extends StatelessWidget {
  const _NormalizedRecordsSection({
    required this.client,
    required this.refreshKey,
    required this.onClassify,
  });

  final FinanceApiClient client;
  final int refreshKey;
  final void Function(int id) onClassify;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NormalizedRecordDto>>(
      key: ValueKey('nr-$refreshKey'),
      future: client.listNormalizedRecords(),
      builder: (context, snapshot) {
        final title = 'Normalized Records';
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _sectionHeader(title, child: const LinearProgressIndicator());
        }
        if (snapshot.hasError) {
          return _errorSection(context, title, snapshot.error);
        }
        final records = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title, count: records.length),
            const SizedBox(height: 8),
            if (records.isEmpty) _emptyCard(title)
            else ...records.map((r) => _normalizedRecordCard(context, r)),
          ],
        );
      },
    );
  }

  Widget _normalizedRecordCard(BuildContext context, NormalizedRecordDto r) {
    final amountYuan = r.amountCents / 100.0;
    final sign = r.direction == Direction.outflow ? '-' : '';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kvRow('id', r.id.toString()),
            _kvRow('record_type', r.recordType.name),
            _kvRow('amount', '$sign${amountYuan.toStringAsFixed(2)} 元'),
            _kvRow('business_date', r.businessDate),
            _kvRow('department', r.department ?? '-'),
            _kvRow('person', r.person ?? '-'),
            _kvRow('description', r.description.length > 60
                ? '${r.description.substring(0, 60)}...'
                : r.description),
            _kvRow('created_at', r.createdAt.toIso8601String()),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => onClassify(r.id),
                icon: const Icon(Icons.label, size: 18),
                label: const Text('Classify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Helpers ─────────────────────────────────────────────────────────

Widget _sectionHeader(String title, {int? count, Widget? child}) {
  if (child != null) return child;
  return Text(
    count != null ? '$title ($count)' : title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );
}

Widget _emptyCard(String label) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text('No $label found.'),
    ),
  );
}

Widget _errorSection(BuildContext context, String title, Object? error) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error: $error',
            style:
                TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
          ),
        ),
      ),
    ],
  );
}

Widget _kvRow(String key, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text('$key:', style: const TextStyle(fontSize: 12)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    ),
  );
}
