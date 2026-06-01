import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'source_record.freezed.dart';
part 'source_record.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class SourceRecordDto with _$SourceRecordDto {
  const factory SourceRecordDto({
    required int id,
    @JsonKey(unknownEnumValue: SourceType.unknown) required SourceType sourceType,
    @Default('') String rawText,
    DateTime? occurredAt,
    @JsonKey(unknownEnumValue: IngestionStatus.unknown)
    @Default(IngestionStatus.pending)
    IngestionStatus ingestionStatus,
    required DateTime createdAt,
  }) = _SourceRecordDto;

  factory SourceRecordDto.fromJson(Map<String, dynamic> json) =>
      _$SourceRecordDtoFromJson(json);
}
