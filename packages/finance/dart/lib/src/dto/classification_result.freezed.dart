// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classification_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ClassificationResultDto _$ClassificationResultDtoFromJson(
  Map<String, dynamic> json,
) {
  return _ClassificationResultDto.fromJson(json);
}

/// @nodoc
mixin _$ClassificationResultDto {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'normalized_record_id')
  int get normalizedRecordId => throw _privateConstructorUsedError;
  String get taxonomy => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'tags')
  Map<String, dynamic>? get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'classifier_kind', unknownEnumValue: ClassifierKind.unknown)
  ClassifierKind get classifierKind => throw _privateConstructorUsedError;
  @JsonKey(name: 'confidence')
  double? get confidence => throw _privateConstructorUsedError;
  @JsonKey(name: 'model_version')
  String? get modelVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_status', unknownEnumValue: ReviewStatus.unknown)
  ReviewStatus get reviewStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ClassificationResultDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassificationResultDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassificationResultDtoCopyWith<ClassificationResultDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassificationResultDtoCopyWith<$Res> {
  factory $ClassificationResultDtoCopyWith(
    ClassificationResultDto value,
    $Res Function(ClassificationResultDto) then,
  ) = _$ClassificationResultDtoCopyWithImpl<$Res, ClassificationResultDto>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'normalized_record_id') int normalizedRecordId,
    String taxonomy,
    String category,
    @JsonKey(name: 'tags') Map<String, dynamic>? tags,
    @JsonKey(name: 'classifier_kind', unknownEnumValue: ClassifierKind.unknown)
    ClassifierKind classifierKind,
    @JsonKey(name: 'confidence') double? confidence,
    @JsonKey(name: 'model_version') String? modelVersion,
    @JsonKey(name: 'review_status', unknownEnumValue: ReviewStatus.unknown)
    ReviewStatus reviewStatus,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$ClassificationResultDtoCopyWithImpl<
  $Res,
  $Val extends ClassificationResultDto
