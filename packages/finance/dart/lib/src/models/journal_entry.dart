import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

@JsonEnum()
enum LineType { debit, credit }

@freezed
class JournalEntryLine with _$JournalEntryLine {
  const JournalEntryLine._();

  @Assert('amount >= 0', 'amount must be non-negative')
  const factory JournalEntryLine({
    required String id,
    required LineType type,
    @Default(0) double amount,
    @Default('') String description,
    required DateTime createdAt,
  }) = _JournalEntryLine;

  factory JournalEntryLine.fromJson(Map<String, dynamic> json) => _$JournalEntryLineFromJson(json);
}

@freezed
class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    required String journalId,
    required DateTime createdAt,
    @Default('') String description,
    @JsonKey(toJson: _linesToJson) @Default(<JournalEntryLine>[]) List<JournalEntryLine> lines,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
}

List<Map<String, dynamic>> _linesToJson(List<JournalEntryLine> lines) =>
    lines.map((l) => l.toJson()).toList();
