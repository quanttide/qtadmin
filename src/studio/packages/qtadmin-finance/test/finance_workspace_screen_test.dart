import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_finance/finance.dart';
import 'package:flutter_quanttide_finance/api/client.dart';
import 'package:quanttide_finance/quanttide_finance.dart';

class _FakeFinanceApiClient extends FinanceApiClient {
  _FakeFinanceApiClient() : super('http://fake.api');

  final List<SourceRecordDto> createdSources = [];
  final List<(int id, String description, int amountCents)> updatedRecords = [];
  final List<(int normalizedRecordId, String category, String reviewStatus)>
      bulkReviewLog = [];
  final List<NormalizedRecordDto> normalizedRecords = [
    NormalizedRecordDto(
      id: 41,
      recordType: RecordType.expense,
      businessDate: '2026-06-01',
      amountCents: 18800,
      direction: Direction.outflow,
      department: 'Finance',
      person: 'Lin',
      description: 'taxi to airport',
      createdAt: DateTime.utc(2026, 6, 1),
    ),
    NormalizedRecordDto(
      id: 42,
      recordType: RecordType.expense,
      businessDate: '2026-06-02',
      amountCents: 3200,
      direction: Direction.outflow,
      department: 'Marketing',
      person: 'Chen',
      description: 'coffee beans',
      createdAt: DateTime.utc(2026, 6, 2),
    ),
  ];
  final Map<int, List<ClassificationResultDto>> classifications = {
    41: [
      ClassificationResultDto(
        id: 7,
        normalizedRecordId: 41,
        taxonomy: 'expense_type',
        category: '差旅',
        classifierKind: ClassifierKind.manual,
        reviewStatus: ReviewStatus.candidate,
        isActive: true,
        createdAt: DateTime.utc(2026, 6, 1),
        updatedAt: DateTime.utc(2026, 6, 1),
      ),
    ],
    42: [],
  };

  @override
  Future<StatisticsSummaryResponse> getStatisticsSummary({
    String currency = 'CNY',
  }) async {
    return StatisticsSummaryResponse(
      recordCount: 12,
      amountCents: 345600,
      classifiedCount: 9,
      filters: const {'currency': 'CNY'},
    );
  }

  @override
  Future<StatisticsBreakdownResponse> getStatisticsBreakdown({
    required String dimension,
    String currency = 'CNY',
  }) async {
    return StatisticsBreakdownResponse(
      dimension: dimension,
      rows: [
        StatisticsRow(key: '财务部', count: 4, amountCents: 120000),
        StatisticsRow(key: '市场部', count: 2, amountCents: 80000),
      ],
      filters: const {'currency': 'CNY'},
    );
  }

  @override
  Future<StatisticsTrendResponse> getStatisticsTrend({
    String granularity = 'month',
    String currency = 'CNY',
  }) async {
    return StatisticsTrendResponse(
      granularity: granularity,
      rows: [
        StatisticsTrendRow(date: '2026-04', count: 3, amountCents: 100000),
        StatisticsTrendRow(date: '2026-05', count: 5, amountCents: 160000),
      ],
      filters: const {'currency': 'CNY'},
    );
  }

  @override
  Future<List<NormalizedRecordDto>> listNormalizedRecords({
    int? sourceRecordId,
    int skip = 0,
    int limit = 20,
  }) async {
    return normalizedRecords;
  }

  @override
  Future<List<ClassificationResultDto>> listClassifications(
    int normalizedRecordId, {
    String? reviewStatus,
  }) async {
    return classifications[normalizedRecordId] ?? const [];
  }

  @override
  Future<SourceRecordDto> createSourceRecord({
    required String sourceType,
    String? sourceChannel,
    String rawText = '',
    String ingestionStatus = 'pending',
  }) async {
    final created = SourceRecordDto(
      id: 101,
      sourceType: SourceType.manual,
      rawText: rawText,
      ingestionStatus: IngestionStatus.pending,
      createdAt: DateTime.utc(2026, 6, 12),
    );
    createdSources.add(created);
    return created;
  }

  @override
  Future<NormalizedRecordDto> createNormalizedRecord({
    int? primarySourceId,
    required String recordType,
    required String businessDate,
    required int amountCents,
    String currency = 'CNY',
    required String direction,
    String? department,
    String? person,
    String? counterparty,
    String description = '',
    String normalizationStatus = 'draft',
  }) async {
    final created = NormalizedRecordDto(
      id: 102,
      recordType: RecordType.expense,
      businessDate: businessDate,
      amountCents: amountCents,
      direction: Direction.outflow,
      department: department,
      person: person,
      description: description,
      createdAt: DateTime.utc(2026, 6, 12),
    );
    normalizedRecords.add(created);
    classifications[created.id] = [];
    return created;
  }

