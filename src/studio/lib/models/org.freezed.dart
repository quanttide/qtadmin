// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'org.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrgInstitution {

 String get id; String get name; String get parentId; int get level; InstitutionStatus get status; String? get lastMeetingDate; String? get nextMeetingDate; String get expectedFrequency; List<String> get memberIds; int get pendingProposalCount;
/// Create a copy of OrgInstitution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrgInstitutionCopyWith<OrgInstitution> get copyWith => _$OrgInstitutionCopyWithImpl<OrgInstitution>(this as OrgInstitution, _$identity);

  /// Serializes this OrgInstitution to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrgInstitution&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.level, level) || other.level == level)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastMeetingDate, lastMeetingDate) || other.lastMeetingDate == lastMeetingDate)&&(identical(other.nextMeetingDate, nextMeetingDate) || other.nextMeetingDate == nextMeetingDate)&&(identical(other.expectedFrequency, expectedFrequency) || other.expectedFrequency == expectedFrequency)&&const DeepCollectionEquality().equals(other.memberIds, memberIds)&&(identical(other.pendingProposalCount, pendingProposalCount) || other.pendingProposalCount == pendingProposalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,parentId,level,status,lastMeetingDate,nextMeetingDate,expectedFrequency,const DeepCollectionEquality().hash(memberIds),pendingProposalCount);

@override
String toString() {
  return 'OrgInstitution(id: $id, name: $name, parentId: $parentId, level: $level, status: $status, lastMeetingDate: $lastMeetingDate, nextMeetingDate: $nextMeetingDate, expectedFrequency: $expectedFrequency, memberIds: $memberIds, pendingProposalCount: $pendingProposalCount)';
}


}

