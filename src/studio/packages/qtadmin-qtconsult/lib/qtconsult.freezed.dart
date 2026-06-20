// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qtconsult.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Discovery {

 String get id; String get text; DiscoveryType get type; DiscoveryStatus get status; String get source; String get date; bool get linkedToStrategy;
/// Create a copy of Discovery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveryCopyWith<Discovery> get copyWith => _$DiscoveryCopyWithImpl<Discovery>(this as Discovery, _$identity);

  /// Serializes this Discovery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Discovery&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.source, source) || other.source == source)&&(identical(other.date, date) || other.date == date)&&(identical(other.linkedToStrategy, linkedToStrategy) || other.linkedToStrategy == linkedToStrategy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,type,status,source,date,linkedToStrategy);

@override
String toString() {
  return 'Discovery(id: $id, text: $text, type: $type, status: $status, source: $source, date: $date, linkedToStrategy: $linkedToStrategy)';
}


}

/// @nodoc
abstract mixin class $DiscoveryCopyWith<$Res>  {
  factory $DiscoveryCopyWith(Discovery value, $Res Function(Discovery) _then) = _$DiscoveryCopyWithImpl;
@useResult
$Res call({
 String id, String text, DiscoveryType type, DiscoveryStatus status, String source, String date, bool linkedToStrategy
});




}
/// @nodoc
class _$DiscoveryCopyWithImpl<$Res>
    implements $DiscoveryCopyWith<$Res> {
  _$DiscoveryCopyWithImpl(this._self, this._then);

  final Discovery _self;
  final $Res Function(Discovery) _then;

/// Create a copy of Discovery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? type = null,Object? status = null,Object? source = null,Object? date = null,Object? linkedToStrategy = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiscoveryType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DiscoveryStatus,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,linkedToStrategy: null == linkedToStrategy ? _self.linkedToStrategy : linkedToStrategy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Discovery].
extension DiscoveryPatterns on Discovery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Discovery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Discovery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Discovery value)  $default,){
final _that = this;
switch (_that) {
case _Discovery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Discovery value)?  $default,){
final _that = this;
switch (_that) {
case _Discovery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  DiscoveryType type,  DiscoveryStatus status,  String source,  String date,  bool linkedToStrategy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Discovery() when $default != null:
return $default(_that.id,_that.text,_that.type,_that.status,_that.source,_that.date,_that.linkedToStrategy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  DiscoveryType type,  DiscoveryStatus status,  String source,  String date,  bool linkedToStrategy)  $default,) {final _that = this;
switch (_that) {
case _Discovery():
return $default(_that.id,_that.text,_that.type,_that.status,_that.source,_that.date,_that.linkedToStrategy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  DiscoveryType type,  DiscoveryStatus status,  String source,  String date,  bool linkedToStrategy)?  $default,) {final _that = this;
switch (_that) {
case _Discovery() when $default != null:
return $default(_that.id,_that.text,_that.type,_that.status,_that.source,_that.date,_that.linkedToStrategy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Discovery implements Discovery {
  const _Discovery({required this.id, required this.text, required this.type, this.status = DiscoveryStatus.pending, required this.source, required this.date, this.linkedToStrategy = false});
  factory _Discovery.fromJson(Map<String, dynamic> json) => _$DiscoveryFromJson(json);

@override final  String id;
@override final  String text;
@override final  DiscoveryType type;
@override@JsonKey() final  DiscoveryStatus status;
@override final  String source;
@override final  String date;
@override@JsonKey() final  bool linkedToStrategy;

/// Create a copy of Discovery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscoveryCopyWith<_Discovery> get copyWith => __$DiscoveryCopyWithImpl<_Discovery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscoveryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Discovery&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.source, source) || other.source == source)&&(identical(other.date, date) || other.date == date)&&(identical(other.linkedToStrategy, linkedToStrategy) || other.linkedToStrategy == linkedToStrategy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,type,status,source,date,linkedToStrategy);

@override
String toString() {
  return 'Discovery(id: $id, text: $text, type: $type, status: $status, source: $source, date: $date, linkedToStrategy: $linkedToStrategy)';
}


}

/// @nodoc
abstract mixin class _$DiscoveryCopyWith<$Res> implements $DiscoveryCopyWith<$Res> {
  factory _$DiscoveryCopyWith(_Discovery value, $Res Function(_Discovery) _then) = __$DiscoveryCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, DiscoveryType type, DiscoveryStatus status, String source, String date, bool linkedToStrategy
});




}
/// @nodoc
class __$DiscoveryCopyWithImpl<$Res>
    implements _$DiscoveryCopyWith<$Res> {
  __$DiscoveryCopyWithImpl(this._self, this._then);

  final _Discovery _self;
  final $Res Function(_Discovery) _then;

/// Create a copy of Discovery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? type = null,Object? status = null,Object? source = null,Object? date = null,Object? linkedToStrategy = null,}) {
  return _then(_Discovery(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiscoveryType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DiscoveryStatus,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,linkedToStrategy: null == linkedToStrategy ? _self.linkedToStrategy : linkedToStrategy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Communication {

 String get id; String get title; String get date; String get summary;
/// Create a copy of Communication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunicationCopyWith<Communication> get copyWith => _$CommunicationCopyWithImpl<Communication>(this as Communication, _$identity);

  /// Serializes this Communication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Communication&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,date,summary);

@override
String toString() {
  return 'Communication(id: $id, title: $title, date: $date, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $CommunicationCopyWith<$Res>  {
  factory $CommunicationCopyWith(Communication value, $Res Function(Communication) _then) = _$CommunicationCopyWithImpl;
@useResult
$Res call({
 String id, String title, String date, String summary
});




}
/// @nodoc
class _$CommunicationCopyWithImpl<$Res>
    implements $CommunicationCopyWith<$Res> {
  _$CommunicationCopyWithImpl(this._self, this._then);

  final Communication _self;
  final $Res Function(Communication) _then;

/// Create a copy of Communication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? date = null,Object? summary = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Communication].
extension CommunicationPatterns on Communication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Communication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Communication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Communication value)  $default,){
final _that = this;
switch (_that) {
case _Communication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Communication value)?  $default,){
final _that = this;
switch (_that) {
case _Communication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String date,  String summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Communication() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String date,  String summary)  $default,) {final _that = this;
switch (_that) {
case _Communication():
return $default(_that.id,_that.title,_that.date,_that.summary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String date,  String summary)?  $default,) {final _that = this;
switch (_that) {
case _Communication() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Communication implements Communication {
  const _Communication({required this.id, required this.title, required this.date, required this.summary});
  factory _Communication.fromJson(Map<String, dynamic> json) => _$CommunicationFromJson(json);

@override final  String id;
@override final  String title;
@override final  String date;
@override final  String summary;

/// Create a copy of Communication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunicationCopyWith<_Communication> get copyWith => __$CommunicationCopyWithImpl<_Communication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Communication&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,date,summary);

@override
String toString() {
  return 'Communication(id: $id, title: $title, date: $date, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$CommunicationCopyWith<$Res> implements $CommunicationCopyWith<$Res> {
  factory _$CommunicationCopyWith(_Communication value, $Res Function(_Communication) _then) = __$CommunicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String date, String summary
});




}
/// @nodoc
class __$CommunicationCopyWithImpl<$Res>
    implements _$CommunicationCopyWith<$Res> {
  __$CommunicationCopyWithImpl(this._self, this._then);

  final _Communication _self;
  final $Res Function(_Communication) _then;

/// Create a copy of Communication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? date = null,Object? summary = null,}) {
  return _then(_Communication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Stakeholder {

 String get id; String get name; String get role; StakeStance get stance; String get concern; String get detail;
/// Create a copy of Stakeholder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StakeholderCopyWith<Stakeholder> get copyWith => _$StakeholderCopyWithImpl<Stakeholder>(this as Stakeholder, _$identity);

  /// Serializes this Stakeholder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Stakeholder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.stance, stance) || other.stance == stance)&&(identical(other.concern, concern) || other.concern == concern)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,role,stance,concern,detail);

@override
String toString() {
  return 'Stakeholder(id: $id, name: $name, role: $role, stance: $stance, concern: $concern, detail: $detail)';
}


}

/// @nodoc
abstract mixin class $StakeholderCopyWith<$Res>  {
  factory $StakeholderCopyWith(Stakeholder value, $Res Function(Stakeholder) _then) = _$StakeholderCopyWithImpl;
@useResult
$Res call({
 String id, String name, String role, StakeStance stance, String concern, String detail
});




}
/// @nodoc
class _$StakeholderCopyWithImpl<$Res>
    implements $StakeholderCopyWith<$Res> {
  _$StakeholderCopyWithImpl(this._self, this._then);

  final Stakeholder _self;
  final $Res Function(Stakeholder) _then;

/// Create a copy of Stakeholder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,Object? stance = null,Object? concern = null,Object? detail = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,stance: null == stance ? _self.stance : stance // ignore: cast_nullable_to_non_nullable
as StakeStance,concern: null == concern ? _self.concern : concern // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Stakeholder].
extension StakeholderPatterns on Stakeholder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Stakeholder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Stakeholder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Stakeholder value)  $default,){
final _that = this;
switch (_that) {
case _Stakeholder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Stakeholder value)?  $default,){
final _that = this;
switch (_that) {
case _Stakeholder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String role,  StakeStance stance,  String concern,  String detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Stakeholder() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.stance,_that.concern,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String role,  StakeStance stance,  String concern,  String detail)  $default,) {final _that = this;
switch (_that) {
case _Stakeholder():
return $default(_that.id,_that.name,_that.role,_that.stance,_that.concern,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String role,  StakeStance stance,  String concern,  String detail)?  $default,) {final _that = this;
switch (_that) {
case _Stakeholder() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.stance,_that.concern,_that.detail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Stakeholder implements Stakeholder {
  const _Stakeholder({required this.id, required this.name, required this.role, required this.stance, required this.concern, required this.detail});
  factory _Stakeholder.fromJson(Map<String, dynamic> json) => _$StakeholderFromJson(json);

@override final  String id;
@override final  String name;
@override final  String role;
@override final  StakeStance stance;
@override final  String concern;
@override final  String detail;

/// Create a copy of Stakeholder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StakeholderCopyWith<_Stakeholder> get copyWith => __$StakeholderCopyWithImpl<_Stakeholder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StakeholderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Stakeholder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.stance, stance) || other.stance == stance)&&(identical(other.concern, concern) || other.concern == concern)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,role,stance,concern,detail);

@override
String toString() {
  return 'Stakeholder(id: $id, name: $name, role: $role, stance: $stance, concern: $concern, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$StakeholderCopyWith<$Res> implements $StakeholderCopyWith<$Res> {
  factory _$StakeholderCopyWith(_Stakeholder value, $Res Function(_Stakeholder) _then) = __$StakeholderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String role, StakeStance stance, String concern, String detail
});




}
/// @nodoc
class __$StakeholderCopyWithImpl<$Res>
    implements _$StakeholderCopyWith<$Res> {
  __$StakeholderCopyWithImpl(this._self, this._then);

  final _Stakeholder _self;
  final $Res Function(_Stakeholder) _then;

/// Create a copy of Stakeholder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,Object? stance = null,Object? concern = null,Object? detail = null,}) {
  return _then(_Stakeholder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,stance: null == stance ? _self.stance : stance // ignore: cast_nullable_to_non_nullable
as StakeStance,concern: null == concern ? _self.concern : concern // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$StrategyRevision {

 String get id; String get date; String get reason; String? get relatedDiscoveryId; bool get isReviewed;
/// Create a copy of StrategyRevision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StrategyRevisionCopyWith<StrategyRevision> get copyWith => _$StrategyRevisionCopyWithImpl<StrategyRevision>(this as StrategyRevision, _$identity);

  /// Serializes this StrategyRevision to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StrategyRevision&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.relatedDiscoveryId, relatedDiscoveryId) || other.relatedDiscoveryId == relatedDiscoveryId)&&(identical(other.isReviewed, isReviewed) || other.isReviewed == isReviewed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,reason,relatedDiscoveryId,isReviewed);

@override
String toString() {
  return 'StrategyRevision(id: $id, date: $date, reason: $reason, relatedDiscoveryId: $relatedDiscoveryId, isReviewed: $isReviewed)';
}


}

/// @nodoc
abstract mixin class $StrategyRevisionCopyWith<$Res>  {
  factory $StrategyRevisionCopyWith(StrategyRevision value, $Res Function(StrategyRevision) _then) = _$StrategyRevisionCopyWithImpl;
@useResult
$Res call({
 String id, String date, String reason, String? relatedDiscoveryId, bool isReviewed
});




}
/// @nodoc
class _$StrategyRevisionCopyWithImpl<$Res>
    implements $StrategyRevisionCopyWith<$Res> {
  _$StrategyRevisionCopyWithImpl(this._self, this._then);

  final StrategyRevision _self;
  final $Res Function(StrategyRevision) _then;

/// Create a copy of StrategyRevision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? reason = null,Object? relatedDiscoveryId = freezed,Object? isReviewed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,relatedDiscoveryId: freezed == relatedDiscoveryId ? _self.relatedDiscoveryId : relatedDiscoveryId // ignore: cast_nullable_to_non_nullable
as String?,isReviewed: null == isReviewed ? _self.isReviewed : isReviewed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StrategyRevision].
extension StrategyRevisionPatterns on StrategyRevision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StrategyRevision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StrategyRevision() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StrategyRevision value)  $default,){
final _that = this;
switch (_that) {
case _StrategyRevision():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StrategyRevision value)?  $default,){
final _that = this;
switch (_that) {
case _StrategyRevision() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String date,  String reason,  String? relatedDiscoveryId,  bool isReviewed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StrategyRevision() when $default != null:
return $default(_that.id,_that.date,_that.reason,_that.relatedDiscoveryId,_that.isReviewed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String date,  String reason,  String? relatedDiscoveryId,  bool isReviewed)  $default,) {final _that = this;
switch (_that) {
case _StrategyRevision():
return $default(_that.id,_that.date,_that.reason,_that.relatedDiscoveryId,_that.isReviewed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String date,  String reason,  String? relatedDiscoveryId,  bool isReviewed)?  $default,) {final _that = this;
switch (_that) {
case _StrategyRevision() when $default != null:
return $default(_that.id,_that.date,_that.reason,_that.relatedDiscoveryId,_that.isReviewed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StrategyRevision implements StrategyRevision {
  const _StrategyRevision({required this.id, required this.date, required this.reason, this.relatedDiscoveryId, this.isReviewed = false});
  factory _StrategyRevision.fromJson(Map<String, dynamic> json) => _$StrategyRevisionFromJson(json);

@override final  String id;
@override final  String date;
@override final  String reason;
@override final  String? relatedDiscoveryId;
@override@JsonKey() final  bool isReviewed;

/// Create a copy of StrategyRevision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StrategyRevisionCopyWith<_StrategyRevision> get copyWith => __$StrategyRevisionCopyWithImpl<_StrategyRevision>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StrategyRevisionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StrategyRevision&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.relatedDiscoveryId, relatedDiscoveryId) || other.relatedDiscoveryId == relatedDiscoveryId)&&(identical(other.isReviewed, isReviewed) || other.isReviewed == isReviewed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,reason,relatedDiscoveryId,isReviewed);

@override
String toString() {
  return 'StrategyRevision(id: $id, date: $date, reason: $reason, relatedDiscoveryId: $relatedDiscoveryId, isReviewed: $isReviewed)';
}


}

/// @nodoc
abstract mixin class _$StrategyRevisionCopyWith<$Res> implements $StrategyRevisionCopyWith<$Res> {
  factory _$StrategyRevisionCopyWith(_StrategyRevision value, $Res Function(_StrategyRevision) _then) = __$StrategyRevisionCopyWithImpl;
@override @useResult
$Res call({
 String id, String date, String reason, String? relatedDiscoveryId, bool isReviewed
});




}
/// @nodoc
class __$StrategyRevisionCopyWithImpl<$Res>
    implements _$StrategyRevisionCopyWith<$Res> {
  __$StrategyRevisionCopyWithImpl(this._self, this._then);

  final _StrategyRevision _self;
  final $Res Function(_StrategyRevision) _then;

/// Create a copy of StrategyRevision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? reason = null,Object? relatedDiscoveryId = freezed,Object? isReviewed = null,}) {
  return _then(_StrategyRevision(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,relatedDiscoveryId: freezed == relatedDiscoveryId ? _self.relatedDiscoveryId : relatedDiscoveryId // ignore: cast_nullable_to_non_nullable
as String?,isReviewed: null == isReviewed ? _self.isReviewed : isReviewed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$QtConsult {

 WorkspaceType get workspace; String get projectName; String get phase; String get industry; String get scale; String get maturity; String get strategyGoal; String get strategyInsight; List<String> get strategySteps; String get riskNote; List<Discovery> get discoveries; List<Communication> get communications; List<StrategyRevision> get revisions; List<Stakeholder> get stakeholders;
/// Create a copy of QtConsult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QtConsultCopyWith<QtConsult> get copyWith => _$QtConsultCopyWithImpl<QtConsult>(this as QtConsult, _$identity);

  /// Serializes this QtConsult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QtConsult&&(identical(other.workspace, workspace) || other.workspace == workspace)&&(identical(other.projectName, projectName) || other.projectName == projectName)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.industry, industry) || other.industry == industry)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.maturity, maturity) || other.maturity == maturity)&&(identical(other.strategyGoal, strategyGoal) || other.strategyGoal == strategyGoal)&&(identical(other.strategyInsight, strategyInsight) || other.strategyInsight == strategyInsight)&&const DeepCollectionEquality().equals(other.strategySteps, strategySteps)&&(identical(other.riskNote, riskNote) || other.riskNote == riskNote)&&const DeepCollectionEquality().equals(other.discoveries, discoveries)&&const DeepCollectionEquality().equals(other.communications, communications)&&const DeepCollectionEquality().equals(other.revisions, revisions)&&const DeepCollectionEquality().equals(other.stakeholders, stakeholders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workspace,projectName,phase,industry,scale,maturity,strategyGoal,strategyInsight,const DeepCollectionEquality().hash(strategySteps),riskNote,const DeepCollectionEquality().hash(discoveries),const DeepCollectionEquality().hash(communications),const DeepCollectionEquality().hash(revisions),const DeepCollectionEquality().hash(stakeholders));

@override
String toString() {
  return 'QtConsult(workspace: $workspace, projectName: $projectName, phase: $phase, industry: $industry, scale: $scale, maturity: $maturity, strategyGoal: $strategyGoal, strategyInsight: $strategyInsight, strategySteps: $strategySteps, riskNote: $riskNote, discoveries: $discoveries, communications: $communications, revisions: $revisions, stakeholders: $stakeholders)';
}


}

/// @nodoc
abstract mixin class $QtConsultCopyWith<$Res>  {
  factory $QtConsultCopyWith(QtConsult value, $Res Function(QtConsult) _then) = _$QtConsultCopyWithImpl;
@useResult
$Res call({
 WorkspaceType workspace, String projectName, String phase, String industry, String scale, String maturity, String strategyGoal, String strategyInsight, List<String> strategySteps, String riskNote, List<Discovery> discoveries, List<Communication> communications, List<StrategyRevision> revisions, List<Stakeholder> stakeholders
});




}
/// @nodoc
class _$QtConsultCopyWithImpl<$Res>
    implements $QtConsultCopyWith<$Res> {
  _$QtConsultCopyWithImpl(this._self, this._then);

  final QtConsult _self;
  final $Res Function(QtConsult) _then;

/// Create a copy of QtConsult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workspace = null,Object? projectName = null,Object? phase = null,Object? industry = null,Object? scale = null,Object? maturity = null,Object? strategyGoal = null,Object? strategyInsight = null,Object? strategySteps = null,Object? riskNote = null,Object? discoveries = null,Object? communications = null,Object? revisions = null,Object? stakeholders = null,}) {
  return _then(_self.copyWith(
workspace: null == workspace ? _self.workspace : workspace // ignore: cast_nullable_to_non_nullable
as WorkspaceType,projectName: null == projectName ? _self.projectName : projectName // ignore: cast_nullable_to_non_nullable
as String,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,industry: null == industry ? _self.industry : industry // ignore: cast_nullable_to_non_nullable
as String,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as String,maturity: null == maturity ? _self.maturity : maturity // ignore: cast_nullable_to_non_nullable
as String,strategyGoal: null == strategyGoal ? _self.strategyGoal : strategyGoal // ignore: cast_nullable_to_non_nullable
as String,strategyInsight: null == strategyInsight ? _self.strategyInsight : strategyInsight // ignore: cast_nullable_to_non_nullable
as String,strategySteps: null == strategySteps ? _self.strategySteps : strategySteps // ignore: cast_nullable_to_non_nullable
as List<String>,riskNote: null == riskNote ? _self.riskNote : riskNote // ignore: cast_nullable_to_non_nullable
as String,discoveries: null == discoveries ? _self.discoveries : discoveries // ignore: cast_nullable_to_non_nullable
as List<Discovery>,communications: null == communications ? _self.communications : communications // ignore: cast_nullable_to_non_nullable
as List<Communication>,revisions: null == revisions ? _self.revisions : revisions // ignore: cast_nullable_to_non_nullable
as List<StrategyRevision>,stakeholders: null == stakeholders ? _self.stakeholders : stakeholders // ignore: cast_nullable_to_non_nullable
as List<Stakeholder>,
  ));
}

}


/// Adds pattern-matching-related methods to [QtConsult].
extension QtConsultPatterns on QtConsult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QtConsult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QtConsult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QtConsult value)  $default,){
final _that = this;
switch (_that) {
case _QtConsult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QtConsult value)?  $default,){
final _that = this;
switch (_that) {
case _QtConsult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WorkspaceType workspace,  String projectName,  String phase,  String industry,  String scale,  String maturity,  String strategyGoal,  String strategyInsight,  List<String> strategySteps,  String riskNote,  List<Discovery> discoveries,  List<Communication> communications,  List<StrategyRevision> revisions,  List<Stakeholder> stakeholders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QtConsult() when $default != null:
return $default(_that.workspace,_that.projectName,_that.phase,_that.industry,_that.scale,_that.maturity,_that.strategyGoal,_that.strategyInsight,_that.strategySteps,_that.riskNote,_that.discoveries,_that.communications,_that.revisions,_that.stakeholders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WorkspaceType workspace,  String projectName,  String phase,  String industry,  String scale,  String maturity,  String strategyGoal,  String strategyInsight,  List<String> strategySteps,  String riskNote,  List<Discovery> discoveries,  List<Communication> communications,  List<StrategyRevision> revisions,  List<Stakeholder> stakeholders)  $default,) {final _that = this;
switch (_that) {
case _QtConsult():
return $default(_that.workspace,_that.projectName,_that.phase,_that.industry,_that.scale,_that.maturity,_that.strategyGoal,_that.strategyInsight,_that.strategySteps,_that.riskNote,_that.discoveries,_that.communications,_that.revisions,_that.stakeholders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WorkspaceType workspace,  String projectName,  String phase,  String industry,  String scale,  String maturity,  String strategyGoal,  String strategyInsight,  List<String> strategySteps,  String riskNote,  List<Discovery> discoveries,  List<Communication> communications,  List<StrategyRevision> revisions,  List<Stakeholder> stakeholders)?  $default,) {final _that = this;
switch (_that) {
case _QtConsult() when $default != null:
return $default(_that.workspace,_that.projectName,_that.phase,_that.industry,_that.scale,_that.maturity,_that.strategyGoal,_that.strategyInsight,_that.strategySteps,_that.riskNote,_that.discoveries,_that.communications,_that.revisions,_that.stakeholders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QtConsult implements QtConsult {
  const _QtConsult({this.workspace = WorkspaceType.customer, required this.projectName, required this.phase, required this.industry, required this.scale, required this.maturity, required this.strategyGoal, required this.strategyInsight, required final  List<String> strategySteps, required this.riskNote, required final  List<Discovery> discoveries, final  List<Communication> communications = const [], required final  List<StrategyRevision> revisions, required final  List<Stakeholder> stakeholders}): _strategySteps = strategySteps,_discoveries = discoveries,_communications = communications,_revisions = revisions,_stakeholders = stakeholders;
  factory _QtConsult.fromJson(Map<String, dynamic> json) => _$QtConsultFromJson(json);

@override@JsonKey() final  WorkspaceType workspace;
@override final  String projectName;
@override final  String phase;
@override final  String industry;
@override final  String scale;
@override final  String maturity;
@override final  String strategyGoal;
@override final  String strategyInsight;
 final  List<String> _strategySteps;
@override List<String> get strategySteps {
  if (_strategySteps is EqualUnmodifiableListView) return _strategySteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strategySteps);
}

@override final  String riskNote;
 final  List<Discovery> _discoveries;
@override List<Discovery> get discoveries {
  if (_discoveries is EqualUnmodifiableListView) return _discoveries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discoveries);
}

 final  List<Communication> _communications;
@override@JsonKey() List<Communication> get communications {
  if (_communications is EqualUnmodifiableListView) return _communications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_communications);
}

 final  List<StrategyRevision> _revisions;
@override List<StrategyRevision> get revisions {
  if (_revisions is EqualUnmodifiableListView) return _revisions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_revisions);
}

 final  List<Stakeholder> _stakeholders;
@override List<Stakeholder> get stakeholders {
  if (_stakeholders is EqualUnmodifiableListView) return _stakeholders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stakeholders);
}


/// Create a copy of QtConsult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QtConsultCopyWith<_QtConsult> get copyWith => __$QtConsultCopyWithImpl<_QtConsult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QtConsultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QtConsult&&(identical(other.workspace, workspace) || other.workspace == workspace)&&(identical(other.projectName, projectName) || other.projectName == projectName)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.industry, industry) || other.industry == industry)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.maturity, maturity) || other.maturity == maturity)&&(identical(other.strategyGoal, strategyGoal) || other.strategyGoal == strategyGoal)&&(identical(other.strategyInsight, strategyInsight) || other.strategyInsight == strategyInsight)&&const DeepCollectionEquality().equals(other._strategySteps, _strategySteps)&&(identical(other.riskNote, riskNote) || other.riskNote == riskNote)&&const DeepCollectionEquality().equals(other._discoveries, _discoveries)&&const DeepCollectionEquality().equals(other._communications, _communications)&&const DeepCollectionEquality().equals(other._revisions, _revisions)&&const DeepCollectionEquality().equals(other._stakeholders, _stakeholders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workspace,projectName,phase,industry,scale,maturity,strategyGoal,strategyInsight,const DeepCollectionEquality().hash(_strategySteps),riskNote,const DeepCollectionEquality().hash(_discoveries),const DeepCollectionEquality().hash(_communications),const DeepCollectionEquality().hash(_revisions),const DeepCollectionEquality().hash(_stakeholders));

@override
String toString() {
  return 'QtConsult(workspace: $workspace, projectName: $projectName, phase: $phase, industry: $industry, scale: $scale, maturity: $maturity, strategyGoal: $strategyGoal, strategyInsight: $strategyInsight, strategySteps: $strategySteps, riskNote: $riskNote, discoveries: $discoveries, communications: $communications, revisions: $revisions, stakeholders: $stakeholders)';
}


}

/// @nodoc
abstract mixin class _$QtConsultCopyWith<$Res> implements $QtConsultCopyWith<$Res> {
  factory _$QtConsultCopyWith(_QtConsult value, $Res Function(_QtConsult) _then) = __$QtConsultCopyWithImpl;
@override @useResult
$Res call({
 WorkspaceType workspace, String projectName, String phase, String industry, String scale, String maturity, String strategyGoal, String strategyInsight, List<String> strategySteps, String riskNote, List<Discovery> discoveries, List<Communication> communications, List<StrategyRevision> revisions, List<Stakeholder> stakeholders
});




}
/// @nodoc
class __$QtConsultCopyWithImpl<$Res>
    implements _$QtConsultCopyWith<$Res> {
  __$QtConsultCopyWithImpl(this._self, this._then);

  final _QtConsult _self;
  final $Res Function(_QtConsult) _then;

/// Create a copy of QtConsult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workspace = null,Object? projectName = null,Object? phase = null,Object? industry = null,Object? scale = null,Object? maturity = null,Object? strategyGoal = null,Object? strategyInsight = null,Object? strategySteps = null,Object? riskNote = null,Object? discoveries = null,Object? communications = null,Object? revisions = null,Object? stakeholders = null,}) {
  return _then(_QtConsult(
workspace: null == workspace ? _self.workspace : workspace // ignore: cast_nullable_to_non_nullable
as WorkspaceType,projectName: null == projectName ? _self.projectName : projectName // ignore: cast_nullable_to_non_nullable
as String,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,industry: null == industry ? _self.industry : industry // ignore: cast_nullable_to_non_nullable
as String,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as String,maturity: null == maturity ? _self.maturity : maturity // ignore: cast_nullable_to_non_nullable
as String,strategyGoal: null == strategyGoal ? _self.strategyGoal : strategyGoal // ignore: cast_nullable_to_non_nullable
as String,strategyInsight: null == strategyInsight ? _self.strategyInsight : strategyInsight // ignore: cast_nullable_to_non_nullable
as String,strategySteps: null == strategySteps ? _self._strategySteps : strategySteps // ignore: cast_nullable_to_non_nullable
as List<String>,riskNote: null == riskNote ? _self.riskNote : riskNote // ignore: cast_nullable_to_non_nullable
as String,discoveries: null == discoveries ? _self._discoveries : discoveries // ignore: cast_nullable_to_non_nullable
as List<Discovery>,communications: null == communications ? _self._communications : communications // ignore: cast_nullable_to_non_nullable
as List<Communication>,revisions: null == revisions ? _self._revisions : revisions // ignore: cast_nullable_to_non_nullable
as List<StrategyRevision>,stakeholders: null == stakeholders ? _self._stakeholders : stakeholders // ignore: cast_nullable_to_non_nullable
as List<Stakeholder>,
  ));
}


}

// dart format on
