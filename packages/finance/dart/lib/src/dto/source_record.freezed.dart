// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'source_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SourceRecordDto _$SourceRecordDtoFromJson(Map<String, dynamic> json) {
  return _SourceRecordDto.fromJson(json);
}

/// @nodoc
mixin _$SourceRecordDto {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_type', unknownEnumValue: SourceType.unknown)
  SourceType get sourceType => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_text')
  String get rawText => throw _privateConstructorUsedError;
  @JsonKey(name: 'occurred_at')
  DateTime? get occurredAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingestion_status', unknownEnumValue: IngestionStatus.unknown)
  IngestionStatus get ingestionStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SourceRecordDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SourceRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SourceRecordDtoCopyWith<SourceRecordDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SourceRecordDtoCopyWith<$Res> {
  factory $SourceRecordDtoCopyWith(
    SourceRecordDto value,
    $Res Function(SourceRecordDto) then,
  ) = _$SourceRecordDtoCopyWithImpl<$Res, SourceRecordDto>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'source_type', unknownEnumValue: SourceType.unknown)
    SourceType sourceType,
    @JsonKey(name: 'raw_text') String rawText,
    @JsonKey(name: 'occurred_at') DateTime? occurredAt,
    @JsonKey(
      name: 'ingestion_status',
      unknownEnumValue: IngestionStatus.unknown,
    )
    IngestionStatus ingestionStatus,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$SourceRecordDtoCopyWithImpl<$Res, $Val extends SourceRecordDto>
    implements $SourceRecordDtoCopyWith<$Res> {
  _$SourceRecordDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SourceRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceType = null,
    Object? rawText = null,
    Object? occurredAt = freezed,
    Object? ingestionStatus = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            sourceType: null == sourceType
                ? _value.sourceType
                : sourceType // ignore: cast_nullable_to_non_nullable
                      as SourceType,
            rawText: null == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String,
            occurredAt: freezed == occurredAt
                ? _value.occurredAt
                : occurredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            ingestionStatus: null == ingestionStatus
                ? _value.ingestionStatus
                : ingestionStatus // ignore: cast_nullable_to_non_nullable
                      as IngestionStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SourceRecordDtoImplCopyWith<$Res>
    implements $SourceRecordDtoCopyWith<$Res> {
  factory _$$SourceRecordDtoImplCopyWith(
    _$SourceRecordDtoImpl value,
    $Res Function(_$SourceRecordDtoImpl) then,
  ) = __$$SourceRecordDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'source_type', unknownEnumValue: SourceType.unknown)
    SourceType sourceType,
    @JsonKey(name: 'raw_text') String rawText,
    @JsonKey(name: 'occurred_at') DateTime? occurredAt,
    @JsonKey(
      name: 'ingestion_status',
      unknownEnumValue: IngestionStatus.unknown,
    )
    IngestionStatus ingestionStatus,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$SourceRecordDtoImplCopyWithImpl<$Res>
    extends _$SourceRecordDtoCopyWithImpl<$Res, _$SourceRecordDtoImpl>
    implements _$$SourceRecordDtoImplCopyWith<$Res> {
  __$$SourceRecordDtoImplCopyWithImpl(
    _$SourceRecordDtoImpl _value,
    $Res Function(_$SourceRecordDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourceRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceType = null,
    Object? rawText = null,
    Object? occurredAt = freezed,
    Object? ingestionStatus = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SourceRecordDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        sourceType: null == sourceType
            ? _value.sourceType
            : sourceType // ignore: cast_nullable_to_non_nullable
                  as SourceType,
        rawText: null == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
                  as String,
        occurredAt: freezed == occurredAt
            ? _value.occurredAt
            : occurredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        ingestionStatus: null == ingestionStatus
            ? _value.ingestionStatus
            : ingestionStatus // ignore: cast_nullable_to_non_nullable
                  as IngestionStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SourceRecordDtoImpl implements _SourceRecordDto {
  const _$SourceRecordDtoImpl({
    required this.id,
    @JsonKey(name: 'source_type', unknownEnumValue: SourceType.unknown)
    required this.sourceType,
    @JsonKey(name: 'raw_text') this.rawText = '',
    @JsonKey(name: 'occurred_at') this.occurredAt,
    @JsonKey(
      name: 'ingestion_status',
      unknownEnumValue: IngestionStatus.unknown,
    )
    this.ingestionStatus = IngestionStatus.pending,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$SourceRecordDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SourceRecordDtoImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'source_type', unknownEnumValue: SourceType.unknown)
  final SourceType sourceType;
  @override
  @JsonKey(name: 'raw_text')
  final String rawText;
  @override
  @JsonKey(name: 'occurred_at')
  final DateTime? occurredAt;
  @override
  @JsonKey(name: 'ingestion_status', unknownEnumValue: IngestionStatus.unknown)
  final IngestionStatus ingestionStatus;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'SourceRecordDto(id: $id, sourceType: $sourceType, rawText: $rawText, occurredAt: $occurredAt, ingestionStatus: $ingestionStatus, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SourceRecordDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            (identical(other.occurredAt, occurredAt) ||
                other.occurredAt == occurredAt) &&
            (identical(other.ingestionStatus, ingestionStatus) ||
                other.ingestionStatus == ingestionStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sourceType,
    rawText,
    occurredAt,
    ingestionStatus,
    createdAt,
  );

  /// Create a copy of SourceRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SourceRecordDtoImplCopyWith<_$SourceRecordDtoImpl> get copyWith =>
      __$$SourceRecordDtoImplCopyWithImpl<_$SourceRecordDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SourceRecordDtoImplToJson(this);
  }
}

abstract class _SourceRecordDto implements SourceRecordDto {
  const factory _SourceRecordDto({
    required final int id,
    @JsonKey(name: 'source_type', unknownEnumValue: SourceType.unknown)
    required final SourceType sourceType,
    @JsonKey(name: 'raw_text') final String rawText,
    @JsonKey(name: 'occurred_at') final DateTime? occurredAt,
    @JsonKey(
      name: 'ingestion_status',
      unknownEnumValue: IngestionStatus.unknown,
    )
    final IngestionStatus ingestionStatus,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$SourceRecordDtoImpl;

  factory _SourceRecordDto.fromJson(Map<String, dynamic> json) =
      _$SourceRecordDtoImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'source_type', unknownEnumValue: SourceType.unknown)
  SourceType get sourceType;
  @override
  @JsonKey(name: 'raw_text')
  String get rawText;
  @override
  @JsonKey(name: 'occurred_at')
  DateTime? get occurredAt;
  @override
  @JsonKey(name: 'ingestion_status', unknownEnumValue: IngestionStatus.unknown)
  IngestionStatus get ingestionStatus;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of SourceRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SourceRecordDtoImplCopyWith<_$SourceRecordDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
