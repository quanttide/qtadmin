import 'package:test/test.dart';
import 'package:quanttide_finance/quanttide_finance.dart';

/// Wire values as defined in doc/entities.md enum value table.
/// These must match the @JsonValue strings on each enum member.
void main() {
  group('SourceType wire values', () {
    test('image', () => expect(SourceType.image.toJson(), 'image'));
    test('chat', () => expect(SourceType.chat.toJson(), 'chat'));
    test('form', () => expect(SourceType.form.toJson(), 'form'));
    test('csv_row', () => expect(SourceType.csvRow.toJson(), 'csv_row'));
    test('bank_tx', () => expect(SourceType.bankTx.toJson(), 'bank_tx'));
    test('api', () => expect(SourceType.api.toJson(), 'api'));
    test('manual', () => expect(SourceType.manual.toJson(), 'manual'));
    test('other', () => expect(SourceType.other.toJson(), 'other'));
  });

  group('IngestionStatus wire values', () {
    test('pending', () => expect(IngestionStatus.pending.toJson(), 'pending'));
    test('parsed', () => expect(IngestionStatus.parsed.toJson(), 'parsed'));
    test('reviewed', () => expect(IngestionStatus.reviewed.toJson(), 'reviewed'));
    test('failed', () => expect(IngestionStatus.failed.toJson(), 'failed'));
  });

  group('RecordType wire values', () {
    test('expense', () => expect(RecordType.expense.toJson(), 'expense'));
    test('income', () => expect(RecordType.income.toJson(), 'income'));
    test('transfer', () => expect(RecordType.transfer.toJson(), 'transfer'));
    test('reimbursement', () => expect(RecordType.reimbursement.toJson(), 'reimbursement'));
    test('other', () => expect(RecordType.other.toJson(), 'other'));
  });

  group('Direction wire values', () {
    test('outflow', () => expect(Direction.outflow.toJson(), 'outflow'));
    test('inflow', () => expect(Direction.inflow.toJson(), 'inflow'));
  });

  group('NormalizationStatus wire values', () {
    test('draft', () => expect(NormalizationStatus.draft.toJson(), 'draft'));
    test('normalized', () => expect(NormalizationStatus.normalized.toJson(), 'normalized'));
    test('reviewed', () => expect(NormalizationStatus.reviewed.toJson(), 'reviewed'));
    test('merged', () => expect(NormalizationStatus.merged.toJson(), 'merged'));
  });
}
