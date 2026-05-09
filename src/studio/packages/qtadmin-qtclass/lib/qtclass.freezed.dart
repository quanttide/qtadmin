// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qtclass.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QtClassComponent {

 QtClassComponentType get type; String get name; String get description; String get status; int get studentCount; int get projectCount; String? get deadline; List<String> get highlights;
/// Create a copy of QtClassComponent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QtClassComponentCopyWith<QtClassComponent> get copyWith => _$QtClassComponentCopyWithImpl<QtClassComponent>(this as QtClassComponent, _$identity);

  /// Serializes this QtClassComponent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QtClassComponent&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.studentCount, studentCount) || other.studentCount == studentCount)&&(identical(other.projectCount, projectCount) || other.projectCount == projectCount)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&const DeepCollectionEquality().equals(other.highlights, highlights));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,name,description,status,studentCount,projectCount,deadline,const DeepCollectionEquality().hash(highlights));

@override
String toString() {
  return 'QtClassComponent(type: $type, name: $name, description: $description, status: $status, studentCount: $studentCount, projectCount: $projectCount, deadline: $deadline, highlights: $highlights)';
}


}

/// @nodoc
abstract mixin class $QtClassComponentCopyWith<$Res>  {
  factory $QtClassComponentCopyWith(QtClassComponent value, $Res Function(QtClassComponent) _then) = _$QtClassComponentCopyWithImpl;
@useResult
$Res call({
 QtClassComponentType type, String name, String description, String status, int studentCount, int projectCount, String? deadline, List<String> highlights
});




}
/// @nodoc
class _$QtClassComponentCopyWithImpl<$Res>
    implements $QtClassComponentCopyWith<$Res> {
  _$QtClassComponentCopyWithImpl(this._self, this._then);

  final QtClassComponent _self;
  final $Res Function(QtClassComponent) _then;

/// Create a copy of QtClassComponent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? name = null,Object? description = null,Object? status = null,Object? studentCount = null,Object? projectCount = null,Object? deadline = freezed,Object? highlights = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as QtClassComponentType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,studentCount: null == studentCount ? _self.studentCount : studentCount // ignore: cast_nullable_to_non_nullable
as int,projectCount: null == projectCount ? _self.projectCount : projectCount // ignore: cast_nullable_to_non_nullable
as int,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String?,highlights: null == highlights ? _self.highlights : highlights // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [QtClassComponent].
extension QtClassComponentPatterns on QtClassComponent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QtClassComponent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QtClassComponent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QtClassComponent value)  $default,){
final _that = this;
switch (_that) {
case _QtClassComponent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QtClassComponent value)?  $default,){
final _that = this;
switch (_that) {
case _QtClassComponent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QtClassComponentType type,  String name,  String description,  String status,  int studentCount,  int projectCount,  String? deadline,  List<String> highlights)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QtClassComponent() when $default != null:
return $default(_that.type,_that.name,_that.description,_that.status,_that.studentCount,_that.projectCount,_that.deadline,_that.highlights);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QtClassComponentType type,  String name,  String description,  String status,  int studentCount,  int projectCount,  String? deadline,  List<String> highlights)  $default,) {final _that = this;
switch (_that) {
case _QtClassComponent():
return $default(_that.type,_that.name,_that.description,_that.status,_that.studentCount,_that.projectCount,_that.deadline,_that.highlights);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QtClassComponentType type,  String name,  String description,  String status,  int studentCount,  int projectCount,  String? deadline,  List<String> highlights)?  $default,) {final _that = this;
switch (_that) {
case _QtClassComponent() when $default != null:
return $default(_that.type,_that.name,_that.description,_that.status,_that.studentCount,_that.projectCount,_that.deadline,_that.highlights);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QtClassComponent implements QtClassComponent {
  const _QtClassComponent({required this.type, required this.name, required this.description, required this.status, required this.studentCount, required this.projectCount, this.deadline, required final  List<String> highlights}): _highlights = highlights;
  factory _QtClassComponent.fromJson(Map<String, dynamic> json) => _$QtClassComponentFromJson(json);

@override final  QtClassComponentType type;
@override final  String name;
@override final  String description;
@override final  String status;
@override final  int studentCount;
@override final  int projectCount;
@override final  String? deadline;
 final  List<String> _highlights;
@override List<String> get highlights {
  if (_highlights is EqualUnmodifiableListView) return _highlights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_highlights);
}


/// Create a copy of QtClassComponent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QtClassComponentCopyWith<_QtClassComponent> get copyWith => __$QtClassComponentCopyWithImpl<_QtClassComponent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QtClassComponentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QtClassComponent&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.studentCount, studentCount) || other.studentCount == studentCount)&&(identical(other.projectCount, projectCount) || other.projectCount == projectCount)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&const DeepCollectionEquality().equals(other._highlights, _highlights));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,name,description,status,studentCount,projectCount,deadline,const DeepCollectionEquality().hash(_highlights));

@override
String toString() {
  return 'QtClassComponent(type: $type, name: $name, description: $description, status: $status, studentCount: $studentCount, projectCount: $projectCount, deadline: $deadline, highlights: $highlights)';
}


}

/// @nodoc
abstract mixin class _$QtClassComponentCopyWith<$Res> implements $QtClassComponentCopyWith<$Res> {
  factory _$QtClassComponentCopyWith(_QtClassComponent value, $Res Function(_QtClassComponent) _then) = __$QtClassComponentCopyWithImpl;
@override @useResult
$Res call({
 QtClassComponentType type, String name, String description, String status, int studentCount, int projectCount, String? deadline, List<String> highlights
});




}
/// @nodoc
class __$QtClassComponentCopyWithImpl<$Res>
    implements _$QtClassComponentCopyWith<$Res> {
  __$QtClassComponentCopyWithImpl(this._self, this._then);

  final _QtClassComponent _self;
  final $Res Function(_QtClassComponent) _then;

/// Create a copy of QtClassComponent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? name = null,Object? description = null,Object? status = null,Object? studentCount = null,Object? projectCount = null,Object? deadline = freezed,Object? highlights = null,}) {
  return _then(_QtClassComponent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as QtClassComponentType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,studentCount: null == studentCount ? _self.studentCount : studentCount // ignore: cast_nullable_to_non_nullable
as int,projectCount: null == projectCount ? _self.projectCount : projectCount // ignore: cast_nullable_to_non_nullable
as int,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String?,highlights: null == highlights ? _self._highlights : highlights // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$QtClass {

 List<QtClassComponent> get components;
/// Create a copy of QtClass
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QtClassCopyWith<QtClass> get copyWith => _$QtClassCopyWithImpl<QtClass>(this as QtClass, _$identity);

  /// Serializes this QtClass to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QtClass&&const DeepCollectionEquality().equals(other.components, components));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(components));

@override
String toString() {
  return 'QtClass(components: $components)';
}


}

/// @nodoc
abstract mixin class $QtClassCopyWith<$Res>  {
  factory $QtClassCopyWith(QtClass value, $Res Function(QtClass) _then) = _$QtClassCopyWithImpl;
@useResult
$Res call({
 List<QtClassComponent> components
});




}
/// @nodoc
class _$QtClassCopyWithImpl<$Res>
    implements $QtClassCopyWith<$Res> {
  _$QtClassCopyWithImpl(this._self, this._then);

  final QtClass _self;
  final $Res Function(QtClass) _then;

/// Create a copy of QtClass
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? components = null,}) {
  return _then(_self.copyWith(
components: null == components ? _self.components : components // ignore: cast_nullable_to_non_nullable
as List<QtClassComponent>,
  ));
}

}


