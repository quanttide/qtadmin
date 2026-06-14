import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'classification_result.freezed.dart';
part 'classification_result.g.dart';

@freezed
class ClassificationResultDto with _$ClassificationResultDto {
  const factory ClassificationResultDto({
    required int id,
    @JsonKey(name: 'normalized_record_id') required int normalizedRecordId,
    @Default('expense_type') String taxonomy,
    required String category,
    @JsonKey(name: 'tags') Map<String, dynamic>? tags,
    @JsonKey(
      name: 'classifier_kind',
      unknownEnumValue: ClassifierKind.unknown,
    )
    required ClassifierKind classifierKind,
    @JsonKey(name: 'confidence') double? confidence,
    @JsonKey(name: 'model_version') String? modelVersion,
    @JsonKey(
      name: 'review_status',
      unknownEnumValue: ReviewStatus.unknown,
    )
    @Default(ReviewStatus.candidate)
    ReviewStatus reviewStatus,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ClassificationResultDto;

  factory ClassificationResultDto.fromJson(Map<String, dynamic> json) =>
      _$ClassificationResultDtoFromJson(json);
}
