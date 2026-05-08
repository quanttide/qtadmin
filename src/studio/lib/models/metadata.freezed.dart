// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NavSectionDef {

 String get id; List<NavEntry> get items;
/// Create a copy of NavSectionDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavSectionDefCopyWith<NavSectionDef> get copyWith => _$NavSectionDefCopyWithImpl<NavSectionDef>(this as NavSectionDef, _$identity);

  /// Serializes this NavSectionDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavSectionDef&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'NavSectionDef(id: $id, items: $items)';
}


}

/// @nodoc
abstract mixin class $NavSectionDefCopyWith<$Res>  {
  factory $NavSectionDefCopyWith(NavSectionDef value, $Res Function(NavSectionDef) _then) = _$NavSectionDefCopyWithImpl;
@useResult
$Res call({
 String id, List<NavEntry> items
});




}
/// @nodoc
class _$NavSectionDefCopyWithImpl<$Res>
    implements $NavSectionDefCopyWith<$Res> {
  _$NavSectionDefCopyWithImpl(this._self, this._then);

  final NavSectionDef _self;
  final $Res Function(NavSectionDef) _then;

/// Create a copy of NavSectionDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<NavEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [NavSectionDef].
extension NavSectionDefPatterns on NavSectionDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavSectionDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavSectionDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavSectionDef value)  $default,){
final _that = this;
switch (_that) {
case _NavSectionDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavSectionDef value)?  $default,){
final _that = this;
switch (_that) {
case _NavSectionDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<NavEntry> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavSectionDef() when $default != null:
return $default(_that.id,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<NavEntry> items)  $default,) {final _that = this;
switch (_that) {
case _NavSectionDef():
return $default(_that.id,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<NavEntry> items)?  $default,) {final _that = this;
switch (_that) {
case _NavSectionDef() when $default != null:
return $default(_that.id,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NavSectionDef implements NavSectionDef {
  const _NavSectionDef({required this.id, required final  List<NavEntry> items}): _items = items;
  factory _NavSectionDef.fromJson(Map<String, dynamic> json) => _$NavSectionDefFromJson(json);

@override final  String id;
 final  List<NavEntry> _items;
@override List<NavEntry> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of NavSectionDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavSectionDefCopyWith<_NavSectionDef> get copyWith => __$NavSectionDefCopyWithImpl<_NavSectionDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NavSectionDefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavSectionDef&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'NavSectionDef(id: $id, items: $items)';
}


}

/// @nodoc
abstract mixin class _$NavSectionDefCopyWith<$Res> implements $NavSectionDefCopyWith<$Res> {
  factory _$NavSectionDefCopyWith(_NavSectionDef value, $Res Function(_NavSectionDef) _then) = __$NavSectionDefCopyWithImpl;
@override @useResult
$Res call({
 String id, List<NavEntry> items
});




}
/// @nodoc
class __$NavSectionDefCopyWithImpl<$Res>
    implements _$NavSectionDefCopyWith<$Res> {
  __$NavSectionDefCopyWithImpl(this._self, this._then);

  final _NavSectionDef _self;
  final $Res Function(_NavSectionDef) _then;

/// Create a copy of NavSectionDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? items = null,}) {
  return _then(_NavSectionDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<NavEntry>,
  ));
}


}


/// @nodoc
mixin _$WorkspaceInfo {

 String get name; String get icon; String get dir;
/// Create a copy of WorkspaceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceInfoCopyWith<WorkspaceInfo> get copyWith => _$WorkspaceInfoCopyWithImpl<WorkspaceInfo>(this as WorkspaceInfo, _$identity);

  /// Serializes this WorkspaceInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.dir, dir) || other.dir == dir));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,icon,dir);

@override
String toString() {
  return 'WorkspaceInfo(name: $name, icon: $icon, dir: $dir)';
}


}

/// @nodoc
abstract mixin class $WorkspaceInfoCopyWith<$Res>  {
  factory $WorkspaceInfoCopyWith(WorkspaceInfo value, $Res Function(WorkspaceInfo) _then) = _$WorkspaceInfoCopyWithImpl;
@useResult
$Res call({
 String name, String icon, String dir
});




}
/// @nodoc
class _$WorkspaceInfoCopyWithImpl<$Res>
    implements $WorkspaceInfoCopyWith<$Res> {
  _$WorkspaceInfoCopyWithImpl(this._self, this._then);

  final WorkspaceInfo _self;
  final $Res Function(WorkspaceInfo) _then;

/// Create a copy of WorkspaceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? icon = null,Object? dir = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,dir: null == dir ? _self.dir : dir // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceInfo].
extension WorkspaceInfoPatterns on WorkspaceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceInfo value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String icon,  String dir)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceInfo() when $default != null:
return $default(_that.name,_that.icon,_that.dir);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String icon,  String dir)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceInfo():
return $default(_that.name,_that.icon,_that.dir);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String icon,  String dir)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceInfo() when $default != null:
return $default(_that.name,_that.icon,_that.dir);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkspaceInfo implements WorkspaceInfo {
  const _WorkspaceInfo({required this.name, required this.icon, required this.dir});
  factory _WorkspaceInfo.fromJson(Map<String, dynamic> json) => _$WorkspaceInfoFromJson(json);

@override final  String name;
@override final  String icon;
@override final  String dir;

/// Create a copy of WorkspaceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceInfoCopyWith<_WorkspaceInfo> get copyWith => __$WorkspaceInfoCopyWithImpl<_WorkspaceInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkspaceInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.dir, dir) || other.dir == dir));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,icon,dir);

@override
String toString() {
  return 'WorkspaceInfo(name: $name, icon: $icon, dir: $dir)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceInfoCopyWith<$Res> implements $WorkspaceInfoCopyWith<$Res> {
  factory _$WorkspaceInfoCopyWith(_WorkspaceInfo value, $Res Function(_WorkspaceInfo) _then) = __$WorkspaceInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String icon, String dir
});




}
/// @nodoc
class __$WorkspaceInfoCopyWithImpl<$Res>
    implements _$WorkspaceInfoCopyWith<$Res> {
  __$WorkspaceInfoCopyWithImpl(this._self, this._then);

  final _WorkspaceInfo _self;
  final $Res Function(_WorkspaceInfo) _then;

/// Create a copy of WorkspaceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? icon = null,Object? dir = null,}) {
  return _then(_WorkspaceInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,dir: null == dir ? _self.dir : dir // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NavMetadata {

 List<NavSectionDef> get sections;
/// Create a copy of NavMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavMetadataCopyWith<NavMetadata> get copyWith => _$NavMetadataCopyWithImpl<NavMetadata>(this as NavMetadata, _$identity);

  /// Serializes this NavMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavMetadata&&const DeepCollectionEquality().equals(other.sections, sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sections));

@override
String toString() {
  return 'NavMetadata(sections: $sections)';
}


}

/// @nodoc
abstract mixin class $NavMetadataCopyWith<$Res>  {
  factory $NavMetadataCopyWith(NavMetadata value, $Res Function(NavMetadata) _then) = _$NavMetadataCopyWithImpl;
@useResult
$Res call({
 List<NavSectionDef> sections
});




}
/// @nodoc
class _$NavMetadataCopyWithImpl<$Res>
    implements $NavMetadataCopyWith<$Res> {
  _$NavMetadataCopyWithImpl(this._self, this._then);

  final NavMetadata _self;
  final $Res Function(NavMetadata) _then;

/// Create a copy of NavMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sections = null,}) {
  return _then(_self.copyWith(
sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<NavSectionDef>,
  ));
}

}


