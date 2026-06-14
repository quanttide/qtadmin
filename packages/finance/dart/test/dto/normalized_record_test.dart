import 'package:test/test.dart';
import 'package:quanttide_finance/quanttide_finance.dart';

void main() {
  group('NormalizedRecordDto', () {
    test('toJson uses snake_case keys', () {
      final dto = NormalizedRecordDto(
        id: 1,
        recordType: RecordType.expense,
        businessDate: '2026-06-01',
        amountCents: 120000,
        direction: Direction.outflow,
        department: '研发部',
        person: '张三',
        description: '办公用品采购',
        createdAt: DateTime(2026, 6, 1),
      );
      final json = dto.toJson();
      expect(json.containsKey('record_type'), isTrue);
      expect(json.containsKey('business_date'), isTrue);
      expect(json.containsKey('amount_cents'), isTrue);
      expect(json.containsKey('created_at'), isTrue);
      expect(json.containsKey('recordType'), isFalse);
      expect(json.containsKey('amountCents'), isFalse);
    });

    test('fromJson round-trip', () {
      final dto = NormalizedRecordDto(
        id: 42,
        recordType: RecordType.income,
        businessDate: '2026-06-15',
        amountCents: 500000,
        direction: Direction.inflow,
        department: null,
        person: null,
        description: '客户回款',
        createdAt: DateTime(2026, 6, 15),
      );
      expect(NormalizedRecordDto.fromJson(dto.toJson()), dto);
    });

    test('copyWith', () {
      final dto = NormalizedRecordDto(
        id: 1,
        recordType: RecordType.expense,
        businessDate: '2026-06-01',
        amountCents: 1000,
        direction: Direction.outflow,
        department: null,
        person: null,
        description: 'test',
        createdAt: DateTime(2026, 6, 1),
      );
      final updated = dto.copyWith(amountCents: 2000);
      expect(updated.amountCents, 2000);
      expect(updated.id, dto.id);
    });

    test('nullable fields', () {
      final dto = NormalizedRecordDto(
        id: 1,
        recordType: RecordType.other,
        businessDate: '2026-06-01',
        amountCents: 0,
        direction: Direction.outflow,
        department: null,
        person: null,
        description: '',
        createdAt: DateTime(2026, 6, 1),
      );
      final json = dto.toJson();
      expect(json['department'], isNull);
      expect(json['person'], isNull);
    });

    test('businessDate is display-only string', () {
      final dto = NormalizedRecordDto(
        id: 1,
        recordType: RecordType.expense,
        businessDate: '2026-06-01',
        amountCents: 0,
        direction: Direction.outflow,
        department: null,
        person: null,
        description: '',
        createdAt: DateTime(2026, 6, 1),
      );
      final json = dto.toJson();
      expect(json['business_date'], isA<String>());
      expect(json['business_date'], '2026-06-01');
    });
  });
}
