import 'package:test/test.dart';
import 'package:quanttide_finance/quanttide_finance.dart';

/// Wire-value alignment tests.
///
/// Each @JsonValue label is verified against doc/entities.md wire values
/// through DTO toJson serialization.
void main() {
  group('SourceType wire values', () {
    for (final entry in {
      'image': SourceType.image,
      'chat': SourceType.chat,
      'form': SourceType.form,
      'csv_row': SourceType.csvRow,
      'bank_tx': SourceType.bankTx,
      'api': SourceType.api,
      'manual': SourceType.manual,
      'other': SourceType.other,
    }.entries) {
      test('${entry.key}', () {
        final dto = SourceRecordDto(
          id: 1,
          sourceType: entry.value,
          rawText: '',
          occurredAt: null,
          ingestionStatus: IngestionStatus.pending,
          createdAt: DateTime(2026, 1, 1),
        );
        final json = dto.toJson();
        expect(
          json['source_type'],
          equals(entry.key),
          reason:
              'SourceType.${entry.value.name} @JsonValue must match doc/entities.md',
        );
      });
    }
  });

  group('IngestionStatus wire values', () {
    for (final entry in {
      'pending': IngestionStatus.pending,
      'parsed': IngestionStatus.parsed,
      'reviewed': IngestionStatus.reviewed,
      'failed': IngestionStatus.failed,
    }.entries) {
      test('${entry.key}', () {
        final dto = SourceRecordDto(
          id: 1,
          sourceType: SourceType.manual,
          rawText: '',
          occurredAt: null,
          ingestionStatus: entry.value,
          createdAt: DateTime(2026, 1, 1),
        );
        final json = dto.toJson();
        expect(
          json['ingestion_status'],
          equals(entry.key),
          reason:
              'IngestionStatus.${entry.value.name} @JsonValue must match doc/entities.md',
        );
      });
    }
  });

  group('RecordType wire values', () {
    for (final entry in {
      'expense': RecordType.expense,
      'income': RecordType.income,
      'transfer': RecordType.transfer,
      'reimbursement': RecordType.reimbursement,
      'other': RecordType.other,
    }.entries) {
      test('${entry.key}', () {
        final dto = NormalizedRecordDto(
          id: 1,
          recordType: entry.value,
          businessDate: '2026-06-01',
          amountCents: 0,
          direction: Direction.outflow,
          department: null,
          person: null,
          description: '',
          createdAt: DateTime(2026, 1, 1),
        );
        final json = dto.toJson();
        expect(
          json['record_type'],
          equals(entry.key),
          reason:
              'RecordType.${entry.value.name} @JsonValue must match doc/entities.md',
        );
      });
    }
  });

  group('Direction wire values', () {
    for (final entry in {
      'outflow': Direction.outflow,
      'inflow': Direction.inflow,
    }.entries) {
      test('${entry.key}', () {
        final dto = NormalizedRecordDto(
          id: 1,
          recordType: RecordType.expense,
          businessDate: '2026-06-01',
          amountCents: 0,
          direction: entry.value,
          department: null,
          person: null,
          description: '',
          createdAt: DateTime(2026, 1, 1),
        );
        final json = dto.toJson();
        expect(
          json['direction'],
          equals(entry.key),
          reason:
              'Direction.${entry.value.name} @JsonValue must match doc/entities.md',
        );
      });
    }
  });

  group('SourceType', () {
    test('unknown fallback', () {
      const json = {
        'id': 1,
        'source_type': 'invalid',
        'created_at': '2026-01-01T00:00:00Z',
      };
      final dto = SourceRecordDto.fromJson(json);
      expect(dto.sourceType, SourceType.unknown);
    });
  });

  group('IngestionStatus', () {
    test('default value', () {
      const json = {
        'id': 1,
        'source_type': 'manual',
        'created_at': '2026-01-01T00:00:00Z',
      };
      final dto = SourceRecordDto.fromJson(json);
      expect(dto.ingestionStatus, IngestionStatus.pending);
    });
  });

  group('ClassifierKind wire values', () {
    for (final entry in {
      'ai': ClassifierKind.ai,
      'rule': ClassifierKind.rule,
      'manual': ClassifierKind.manual,
    }.entries) {
      test(entry.key, () {
        final dto = ClassificationResultDto(
          id: 1,
          normalizedRecordId: 1,
          taxonomy: 'expense_type',
          category: 'office_supplies',
          classifierKind: entry.value,
          reviewStatus: ReviewStatus.candidate,
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
        final json = dto.toJson();
        expect(
          json['classifier_kind'],
          equals(entry.key),
          reason:
              'ClassifierKind.${entry.value.name} @JsonValue must match doc/entities.md',
        );
      });
    }
  });

  group('ReviewStatus wire values', () {
    for (final entry in {
      'candidate': ReviewStatus.candidate,
      'accepted': ReviewStatus.accepted,
      'rejected': ReviewStatus.rejected,
    }.entries) {
      test(entry.key, () {
        final dto = ClassificationResultDto(
          id: 1,
          normalizedRecordId: 1,
          taxonomy: 'expense_type',
          category: 'office_supplies',
          classifierKind: ClassifierKind.manual,
          reviewStatus: entry.value,
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
        final json = dto.toJson();
        expect(
          json['review_status'],
          equals(entry.key),
          reason:
              'ReviewStatus.${entry.value.name} @JsonValue must match doc/entities.md',
        );
      });
    }
  });
}