/// Adds pattern-matching-related methods to [NavMetadata].
extension NavMetadataPatterns on NavMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavMetadata value)  $default,){
final _that = this;
switch (_that) {
case _NavMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _NavMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NavSectionDef> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavMetadata() when $default != null:
return $default(_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NavSectionDef> sections)  $default,) {final _that = this;
switch (_that) {
case _NavMetadata():
return $default(_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NavSectionDef> sections)?  $default,) {final _that = this;
switch (_that) {
case _NavMetadata() when $default != null:
return $default(_that.sections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NavMetadata implements NavMetadata {
  const _NavMetadata({required final  List<NavSectionDef> sections}): _sections = sections;
  factory _NavMetadata.fromJson(Map<String, dynamic> json) => _$NavMetadataFromJson(json);

 final  List<NavSectionDef> _sections;
@override List<NavSectionDef> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of NavMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavMetadataCopyWith<_NavMetadata> get copyWith => __$NavMetadataCopyWithImpl<_NavMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NavMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavMetadata&&const DeepCollectionEquality().equals(other._sections, _sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sections));

@override
String toString() {
  return 'NavMetadata(sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$NavMetadataCopyWith<$Res> implements $NavMetadataCopyWith<$Res> {
  factory _$NavMetadataCopyWith(_NavMetadata value, $Res Function(_NavMetadata) _then) = __$NavMetadataCopyWithImpl;
@override @useResult
$Res call({
 List<NavSectionDef> sections
});




}
/// @nodoc
class __$NavMetadataCopyWithImpl<$Res>
    implements _$NavMetadataCopyWith<$Res> {
  __$NavMetadataCopyWithImpl(this._self, this._then);

  final _NavMetadata _self;
  final $Res Function(_NavMetadata) _then;

/// Create a copy of NavMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sections = null,}) {
  return _then(_NavMetadata(
sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<NavSectionDef>,
  ));
}


}


/// @nodoc
mixin _$SectionDef {

 String get id; bool get dividerBefore;
/// Create a copy of SectionDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SectionDefCopyWith<SectionDef> get copyWith => _$SectionDefCopyWithImpl<SectionDef>(this as SectionDef, _$identity);

  /// Serializes this SectionDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SectionDef&&(identical(other.id, id) || other.id == id)&&(identical(other.dividerBefore, dividerBefore) || other.dividerBefore == dividerBefore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dividerBefore);

@override
String toString() {
  return 'SectionDef(id: $id, dividerBefore: $dividerBefore)';
}


}

/// @nodoc
abstract mixin class $SectionDefCopyWith<$Res>  {
  factory $SectionDefCopyWith(SectionDef value, $Res Function(SectionDef) _then) = _$SectionDefCopyWithImpl;
@useResult
$Res call({
 String id, bool dividerBefore
});




}
/// @nodoc
class _$SectionDefCopyWithImpl<$Res>
    implements $SectionDefCopyWith<$Res> {
  _$SectionDefCopyWithImpl(this._self, this._then);

  final SectionDef _self;
  final $Res Function(SectionDef) _then;

/// Create a copy of SectionDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dividerBefore = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dividerBefore: null == dividerBefore ? _self.dividerBefore : dividerBefore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SectionDef].
extension SectionDefPatterns on SectionDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SectionDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SectionDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SectionDef value)  $default,){
final _that = this;
switch (_that) {
case _SectionDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SectionDef value)?  $default,){
final _that = this;
switch (_that) {
case _SectionDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool dividerBefore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SectionDef() when $default != null:
return $default(_that.id,_that.dividerBefore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool dividerBefore)  $default,) {final _that = this;
switch (_that) {
case _SectionDef():
return $default(_that.id,_that.dividerBefore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool dividerBefore)?  $default,) {final _that = this;
switch (_that) {
case _SectionDef() when $default != null:
return $default(_that.id,_that.dividerBefore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SectionDef implements SectionDef {
  const _SectionDef({required this.id, required this.dividerBefore});
  factory _SectionDef.fromJson(Map<String, dynamic> json) => _$SectionDefFromJson(json);

@override final  String id;
@override final  bool dividerBefore;

/// Create a copy of SectionDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SectionDefCopyWith<_SectionDef> get copyWith => __$SectionDefCopyWithImpl<_SectionDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SectionDefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SectionDef&&(identical(other.id, id) || other.id == id)&&(identical(other.dividerBefore, dividerBefore) || other.dividerBefore == dividerBefore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,dividerBefore);

@override
String toString() {
  return 'SectionDef(id: $id, dividerBefore: $dividerBefore)';
}


}

/// @nodoc
abstract mixin class _$SectionDefCopyWith<$Res> implements $SectionDefCopyWith<$Res> {
  factory _$SectionDefCopyWith(_SectionDef value, $Res Function(_SectionDef) _then) = __$SectionDefCopyWithImpl;
@override @useResult
$Res call({
 String id, bool dividerBefore
});




}
/// @nodoc
class __$SectionDefCopyWithImpl<$Res>
    implements _$SectionDefCopyWith<$Res> {
  __$SectionDefCopyWithImpl(this._self, this._then);

  final _SectionDef _self;
  final $Res Function(_SectionDef) _then;

/// Create a copy of SectionDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dividerBefore = null,}) {
  return _then(_SectionDef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dividerBefore: null == dividerBefore ? _self.dividerBefore : dividerBefore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RootMetadata {

 List<WorkspaceInfo> get workspaces; List<SectionDef> get sections;
/// Create a copy of RootMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RootMetadataCopyWith<RootMetadata> get copyWith => _$RootMetadataCopyWithImpl<RootMetadata>(this as RootMetadata, _$identity);

  /// Serializes this RootMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RootMetadata&&const DeepCollectionEquality().equals(other.workspaces, workspaces)&&const DeepCollectionEquality().equals(other.sections, sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(workspaces),const DeepCollectionEquality().hash(sections));

@override
String toString() {
  return 'RootMetadata(workspaces: $workspaces, sections: $sections)';
}


}

/// @nodoc
abstract mixin class $RootMetadataCopyWith<$Res>  {
  factory $RootMetadataCopyWith(RootMetadata value, $Res Function(RootMetadata) _then) = _$RootMetadataCopyWithImpl;
@useResult
$Res call({
 List<WorkspaceInfo> workspaces, List<SectionDef> sections
});




}
/// @nodoc
class _$RootMetadataCopyWithImpl<$Res>
    implements $RootMetadataCopyWith<$Res> {
  _$RootMetadataCopyWithImpl(this._self, this._then);

  final RootMetadata _self;
  final $Res Function(RootMetadata) _then;

/// Create a copy of RootMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workspaces = null,Object? sections = null,}) {
  return _then(_self.copyWith(
workspaces: null == workspaces ? _self.workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<WorkspaceInfo>,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<SectionDef>,
  ));
}

}


/// Adds pattern-matching-related methods to [RootMetadata].
extension RootMetadataPatterns on RootMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RootMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RootMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RootMetadata value)  $default,){
final _that = this;
switch (_that) {
case _RootMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RootMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _RootMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<WorkspaceInfo> workspaces,  List<SectionDef> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RootMetadata() when $default != null:
return $default(_that.workspaces,_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<WorkspaceInfo> workspaces,  List<SectionDef> sections)  $default,) {final _that = this;
switch (_that) {
case _RootMetadata():
return $default(_that.workspaces,_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<WorkspaceInfo> workspaces,  List<SectionDef> sections)?  $default,) {final _that = this;
switch (_that) {
case _RootMetadata() when $default != null:
return $default(_that.workspaces,_that.sections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RootMetadata implements RootMetadata {
  const _RootMetadata({required final  List<WorkspaceInfo> workspaces, required final  List<SectionDef> sections}): _workspaces = workspaces,_sections = sections;
  factory _RootMetadata.fromJson(Map<String, dynamic> json) => _$RootMetadataFromJson(json);

 final  List<WorkspaceInfo> _workspaces;
@override List<WorkspaceInfo> get workspaces {
  if (_workspaces is EqualUnmodifiableListView) return _workspaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workspaces);
}

 final  List<SectionDef> _sections;
@override List<SectionDef> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of RootMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RootMetadataCopyWith<_RootMetadata> get copyWith => __$RootMetadataCopyWithImpl<_RootMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RootMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RootMetadata&&const DeepCollectionEquality().equals(other._workspaces, _workspaces)&&const DeepCollectionEquality().equals(other._sections, _sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_workspaces),const DeepCollectionEquality().hash(_sections));

@override
String toString() {
  return 'RootMetadata(workspaces: $workspaces, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$RootMetadataCopyWith<$Res> implements $RootMetadataCopyWith<$Res> {
  factory _$RootMetadataCopyWith(_RootMetadata value, $Res Function(_RootMetadata) _then) = __$RootMetadataCopyWithImpl;
@override @useResult
$Res call({
 List<WorkspaceInfo> workspaces, List<SectionDef> sections
});




}
/// @nodoc
class __$RootMetadataCopyWithImpl<$Res>
    implements _$RootMetadataCopyWith<$Res> {
  __$RootMetadataCopyWithImpl(this._self, this._then);

  final _RootMetadata _self;
  final $Res Function(_RootMetadata) _then;

/// Create a copy of RootMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workspaces = null,Object? sections = null,}) {
  return _then(_RootMetadata(
workspaces: null == workspaces ? _self._workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<WorkspaceInfo>,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<SectionDef>,
  ));
}


}

// dart format on