>
    implements $ClassificationResultDtoCopyWith<$Res> {
  _$ClassificationResultDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassificationResultDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? normalizedRecordId = null,
    Object? taxonomy = null,
    Object? category = null,
    Object? tags = freezed,
    Object? classifierKind = null,
    Object? confidence = freezed,
    Object? modelVersion = freezed,
    Object? reviewStatus = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            normalizedRecordId: null == normalizedRecordId
                ? _value.normalizedRecordId
                : normalizedRecordId // ignore: cast_nullable_to_non_nullable
                      as int,
            taxonomy: null == taxonomy
                ? _value.taxonomy
                : taxonomy // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            classifierKind: null == classifierKind
                ? _value.classifierKind
                : classifierKind // ignore: cast_nullable_to_non_nullable
                      as ClassifierKind,
            confidence: freezed == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double?,
            modelVersion: freezed == modelVersion
                ? _value.modelVersion
                : modelVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            reviewStatus: null == reviewStatus
                ? _value.reviewStatus
                : reviewStatus // ignore: cast_nullable_to_non_nullable
                      as ReviewStatus,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClassificationResultDtoImplCopyWith<$Res>
    implements $ClassificationResultDtoCopyWith<$Res> {
  factory _$$ClassificationResultDtoImplCopyWith(
    _$ClassificationResultDtoImpl value,
    $Res Function(_$ClassificationResultDtoImpl) then,
  ) = __$$ClassificationResultDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'normalized_record_id') int normalizedRecordId,
    String taxonomy,
    String category,
    @JsonKey(name: 'tags') Map<String, dynamic>? tags,
    @JsonKey(name: 'classifier_kind', unknownEnumValue: ClassifierKind.unknown)
    ClassifierKind classifierKind,
    @JsonKey(name: 'confidence') double? confidence,
    @JsonKey(name: 'model_version') String? modelVersion,
    @JsonKey(name: 'review_status', unknownEnumValue: ReviewStatus.unknown)
    ReviewStatus reviewStatus,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$ClassificationResultDtoImplCopyWithImpl<$Res>
    extends
        _$ClassificationResultDtoCopyWithImpl<
          $Res,
          _$ClassificationResultDtoImpl
        >
    implements _$$ClassificationResultDtoImplCopyWith<$Res> {
  __$$ClassificationResultDtoImplCopyWithImpl(
    _$ClassificationResultDtoImpl _value,
    $Res Function(_$ClassificationResultDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClassificationResultDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? normalizedRecordId = null,
    Object? taxonomy = null,
    Object? category = null,
    Object? tags = freezed,
    Object? classifierKind = null,
    Object? confidence = freezed,
    Object? modelVersion = freezed,
    Object? reviewStatus = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ClassificationResultDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        normalizedRecordId: null == normalizedRecordId
            ? _value.normalizedRecordId
            : normalizedRecordId // ignore: cast_nullable_to_non_nullable
                  as int,
        taxonomy: null == taxonomy
            ? _value.taxonomy
            : taxonomy // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: freezed == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        classifierKind: null == classifierKind
            ? _value.classifierKind
            : classifierKind // ignore: cast_nullable_to_non_nullable
                  as ClassifierKind,
        confidence: freezed == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double?,
        modelVersion: freezed == modelVersion
            ? _value.modelVersion
            : modelVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        reviewStatus: null == reviewStatus
            ? _value.reviewStatus
            : reviewStatus // ignore: cast_nullable_to_non_nullable
                  as ReviewStatus,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassificationResultDtoImpl implements _ClassificationResultDto {
  const _$ClassificationResultDtoImpl({
    required this.id,
    @JsonKey(name: 'normalized_record_id') required this.normalizedRecordId,
    this.taxonomy = 'expense_type',
    required this.category,
    @JsonKey(name: 'tags') final Map<String, dynamic>? tags,
    @JsonKey(name: 'classifier_kind', unknownEnumValue: ClassifierKind.unknown)
    required this.classifierKind,
    @JsonKey(name: 'confidence') this.confidence,
    @JsonKey(name: 'model_version') this.modelVersion,
    @JsonKey(name: 'review_status', unknownEnumValue: ReviewStatus.unknown)
    this.reviewStatus = ReviewStatus.candidate,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _tags = tags;

  factory _$ClassificationResultDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassificationResultDtoImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'normalized_record_id')
  final int normalizedRecordId;
  @override
  @JsonKey()
  final String taxonomy;
  @override
  final String category;
  final Map<String, dynamic>? _tags;
  @override
  @JsonKey(name: 'tags')
  Map<String, dynamic>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableMapView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'classifier_kind', unknownEnumValue: ClassifierKind.unknown)
  final ClassifierKind classifierKind;
  @override
  @JsonKey(name: 'confidence')
  final double? confidence;
  @override
  @JsonKey(name: 'model_version')
  final String? modelVersion;
  @override
  @JsonKey(name: 'review_status', unknownEnumValue: ReviewStatus.unknown)
  final ReviewStatus reviewStatus;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ClassificationResultDto(id: $id, normalizedRecordId: $normalizedRecordId, taxonomy: $taxonomy, category: $category, tags: $tags, classifierKind: $classifierKind, confidence: $confidence, modelVersion: $modelVersion, reviewStatus: $reviewStatus, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassificationResultDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.normalizedRecordId, normalizedRecordId) ||
                other.normalizedRecordId == normalizedRecordId) &&
            (identical(other.taxonomy, taxonomy) ||
                other.taxonomy == taxonomy) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.classifierKind, classifierKind) ||
                other.classifierKind == classifierKind) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.modelVersion, modelVersion) ||
                other.modelVersion == modelVersion) &&
            (identical(other.reviewStatus, reviewStatus) ||
                other.reviewStatus == reviewStatus) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    normalizedRecordId,
    taxonomy,
    category,
    const DeepCollectionEquality().hash(_tags),
    classifierKind,
    confidence,
    modelVersion,
    reviewStatus,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ClassificationResultDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassificationResultDtoImplCopyWith<_$ClassificationResultDtoImpl>
  get copyWith =>
      __$$ClassificationResultDtoImplCopyWithImpl<
        _$ClassificationResultDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassificationResultDtoImplToJson(this);
  }
}

abstract class _ClassificationResultDto implements ClassificationResultDto {
  const factory _ClassificationResultDto({
    required final int id,
    @JsonKey(name: 'normalized_record_id')
    required final int normalizedRecordId,
    final String taxonomy,
    required final String category,
    @JsonKey(name: 'tags') final Map<String, dynamic>? tags,
    @JsonKey(name: 'classifier_kind', unknownEnumValue: ClassifierKind.unknown)
    required final ClassifierKind classifierKind,
    @JsonKey(name: 'confidence') final double? confidence,
    @JsonKey(name: 'model_version') final String? modelVersion,
    @JsonKey(name: 'review_status', unknownEnumValue: ReviewStatus.unknown)
    final ReviewStatus reviewStatus,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$ClassificationResultDtoImpl;

  factory _ClassificationResultDto.fromJson(Map<String, dynamic> json) =
      _$ClassificationResultDtoImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'normalized_record_id')
  int get normalizedRecordId;
  @override
  String get taxonomy;
  @override
  String get category;
  @override
  @JsonKey(name: 'tags')
  Map<String, dynamic>? get tags;
  @override
  @JsonKey(name: 'classifier_kind', unknownEnumValue: ClassifierKind.unknown)
  ClassifierKind get classifierKind;
  @override
  @JsonKey(name: 'confidence')
  double? get confidence;
  @override
  @JsonKey(name: 'model_version')
  String? get modelVersion;
  @override
  @JsonKey(name: 'review_status', unknownEnumValue: ReviewStatus.unknown)
  ReviewStatus get reviewStatus;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of ClassificationResultDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassificationResultDtoImplCopyWith<_$ClassificationResultDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
