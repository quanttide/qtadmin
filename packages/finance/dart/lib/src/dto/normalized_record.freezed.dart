// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'normalized_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NormalizedRecordDto _$NormalizedRecordDtoFromJson(Map<String, dynamic> json) {
  return _NormalizedRecordDto.fromJson(json);
}

/// @nodoc
mixin _$NormalizedRecordDto {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'record_type', unknownEnumValue: RecordType.unknown)
  RecordType get recordType => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_date')
  String get businessDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_cents')
  int get amountCents => throw _privateConstructorUsedError;
  @JsonKey(name: 'direction', unknownEnumValue: Direction.unknown)
  Direction get direction => throw _privateConstructorUsedError;
  @JsonKey(name: 'department')
  String? get department => throw _privateConstructorUsedError;
  @JsonKey(name: 'person')
  String? get person => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this NormalizedRecordDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NormalizedRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NormalizedRecordDtoCopyWith<NormalizedRecordDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NormalizedRecordDtoCopyWith<$Res> {
  factory $NormalizedRecordDtoCopyWith(
    NormalizedRecordDto value,
    $Res Function(NormalizedRecordDto) then,
  ) = _$NormalizedRecordDtoCopyWithImpl<$Res, NormalizedRecordDto>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'record_type', unknownEnumValue: RecordType.unknown)
    RecordType recordType,
    @JsonKey(name: 'business_date') String businessDate,
    @JsonKey(name: 'amount_cents') int amountCents,
    @JsonKey(name: 'direction', unknownEnumValue: Direction.unknown)
    Direction direction,
    @JsonKey(name: 'department') String? department,
    @JsonKey(name: 'person') String? person,
    @JsonKey(name: 'description') String description,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$NormalizedRecordDtoCopyWithImpl<$Res, $Val extends NormalizedRecordDto>
    implements $NormalizedRecordDtoCopyWith<$Res> {
  _$NormalizedRecordDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NormalizedRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recordType = null,
    Object? businessDate = null,
    Object? amountCents = null,
    Object? direction = null,
    Object? department = freezed,
    Object? person = freezed,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            recordType: null == recordType
                ? _value.recordType
                : recordType // ignore: cast_nullable_to_non_nullable
                      as RecordType,
            businessDate: null == businessDate
                ? _value.businessDate
                : businessDate // ignore: cast_nullable_to_non_nullable
                      as String,
            amountCents: null == amountCents
                ? _value.amountCents
                : amountCents // ignore: cast_nullable_to_non_nullable
                      as int,
            direction: null == direction
                ? _value.direction
                : direction // ignore: cast_nullable_to_non_nullable
                      as Direction,
            department: freezed == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String?,
            person: freezed == person
                ? _value.person
                : person // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$NormalizedRecordDtoImplCopyWith<$Res>
    implements $NormalizedRecordDtoCopyWith<$Res> {
  factory _$$NormalizedRecordDtoImplCopyWith(
    _$NormalizedRecordDtoImpl value,
    $Res Function(_$NormalizedRecordDtoImpl) then,
  ) = __$$NormalizedRecordDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'record_type', unknownEnumValue: RecordType.unknown)
    RecordType recordType,
    @JsonKey(name: 'business_date') String businessDate,
    @JsonKey(name: 'amount_cents') int amountCents,
    @JsonKey(name: 'direction', unknownEnumValue: Direction.unknown)
    Direction direction,
    @JsonKey(name: 'department') String? department,
    @JsonKey(name: 'person') String? person,
    @JsonKey(name: 'description') String description,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$NormalizedRecordDtoImplCopyWithImpl<$Res>
    extends _$NormalizedRecordDtoCopyWithImpl<$Res, _$NormalizedRecordDtoImpl>
    implements _$$NormalizedRecordDtoImplCopyWith<$Res> {
  __$$NormalizedRecordDtoImplCopyWithImpl(
    _$NormalizedRecordDtoImpl _value,
    $Res Function(_$NormalizedRecordDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NormalizedRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recordType = null,
    Object? businessDate = null,
    Object? amountCents = null,
    Object? direction = null,
    Object? department = freezed,
    Object? person = freezed,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$NormalizedRecordDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        recordType: null == recordType
            ? _value.recordType
            : recordType // ignore: cast_nullable_to_non_nullable
                  as RecordType,
        businessDate: null == businessDate
            ? _value.businessDate
            : businessDate // ignore: cast_nullable_to_non_nullable
                  as String,
        amountCents: null == amountCents
            ? _value.amountCents
            : amountCents // ignore: cast_nullable_to_non_nullable
                  as int,
        direction: null == direction
            ? _value.direction
            : direction // ignore: cast_nullable_to_non_nullable
                  as Direction,
        department: freezed == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String?,
        person: freezed == person
            ? _value.person
            : person // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$NormalizedRecordDtoImpl implements _NormalizedRecordDto {
  const _$NormalizedRecordDtoImpl({
    required this.id,
    @JsonKey(name: 'record_type', unknownEnumValue: RecordType.unknown)
    required this.recordType,
    @JsonKey(name: 'business_date') this.businessDate = '',
    @JsonKey(name: 'amount_cents') this.amountCents = 0,
    @JsonKey(name: 'direction', unknownEnumValue: Direction.unknown)
    required this.direction,
    @JsonKey(name: 'department') this.department,
    @JsonKey(name: 'person') this.person,
    @JsonKey(name: 'description') this.description = '',
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$NormalizedRecordDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$NormalizedRecordDtoImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'record_type', unknownEnumValue: RecordType.unknown)
  final RecordType recordType;
  @override
  @JsonKey(name: 'business_date')
  final String businessDate;
  @override
  @JsonKey(name: 'amount_cents')
  final int amountCents;
  @override
  @JsonKey(name: 'direction', unknownEnumValue: Direction.unknown)
  final Direction direction;
  @override
  @JsonKey(name: 'department')
  final String? department;
  @override
  @JsonKey(name: 'person')
  final String? person;
  @override
  @JsonKey(name: 'description')
  final String description;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'NormalizedRecordDto(id: $id, recordType: $recordType, businessDate: $businessDate, amountCents: $amountCents, direction: $direction, department: $department, person: $person, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NormalizedRecordDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.recordType, recordType) ||
                other.recordType == recordType) &&
            (identical(other.businessDate, businessDate) ||
                other.businessDate == businessDate) &&
            (identical(other.amountCents, amountCents) ||
                other.amountCents == amountCents) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.person, person) || other.person == person) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    recordType,
    businessDate,
    amountCents,
    direction,
    department,
    person,
    description,
    createdAt,
  );

  /// Create a copy of NormalizedRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NormalizedRecordDtoImplCopyWith<_$NormalizedRecordDtoImpl> get copyWith =>
      __$$NormalizedRecordDtoImplCopyWithImpl<_$NormalizedRecordDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NormalizedRecordDtoImplToJson(this);
  }
}

