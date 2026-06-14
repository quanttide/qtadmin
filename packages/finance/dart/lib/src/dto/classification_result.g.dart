// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classification_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassificationResultDtoImpl _$$ClassificationResultDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ClassificationResultDtoImpl(
  id: (json['id'] as num).toInt(),
  normalizedRecordId: (json['normalized_record_id'] as num).toInt(),
  taxonomy: json['taxonomy'] as String? ?? 'expense_type',
  category: json['category'] as String,
  tags: json['tags'] as Map<String, dynamic>?,
  classifierKind: $enumDecode(
    _$ClassifierKindEnumMap,
    json['classifier_kind'],
    unknownValue: ClassifierKind.unknown,
  ),
  confidence: (json['confidence'] as num?)?.toDouble(),
  modelVersion: json['model_version'] as String?,
  reviewStatus:
      $enumDecodeNullable(
        _$ReviewStatusEnumMap,
        json['review_status'],
        unknownValue: ReviewStatus.unknown,
      ) ??
      ReviewStatus.candidate,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$ClassificationResultDtoImplToJson(
  _$ClassificationResultDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'normalized_record_id': instance.normalizedRecordId,
  'taxonomy': instance.taxonomy,
  'category': instance.category,
  'tags': instance.tags,
  'classifier_kind': _$ClassifierKindEnumMap[instance.classifierKind]!,
  'confidence': instance.confidence,
  'model_version': instance.modelVersion,
  'review_status': _$ReviewStatusEnumMap[instance.reviewStatus]!,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$ClassifierKindEnumMap = {
  ClassifierKind.ai: 'ai',
  ClassifierKind.rule: 'rule',
  ClassifierKind.manual: 'manual',
  ClassifierKind.unknown: '__unknown__',
};

const _$ReviewStatusEnumMap = {
  ReviewStatus.candidate: 'candidate',
  ReviewStatus.accepted: 'accepted',
  ReviewStatus.rejected: 'rejected',
  ReviewStatus.unknown: '__unknown__',
};
