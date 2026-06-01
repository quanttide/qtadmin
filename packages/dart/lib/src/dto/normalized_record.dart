import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'normalized_record.freezed.dart';
part 'normalized_record.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class NormalizedRecordDto with _$NormalizedRecordDto {
  const factory NormalizedRecordDto({
    required int id,
    @JsonKey(unknownEnumValue: RecordType.unknown) required RecordType recordType,
    @Default('') String businessDate,
    @Default(0) int amountCents,
    @JsonKey(unknownEnumValue: Direction.unknown) required Direction direction,
    String? department,
    String? person,
    @Default('') String description,
    required DateTime createdAt,
  }) = _NormalizedRecordDto;

  factory NormalizedRecordDto.fromJson(Map<String, dynamic> json) =>
      _$NormalizedRecordDtoFromJson(json);
}
