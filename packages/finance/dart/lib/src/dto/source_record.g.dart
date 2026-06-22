// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SourceRecordDtoImpl _$$SourceRecordDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SourceRecordDtoImpl(
  id: (json['id'] as num).toInt(),
  sourceType: $enumDecode(
    _$SourceTypeEnumMap,
    json['source_type'],
    unknownValue: SourceType.unknown,
  ),
  rawText: json['raw_text'] as String? ?? '',
  occurredAt: json['occurred_at'] == null
      ? null
      : DateTime.parse(json['occurred_at'] as String),
  ingestionStatus:
      $enumDecodeNullable(
        _$IngestionStatusEnumMap,
        json['ingestion_status'],
        unknownValue: IngestionStatus.unknown,
      ) ??
      IngestionStatus.pending,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$SourceRecordDtoImplToJson(
  _$SourceRecordDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'source_type': _$SourceTypeEnumMap[instance.sourceType]!,
  'raw_text': instance.rawText,
  'occurred_at': instance.occurredAt?.toIso8601String(),
  'ingestion_status': _$IngestionStatusEnumMap[instance.ingestionStatus]!,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$SourceTypeEnumMap = {
  SourceType.image: 'image',
  SourceType.chat: 'chat',
  SourceType.form: 'form',
  SourceType.csvRow: 'csv_row',
  SourceType.bankTx: 'bank_tx',
  SourceType.api: 'api',
  SourceType.manual: 'manual',
  SourceType.other: 'other',
  SourceType.unknown: '__unknown__',
};

const _$IngestionStatusEnumMap = {
  IngestionStatus.pending: 'pending',
  IngestionStatus.parsed: 'parsed',
  IngestionStatus.reviewed: 'reviewed',
  IngestionStatus.failed: 'failed',
  IngestionStatus.unknown: '__unknown__',
};
