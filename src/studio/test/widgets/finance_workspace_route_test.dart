import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quanttide_finance/api/client.dart';
import 'package:qtadmin_dashboard/dashboard_barrel.dart';
import 'package:qtadmin_finance/finance.dart';
import 'package:quanttide_finance/quanttide_finance.dart';
import 'package:qtadmin_studio/router.dart';

class _FakeFinanceApiClient extends FinanceApiClient {
  _FakeFinanceApiClient() : super('http://fake.api');

  @override
  Future<StatisticsSummaryResponse> getStatisticsSummary({
    String currency = 'CNY',
  }) async {
    return StatisticsSummaryResponse(
      recordCount: 8,
      amountCents: 123400,
      classifiedCount: 6,
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
      rows: [StatisticsRow(key: '运营部', count: 3, amountCents: 45600)],
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
      rows: [StatisticsTrendRow(date: '2026-06', count: 3, amountCents: 45600)],
      filters: const {'currency': 'CNY'},
    );
  }

  @override
  Future<List<NormalizedRecordDto>> listNormalizedRecords({
    int? sourceRecordId,
    int skip = 0,
    int limit = 20,
  }) async {
    return [
      NormalizedRecordDto(
        id: 1,
        recordType: RecordType.expense,
        businessDate: '2026-06-01',
        amountCents: 45600,
        direction: Direction.outflow,
        department: 'Ops',
        person: 'Li',
        description: 'server bill',
        createdAt: DateTime.utc(2026, 6, 1),
      ),
    ];
  }

  @override
  Future<List<ClassificationResultDto>> listClassifications(
    int normalizedRecordId, {
    String? reviewStatus,
  }) async {
    return const [];
  }
}

void main() {
  testWidgets('renders finance workspace screen', (tester) async {
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
          client: _FakeFinanceApiClient(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Department Breakdown'), findsOneWidget);
    expect(find.text('Review Queue'), findsOneWidget);
  });

  testWidgets('finance route uses ScreenContext financeConfig', (tester) async {
    tester.view.physicalSize = const Size(1600, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final route = RouteConfig.find('finance');
    final context = ScreenContext(
      dashboard: const Dashboard(
        businessUnits: [],
        functionCards: [],
      ),
      workspaceName: '量潮科技',
      selectedWorkspace: 0,
      financeConfig: const FinanceModuleConfig(
        apiBaseUrl: 'http://finance.internal:9000',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FinanceWorkspaceScreen(
          config: context.financeConfig,
          client: _FakeFinanceApiClient(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final built = route.builder(context);
    expect(built, isA<FinanceWorkspaceScreen>());
    expect((built as FinanceWorkspaceScreen).config.apiBaseUrl, 'http://finance.internal:9000');
  });
}
