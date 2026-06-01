// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JournalEntryLineImpl _$$JournalEntryLineImplFromJson(
  Map<String, dynamic> json,
) => _$JournalEntryLineImpl(
  id: json['id'] as String,
  type: $enumDecode(_$LineTypeEnumMap, json['type']),
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  description: json['description'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$JournalEntryLineImplToJson(
  _$JournalEntryLineImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$LineTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$LineTypeEnumMap = {LineType.debit: 'debit', LineType.credit: 'credit'};

_$JournalEntryImpl _$$JournalEntryImplFromJson(Map<String, dynamic> json) =>
    _$JournalEntryImpl(
      id: json['id'] as String,
      journalId: json['journalId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String? ?? '',
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map((e) => JournalEntryLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <JournalEntryLine>[],
    );

Map<String, dynamic> _$$JournalEntryImplToJson(_$JournalEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'journalId': instance.journalId,
      'createdAt': instance.createdAt.toIso8601String(),
      'description': instance.description,
      'lines': _linesToJson(instance.lines),
    };
