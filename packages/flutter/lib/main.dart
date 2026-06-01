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
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
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
  final _client = FinanceApiClient(
    'http://localhost:8000',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quanttide Finance'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Source Records',
            client: _client,
            loadRecords: _loadSourceRecords,
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Normalized Records',
            client: _client,
            loadRecords: _loadNormalizedRecords,
          ),
        ],
      ),
    );
  }

  static Future<List<dynamic>> _loadSourceRecords(
    FinanceApiClient client,
  ) async {
    final records = await client.listSourceRecords();
    return records.map((r) => _sourceRecordSummary(r)).toList();
  }

  static Future<List<dynamic>> _loadNormalizedRecords(
    FinanceApiClient client,
  ) async {
    final records = await client.listNormalizedRecords();
    return records.map((r) => _normalizedRecordSummary(r)).toList();
  }

  static Map<String, String> _sourceRecordSummary(SourceRecordDto r) {
    return {
      'id': r.id.toString(),
      'source_type': r.sourceType.name,
      'raw_text': r.rawText.length > 80
          ? '${r.rawText.substring(0, 80)}...'
          : r.rawText,
      'ingestion_status': r.ingestionStatus.name,
      'created_at': r.createdAt.toIso8601String(),
    };
  }

  static Map<String, String> _normalizedRecordSummary(NormalizedRecordDto r) {
    return {
      'id': r.id.toString(),
      'record_type': r.recordType.name,
      'amount': '${r.direction.name == 'outflow' ? '-' : ''}${r.amountCents}¢',
      'business_date': r.businessDate,
      'department': r.department ?? '-',
      'person': r.person ?? '-',
      'description': r.description.length > 60
          ? '${r.description.substring(0, 60)}...'
          : r.description,
      'created_at': r.createdAt.toIso8601String(),
    };
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.client,
    required this.loadRecords,
  });

  final String title;
  final FinanceApiClient client;
  final Future<List<dynamic>> Function(FinanceApiClient) loadRecords;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: loadRecords(client),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
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
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        final records = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (records.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No $title found.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ...records.map(
                (r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (r as Map<String, String>)
                          .entries
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      '${e.key}:',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
