import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'normalized_record.freezed.dart';
part 'normalized_record.g.dart';

@freezed
class NormalizedRecordDto with _$NormalizedRecordDto {
  const factory NormalizedRecordDto({
    required int id,
    @JsonKey(name: 'record_type', unknownEnumValue: RecordType.unknown)
    required RecordType recordType,
    @JsonKey(name: 'business_date') @Default('') String businessDate,
    @JsonKey(name: 'amount_cents') @Default(0) int amountCents,
    @JsonKey(name: 'direction', unknownEnumValue: Direction.unknown)
    required Direction direction,
    @JsonKey(name: 'department') String? department,
    @JsonKey(name: 'person') String? person,
    @JsonKey(name: 'description') @Default('') String description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _NormalizedRecordDto;

  factory NormalizedRecordDto.fromJson(Map<String, dynamic> json) =>
      _$NormalizedRecordDtoFromJson(json);
}
