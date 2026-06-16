import 'package:test/test.dart';
import 'package:quanttide_finance/quanttide_finance.dart';

void main() {
  group('SourceRecordDto', () {
    test('toJson uses snake_case keys', () {
      final dto = SourceRecordDto(
        id: 1,
        sourceType: SourceType.csvRow,
        rawText: '2026-06-01,办公用品,120000,outflow',
        occurredAt: null,
        ingestionStatus: IngestionStatus.parsed,
        createdAt: DateTime(2026, 6, 1),
      );
      final json = dto.toJson();
      expect(json.containsKey('source_type'), isTrue);
      expect(json.containsKey('raw_text'), isTrue);
      expect(json.containsKey('ingestion_status'), isTrue);
      expect(json.containsKey('created_at'), isTrue);
      // Ensure no camelCase keys leak through
      expect(json.containsKey('sourceType'), isFalse);
      expect(json.containsKey('rawText'), isFalse);
    });

    test('fromJson round-trip', () {
      final dto = SourceRecordDto(
        id: 42,
        sourceType: SourceType.manual,
        rawText: '购买办公用品',
        occurredAt: DateTime(2026, 5, 30),
        ingestionStatus: IngestionStatus.pending,
        createdAt: DateTime(2026, 5, 31),
      );
      expect(SourceRecordDto.fromJson(dto.toJson()), dto);
    });

    test('copyWith', () {
      final dto = SourceRecordDto(
        id: 1,
        sourceType: SourceType.other,
        rawText: '',
        occurredAt: null,
        ingestionStatus: IngestionStatus.pending,
        createdAt: DateTime(2026, 6, 1),
      );
      final updated = dto.copyWith(ingestionStatus: IngestionStatus.reviewed);
      expect(updated.ingestionStatus, IngestionStatus.reviewed);
      expect(updated.id, dto.id); // unchanged
    });

    test('nullable fields', () {
      final dto = SourceRecordDto(
        id: 1,
        sourceType: SourceType.form,
        rawText: 'test',
        occurredAt: null,
        ingestionStatus: IngestionStatus.pending,
        createdAt: DateTime(2026, 6, 1),
      );
      final json = dto.toJson();
      expect(json['occurred_at'], isNull);
    });
  });
}
