import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal.freezed.dart';
part 'journal.g.dart';

@freezed
class Journal with _$Journal {
  const factory Journal({
    required String id,
    required String name,
    required DateTime createdAt,
  }) = _Journal;

  factory Journal.fromJson(Map<String, dynamic> json) => _$JournalFromJson(json);
}
