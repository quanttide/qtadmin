import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'source_record.freezed.dart';
part 'source_record.g.dart';

@freezed
class SourceRecordDto with _$SourceRecordDto {
  const factory SourceRecordDto({
    required int id,
    @JsonKey(name: 'source_type', unknownEnumValue: SourceType.unknown)
    required SourceType sourceType,
    @JsonKey(name: 'raw_text') @Default('') String rawText,
    @JsonKey(name: 'occurred_at') DateTime? occurredAt,
    @JsonKey(
      name: 'ingestion_status',
      unknownEnumValue: IngestionStatus.unknown,
    )
    @Default(IngestionStatus.pending)
    IngestionStatus ingestionStatus,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SourceRecordDto;

  factory SourceRecordDto.fromJson(Map<String, dynamic> json) =>
      _$SourceRecordDtoFromJson(json);
}