/// @nodoc
abstract mixin class $OrgInstitutionCopyWith<$Res>  {
  factory $OrgInstitutionCopyWith(OrgInstitution value, $Res Function(OrgInstitution) _then) = _$OrgInstitutionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String parentId, int level, InstitutionStatus status, String? lastMeetingDate, String? nextMeetingDate, String expectedFrequency, List<String> memberIds, int pendingProposalCount
});




}
/// @nodoc
class _$OrgInstitutionCopyWithImpl<$Res>
    implements $OrgInstitutionCopyWith<$Res> {
  _$OrgInstitutionCopyWithImpl(this._self, this._then);

  final OrgInstitution _self;
  final $Res Function(OrgInstitution) _then;

/// Create a copy of OrgInstitution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? parentId = null,Object? level = null,Object? status = null,Object? lastMeetingDate = freezed,Object? nextMeetingDate = freezed,Object? expectedFrequency = null,Object? memberIds = null,Object? pendingProposalCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InstitutionStatus,lastMeetingDate: freezed == lastMeetingDate ? _self.lastMeetingDate : lastMeetingDate // ignore: cast_nullable_to_non_nullable
as String?,nextMeetingDate: freezed == nextMeetingDate ? _self.nextMeetingDate : nextMeetingDate // ignore: cast_nullable_to_non_nullable
as String?,expectedFrequency: null == expectedFrequency ? _self.expectedFrequency : expectedFrequency // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,pendingProposalCount: null == pendingProposalCount ? _self.pendingProposalCount : pendingProposalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrgInstitution].
extension OrgInstitutionPatterns on OrgInstitution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrgInstitution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrgInstitution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrgInstitution value)  $default,){
final _that = this;
switch (_that) {
case _OrgInstitution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrgInstitution value)?  $default,){
final _that = this;
switch (_that) {
case _OrgInstitution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String parentId,  int level,  InstitutionStatus status,  String? lastMeetingDate,  String? nextMeetingDate,  String expectedFrequency,  List<String> memberIds,  int pendingProposalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrgInstitution() when $default != null:
return $default(_that.id,_that.name,_that.parentId,_that.level,_that.status,_that.lastMeetingDate,_that.nextMeetingDate,_that.expectedFrequency,_that.memberIds,_that.pendingProposalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String parentId,  int level,  InstitutionStatus status,  String? lastMeetingDate,  String? nextMeetingDate,  String expectedFrequency,  List<String> memberIds,  int pendingProposalCount)  $default,) {final _that = this;
switch (_that) {
case _OrgInstitution():
return $default(_that.id,_that.name,_that.parentId,_that.level,_that.status,_that.lastMeetingDate,_that.nextMeetingDate,_that.expectedFrequency,_that.memberIds,_that.pendingProposalCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String parentId,  int level,  InstitutionStatus status,  String? lastMeetingDate,  String? nextMeetingDate,  String expectedFrequency,  List<String> memberIds,  int pendingProposalCount)?  $default,) {final _that = this;
switch (_that) {
case _OrgInstitution() when $default != null:
return $default(_that.id,_that.name,_that.parentId,_that.level,_that.status,_that.lastMeetingDate,_that.nextMeetingDate,_that.expectedFrequency,_that.memberIds,_that.pendingProposalCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrgInstitution implements OrgInstitution {
  const _OrgInstitution({required this.id, required this.name, this.parentId = '', this.level = 0, required this.status, this.lastMeetingDate, this.nextMeetingDate, this.expectedFrequency = '', final  List<String> memberIds = const [], this.pendingProposalCount = 0}): _memberIds = memberIds;
  factory _OrgInstitution.fromJson(Map<String, dynamic> json) => _$OrgInstitutionFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String parentId;
@override@JsonKey() final  int level;
@override final  InstitutionStatus status;
@override final  String? lastMeetingDate;
@override final  String? nextMeetingDate;
@override@JsonKey() final  String expectedFrequency;
 final  List<String> _memberIds;
@override@JsonKey() List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}

@override@JsonKey() final  int pendingProposalCount;

/// Create a copy of OrgInstitution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrgInstitutionCopyWith<_OrgInstitution> get copyWith => __$OrgInstitutionCopyWithImpl<_OrgInstitution>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrgInstitutionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrgInstitution&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.level, level) || other.level == level)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastMeetingDate, lastMeetingDate) || other.lastMeetingDate == lastMeetingDate)&&(identical(other.nextMeetingDate, nextMeetingDate) || other.nextMeetingDate == nextMeetingDate)&&(identical(other.expectedFrequency, expectedFrequency) || other.expectedFrequency == expectedFrequency)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds)&&(identical(other.pendingProposalCount, pendingProposalCount) || other.pendingProposalCount == pendingProposalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,parentId,level,status,lastMeetingDate,nextMeetingDate,expectedFrequency,const DeepCollectionEquality().hash(_memberIds),pendingProposalCount);

@override
String toString() {
  return 'OrgInstitution(id: $id, name: $name, parentId: $parentId, level: $level, status: $status, lastMeetingDate: $lastMeetingDate, nextMeetingDate: $nextMeetingDate, expectedFrequency: $expectedFrequency, memberIds: $memberIds, pendingProposalCount: $pendingProposalCount)';
}


}

/// @nodoc
abstract mixin class _$OrgInstitutionCopyWith<$Res> implements $OrgInstitutionCopyWith<$Res> {
  factory _$OrgInstitutionCopyWith(_OrgInstitution value, $Res Function(_OrgInstitution) _then) = __$OrgInstitutionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String parentId, int level, InstitutionStatus status, String? lastMeetingDate, String? nextMeetingDate, String expectedFrequency, List<String> memberIds, int pendingProposalCount
});




}
/// @nodoc
class __$OrgInstitutionCopyWithImpl<$Res>
    implements _$OrgInstitutionCopyWith<$Res> {
  __$OrgInstitutionCopyWithImpl(this._self, this._then);

  final _OrgInstitution _self;
  final $Res Function(_OrgInstitution) _then;

/// Create a copy of OrgInstitution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? parentId = null,Object? level = null,Object? status = null,Object? lastMeetingDate = freezed,Object? nextMeetingDate = freezed,Object? expectedFrequency = null,Object? memberIds = null,Object? pendingProposalCount = null,}) {
  return _then(_OrgInstitution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InstitutionStatus,lastMeetingDate: freezed == lastMeetingDate ? _self.lastMeetingDate : lastMeetingDate // ignore: cast_nullable_to_non_nullable
as String?,nextMeetingDate: freezed == nextMeetingDate ? _self.nextMeetingDate : nextMeetingDate // ignore: cast_nullable_to_non_nullable
as String?,expectedFrequency: null == expectedFrequency ? _self.expectedFrequency : expectedFrequency // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,pendingProposalCount: null == pendingProposalCount ? _self.pendingProposalCount : pendingProposalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OrgMeeting {

 String get id; String get institutionId; String get date; String get title; List<String> get agendaItems; int get attendeeCount; int get totalMemberCount;
/// Create a copy of OrgMeeting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrgMeetingCopyWith<OrgMeeting> get copyWith => _$OrgMeetingCopyWithImpl<OrgMeeting>(this as OrgMeeting, _$identity);

  /// Serializes this OrgMeeting to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrgMeeting&&(identical(other.id, id) || other.id == id)&&(identical(other.institutionId, institutionId) || other.institutionId == institutionId)&&(identical(other.date, date) || other.date == date)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.agendaItems, agendaItems)&&(identical(other.attendeeCount, attendeeCount) || other.attendeeCount == attendeeCount)&&(identical(other.totalMemberCount, totalMemberCount) || other.totalMemberCount == totalMemberCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,institutionId,date,title,const DeepCollectionEquality().hash(agendaItems),attendeeCount,totalMemberCount);

@override
String toString() {
  return 'OrgMeeting(id: $id, institutionId: $institutionId, date: $date, title: $title, agendaItems: $agendaItems, attendeeCount: $attendeeCount, totalMemberCount: $totalMemberCount)';
}


}

/// @nodoc
abstract mixin class $OrgMeetingCopyWith<$Res>  {
  factory $OrgMeetingCopyWith(OrgMeeting value, $Res Function(OrgMeeting) _then) = _$OrgMeetingCopyWithImpl;
@useResult
$Res call({
 String id, String institutionId, String date, String title, List<String> agendaItems, int attendeeCount, int totalMemberCount
});




}
/// @nodoc
class _$OrgMeetingCopyWithImpl<$Res>
    implements $OrgMeetingCopyWith<$Res> {
  _$OrgMeetingCopyWithImpl(this._self, this._then);

  final OrgMeeting _self;
  final $Res Function(OrgMeeting) _then;

/// Create a copy of OrgMeeting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? institutionId = null,Object? date = null,Object? title = null,Object? agendaItems = null,Object? attendeeCount = null,Object? totalMemberCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,institutionId: null == institutionId ? _self.institutionId : institutionId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,agendaItems: null == agendaItems ? _self.agendaItems : agendaItems // ignore: cast_nullable_to_non_nullable
as List<String>,attendeeCount: null == attendeeCount ? _self.attendeeCount : attendeeCount // ignore: cast_nullable_to_non_nullable
as int,totalMemberCount: null == totalMemberCount ? _self.totalMemberCount : totalMemberCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrgMeeting].
extension OrgMeetingPatterns on OrgMeeting {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrgMeeting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrgMeeting() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrgMeeting value)  $default,){
final _that = this;
switch (_that) {
case _OrgMeeting():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrgMeeting value)?  $default,){
final _that = this;
switch (_that) {
case _OrgMeeting() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String institutionId,  String date,  String title,  List<String> agendaItems,  int attendeeCount,  int totalMemberCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrgMeeting() when $default != null:
return $default(_that.id,_that.institutionId,_that.date,_that.title,_that.agendaItems,_that.attendeeCount,_that.totalMemberCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String institutionId,  String date,  String title,  List<String> agendaItems,  int attendeeCount,  int totalMemberCount)  $default,) {final _that = this;
switch (_that) {
case _OrgMeeting():
return $default(_that.id,_that.institutionId,_that.date,_that.title,_that.agendaItems,_that.attendeeCount,_that.totalMemberCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String institutionId,  String date,  String title,  List<String> agendaItems,  int attendeeCount,  int totalMemberCount)?  $default,) {final _that = this;
switch (_that) {
case _OrgMeeting() when $default != null:
return $default(_that.id,_that.institutionId,_that.date,_that.title,_that.agendaItems,_that.attendeeCount,_that.totalMemberCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrgMeeting implements OrgMeeting {
  const _OrgMeeting({required this.id, required this.institutionId, required this.date, required this.title, final  List<String> agendaItems = const [], this.attendeeCount = 0, this.totalMemberCount = 0}): _agendaItems = agendaItems;
  factory _OrgMeeting.fromJson(Map<String, dynamic> json) => _$OrgMeetingFromJson(json);

@override final  String id;
@override final  String institutionId;
@override final  String date;
@override final  String title;
 final  List<String> _agendaItems;
@override@JsonKey() List<String> get agendaItems {
  if (_agendaItems is EqualUnmodifiableListView) return _agendaItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_agendaItems);
}

@override@JsonKey() final  int attendeeCount;
@override@JsonKey() final  int totalMemberCount;

/// Create a copy of OrgMeeting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrgMeetingCopyWith<_OrgMeeting> get copyWith => __$OrgMeetingCopyWithImpl<_OrgMeeting>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrgMeetingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrgMeeting&&(identical(other.id, id) || other.id == id)&&(identical(other.institutionId, institutionId) || other.institutionId == institutionId)&&(identical(other.date, date) || other.date == date)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._agendaItems, _agendaItems)&&(identical(other.attendeeCount, attendeeCount) || other.attendeeCount == attendeeCount)&&(identical(other.totalMemberCount, totalMemberCount) || other.totalMemberCount == totalMemberCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,institutionId,date,title,const DeepCollectionEquality().hash(_agendaItems),attendeeCount,totalMemberCount);

@override
String toString() {
  return 'OrgMeeting(id: $id, institutionId: $institutionId, date: $date, title: $title, agendaItems: $agendaItems, attendeeCount: $attendeeCount, totalMemberCount: $totalMemberCount)';
}


}

/// @nodoc
abstract mixin class _$OrgMeetingCopyWith<$Res> implements $OrgMeetingCopyWith<$Res> {
  factory _$OrgMeetingCopyWith(_OrgMeeting value, $Res Function(_OrgMeeting) _then) = __$OrgMeetingCopyWithImpl;
@override @useResult
$Res call({
 String id, String institutionId, String date, String title, List<String> agendaItems, int attendeeCount, int totalMemberCount
});




}
/// @nodoc
class __$OrgMeetingCopyWithImpl<$Res>
    implements _$OrgMeetingCopyWith<$Res> {
  __$OrgMeetingCopyWithImpl(this._self, this._then);

  final _OrgMeeting _self;
  final $Res Function(_OrgMeeting) _then;

/// Create a copy of OrgMeeting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? institutionId = null,Object? date = null,Object? title = null,Object? agendaItems = null,Object? attendeeCount = null,Object? totalMemberCount = null,}) {
  return _then(_OrgMeeting(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,institutionId: null == institutionId ? _self.institutionId : institutionId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,agendaItems: null == agendaItems ? _self._agendaItems : agendaItems // ignore: cast_nullable_to_non_nullable
as List<String>,attendeeCount: null == attendeeCount ? _self.attendeeCount : attendeeCount // ignore: cast_nullable_to_non_nullable
as int,totalMemberCount: null == totalMemberCount ? _self.totalMemberCount : totalMemberCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OrgRepresentative {

 String get id; String get name; List<String> get institutionIds; String get rank; String get term; double get attendanceRate; int get proposalCount; double get voteRate; int get objectionCount; RepPerformanceTier get tier; List<OrgMeeting> get recentVotes;
/// Create a copy of OrgRepresentative
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrgRepresentativeCopyWith<OrgRepresentative> get copyWith => _$OrgRepresentativeCopyWithImpl<OrgRepresentative>(this as OrgRepresentative, _$identity);

  /// Serializes this OrgRepresentative to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrgRepresentative&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.institutionIds, institutionIds)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.term, term) || other.term == term)&&(identical(other.attendanceRate, attendanceRate) || other.attendanceRate == attendanceRate)&&(identical(other.proposalCount, proposalCount) || other.proposalCount == proposalCount)&&(identical(other.voteRate, voteRate) || other.voteRate == voteRate)&&(identical(other.objectionCount, objectionCount) || other.objectionCount == objectionCount)&&(identical(other.tier, tier) || other.tier == tier)&&const DeepCollectionEquality().equals(other.recentVotes, recentVotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(institutionIds),rank,term,attendanceRate,proposalCount,voteRate,objectionCount,tier,const DeepCollectionEquality().hash(recentVotes));

@override
String toString() {
  return 'OrgRepresentative(id: $id, name: $name, institutionIds: $institutionIds, rank: $rank, term: $term, attendanceRate: $attendanceRate, proposalCount: $proposalCount, voteRate: $voteRate, objectionCount: $objectionCount, tier: $tier, recentVotes: $recentVotes)';
}


}

/// @nodoc
abstract mixin class $OrgRepresentativeCopyWith<$Res>  {
  factory $OrgRepresentativeCopyWith(OrgRepresentative value, $Res Function(OrgRepresentative) _then) = _$OrgRepresentativeCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> institutionIds, String rank, String term, double attendanceRate, int proposalCount, double voteRate, int objectionCount, RepPerformanceTier tier, List<OrgMeeting> recentVotes
});




}
/// @nodoc
class _$OrgRepresentativeCopyWithImpl<$Res>
    implements $OrgRepresentativeCopyWith<$Res> {
  _$OrgRepresentativeCopyWithImpl(this._self, this._then);

  final OrgRepresentative _self;
  final $Res Function(OrgRepresentative) _then;

/// Create a copy of OrgRepresentative
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? institutionIds = null,Object? rank = null,Object? term = null,Object? attendanceRate = null,Object? proposalCount = null,Object? voteRate = null,Object? objectionCount = null,Object? tier = null,Object? recentVotes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,institutionIds: null == institutionIds ? _self.institutionIds : institutionIds // ignore: cast_nullable_to_non_nullable
as List<String>,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as String,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,attendanceRate: null == attendanceRate ? _self.attendanceRate : attendanceRate // ignore: cast_nullable_to_non_nullable
as double,proposalCount: null == proposalCount ? _self.proposalCount : proposalCount // ignore: cast_nullable_to_non_nullable
as int,voteRate: null == voteRate ? _self.voteRate : voteRate // ignore: cast_nullable_to_non_nullable
as double,objectionCount: null == objectionCount ? _self.objectionCount : objectionCount // ignore: cast_nullable_to_non_nullable
as int,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as RepPerformanceTier,recentVotes: null == recentVotes ? _self.recentVotes : recentVotes // ignore: cast_nullable_to_non_nullable
as List<OrgMeeting>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrgRepresentative].
extension OrgRepresentativePatterns on OrgRepresentative {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrgRepresentative value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrgRepresentative() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrgRepresentative value)  $default,){
final _that = this;
switch (_that) {
case _OrgRepresentative():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrgRepresentative value)?  $default,){
final _that = this;
switch (_that) {
case _OrgRepresentative() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> institutionIds,  String rank,  String term,  double attendanceRate,  int proposalCount,  double voteRate,  int objectionCount,  RepPerformanceTier tier,  List<OrgMeeting> recentVotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrgRepresentative() when $default != null:
return $default(_that.id,_that.name,_that.institutionIds,_that.rank,_that.term,_that.attendanceRate,_that.proposalCount,_that.voteRate,_that.objectionCount,_that.tier,_that.recentVotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> institutionIds,  String rank,  String term,  double attendanceRate,  int proposalCount,  double voteRate,  int objectionCount,  RepPerformanceTier tier,  List<OrgMeeting> recentVotes)  $default,) {final _that = this;
switch (_that) {
case _OrgRepresentative():
return $default(_that.id,_that.name,_that.institutionIds,_that.rank,_that.term,_that.attendanceRate,_that.proposalCount,_that.voteRate,_that.objectionCount,_that.tier,_that.recentVotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> institutionIds,  String rank,  String term,  double attendanceRate,  int proposalCount,  double voteRate,  int objectionCount,  RepPerformanceTier tier,  List<OrgMeeting> recentVotes)?  $default,) {final _that = this;
switch (_that) {
case _OrgRepresentative() when $default != null:
return $default(_that.id,_that.name,_that.institutionIds,_that.rank,_that.term,_that.attendanceRate,_that.proposalCount,_that.voteRate,_that.objectionCount,_that.tier,_that.recentVotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrgRepresentative implements OrgRepresentative {
  const _OrgRepresentative({required this.id, required this.name, required final  List<String> institutionIds, required this.rank, this.term = '', this.attendanceRate = 0.0, this.proposalCount = 0, this.voteRate = 0.0, this.objectionCount = 0, required this.tier, final  List<OrgMeeting> recentVotes = const []}): _institutionIds = institutionIds,_recentVotes = recentVotes;
  factory _OrgRepresentative.fromJson(Map<String, dynamic> json) => _$OrgRepresentativeFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _institutionIds;
@override List<String> get institutionIds {
  if (_institutionIds is EqualUnmodifiableListView) return _institutionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_institutionIds);
}

@override final  String rank;
@override@JsonKey() final  String term;
@override@JsonKey() final  double attendanceRate;
@override@JsonKey() final  int proposalCount;
@override@JsonKey() final  double voteRate;
@override@JsonKey() final  int objectionCount;
@override final  RepPerformanceTier tier;
 final  List<OrgMeeting> _recentVotes;
@override@JsonKey() List<OrgMeeting> get recentVotes {
  if (_recentVotes is EqualUnmodifiableListView) return _recentVotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentVotes);
}


/// Create a copy of OrgRepresentative
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrgRepresentativeCopyWith<_OrgRepresentative> get copyWith => __$OrgRepresentativeCopyWithImpl<_OrgRepresentative>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrgRepresentativeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrgRepresentative&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._institutionIds, _institutionIds)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.term, term) || other.term == term)&&(identical(other.attendanceRate, attendanceRate) || other.attendanceRate == attendanceRate)&&(identical(other.proposalCount, proposalCount) || other.proposalCount == proposalCount)&&(identical(other.voteRate, voteRate) || other.voteRate == voteRate)&&(identical(other.objectionCount, objectionCount) || other.objectionCount == objectionCount)&&(identical(other.tier, tier) || other.tier == tier)&&const DeepCollectionEquality().equals(other._recentVotes, _recentVotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_institutionIds),rank,term,attendanceRate,proposalCount,voteRate,objectionCount,tier,const DeepCollectionEquality().hash(_recentVotes));

@override
String toString() {
  return 'OrgRepresentative(id: $id, name: $name, institutionIds: $institutionIds, rank: $rank, term: $term, attendanceRate: $attendanceRate, proposalCount: $proposalCount, voteRate: $voteRate, objectionCount: $objectionCount, tier: $tier, recentVotes: $recentVotes)';
}


}

/// @nodoc
abstract mixin class _$OrgRepresentativeCopyWith<$Res> implements $OrgRepresentativeCopyWith<$Res> {
  factory _$OrgRepresentativeCopyWith(_OrgRepresentative value, $Res Function(_OrgRepresentative) _then) = __$OrgRepresentativeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> institutionIds, String rank, String term, double attendanceRate, int proposalCount, double voteRate, int objectionCount, RepPerformanceTier tier, List<OrgMeeting> recentVotes
});




}
/// @nodoc
class __$OrgRepresentativeCopyWithImpl<$Res>
    implements _$OrgRepresentativeCopyWith<$Res> {
  __$OrgRepresentativeCopyWithImpl(this._self, this._then);

  final _OrgRepresentative _self;
  final $Res Function(_OrgRepresentative) _then;

/// Create a copy of OrgRepresentative
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? institutionIds = null,Object? rank = null,Object? term = null,Object? attendanceRate = null,Object? proposalCount = null,Object? voteRate = null,Object? objectionCount = null,Object? tier = null,Object? recentVotes = null,}) {
  return _then(_OrgRepresentative(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,institutionIds: null == institutionIds ? _self._institutionIds : institutionIds // ignore: cast_nullable_to_non_nullable
as List<String>,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as String,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,attendanceRate: null == attendanceRate ? _self.attendanceRate : attendanceRate // ignore: cast_nullable_to_non_nullable
as double,proposalCount: null == proposalCount ? _self.proposalCount : proposalCount // ignore: cast_nullable_to_non_nullable
as int,voteRate: null == voteRate ? _self.voteRate : voteRate // ignore: cast_nullable_to_non_nullable
as double,objectionCount: null == objectionCount ? _self.objectionCount : objectionCount // ignore: cast_nullable_to_non_nullable
as int,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as RepPerformanceTier,recentVotes: null == recentVotes ? _self._recentVotes : recentVotes // ignore: cast_nullable_to_non_nullable
as List<OrgMeeting>,
  ));
}


}


/// @nodoc
mixin _$OrgRank {

 String get name; bool get isManagement; int get headCount;
/// Create a copy of OrgRank
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrgRankCopyWith<OrgRank> get copyWith => _$OrgRankCopyWithImpl<OrgRank>(this as OrgRank, _$identity);

  /// Serializes this OrgRank to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrgRank&&(identical(other.name, name) || other.name == name)&&(identical(other.isManagement, isManagement) || other.isManagement == isManagement)&&(identical(other.headCount, headCount) || other.headCount == headCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,isManagement,headCount);

@override
String toString() {
  return 'OrgRank(name: $name, isManagement: $isManagement, headCount: $headCount)';
}


}

/// @nodoc
abstract mixin class $OrgRankCopyWith<$Res>  {
  factory $OrgRankCopyWith(OrgRank value, $Res Function(OrgRank) _then) = _$OrgRankCopyWithImpl;
@useResult
$Res call({
 String name, bool isManagement, int headCount
});




}
/// @nodoc
class _$OrgRankCopyWithImpl<$Res>
    implements $OrgRankCopyWith<$Res> {
  _$OrgRankCopyWithImpl(this._self, this._then);

  final OrgRank _self;
  final $Res Function(OrgRank) _then;

/// Create a copy of OrgRank
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? isManagement = null,Object? headCount = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isManagement: null == isManagement ? _self.isManagement : isManagement // ignore: cast_nullable_to_non_nullable
as bool,headCount: null == headCount ? _self.headCount : headCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrgRank].
extension OrgRankPatterns on OrgRank {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrgRank value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrgRank() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrgRank value)  $default,){
final _that = this;
switch (_that) {
case _OrgRank():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrgRank value)?  $default,){
final _that = this;
switch (_that) {
case _OrgRank() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  bool isManagement,  int headCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrgRank() when $default != null:
return $default(_that.name,_that.isManagement,_that.headCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  bool isManagement,  int headCount)  $default,) {final _that = this;
switch (_that) {
case _OrgRank():
return $default(_that.name,_that.isManagement,_that.headCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  bool isManagement,  int headCount)?  $default,) {final _that = this;
switch (_that) {
case _OrgRank() when $default != null:
return $default(_that.name,_that.isManagement,_that.headCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrgRank implements OrgRank {
  const _OrgRank({required this.name, this.isManagement = false, this.headCount = 0});
  factory _OrgRank.fromJson(Map<String, dynamic> json) => _$OrgRankFromJson(json);

@override final  String name;
@override@JsonKey() final  bool isManagement;
@override@JsonKey() final  int headCount;

/// Create a copy of OrgRank
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrgRankCopyWith<_OrgRank> get copyWith => __$OrgRankCopyWithImpl<_OrgRank>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrgRankToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrgRank&&(identical(other.name, name) || other.name == name)&&(identical(other.isManagement, isManagement) || other.isManagement == isManagement)&&(identical(other.headCount, headCount) || other.headCount == headCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,isManagement,headCount);

@override
String toString() {
  return 'OrgRank(name: $name, isManagement: $isManagement, headCount: $headCount)';
}


}

/// @nodoc
abstract mixin class _$OrgRankCopyWith<$Res> implements $OrgRankCopyWith<$Res> {
  factory _$OrgRankCopyWith(_OrgRank value, $Res Function(_OrgRank) _then) = __$OrgRankCopyWithImpl;
@override @useResult
$Res call({
 String name, bool isManagement, int headCount
});




}
/// @nodoc
class __$OrgRankCopyWithImpl<$Res>
    implements _$OrgRankCopyWith<$Res> {
  __$OrgRankCopyWithImpl(this._self, this._then);

  final _OrgRank _self;
  final $Res Function(_OrgRank) _then;

/// Create a copy of OrgRank
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? isManagement = null,Object? headCount = null,}) {
  return _then(_OrgRank(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isManagement: null == isManagement ? _self.isManagement : isManagement // ignore: cast_nullable_to_non_nullable
as bool,headCount: null == headCount ? _self.headCount : headCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OrgPromotion {

 String get id; String get personName; String get fromRank; String get toRank; String get date; bool get isCrossTrack;
/// Create a copy of OrgPromotion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrgPromotionCopyWith<OrgPromotion> get copyWith => _$OrgPromotionCopyWithImpl<OrgPromotion>(this as OrgPromotion, _$identity);

  /// Serializes this OrgPromotion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrgPromotion&&(identical(other.id, id) || other.id == id)&&(identical(other.personName, personName) || other.personName == personName)&&(identical(other.fromRank, fromRank) || other.fromRank == fromRank)&&(identical(other.toRank, toRank) || other.toRank == toRank)&&(identical(other.date, date) || other.date == date)&&(identical(other.isCrossTrack, isCrossTrack) || other.isCrossTrack == isCrossTrack));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,personName,fromRank,toRank,date,isCrossTrack);

@override
String toString() {
  return 'OrgPromotion(id: $id, personName: $personName, fromRank: $fromRank, toRank: $toRank, date: $date, isCrossTrack: $isCrossTrack)';
}


}

/// @nodoc
abstract mixin class $OrgPromotionCopyWith<$Res>  {
  factory $OrgPromotionCopyWith(OrgPromotion value, $Res Function(OrgPromotion) _then) = _$OrgPromotionCopyWithImpl;
@useResult
$Res call({
 String id, String personName, String fromRank, String toRank, String date, bool isCrossTrack
});




}
/// @nodoc
class _$OrgPromotionCopyWithImpl<$Res>
    implements $OrgPromotionCopyWith<$Res> {
  _$OrgPromotionCopyWithImpl(this._self, this._then);

  final OrgPromotion _self;
  final $Res Function(OrgPromotion) _then;

/// Create a copy of OrgPromotion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? personName = null,Object? fromRank = null,Object? toRank = null,Object? date = null,Object? isCrossTrack = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,personName: null == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String,fromRank: null == fromRank ? _self.fromRank : fromRank // ignore: cast_nullable_to_non_nullable
as String,toRank: null == toRank ? _self.toRank : toRank // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,isCrossTrack: null == isCrossTrack ? _self.isCrossTrack : isCrossTrack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OrgPromotion].
extension OrgPromotionPatterns on OrgPromotion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrgPromotion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrgPromotion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrgPromotion value)  $default,){
final _that = this;
switch (_that) {
case _OrgPromotion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrgPromotion value)?  $default,){
final _that = this;
switch (_that) {
case _OrgPromotion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String personName,  String fromRank,  String toRank,  String date,  bool isCrossTrack)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrgPromotion() when $default != null:
return $default(_that.id,_that.personName,_that.fromRank,_that.toRank,_that.date,_that.isCrossTrack);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String personName,  String fromRank,  String toRank,  String date,  bool isCrossTrack)  $default,) {final _that = this;
switch (_that) {
case _OrgPromotion():
return $default(_that.id,_that.personName,_that.fromRank,_that.toRank,_that.date,_that.isCrossTrack);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String personName,  String fromRank,  String toRank,  String date,  bool isCrossTrack)?  $default,) {final _that = this;
switch (_that) {
case _OrgPromotion() when $default != null:
return $default(_that.id,_that.personName,_that.fromRank,_that.toRank,_that.date,_that.isCrossTrack);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrgPromotion implements OrgPromotion {
  const _OrgPromotion({required this.id, required this.personName, required this.fromRank, required this.toRank, required this.date, this.isCrossTrack = false});
  factory _OrgPromotion.fromJson(Map<String, dynamic> json) => _$OrgPromotionFromJson(json);

@override final  String id;
@override final  String personName;
@override final  String fromRank;
@override final  String toRank;
@override final  String date;
@override@JsonKey() final  bool isCrossTrack;

/// Create a copy of OrgPromotion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrgPromotionCopyWith<_OrgPromotion> get copyWith => __$OrgPromotionCopyWithImpl<_OrgPromotion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrgPromotionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrgPromotion&&(identical(other.id, id) || other.id == id)&&(identical(other.personName, personName) || other.personName == personName)&&(identical(other.fromRank, fromRank) || other.fromRank == fromRank)&&(identical(other.toRank, toRank) || other.toRank == toRank)&&(identical(other.date, date) || other.date == date)&&(identical(other.isCrossTrack, isCrossTrack) || other.isCrossTrack == isCrossTrack));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,personName,fromRank,toRank,date,isCrossTrack);

@override
String toString() {
  return 'OrgPromotion(id: $id, personName: $personName, fromRank: $fromRank, toRank: $toRank, date: $date, isCrossTrack: $isCrossTrack)';
}


}

/// @nodoc
abstract mixin class _$OrgPromotionCopyWith<$Res> implements $OrgPromotionCopyWith<$Res> {
  factory _$OrgPromotionCopyWith(_OrgPromotion value, $Res Function(_OrgPromotion) _then) = __$OrgPromotionCopyWithImpl;
@override @useResult
$Res call({
 String id, String personName, String fromRank, String toRank, String date, bool isCrossTrack
});




}
/// @nodoc
class __$OrgPromotionCopyWithImpl<$Res>
    implements _$OrgPromotionCopyWith<$Res> {
  __$OrgPromotionCopyWithImpl(this._self, this._then);

  final _OrgPromotion _self;
  final $Res Function(_OrgPromotion) _then;

/// Create a copy of OrgPromotion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? personName = null,Object? fromRank = null,Object? toRank = null,Object? date = null,Object? isCrossTrack = null,}) {
  return _then(_OrgPromotion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,personName: null == personName ? _self.personName : personName // ignore: cast_nullable_to_non_nullable
as String,fromRank: null == fromRank ? _self.fromRank : fromRank // ignore: cast_nullable_to_non_nullable
as String,toRank: null == toRank ? _self.toRank : toRank // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,isCrossTrack: null == isCrossTrack ? _self.isCrossTrack : isCrossTrack // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$OrgDashboard {

 List<OrgInstitution> get institutions; List<OrgRepresentative> get representatives; List<OrgRank> get ranks; List<OrgPromotion> get promotions;
/// Create a copy of OrgDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrgDashboardCopyWith<OrgDashboard> get copyWith => _$OrgDashboardCopyWithImpl<OrgDashboard>(this as OrgDashboard, _$identity);

  /// Serializes this OrgDashboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrgDashboard&&const DeepCollectionEquality().equals(other.institutions, institutions)&&const DeepCollectionEquality().equals(other.representatives, representatives)&&const DeepCollectionEquality().equals(other.ranks, ranks)&&const DeepCollectionEquality().equals(other.promotions, promotions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(institutions),const DeepCollectionEquality().hash(representatives),const DeepCollectionEquality().hash(ranks),const DeepCollectionEquality().hash(promotions));

@override
String toString() {
  return 'OrgDashboard(institutions: $institutions, representatives: $representatives, ranks: $ranks, promotions: $promotions)';
}


}

/// @nodoc
abstract mixin class $OrgDashboardCopyWith<$Res>  {
  factory $OrgDashboardCopyWith(OrgDashboard value, $Res Function(OrgDashboard) _then) = _$OrgDashboardCopyWithImpl;
@useResult
$Res call({
 List<OrgInstitution> institutions, List<OrgRepresentative> representatives, List<OrgRank> ranks, List<OrgPromotion> promotions
});




}
/// @nodoc
class _$OrgDashboardCopyWithImpl<$Res>
    implements $OrgDashboardCopyWith<$Res> {
  _$OrgDashboardCopyWithImpl(this._self, this._then);

  final OrgDashboard _self;
  final $Res Function(OrgDashboard) _then;

/// Create a copy of OrgDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? institutions = null,Object? representatives = null,Object? ranks = null,Object? promotions = null,}) {
  return _then(_self.copyWith(
institutions: null == institutions ? _self.institutions : institutions // ignore: cast_nullable_to_non_nullable
as List<OrgInstitution>,representatives: null == representatives ? _self.representatives : representatives // ignore: cast_nullable_to_non_nullable
as List<OrgRepresentative>,ranks: null == ranks ? _self.ranks : ranks // ignore: cast_nullable_to_non_nullable
as List<OrgRank>,promotions: null == promotions ? _self.promotions : promotions // ignore: cast_nullable_to_non_nullable
as List<OrgPromotion>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrgDashboard].
extension OrgDashboardPatterns on OrgDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrgDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrgDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrgDashboard value)  $default,){
final _that = this;
switch (_that) {
case _OrgDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrgDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _OrgDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OrgInstitution> institutions,  List<OrgRepresentative> representatives,  List<OrgRank> ranks,  List<OrgPromotion> promotions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrgDashboard() when $default != null:
return $default(_that.institutions,_that.representatives,_that.ranks,_that.promotions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OrgInstitution> institutions,  List<OrgRepresentative> representatives,  List<OrgRank> ranks,  List<OrgPromotion> promotions)  $default,) {final _that = this;
switch (_that) {
case _OrgDashboard():
return $default(_that.institutions,_that.representatives,_that.ranks,_that.promotions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OrgInstitution> institutions,  List<OrgRepresentative> representatives,  List<OrgRank> ranks,  List<OrgPromotion> promotions)?  $default,) {final _that = this;
switch (_that) {
case _OrgDashboard() when $default != null:
return $default(_that.institutions,_that.representatives,_that.ranks,_that.promotions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrgDashboard implements OrgDashboard {
  const _OrgDashboard({required final  List<OrgInstitution> institutions, required final  List<OrgRepresentative> representatives, required final  List<OrgRank> ranks, required final  List<OrgPromotion> promotions}): _institutions = institutions,_representatives = representatives,_ranks = ranks,_promotions = promotions;
  factory _OrgDashboard.fromJson(Map<String, dynamic> json) => _$OrgDashboardFromJson(json);

 final  List<OrgInstitution> _institutions;
@override List<OrgInstitution> get institutions {
  if (_institutions is EqualUnmodifiableListView) return _institutions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_institutions);
}

 final  List<OrgRepresentative> _representatives;
@override List<OrgRepresentative> get representatives {
  if (_representatives is EqualUnmodifiableListView) return _representatives;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_representatives);
}

 final  List<OrgRank> _ranks;
@override List<OrgRank> get ranks {
  if (_ranks is EqualUnmodifiableListView) return _ranks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ranks);
}

 final  List<OrgPromotion> _promotions;
@override List<OrgPromotion> get promotions {
  if (_promotions is EqualUnmodifiableListView) return _promotions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_promotions);
}


/// Create a copy of OrgDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrgDashboardCopyWith<_OrgDashboard> get copyWith => __$OrgDashboardCopyWithImpl<_OrgDashboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrgDashboardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrgDashboard&&const DeepCollectionEquality().equals(other._institutions, _institutions)&&const DeepCollectionEquality().equals(other._representatives, _representatives)&&const DeepCollectionEquality().equals(other._ranks, _ranks)&&const DeepCollectionEquality().equals(other._promotions, _promotions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_institutions),const DeepCollectionEquality().hash(_representatives),const DeepCollectionEquality().hash(_ranks),const DeepCollectionEquality().hash(_promotions));

@override
String toString() {
  return 'OrgDashboard(institutions: $institutions, representatives: $representatives, ranks: $ranks, promotions: $promotions)';
}


}

/// @nodoc
abstract mixin class _$OrgDashboardCopyWith<$Res> implements $OrgDashboardCopyWith<$Res> {
  factory _$OrgDashboardCopyWith(_OrgDashboard value, $Res Function(_OrgDashboard) _then) = __$OrgDashboardCopyWithImpl;
@override @useResult
$Res call({
 List<OrgInstitution> institutions, List<OrgRepresentative> representatives, List<OrgRank> ranks, List<OrgPromotion> promotions
});




}
/// @nodoc
class __$OrgDashboardCopyWithImpl<$Res>
    implements _$OrgDashboardCopyWith<$Res> {
  __$OrgDashboardCopyWithImpl(this._self, this._then);

  final _OrgDashboard _self;
  final $Res Function(_OrgDashboard) _then;

/// Create a copy of OrgDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? institutions = null,Object? representatives = null,Object? ranks = null,Object? promotions = null,}) {
  return _then(_OrgDashboard(
institutions: null == institutions ? _self._institutions : institutions // ignore: cast_nullable_to_non_nullable
as List<OrgInstitution>,representatives: null == representatives ? _self._representatives : representatives // ignore: cast_nullable_to_non_nullable
as List<OrgRepresentative>,ranks: null == ranks ? _self._ranks : ranks // ignore: cast_nullable_to_non_nullable
as List<OrgRank>,promotions: null == promotions ? _self._promotions : promotions // ignore: cast_nullable_to_non_nullable
as List<OrgPromotion>,
  ));
}


}

// dart format on