/// Adds pattern-matching-related methods to [QtClass].
extension QtClassPatterns on QtClass {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QtClass value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QtClass() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QtClass value)  $default,){
final _that = this;
switch (_that) {
case _QtClass():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QtClass value)?  $default,){
final _that = this;
switch (_that) {
case _QtClass() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<QtClassComponent> components)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QtClass() when $default != null:
return $default(_that.components);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<QtClassComponent> components)  $default,) {final _that = this;
switch (_that) {
case _QtClass():
return $default(_that.components);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<QtClassComponent> components)?  $default,) {final _that = this;
switch (_that) {
case _QtClass() when $default != null:
return $default(_that.components);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QtClass implements QtClass {
  const _QtClass({required final  List<QtClassComponent> components}): _components = components;
  factory _QtClass.fromJson(Map<String, dynamic> json) => _$QtClassFromJson(json);

 final  List<QtClassComponent> _components;
@override List<QtClassComponent> get components {
  if (_components is EqualUnmodifiableListView) return _components;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_components);
}


/// Create a copy of QtClass
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QtClassCopyWith<_QtClass> get copyWith => __$QtClassCopyWithImpl<_QtClass>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QtClassToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QtClass&&const DeepCollectionEquality().equals(other._components, _components));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_components));

@override
String toString() {
  return 'QtClass(components: $components)';
}


}

/// @nodoc
abstract mixin class _$QtClassCopyWith<$Res> implements $QtClassCopyWith<$Res> {
  factory _$QtClassCopyWith(_QtClass value, $Res Function(_QtClass) _then) = __$QtClassCopyWithImpl;
@override @useResult
$Res call({
 List<QtClassComponent> components
});




}
/// @nodoc
class __$QtClassCopyWithImpl<$Res>
    implements _$QtClassCopyWith<$Res> {
  __$QtClassCopyWithImpl(this._self, this._then);

  final _QtClass _self;
  final $Res Function(_QtClass) _then;

/// Create a copy of QtClass
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? components = null,}) {
  return _then(_QtClass(
components: null == components ? _self._components : components // ignore: cast_nullable_to_non_nullable
as List<QtClassComponent>,
  ));
}


}

// dart format on
