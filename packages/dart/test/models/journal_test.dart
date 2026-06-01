import 'package:test/test.dart';
import 'package:quanttide_finance/quanttide_finance.dart';

void main() {
  test('Journal toJson / fromJson', () {
    final j = Journal(id: '1', name: '备用金', createdAt: DateTime(2026, 5, 29));
    expect(Journal.fromJson(j.toJson()), j);
  });

  test('JournalEntryLine toJson / fromJson', () {
    final l = JournalEntryLine(
      id: 'l1', type: LineType.debit, amount: 1000,
      description: '买纸', createdAt: DateTime(2026, 5, 29),
    );
    expect(JournalEntryLine.fromJson(l.toJson()), l);
  });

  test('JournalEntry toJson / fromJson', () {
    final e = JournalEntry(
      id: 'je1', journalId: 'j1', createdAt: DateTime(2026, 5, 29),
      description: '采购',
      lines: [
        JournalEntryLine(id: 'l1', type: LineType.debit, amount: 1200, createdAt: DateTime(2026, 5, 29)),
        JournalEntryLine(id: 'l2', type: LineType.credit, amount: 1200, createdAt: DateTime(2026, 5, 29)),
      ],
    );
    expect(JournalEntry.fromJson(e.toJson()), e);
  });

  test('copyWith', () {
    final j = Journal(id: '1', name: '备用金', createdAt: DateTime(2026, 5, 29));
    expect(j.copyWith(name: '改名的备用金').name, '改名的备用金');
  });
}