abstract class _NormalizedRecordDto implements NormalizedRecordDto {
  const factory _NormalizedRecordDto({
    required final int id,
    @JsonKey(name: 'record_type', unknownEnumValue: RecordType.unknown)
    required final RecordType recordType,
    @JsonKey(name: 'business_date') final String businessDate,
    @JsonKey(name: 'amount_cents') final int amountCents,
    @JsonKey(name: 'direction', unknownEnumValue: Direction.unknown)
    required final Direction direction,
    @JsonKey(name: 'department') final String? department,
    @JsonKey(name: 'person') final String? person,
    @JsonKey(name: 'description') final String description,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$NormalizedRecordDtoImpl;

  factory _NormalizedRecordDto.fromJson(Map<String, dynamic> json) =
      _$NormalizedRecordDtoImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'record_type', unknownEnumValue: RecordType.unknown)
  RecordType get recordType;
  @override
  @JsonKey(name: 'business_date')
  String get businessDate;
  @override
  @JsonKey(name: 'amount_cents')
  int get amountCents;
  @override
  @JsonKey(name: 'direction', unknownEnumValue: Direction.unknown)
  Direction get direction;
  @override
  @JsonKey(name: 'department')
  String? get department;
  @override
  @JsonKey(name: 'person')
  String? get person;
  @override
  @JsonKey(name: 'description')
  String get description;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of NormalizedRecordDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NormalizedRecordDtoImplCopyWith<_$NormalizedRecordDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
