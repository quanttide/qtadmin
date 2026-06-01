// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journal_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JournalEntryLine _$JournalEntryLineFromJson(Map<String, dynamic> json) {
  return _JournalEntryLine.fromJson(json);
}

/// @nodoc
mixin _$JournalEntryLine {
  String get id => throw _privateConstructorUsedError;
  LineType get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this JournalEntryLine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JournalEntryLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JournalEntryLineCopyWith<JournalEntryLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JournalEntryLineCopyWith<$Res> {
  factory $JournalEntryLineCopyWith(
    JournalEntryLine value,
    $Res Function(JournalEntryLine) then,
  ) = _$JournalEntryLineCopyWithImpl<$Res, JournalEntryLine>;
  @useResult
  $Res call({
    String id,
    LineType type,
    double amount,
    String description,
    DateTime createdAt,
  });
}

/// @nodoc
class _$JournalEntryLineCopyWithImpl<$Res, $Val extends JournalEntryLine>
    implements $JournalEntryLineCopyWith<$Res> {
  _$JournalEntryLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JournalEntryLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as LineType,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
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
abstract class _$$JournalEntryLineImplCopyWith<$Res>
    implements $JournalEntryLineCopyWith<$Res> {
  factory _$$JournalEntryLineImplCopyWith(
    _$JournalEntryLineImpl value,
    $Res Function(_$JournalEntryLineImpl) then,
  ) = __$$JournalEntryLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    LineType type,
    double amount,
    String description,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$JournalEntryLineImplCopyWithImpl<$Res>
    extends _$JournalEntryLineCopyWithImpl<$Res, _$JournalEntryLineImpl>
    implements _$$JournalEntryLineImplCopyWith<$Res> {
  __$$JournalEntryLineImplCopyWithImpl(
    _$JournalEntryLineImpl _value,
    $Res Function(_$JournalEntryLineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JournalEntryLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$JournalEntryLineImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as LineType,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
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
class _$JournalEntryLineImpl extends _JournalEntryLine {
  const _$JournalEntryLineImpl({
    required this.id,
    required this.type,
    this.amount = 0,
    this.description = '',
    required this.createdAt,
  }) : assert(amount >= 0, 'amount must be non-negative'),
       super._();

  factory _$JournalEntryLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$JournalEntryLineImplFromJson(json);

  @override
  final String id;
  @override
  final LineType type;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final String description;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'JournalEntryLine(id: $id, type: $type, amount: $amount, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JournalEntryLineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, amount, description, createdAt);

  /// Create a copy of JournalEntryLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JournalEntryLineImplCopyWith<_$JournalEntryLineImpl> get copyWith =>
      __$$JournalEntryLineImplCopyWithImpl<_$JournalEntryLineImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JournalEntryLineImplToJson(this);
  }
}

abstract class _JournalEntryLine extends JournalEntryLine {
  const factory _JournalEntryLine({
    required final String id,
    required final LineType type,
    final double amount,
    final String description,
    required final DateTime createdAt,
  }) = _$JournalEntryLineImpl;
  const _JournalEntryLine._() : super._();

  factory _JournalEntryLine.fromJson(Map<String, dynamic> json) =
      _$JournalEntryLineImpl.fromJson;

  @override
  String get id;
  @override
  LineType get type;
  @override
  double get amount;
  @override
  String get description;
  @override
  DateTime get createdAt;

  /// Create a copy of JournalEntryLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JournalEntryLineImplCopyWith<_$JournalEntryLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) {
  return _JournalEntry.fromJson(json);
}

/// @nodoc
mixin _$JournalEntry {
  String get id => throw _privateConstructorUsedError;
  String get journalId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(toJson: _linesToJson)
  List<JournalEntryLine> get lines => throw _privateConstructorUsedError;

  /// Serializes this JournalEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JournalEntryCopyWith<JournalEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JournalEntryCopyWith<$Res> {
  factory $JournalEntryCopyWith(
    JournalEntry value,
    $Res Function(JournalEntry) then,
  ) = _$JournalEntryCopyWithImpl<$Res, JournalEntry>;
  @useResult
  $Res call({
    String id,
    String journalId,
    DateTime createdAt,
    String description,
    @JsonKey(toJson: _linesToJson) List<JournalEntryLine> lines,
  });
}

/// @nodoc
class _$JournalEntryCopyWithImpl<$Res, $Val extends JournalEntry>
    implements $JournalEntryCopyWith<$Res> {
  _$JournalEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? journalId = null,
    Object? createdAt = null,
    Object? description = null,
    Object? lines = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            journalId: null == journalId
                ? _value.journalId
                : journalId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            lines: null == lines
                ? _value.lines
                : lines // ignore: cast_nullable_to_non_nullable
                      as List<JournalEntryLine>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JournalEntryImplCopyWith<$Res>
    implements $JournalEntryCopyWith<$Res> {
  factory _$$JournalEntryImplCopyWith(
    _$JournalEntryImpl value,
    $Res Function(_$JournalEntryImpl) then,
  ) = __$$JournalEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String journalId,
    DateTime createdAt,
    String description,
    @JsonKey(toJson: _linesToJson) List<JournalEntryLine> lines,
  });
}

/// @nodoc
class __$$JournalEntryImplCopyWithImpl<$Res>
    extends _$JournalEntryCopyWithImpl<$Res, _$JournalEntryImpl>
    implements _$$JournalEntryImplCopyWith<$Res> {
  __$$JournalEntryImplCopyWithImpl(
    _$JournalEntryImpl _value,
    $Res Function(_$JournalEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? journalId = null,
    Object? createdAt = null,
    Object? description = null,
    Object? lines = null,
  }) {
    return _then(
      _$JournalEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        journalId: null == journalId
            ? _value.journalId
            : journalId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        lines: null == lines
            ? _value._lines
            : lines // ignore: cast_nullable_to_non_nullable
                  as List<JournalEntryLine>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JournalEntryImpl implements _JournalEntry {
  const _$JournalEntryImpl({
    required this.id,
    required this.journalId,
    required this.createdAt,
    this.description = '',
    @JsonKey(toJson: _linesToJson)
    final List<JournalEntryLine> lines = const <JournalEntryLine>[],
  }) : _lines = lines;

  factory _$JournalEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$JournalEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String journalId;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final String description;
  final List<JournalEntryLine> _lines;
  @override
  @JsonKey(toJson: _linesToJson)
  List<JournalEntryLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  String toString() {
    return 'JournalEntry(id: $id, journalId: $journalId, createdAt: $createdAt, description: $description, lines: $lines)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JournalEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.journalId, journalId) ||
                other.journalId == journalId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._lines, _lines));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    journalId,
    createdAt,
    description,
    const DeepCollectionEquality().hash(_lines),
  );

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JournalEntryImplCopyWith<_$JournalEntryImpl> get copyWith =>
      __$$JournalEntryImplCopyWithImpl<_$JournalEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JournalEntryImplToJson(this);
  }
}

abstract class _JournalEntry implements JournalEntry {
  const factory _JournalEntry({
    required final String id,
    required final String journalId,
    required final DateTime createdAt,
    final String description,
    @JsonKey(toJson: _linesToJson) final List<JournalEntryLine> lines,
  }) = _$JournalEntryImpl;

  factory _JournalEntry.fromJson(Map<String, dynamic> json) =
      _$JournalEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get journalId;
  @override
  DateTime get createdAt;
  @override
  String get description;
  @override
  @JsonKey(toJson: _linesToJson)
  List<JournalEntryLine> get lines;

  /// Create a copy of JournalEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JournalEntryImplCopyWith<_$JournalEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
