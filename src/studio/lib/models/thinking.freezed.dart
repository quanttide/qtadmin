// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thinking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThinkingEmotion {

 String get label; String get value;@JsonKey(name: 'color', fromJson: parseHexColor) int get colorValue;
/// Create a copy of ThinkingEmotion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThinkingEmotionCopyWith<ThinkingEmotion> get copyWith => _$ThinkingEmotionCopyWithImpl<ThinkingEmotion>(this as ThinkingEmotion, _$identity);

  /// Serializes this ThinkingEmotion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThinkingEmotion&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value,colorValue);

@override
String toString() {
  return 'ThinkingEmotion(label: $label, value: $value, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class $ThinkingEmotionCopyWith<$Res>  {
  factory $ThinkingEmotionCopyWith(ThinkingEmotion value, $Res Function(ThinkingEmotion) _then) = _$ThinkingEmotionCopyWithImpl;
@useResult
$Res call({
 String label, String value,@JsonKey(name: 'color', fromJson: parseHexColor) int colorValue
});




}
/// @nodoc
class _$ThinkingEmotionCopyWithImpl<$Res>
    implements $ThinkingEmotionCopyWith<$Res> {
  _$ThinkingEmotionCopyWithImpl(this._self, this._then);

  final ThinkingEmotion _self;
  final $Res Function(ThinkingEmotion) _then;

/// Create a copy of ThinkingEmotion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? value = null,Object? colorValue = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ThinkingEmotion].
extension ThinkingEmotionPatterns on ThinkingEmotion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThinkingEmotion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThinkingEmotion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThinkingEmotion value)  $default,){
final _that = this;
switch (_that) {
case _ThinkingEmotion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThinkingEmotion value)?  $default,){
final _that = this;
switch (_that) {
case _ThinkingEmotion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String value, @JsonKey(name: 'color', fromJson: parseHexColor)  int colorValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThinkingEmotion() when $default != null:
return $default(_that.label,_that.value,_that.colorValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String value, @JsonKey(name: 'color', fromJson: parseHexColor)  int colorValue)  $default,) {final _that = this;
switch (_that) {
case _ThinkingEmotion():
return $default(_that.label,_that.value,_that.colorValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String value, @JsonKey(name: 'color', fromJson: parseHexColor)  int colorValue)?  $default,) {final _that = this;
switch (_that) {
case _ThinkingEmotion() when $default != null:
return $default(_that.label,_that.value,_that.colorValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThinkingEmotion extends ThinkingEmotion {
  const _ThinkingEmotion({required this.label, required this.value, @JsonKey(name: 'color', fromJson: parseHexColor) required this.colorValue}): super._();
  factory _ThinkingEmotion.fromJson(Map<String, dynamic> json) => _$ThinkingEmotionFromJson(json);

@override final  String label;
@override final  String value;
@override@JsonKey(name: 'color', fromJson: parseHexColor) final  int colorValue;

/// Create a copy of ThinkingEmotion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThinkingEmotionCopyWith<_ThinkingEmotion> get copyWith => __$ThinkingEmotionCopyWithImpl<_ThinkingEmotion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThinkingEmotionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThinkingEmotion&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value,colorValue);

@override
String toString() {
  return 'ThinkingEmotion(label: $label, value: $value, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class _$ThinkingEmotionCopyWith<$Res> implements $ThinkingEmotionCopyWith<$Res> {
  factory _$ThinkingEmotionCopyWith(_ThinkingEmotion value, $Res Function(_ThinkingEmotion) _then) = __$ThinkingEmotionCopyWithImpl;
@override @useResult
$Res call({
 String label, String value,@JsonKey(name: 'color', fromJson: parseHexColor) int colorValue
});




}
/// @nodoc
class __$ThinkingEmotionCopyWithImpl<$Res>
    implements _$ThinkingEmotionCopyWith<$Res> {
  __$ThinkingEmotionCopyWithImpl(this._self, this._then);

  final _ThinkingEmotion _self;
  final $Res Function(_ThinkingEmotion) _then;

/// Create a copy of ThinkingEmotion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? value = null,Object? colorValue = null,}) {
  return _then(_ThinkingEmotion(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ThinkingStage {

@JsonKey(name: 'icon') String get iconName; String get title; String get subtitle; List<String> get points;@JsonKey(name: 'color', fromJson: parseHexColor) int get colorValue;
/// Create a copy of ThinkingStage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThinkingStageCopyWith<ThinkingStage> get copyWith => _$ThinkingStageCopyWithImpl<ThinkingStage>(this as ThinkingStage, _$identity);

  /// Serializes this ThinkingStage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThinkingStage&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iconName,title,subtitle,const DeepCollectionEquality().hash(points),colorValue);

@override
String toString() {
  return 'ThinkingStage(iconName: $iconName, title: $title, subtitle: $subtitle, points: $points, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class $ThinkingStageCopyWith<$Res>  {
  factory $ThinkingStageCopyWith(ThinkingStage value, $Res Function(ThinkingStage) _then) = _$ThinkingStageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'icon') String iconName, String title, String subtitle, List<String> points,@JsonKey(name: 'color', fromJson: parseHexColor) int colorValue
});




}
/// @nodoc
class _$ThinkingStageCopyWithImpl<$Res>
    implements $ThinkingStageCopyWith<$Res> {
  _$ThinkingStageCopyWithImpl(this._self, this._then);

  final ThinkingStage _self;
  final $Res Function(ThinkingStage) _then;

/// Create a copy of ThinkingStage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? iconName = null,Object? title = null,Object? subtitle = null,Object? points = null,Object? colorValue = null,}) {
  return _then(_self.copyWith(
iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<String>,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ThinkingStage].
extension ThinkingStagePatterns on ThinkingStage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThinkingStage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThinkingStage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThinkingStage value)  $default,){
final _that = this;
switch (_that) {
case _ThinkingStage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThinkingStage value)?  $default,){
final _that = this;
switch (_that) {
case _ThinkingStage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'icon')  String iconName,  String title,  String subtitle,  List<String> points, @JsonKey(name: 'color', fromJson: parseHexColor)  int colorValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThinkingStage() when $default != null:
return $default(_that.iconName,_that.title,_that.subtitle,_that.points,_that.colorValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'icon')  String iconName,  String title,  String subtitle,  List<String> points, @JsonKey(name: 'color', fromJson: parseHexColor)  int colorValue)  $default,) {final _that = this;
switch (_that) {
case _ThinkingStage():
return $default(_that.iconName,_that.title,_that.subtitle,_that.points,_that.colorValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'icon')  String iconName,  String title,  String subtitle,  List<String> points, @JsonKey(name: 'color', fromJson: parseHexColor)  int colorValue)?  $default,) {final _that = this;
switch (_that) {
case _ThinkingStage() when $default != null:
return $default(_that.iconName,_that.title,_that.subtitle,_that.points,_that.colorValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThinkingStage extends ThinkingStage {
  const _ThinkingStage({@JsonKey(name: 'icon') required this.iconName, required this.title, required this.subtitle, required final  List<String> points, @JsonKey(name: 'color', fromJson: parseHexColor) required this.colorValue}): _points = points,super._();
  factory _ThinkingStage.fromJson(Map<String, dynamic> json) => _$ThinkingStageFromJson(json);

@override@JsonKey(name: 'icon') final  String iconName;
@override final  String title;
@override final  String subtitle;
 final  List<String> _points;
@override List<String> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override@JsonKey(name: 'color', fromJson: parseHexColor) final  int colorValue;

/// Create a copy of ThinkingStage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThinkingStageCopyWith<_ThinkingStage> get copyWith => __$ThinkingStageCopyWithImpl<_ThinkingStage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThinkingStageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThinkingStage&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iconName,title,subtitle,const DeepCollectionEquality().hash(_points),colorValue);

@override
String toString() {
  return 'ThinkingStage(iconName: $iconName, title: $title, subtitle: $subtitle, points: $points, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class _$ThinkingStageCopyWith<$Res> implements $ThinkingStageCopyWith<$Res> {
  factory _$ThinkingStageCopyWith(_ThinkingStage value, $Res Function(_ThinkingStage) _then) = __$ThinkingStageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'icon') String iconName, String title, String subtitle, List<String> points,@JsonKey(name: 'color', fromJson: parseHexColor) int colorValue
});




}
/// @nodoc
class __$ThinkingStageCopyWithImpl<$Res>
    implements _$ThinkingStageCopyWith<$Res> {
  __$ThinkingStageCopyWithImpl(this._self, this._then);

  final _ThinkingStage _self;
  final $Res Function(_ThinkingStage) _then;

/// Create a copy of ThinkingStage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? iconName = null,Object? title = null,Object? subtitle = null,Object? points = null,Object? colorValue = null,}) {
  return _then(_ThinkingStage(
iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<String>,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ThinkingInsight {

@JsonKey(name: 'icon') String get iconName; String get title; String get description;
/// Create a copy of ThinkingInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThinkingInsightCopyWith<ThinkingInsight> get copyWith => _$ThinkingInsightCopyWithImpl<ThinkingInsight>(this as ThinkingInsight, _$identity);

  /// Serializes this ThinkingInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThinkingInsight&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iconName,title,description);

@override
String toString() {
  return 'ThinkingInsight(iconName: $iconName, title: $title, description: $description)';
}


}

/// @nodoc
abstract mixin class $ThinkingInsightCopyWith<$Res>  {
  factory $ThinkingInsightCopyWith(ThinkingInsight value, $Res Function(ThinkingInsight) _then) = _$ThinkingInsightCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'icon') String iconName, String title, String description
});




}
/// @nodoc
class _$ThinkingInsightCopyWithImpl<$Res>
    implements $ThinkingInsightCopyWith<$Res> {
  _$ThinkingInsightCopyWithImpl(this._self, this._then);

  final ThinkingInsight _self;
  final $Res Function(ThinkingInsight) _then;

/// Create a copy of ThinkingInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? iconName = null,Object? title = null,Object? description = null,}) {
  return _then(_self.copyWith(
iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ThinkingInsight].
extension ThinkingInsightPatterns on ThinkingInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThinkingInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThinkingInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThinkingInsight value)  $default,){
final _that = this;
switch (_that) {
case _ThinkingInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThinkingInsight value)?  $default,){
final _that = this;
switch (_that) {
case _ThinkingInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'icon')  String iconName,  String title,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThinkingInsight() when $default != null:
return $default(_that.iconName,_that.title,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'icon')  String iconName,  String title,  String description)  $default,) {final _that = this;
switch (_that) {
case _ThinkingInsight():
return $default(_that.iconName,_that.title,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'icon')  String iconName,  String title,  String description)?  $default,) {final _that = this;
switch (_that) {
case _ThinkingInsight() when $default != null:
return $default(_that.iconName,_that.title,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThinkingInsight implements ThinkingInsight {
  const _ThinkingInsight({@JsonKey(name: 'icon') required this.iconName, required this.title, required this.description});
  factory _ThinkingInsight.fromJson(Map<String, dynamic> json) => _$ThinkingInsightFromJson(json);

@override@JsonKey(name: 'icon') final  String iconName;
@override final  String title;
@override final  String description;

/// Create a copy of ThinkingInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThinkingInsightCopyWith<_ThinkingInsight> get copyWith => __$ThinkingInsightCopyWithImpl<_ThinkingInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThinkingInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThinkingInsight&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iconName,title,description);

@override
String toString() {
  return 'ThinkingInsight(iconName: $iconName, title: $title, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ThinkingInsightCopyWith<$Res> implements $ThinkingInsightCopyWith<$Res> {
  factory _$ThinkingInsightCopyWith(_ThinkingInsight value, $Res Function(_ThinkingInsight) _then) = __$ThinkingInsightCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'icon') String iconName, String title, String description
});




}
/// @nodoc
class __$ThinkingInsightCopyWithImpl<$Res>
    implements _$ThinkingInsightCopyWith<$Res> {
  __$ThinkingInsightCopyWithImpl(this._self, this._then);

  final _ThinkingInsight _self;
  final $Res Function(_ThinkingInsight) _then;

/// Create a copy of ThinkingInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? iconName = null,Object? title = null,Object? description = null,}) {
  return _then(_ThinkingInsight(
iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ThinkingClosing {

 String get title; String get description; String get quote;
/// Create a copy of ThinkingClosing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThinkingClosingCopyWith<ThinkingClosing> get copyWith => _$ThinkingClosingCopyWithImpl<ThinkingClosing>(this as ThinkingClosing, _$identity);

  /// Serializes this ThinkingClosing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThinkingClosing&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.quote, quote) || other.quote == quote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,quote);

@override
String toString() {
  return 'ThinkingClosing(title: $title, description: $description, quote: $quote)';
}


}

/// @nodoc
abstract mixin class $ThinkingClosingCopyWith<$Res>  {
  factory $ThinkingClosingCopyWith(ThinkingClosing value, $Res Function(ThinkingClosing) _then) = _$ThinkingClosingCopyWithImpl;
@useResult
$Res call({
 String title, String description, String quote
});




}
/// @nodoc
class _$ThinkingClosingCopyWithImpl<$Res>
    implements $ThinkingClosingCopyWith<$Res> {
  _$ThinkingClosingCopyWithImpl(this._self, this._then);

  final ThinkingClosing _self;
  final $Res Function(ThinkingClosing) _then;

/// Create a copy of ThinkingClosing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? quote = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ThinkingClosing].
extension ThinkingClosingPatterns on ThinkingClosing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThinkingClosing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThinkingClosing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThinkingClosing value)  $default,){
final _that = this;
switch (_that) {
case _ThinkingClosing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThinkingClosing value)?  $default,){
final _that = this;
switch (_that) {
case _ThinkingClosing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description,  String quote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThinkingClosing() when $default != null:
return $default(_that.title,_that.description,_that.quote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description,  String quote)  $default,) {final _that = this;
switch (_that) {
case _ThinkingClosing():
return $default(_that.title,_that.description,_that.quote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description,  String quote)?  $default,) {final _that = this;
switch (_that) {
case _ThinkingClosing() when $default != null:
return $default(_that.title,_that.description,_that.quote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThinkingClosing implements ThinkingClosing {
  const _ThinkingClosing({required this.title, required this.description, required this.quote});
  factory _ThinkingClosing.fromJson(Map<String, dynamic> json) => _$ThinkingClosingFromJson(json);

@override final  String title;
@override final  String description;
@override final  String quote;

/// Create a copy of ThinkingClosing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThinkingClosingCopyWith<_ThinkingClosing> get copyWith => __$ThinkingClosingCopyWithImpl<_ThinkingClosing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThinkingClosingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThinkingClosing&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.quote, quote) || other.quote == quote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,quote);

@override
String toString() {
  return 'ThinkingClosing(title: $title, description: $description, quote: $quote)';
}


}

/// @nodoc
abstract mixin class _$ThinkingClosingCopyWith<$Res> implements $ThinkingClosingCopyWith<$Res> {
  factory _$ThinkingClosingCopyWith(_ThinkingClosing value, $Res Function(_ThinkingClosing) _then) = __$ThinkingClosingCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, String quote
});




}
/// @nodoc
class __$ThinkingClosingCopyWithImpl<$Res>
    implements _$ThinkingClosingCopyWith<$Res> {
  __$ThinkingClosingCopyWithImpl(this._self, this._then);

  final _ThinkingClosing _self;
  final $Res Function(_ThinkingClosing) _then;

/// Create a copy of ThinkingClosing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? quote = null,}) {
  return _then(_ThinkingClosing(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Thinking {

 String get title; String get subtitle; String get period; List<ThinkingStage> get stages; List<ThinkingEmotion> get emotions; String get emotionNote; String get awarenessSectionLabel; String get awarenessSectionIcon; int get awarenessSectionColor; List<ThinkingInsight> get insights; String get insightSectionLabel; String get insightSectionIcon; int get insightSectionColor; ThinkingClosing get closing;
/// Create a copy of Thinking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThinkingCopyWith<Thinking> get copyWith => _$ThinkingCopyWithImpl<Thinking>(this as Thinking, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Thinking&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other.stages, stages)&&const DeepCollectionEquality().equals(other.emotions, emotions)&&(identical(other.emotionNote, emotionNote) || other.emotionNote == emotionNote)&&(identical(other.awarenessSectionLabel, awarenessSectionLabel) || other.awarenessSectionLabel == awarenessSectionLabel)&&(identical(other.awarenessSectionIcon, awarenessSectionIcon) || other.awarenessSectionIcon == awarenessSectionIcon)&&(identical(other.awarenessSectionColor, awarenessSectionColor) || other.awarenessSectionColor == awarenessSectionColor)&&const DeepCollectionEquality().equals(other.insights, insights)&&(identical(other.insightSectionLabel, insightSectionLabel) || other.insightSectionLabel == insightSectionLabel)&&(identical(other.insightSectionIcon, insightSectionIcon) || other.insightSectionIcon == insightSectionIcon)&&(identical(other.insightSectionColor, insightSectionColor) || other.insightSectionColor == insightSectionColor)&&(identical(other.closing, closing) || other.closing == closing));
}


@override
int get hashCode => Object.hash(runtimeType,title,subtitle,period,const DeepCollectionEquality().hash(stages),const DeepCollectionEquality().hash(emotions),emotionNote,awarenessSectionLabel,awarenessSectionIcon,awarenessSectionColor,const DeepCollectionEquality().hash(insights),insightSectionLabel,insightSectionIcon,insightSectionColor,closing);

@override
String toString() {
  return 'Thinking(title: $title, subtitle: $subtitle, period: $period, stages: $stages, emotions: $emotions, emotionNote: $emotionNote, awarenessSectionLabel: $awarenessSectionLabel, awarenessSectionIcon: $awarenessSectionIcon, awarenessSectionColor: $awarenessSectionColor, insights: $insights, insightSectionLabel: $insightSectionLabel, insightSectionIcon: $insightSectionIcon, insightSectionColor: $insightSectionColor, closing: $closing)';
}


}

/// @nodoc
abstract mixin class $ThinkingCopyWith<$Res>  {
  factory $ThinkingCopyWith(Thinking value, $Res Function(Thinking) _then) = _$ThinkingCopyWithImpl;
@useResult
$Res call({
 String title, String subtitle, String period, List<ThinkingStage> stages, List<ThinkingEmotion> emotions, String emotionNote, String awarenessSectionLabel, String awarenessSectionIcon, int awarenessSectionColor, List<ThinkingInsight> insights, String insightSectionLabel, String insightSectionIcon, int insightSectionColor, ThinkingClosing closing
});


$ThinkingClosingCopyWith<$Res> get closing;

}
/// @nodoc
class _$ThinkingCopyWithImpl<$Res>
    implements $ThinkingCopyWith<$Res> {
  _$ThinkingCopyWithImpl(this._self, this._then);

  final Thinking _self;
  final $Res Function(Thinking) _then;

/// Create a copy of Thinking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? subtitle = null,Object? period = null,Object? stages = null,Object? emotions = null,Object? emotionNote = null,Object? awarenessSectionLabel = null,Object? awarenessSectionIcon = null,Object? awarenessSectionColor = null,Object? insights = null,Object? insightSectionLabel = null,Object? insightSectionIcon = null,Object? insightSectionColor = null,Object? closing = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,stages: null == stages ? _self.stages : stages // ignore: cast_nullable_to_non_nullable
as List<ThinkingStage>,emotions: null == emotions ? _self.emotions : emotions // ignore: cast_nullable_to_non_nullable
as List<ThinkingEmotion>,emotionNote: null == emotionNote ? _self.emotionNote : emotionNote // ignore: cast_nullable_to_non_nullable
as String,awarenessSectionLabel: null == awarenessSectionLabel ? _self.awarenessSectionLabel : awarenessSectionLabel // ignore: cast_nullable_to_non_nullable
as String,awarenessSectionIcon: null == awarenessSectionIcon ? _self.awarenessSectionIcon : awarenessSectionIcon // ignore: cast_nullable_to_non_nullable
as String,awarenessSectionColor: null == awarenessSectionColor ? _self.awarenessSectionColor : awarenessSectionColor // ignore: cast_nullable_to_non_nullable
as int,insights: null == insights ? _self.insights : insights // ignore: cast_nullable_to_non_nullable
as List<ThinkingInsight>,insightSectionLabel: null == insightSectionLabel ? _self.insightSectionLabel : insightSectionLabel // ignore: cast_nullable_to_non_nullable
as String,insightSectionIcon: null == insightSectionIcon ? _self.insightSectionIcon : insightSectionIcon // ignore: cast_nullable_to_non_nullable
as String,insightSectionColor: null == insightSectionColor ? _self.insightSectionColor : insightSectionColor // ignore: cast_nullable_to_non_nullable
as int,closing: null == closing ? _self.closing : closing // ignore: cast_nullable_to_non_nullable
as ThinkingClosing,
  ));
}
/// Create a copy of Thinking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThinkingClosingCopyWith<$Res> get closing {
  
  return $ThinkingClosingCopyWith<$Res>(_self.closing, (value) {
    return _then(_self.copyWith(closing: value));
  });
}
}


/// Adds pattern-matching-related methods to [Thinking].
extension ThinkingPatterns on Thinking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Thinking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Thinking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Thinking value)  $default,){
final _that = this;
switch (_that) {
case _Thinking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Thinking value)?  $default,){
final _that = this;
switch (_that) {
case _Thinking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String subtitle,  String period,  List<ThinkingStage> stages,  List<ThinkingEmotion> emotions,  String emotionNote,  String awarenessSectionLabel,  String awarenessSectionIcon,  int awarenessSectionColor,  List<ThinkingInsight> insights,  String insightSectionLabel,  String insightSectionIcon,  int insightSectionColor,  ThinkingClosing closing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Thinking() when $default != null:
return $default(_that.title,_that.subtitle,_that.period,_that.stages,_that.emotions,_that.emotionNote,_that.awarenessSectionLabel,_that.awarenessSectionIcon,_that.awarenessSectionColor,_that.insights,_that.insightSectionLabel,_that.insightSectionIcon,_that.insightSectionColor,_that.closing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String subtitle,  String period,  List<ThinkingStage> stages,  List<ThinkingEmotion> emotions,  String emotionNote,  String awarenessSectionLabel,  String awarenessSectionIcon,  int awarenessSectionColor,  List<ThinkingInsight> insights,  String insightSectionLabel,  String insightSectionIcon,  int insightSectionColor,  ThinkingClosing closing)  $default,) {final _that = this;
switch (_that) {
case _Thinking():
return $default(_that.title,_that.subtitle,_that.period,_that.stages,_that.emotions,_that.emotionNote,_that.awarenessSectionLabel,_that.awarenessSectionIcon,_that.awarenessSectionColor,_that.insights,_that.insightSectionLabel,_that.insightSectionIcon,_that.insightSectionColor,_that.closing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String subtitle,  String period,  List<ThinkingStage> stages,  List<ThinkingEmotion> emotions,  String emotionNote,  String awarenessSectionLabel,  String awarenessSectionIcon,  int awarenessSectionColor,  List<ThinkingInsight> insights,  String insightSectionLabel,  String insightSectionIcon,  int insightSectionColor,  ThinkingClosing closing)?  $default,) {final _that = this;
switch (_that) {
case _Thinking() when $default != null:
return $default(_that.title,_that.subtitle,_that.period,_that.stages,_that.emotions,_that.emotionNote,_that.awarenessSectionLabel,_that.awarenessSectionIcon,_that.awarenessSectionColor,_that.insights,_that.insightSectionLabel,_that.insightSectionIcon,_that.insightSectionColor,_that.closing);case _:
  return null;

}
}

}

/// @nodoc


class _Thinking implements Thinking {
  const _Thinking({required this.title, required this.subtitle, required this.period, required final  List<ThinkingStage> stages, required final  List<ThinkingEmotion> emotions, required this.emotionNote, required this.awarenessSectionLabel, required this.awarenessSectionIcon, required this.awarenessSectionColor, required final  List<ThinkingInsight> insights, required this.insightSectionLabel, required this.insightSectionIcon, required this.insightSectionColor, required this.closing}): _stages = stages,_emotions = emotions,_insights = insights;
  

@override final  String title;
@override final  String subtitle;
@override final  String period;
 final  List<ThinkingStage> _stages;
@override List<ThinkingStage> get stages {
  if (_stages is EqualUnmodifiableListView) return _stages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stages);
}

 final  List<ThinkingEmotion> _emotions;
@override List<ThinkingEmotion> get emotions {
  if (_emotions is EqualUnmodifiableListView) return _emotions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_emotions);
}

@override final  String emotionNote;
@override final  String awarenessSectionLabel;
@override final  String awarenessSectionIcon;
@override final  int awarenessSectionColor;
 final  List<ThinkingInsight> _insights;
@override List<ThinkingInsight> get insights {
  if (_insights is EqualUnmodifiableListView) return _insights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_insights);
}

@override final  String insightSectionLabel;
@override final  String insightSectionIcon;
@override final  int insightSectionColor;
@override final  ThinkingClosing closing;

/// Create a copy of Thinking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThinkingCopyWith<_Thinking> get copyWith => __$ThinkingCopyWithImpl<_Thinking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Thinking&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other._stages, _stages)&&const DeepCollectionEquality().equals(other._emotions, _emotions)&&(identical(other.emotionNote, emotionNote) || other.emotionNote == emotionNote)&&(identical(other.awarenessSectionLabel, awarenessSectionLabel) || other.awarenessSectionLabel == awarenessSectionLabel)&&(identical(other.awarenessSectionIcon, awarenessSectionIcon) || other.awarenessSectionIcon == awarenessSectionIcon)&&(identical(other.awarenessSectionColor, awarenessSectionColor) || other.awarenessSectionColor == awarenessSectionColor)&&const DeepCollectionEquality().equals(other._insights, _insights)&&(identical(other.insightSectionLabel, insightSectionLabel) || other.insightSectionLabel == insightSectionLabel)&&(identical(other.insightSectionIcon, insightSectionIcon) || other.insightSectionIcon == insightSectionIcon)&&(identical(other.insightSectionColor, insightSectionColor) || other.insightSectionColor == insightSectionColor)&&(identical(other.closing, closing) || other.closing == closing));
}


@override
int get hashCode => Object.hash(runtimeType,title,subtitle,period,const DeepCollectionEquality().hash(_stages),const DeepCollectionEquality().hash(_emotions),emotionNote,awarenessSectionLabel,awarenessSectionIcon,awarenessSectionColor,const DeepCollectionEquality().hash(_insights),insightSectionLabel,insightSectionIcon,insightSectionColor,closing);

@override
String toString() {
  return 'Thinking(title: $title, subtitle: $subtitle, period: $period, stages: $stages, emotions: $emotions, emotionNote: $emotionNote, awarenessSectionLabel: $awarenessSectionLabel, awarenessSectionIcon: $awarenessSectionIcon, awarenessSectionColor: $awarenessSectionColor, insights: $insights, insightSectionLabel: $insightSectionLabel, insightSectionIcon: $insightSectionIcon, insightSectionColor: $insightSectionColor, closing: $closing)';
}


}

/// @nodoc
abstract mixin class _$ThinkingCopyWith<$Res> implements $ThinkingCopyWith<$Res> {
  factory _$ThinkingCopyWith(_Thinking value, $Res Function(_Thinking) _then) = __$ThinkingCopyWithImpl;
@override @useResult
$Res call({
 String title, String subtitle, String period, List<ThinkingStage> stages, List<ThinkingEmotion> emotions, String emotionNote, String awarenessSectionLabel, String awarenessSectionIcon, int awarenessSectionColor, List<ThinkingInsight> insights, String insightSectionLabel, String insightSectionIcon, int insightSectionColor, ThinkingClosing closing
});


@override $ThinkingClosingCopyWith<$Res> get closing;

}
/// @nodoc
class __$ThinkingCopyWithImpl<$Res>
    implements _$ThinkingCopyWith<$Res> {
  __$ThinkingCopyWithImpl(this._self, this._then);

  final _Thinking _self;
  final $Res Function(_Thinking) _then;

/// Create a copy of Thinking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? subtitle = null,Object? period = null,Object? stages = null,Object? emotions = null,Object? emotionNote = null,Object? awarenessSectionLabel = null,Object? awarenessSectionIcon = null,Object? awarenessSectionColor = null,Object? insights = null,Object? insightSectionLabel = null,Object? insightSectionIcon = null,Object? insightSectionColor = null,Object? closing = null,}) {
  return _then(_Thinking(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,stages: null == stages ? _self._stages : stages // ignore: cast_nullable_to_non_nullable
as List<ThinkingStage>,emotions: null == emotions ? _self._emotions : emotions // ignore: cast_nullable_to_non_nullable
as List<ThinkingEmotion>,emotionNote: null == emotionNote ? _self.emotionNote : emotionNote // ignore: cast_nullable_to_non_nullable
as String,awarenessSectionLabel: null == awarenessSectionLabel ? _self.awarenessSectionLabel : awarenessSectionLabel // ignore: cast_nullable_to_non_nullable
as String,awarenessSectionIcon: null == awarenessSectionIcon ? _self.awarenessSectionIcon : awarenessSectionIcon // ignore: cast_nullable_to_non_nullable
as String,awarenessSectionColor: null == awarenessSectionColor ? _self.awarenessSectionColor : awarenessSectionColor // ignore: cast_nullable_to_non_nullable
as int,insights: null == insights ? _self._insights : insights // ignore: cast_nullable_to_non_nullable
as List<ThinkingInsight>,insightSectionLabel: null == insightSectionLabel ? _self.insightSectionLabel : insightSectionLabel // ignore: cast_nullable_to_non_nullable
as String,insightSectionIcon: null == insightSectionIcon ? _self.insightSectionIcon : insightSectionIcon // ignore: cast_nullable_to_non_nullable
as String,insightSectionColor: null == insightSectionColor ? _self.insightSectionColor : insightSectionColor // ignore: cast_nullable_to_non_nullable
as int,closing: null == closing ? _self.closing : closing // ignore: cast_nullable_to_non_nullable
as ThinkingClosing,
  ));
}

/// Create a copy of Thinking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThinkingClosingCopyWith<$Res> get closing {
  
  return $ThinkingClosingCopyWith<$Res>(_self.closing, (value) {
    return _then(_self.copyWith(closing: value));
  });
}
}

// dart format on