  @override
  Future<ClassificationResultDto> createClassification(
    int normalizedRecordId, {
    required String category,
    required String classifierKind,
    String taxonomy = 'expense_type',
    double? confidence,
    String? modelVersion,
    Map<String, dynamic>? tags,
  }) async {
    final created = ClassificationResultDto(
      id: 900 + normalizedRecordId,
      normalizedRecordId: normalizedRecordId,
      taxonomy: taxonomy,
      category: category,
      classifierKind: ClassifierKind.manual,
      reviewStatus: ReviewStatus.candidate,
      isActive: true,
      createdAt: DateTime.utc(2026, 6, 12),
      updatedAt: DateTime.utc(2026, 6, 12),
    );
    classifications[normalizedRecordId] = [created];
    return created;
  }

  @override
  Future<ClassificationResultDto> reviewClassification(
    int id, {
    String? reviewStatus,
    bool? isActive,
  }) async {
    for (final entry in classifications.entries) {
      final index = entry.value.indexWhere((item) => item.id == id);
      if (index >= 0) {
        final current = entry.value[index];
        final updated = current.copyWith(
          reviewStatus: reviewStatus == 'accepted'
              ? ReviewStatus.accepted
              : reviewStatus == 'rejected'
                  ? ReviewStatus.rejected
                  : current.reviewStatus,
          isActive: isActive ?? current.isActive,
        );
        entry.value[index] = updated;
        bulkReviewLog.add((
          current.normalizedRecordId,
          current.category,
          reviewStatus ?? current.reviewStatus.name,
        ));
        return updated;
      }
    }
    throw ApiException('Classification not found', statusCode: 404);
  }

  @override
  Future<NormalizedRecordDto> updateNormalizedRecord(
    int id, {
    String? recordType,
    String? businessDate,
    int? amountCents,
    String? currency,
    String? direction,
    String? department,
    String? person,
    String? counterparty,
    String? description,
    String? normalizationStatus,
  }) async {
    final index = normalizedRecords.indexWhere((record) => record.id == id);
    if (index < 0) {
      throw ApiException('Normalized record not found', statusCode: 404);
    }
    final current = normalizedRecords[index];
    final updated = current.copyWith(
      businessDate: businessDate ?? current.businessDate,
      amountCents: amountCents ?? current.amountCents,
      department: department ?? current.department,
      person: person ?? current.person,
      description: description ?? current.description,
    );
    normalizedRecords[index] = updated;
    updatedRecords.add((id, updated.description, updated.amountCents));
    return updated;
  }
}

void main() {
  testWidgets('renders finance statistics workspace', (tester) async {
    final client = _FakeFinanceApiClient();
    tester.view.physicalSize = const Size(1600, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: FinanceWorkspaceScreen(
          config: const FinanceModuleConfig(apiBaseUrl: 'http://localhost:8000'),
          client: client,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Department Breakdown'), findsOneWidget);
    expect(find.text('Monthly Trend'), findsOneWidget);
    expect(find.text('Manual Entry'), findsOneWidget);
    expect(find.text('Review Queue'), findsWidgets);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('¥3,456.00'), findsOneWidget);
    expect(find.text('财务部'), findsOneWidget);
    expect(find.text('2026-05'), findsOneWidget);
    expect(find.text('taxi to airport'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '出差打车票据');
    await tester.enterText(find.byType(TextField).at(2), '18800');
    await tester.enterText(find.byType(TextField).at(5), '差旅打车费用');
    await tester.tap(find.text('提交录入'));
    await tester.pumpAndSettle();

    expect(client.createdSources, hasLength(1));
    expect(find.text('录入成功。'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).at(0));
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pumpAndSettle();

    expect(find.text('已选 2 条'), findsOneWidget);
    await tester.tap(find.text('批量确认'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('批量确认').last);
    await tester.pumpAndSettle();

    expect(client.bulkReviewLog.length, 2);
    expect(
      client.bulkReviewLog.every((entry) => entry.$3 == 'accepted'),
      isTrue,
    );

    await tester.tap(find.text('编辑').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Editing #41'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(2), '25600');
    await tester.enterText(find.byType(TextField).at(5), 'updated taxi');
    await tester.tap(find.text('保存修改'));
    await tester.pumpAndSettle();

    expect(client.updatedRecords, hasLength(1));
    expect(client.updatedRecords.first.$1, 41);
    expect(client.updatedRecords.first.$2, 'updated taxi');
    expect(client.updatedRecords.first.$3, 25600);
  });

  testWidgets('shows validation message for invalid manual entry', (tester) async {
    final client = _FakeFinanceApiClient();
    tester.view.physicalSize = const Size(1600, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: FinanceWorkspaceScreen(
          config: const FinanceModuleConfig(apiBaseUrl: 'http://localhost:8000'),
          client: client,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '');
    await tester.enterText(find.byType(TextField).at(1), '2026/06/12');
    await tester.enterText(find.byType(TextField).at(2), '-10');
    await tester.enterText(find.byType(TextField).at(5), '');
    await tester.tap(find.text('提交录入'));
    await tester.pumpAndSettle();

    expect(find.text('Raw Text 不能为空。'), findsOneWidget);
    expect(client.createdSources, isEmpty);
  });
}
