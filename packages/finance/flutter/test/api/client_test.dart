import 'dart:convert';

import 'package:flutter_quanttide_finance/api/client.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quanttide_finance/quanttide_finance.dart';
import 'package:flutter_test/flutter_test.dart';

import 'client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  const baseUrl = 'http://test.api';
  late FinanceApiClient client;
  late MockClient mockHttp;

  setUp(() {
    mockHttp = MockClient();
    client = FinanceApiClient(baseUrl, httpClient: mockHttp);
  });

  group('listSourceRecords', () {
    test('returns list of SourceRecordDto on 200', () async {
      when(mockHttp.get(any)).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {
              'id': 1,
              'source_type': 'image',
              'raw_text': 'receipt photo',
              'ingestion_status': 'parsed',
              'created_at': '2026-05-01T00:00:00Z',
            },
          ]),
          200,
        ),
      );

      final records = await client.listSourceRecords();
      expect(records, hasLength(1));
      expect(records.first.id, 1);
      expect(records.first.sourceType, SourceType.image);
      expect(records.first.ingestionStatus, IngestionStatus.parsed);

      final captured = verify(mockHttp.get(captureAny)).captured.first as Uri;
      expect(captured.path, '/source-records');
    });

    test('passes skip and limit query parameters', () async {
      when(
        mockHttp.get(any),
      ).thenAnswer((_) async => http.Response(jsonEncode([]), 200));

      await client.listSourceRecords(skip: 10, limit: 5);

      final captured = verify(mockHttp.get(captureAny)).captured.first as Uri;
      expect(captured.path, '/source-records');
      expect(captured.queryParameters['skip'], '10');
      expect(captured.queryParameters['limit'], '5');
    });

    test('throws ApiException on non-200', () async {
      when(
        mockHttp.get(any),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => client.listSourceRecords(), throwsA(isA<ApiException>()));
    });

    test('returns empty list when no records exist', () async {
      when(
        mockHttp.get(any),
      ).thenAnswer((_) async => http.Response(jsonEncode([]), 200));

      final records = await client.listSourceRecords();
      expect(records, isEmpty);
    });
  });

  group('getSourceRecord', () {
    test('returns SourceRecordDto on 200', () async {
      when(mockHttp.get(any)).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 42,
            'source_type': 'manual',
            'raw_text': 'manual entry',
            'ingestion_status': 'pending',
            'created_at': '2026-05-15T12:00:00Z',
          }),
          200,
        ),
      );

      final record = await client.getSourceRecord(42);
      expect(record.id, 42);
      expect(record.sourceType, SourceType.manual);

      final captured = verify(mockHttp.get(captureAny)).captured.first as Uri;
      expect(captured.path, '/source-records/42');
    });

    test('throws ApiException on 404', () async {
      when(
        mockHttp.get(any),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => client.getSourceRecord(999), throwsA(isA<ApiException>()));
    });
  });

  group('listNormalizedRecords', () {
    test('returns list of NormalizedRecordDto on 200', () async {
      when(mockHttp.get(any)).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {
              'id': 1,
              'record_type': 'expense',
              'business_date': '2026-05-01',
              'amount_cents': 5000,
              'direction': 'outflow',
              'description': 'office supplies',
              'created_at': '2026-05-01T00:00:00Z',
            },
          ]),
          200,
        ),
      );

      final records = await client.listNormalizedRecords();
      expect(records, hasLength(1));
      expect(records.first.id, 1);
      expect(records.first.recordType, RecordType.expense);
      expect(records.first.direction, Direction.outflow);

      final captured = verify(mockHttp.get(captureAny)).captured.first as Uri;
      expect(captured.path, '/normalized-records');
    });

    test('includes source_record_id query param when provided', () async {
      when(
        mockHttp.get(any),
      ).thenAnswer((_) async => http.Response(jsonEncode([]), 200));

      await client.listNormalizedRecords(sourceRecordId: 7);

      final captured = verify(mockHttp.get(captureAny)).captured.first as Uri;
      expect(captured.path, '/normalized-records');
      expect(captured.queryParameters['source_record_id'], '7');
    });

    test('throws ApiException on non-200', () async {
      when(
        mockHttp.get(any),
      ).thenAnswer((_) async => http.Response('Server Error', 500));

      expect(
        () => client.listNormalizedRecords(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('getNormalizedRecord', () {
    test('returns NormalizedRecordDto on 200', () async {
      when(mockHttp.get(any)).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 5,
            'record_type': 'income',
            'business_date': '2026-05-10',
            'amount_cents': 1000000,
            'direction': 'inflow',
            'department': 'Engineering',
            'person': 'Alice',
            'description': 'monthly salary',
            'created_at': '2026-05-10T08:00:00Z',
          }),
          200,
        ),
      );

      final record = await client.getNormalizedRecord(5);
      expect(record.id, 5);
      expect(record.recordType, RecordType.income);
      expect(record.direction, Direction.inflow);
      expect(record.department, 'Engineering');
      expect(record.person, 'Alice');

      final captured = verify(mockHttp.get(captureAny)).captured.first as Uri;
      expect(captured.path, '/normalized-records/5');
    });

    test('throws ApiException on 404', () async {
      when(
        mockHttp.get(any),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => client.getNormalizedRecord(999),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ApiException', () {
    test('toString includes status code and message', () {
      final ex = ApiException('test error', statusCode: 500);
      expect(ex.toString(), contains('500'));
      expect(ex.toString(), contains('test error'));
    });

    test('toString handles missing status code', () {
      final ex = ApiException('network error');
      expect(ex.toString(), contains('network error'));
    });
  });

  group('createSourceRecord', () {
    test('returns SourceRecordDto on 201', () async {
      when(mockHttp.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 1,
            'source_type': 'manual',
            'raw_text': 'test record',
            'ingestion_status': 'pending',
            'created_at': '2026-06-01T00:00:00Z',
          }),
          201,
        ),
      );

      final record = await client.createSourceRecord(
        sourceType: 'manual',
        rawText: 'test record',
      );

      expect(record.id, 1);
      expect(record.sourceType, SourceType.manual);
      expect(record.rawText, 'test record');

      final captured = verify(mockHttp.post(captureAny, headers: anyNamed('headers'), body: anyNamed('body'))).captured.first as Uri;
      expect(captured.path, '/source-records');
    });

    test('throws ApiException on non-201', () async {
      when(mockHttp.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Bad Request', 400));

      expect(
        () => client.createSourceRecord(sourceType: 'manual', rawText: ''),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('normalizeSourceRecord', () {
    test('returns list of NormalizedRecordDto on 200', () async {
      when(mockHttp.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
                jsonEncode([
                  {
                    'id': 1,
                    'record_type': 'expense',
                    'business_date': '2026-06-01',
                    'amount_cents': 5000,
                    'direction': 'outflow',
                    'description': 'test expense',
                    'created_at': '2026-06-01T00:00:00Z',
                  },
                ]),
                200,
              ));

      final records = await client.normalizeSourceRecord(1);
      expect(records, hasLength(1));
      expect(records.first.recordType, RecordType.expense);

      final captured = verify(mockHttp.post(captureAny, headers: anyNamed('headers'), body: anyNamed('body'))).captured.first as Uri;
      expect(captured.path, '/source-records/1/normalize');
    });

    test('throws ApiException on 404', () async {
      when(mockHttp.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => client.normalizeSourceRecord(999),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('createClassification', () {
    test('returns ClassificationResultDto on 201', () async {
      when(mockHttp.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({
                  'id': 1,
                  'normalized_record_id': 42,
                  'taxonomy': 'expense_type',
                  'category': 'office_supplies',
                  'classifier_kind': 'manual',
                  'review_status': 'candidate',
                  'is_active': true,
                  'created_at': '2026-06-01T00:00:00Z',
                  'updated_at': '2026-06-01T00:00:00Z',
                }),
                201,
              ));

      final result = await client.createClassification(
        42,
        category: 'office_supplies',
        classifierKind: 'manual',
      );

      expect(result.id, 1);
      expect(result.normalizedRecordId, 42);
      expect(result.category, 'office_supplies');
      expect(result.classifierKind, ClassifierKind.manual);
      expect(result.reviewStatus, ReviewStatus.candidate);

      final captured = verify(mockHttp.post(captureAny, headers: anyNamed('headers'), body: anyNamed('body'))).captured.first as Uri;
      expect(captured.path, '/normalized-records/42/classifications');
    });

    test('throws ApiException on 400', () async {
      when(mockHttp.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Bad Request', 400));

      expect(
        () => client.createClassification(1, category: '', classifierKind: 'manual'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('listClassifications', () {
    test('returns list of ClassificationResultDto on 200', () async {
      when(mockHttp.get(any)).thenAnswer((_) async => http.Response(
            jsonEncode([
              {
                'id': 1,
                'normalized_record_id': 42,
                'taxonomy': 'expense_type',
                'category': 'office_supplies',
                'classifier_kind': 'ai',
                'review_status': 'candidate',
                'is_active': true,
                'created_at': '2026-06-01T00:00:00Z',
                'updated_at': '2026-06-01T00:00:00Z',
              },
            ]),
            200,
          ));

      final results = await client.listClassifications(42);
      expect(results, hasLength(1));
      expect(results.first.category, 'office_supplies');

      final captured = verify(mockHttp.get(captureAny)).captured.first as Uri;
      expect(captured.path, '/normalized-records/42/classifications');
    });

    test('passes review_status query param when provided', () async {
      when(mockHttp.get(any))
          .thenAnswer((_) async => http.Response(jsonEncode([]), 200));

      await client.listClassifications(42, reviewStatus: 'accepted');

      final captured = verify(mockHttp.get(captureAny)).captured.first as Uri;
      expect(captured.queryParameters['review_status'], 'accepted');
    });

    test('throws ApiException on non-200', () async {
      when(mockHttp.get(any))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => client.listClassifications(999),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('reviewClassification', () {
    test('updates review_status on 200', () async {
      when(mockHttp.patch(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({
                  'id': 1,
                  'normalized_record_id': 42,
                  'taxonomy': 'expense_type',
                  'category': 'office_supplies',
                  'classifier_kind': 'ai',
                  'review_status': 'accepted',
                  'is_active': true,
                  'created_at': '2026-06-01T00:00:00Z',
                  'updated_at': '2026-06-01T00:30:00Z',
                }),
                200,
              ));

      final result = await client.reviewClassification(1, reviewStatus: 'accepted');
      expect(result.reviewStatus, ReviewStatus.accepted);

      final captured = verify(mockHttp.patch(captureAny, headers: anyNamed('headers'), body: anyNamed('body'))).captured.first as Uri;
      expect(captured.path, '/classifications/1');
    });

    test('throws ApiException on 404', () async {
      when(mockHttp.patch(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => client.reviewClassification(999, reviewStatus: 'accepted'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
