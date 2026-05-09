// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DecisionAction {

 String get label; bool get isPrimary;
/// Create a copy of DecisionAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionActionCopyWith<DecisionAction> get copyWith => _$DecisionActionCopyWithImpl<DecisionAction>(this as DecisionAction, _$identity);

  /// Serializes this DecisionAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DecisionAction&&(identical(other.label, label) || other.label == label)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,isPrimary);

@override
String toString() {
  return 'DecisionAction(label: $label, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class $DecisionActionCopyWith<$Res>  {
  factory $DecisionActionCopyWith(DecisionAction value, $Res Function(DecisionAction) _then) = _$DecisionActionCopyWithImpl;
@useResult
$Res call({
 String label, bool isPrimary
});




}
/// @nodoc
class _$DecisionActionCopyWithImpl<$Res>
    implements $DecisionActionCopyWith<$Res> {
  _$DecisionActionCopyWithImpl(this._self, this._then);

  final DecisionAction _self;
  final $Res Function(DecisionAction) _then;

/// Create a copy of DecisionAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? isPrimary = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DecisionAction].
extension DecisionActionPatterns on DecisionAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DecisionAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DecisionAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DecisionAction value)  $default,){
final _that = this;
switch (_that) {
case _DecisionAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DecisionAction value)?  $default,){
final _that = this;
switch (_that) {
case _DecisionAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  bool isPrimary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DecisionAction() when $default != null:
return $default(_that.label,_that.isPrimary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  bool isPrimary)  $default,) {final _that = this;
switch (_that) {
case _DecisionAction():
return $default(_that.label,_that.isPrimary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  bool isPrimary)?  $default,) {final _that = this;
switch (_that) {
case _DecisionAction() when $default != null:
return $default(_that.label,_that.isPrimary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DecisionAction implements DecisionAction {
  const _DecisionAction({required this.label, this.isPrimary = false});
  factory _DecisionAction.fromJson(Map<String, dynamic> json) => _$DecisionActionFromJson(json);

@override final  String label;
@override@JsonKey() final  bool isPrimary;

/// Create a copy of DecisionAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecisionActionCopyWith<_DecisionAction> get copyWith => __$DecisionActionCopyWithImpl<_DecisionAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DecisionActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DecisionAction&&(identical(other.label, label) || other.label == label)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,isPrimary);

@override
String toString() {
  return 'DecisionAction(label: $label, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class _$DecisionActionCopyWith<$Res> implements $DecisionActionCopyWith<$Res> {
  factory _$DecisionActionCopyWith(_DecisionAction value, $Res Function(_DecisionAction) _then) = __$DecisionActionCopyWithImpl;
@override @useResult
$Res call({
 String label, bool isPrimary
});




}
/// @nodoc
class __$DecisionActionCopyWithImpl<$Res>
    implements _$DecisionActionCopyWith<$Res> {
  __$DecisionActionCopyWithImpl(this._self, this._then);

  final _DecisionAction _self;
  final $Res Function(_DecisionAction) _then;

/// Create a copy of DecisionAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? isPrimary = null,}) {
  return _then(_DecisionAction(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Decision {

 String get fromPerson; String get deadline; String get title; String get context; String get teamAdvice; bool get isUrgent; List<DecisionAction> get actions;
/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionCopyWith<Decision> get copyWith => _$DecisionCopyWithImpl<Decision>(this as Decision, _$identity);

  /// Serializes this Decision to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Decision&&(identical(other.fromPerson, fromPerson) || other.fromPerson == fromPerson)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.title, title) || other.title == title)&&(identical(other.context, context) || other.context == context)&&(identical(other.teamAdvice, teamAdvice) || other.teamAdvice == teamAdvice)&&(identical(other.isUrgent, isUrgent) || other.isUrgent == isUrgent)&&const DeepCollectionEquality().equals(other.actions, actions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromPerson,deadline,title,context,teamAdvice,isUrgent,const DeepCollectionEquality().hash(actions));

@override
String toString() {
  return 'Decision(fromPerson: $fromPerson, deadline: $deadline, title: $title, context: $context, teamAdvice: $teamAdvice, isUrgent: $isUrgent, actions: $actions)';
}


}

/// @nodoc
abstract mixin class $DecisionCopyWith<$Res>  {
  factory $DecisionCopyWith(Decision value, $Res Function(Decision) _then) = _$DecisionCopyWithImpl;
@useResult
$Res call({
 String fromPerson, String deadline, String title, String context, String teamAdvice, bool isUrgent, List<DecisionAction> actions
});




}
/// @nodoc
class _$DecisionCopyWithImpl<$Res>
    implements $DecisionCopyWith<$Res> {
  _$DecisionCopyWithImpl(this._self, this._then);

  final Decision _self;
  final $Res Function(Decision) _then;

/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromPerson = null,Object? deadline = null,Object? title = null,Object? context = null,Object? teamAdvice = null,Object? isUrgent = null,Object? actions = null,}) {
  return _then(_self.copyWith(
fromPerson: null == fromPerson ? _self.fromPerson : fromPerson // ignore: cast_nullable_to_non_nullable
as String,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String,teamAdvice: null == teamAdvice ? _self.teamAdvice : teamAdvice // ignore: cast_nullable_to_non_nullable
as String,isUrgent: null == isUrgent ? _self.isUrgent : isUrgent // ignore: cast_nullable_to_non_nullable
as bool,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<DecisionAction>,
  ));
}

}


/// Adds pattern-matching-related methods to [Decision].
extension DecisionPatterns on Decision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Decision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Decision() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Decision value)  $default,){
final _that = this;
switch (_that) {
case _Decision():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Decision value)?  $default,){
final _that = this;
switch (_that) {
case _Decision() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fromPerson,  String deadline,  String title,  String context,  String teamAdvice,  bool isUrgent,  List<DecisionAction> actions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Decision() when $default != null:
return $default(_that.fromPerson,_that.deadline,_that.title,_that.context,_that.teamAdvice,_that.isUrgent,_that.actions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fromPerson,  String deadline,  String title,  String context,  String teamAdvice,  bool isUrgent,  List<DecisionAction> actions)  $default,) {final _that = this;
switch (_that) {
case _Decision():
return $default(_that.fromPerson,_that.deadline,_that.title,_that.context,_that.teamAdvice,_that.isUrgent,_that.actions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fromPerson,  String deadline,  String title,  String context,  String teamAdvice,  bool isUrgent,  List<DecisionAction> actions)?  $default,) {final _that = this;
switch (_that) {
case _Decision() when $default != null:
return $default(_that.fromPerson,_that.deadline,_that.title,_that.context,_that.teamAdvice,_that.isUrgent,_that.actions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Decision implements Decision {
  const _Decision({required this.fromPerson, required this.deadline, required this.title, required this.context, required this.teamAdvice, this.isUrgent = false, required final  List<DecisionAction> actions}): _actions = actions;
  factory _Decision.fromJson(Map<String, dynamic> json) => _$DecisionFromJson(json);

@override final  String fromPerson;
@override final  String deadline;
@override final  String title;
@override final  String context;
@override final  String teamAdvice;
@override@JsonKey() final  bool isUrgent;
 final  List<DecisionAction> _actions;
@override List<DecisionAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}


/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecisionCopyWith<_Decision> get copyWith => __$DecisionCopyWithImpl<_Decision>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DecisionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Decision&&(identical(other.fromPerson, fromPerson) || other.fromPerson == fromPerson)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.title, title) || other.title == title)&&(identical(other.context, context) || other.context == context)&&(identical(other.teamAdvice, teamAdvice) || other.teamAdvice == teamAdvice)&&(identical(other.isUrgent, isUrgent) || other.isUrgent == isUrgent)&&const DeepCollectionEquality().equals(other._actions, _actions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromPerson,deadline,title,context,teamAdvice,isUrgent,const DeepCollectionEquality().hash(_actions));

@override
String toString() {
  return 'Decision(fromPerson: $fromPerson, deadline: $deadline, title: $title, context: $context, teamAdvice: $teamAdvice, isUrgent: $isUrgent, actions: $actions)';
}


}

/// @nodoc
abstract mixin class _$DecisionCopyWith<$Res> implements $DecisionCopyWith<$Res> {
  factory _$DecisionCopyWith(_Decision value, $Res Function(_Decision) _then) = __$DecisionCopyWithImpl;
@override @useResult
$Res call({
 String fromPerson, String deadline, String title, String context, String teamAdvice, bool isUrgent, List<DecisionAction> actions
});




}
/// @nodoc
class __$DecisionCopyWithImpl<$Res>
    implements _$DecisionCopyWith<$Res> {
  __$DecisionCopyWithImpl(this._self, this._then);

  final _Decision _self;
  final $Res Function(_Decision) _then;

/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromPerson = null,Object? deadline = null,Object? title = null,Object? context = null,Object? teamAdvice = null,Object? isUrgent = null,Object? actions = null,}) {
  return _then(_Decision(
fromPerson: null == fromPerson ? _self.fromPerson : fromPerson // ignore: cast_nullable_to_non_nullable
as String,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String,teamAdvice: null == teamAdvice ? _self.teamAdvice : teamAdvice // ignore: cast_nullable_to_non_nullable
as String,isUrgent: null == isUrgent ? _self.isUrgent : isUrgent // ignore: cast_nullable_to_non_nullable
as bool,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<DecisionAction>,
  ));
}


}


/// @nodoc
mixin _$BusinessUnit {

 String get name; String get tag; bool get isPrimary; String get screenType; String? get consultSource; List<Decision> get decisions; String? get emptyMessage;
/// Create a copy of BusinessUnit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessUnitCopyWith<BusinessUnit> get copyWith => _$BusinessUnitCopyWithImpl<BusinessUnit>(this as BusinessUnit, _$identity);

  /// Serializes this BusinessUnit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessUnit&&(identical(other.name, name) || other.name == name)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.screenType, screenType) || other.screenType == screenType)&&(identical(other.consultSource, consultSource) || other.consultSource == consultSource)&&const DeepCollectionEquality().equals(other.decisions, decisions)&&(identical(other.emptyMessage, emptyMessage) || other.emptyMessage == emptyMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,tag,isPrimary,screenType,consultSource,const DeepCollectionEquality().hash(decisions),emptyMessage);

@override
String toString() {
  return 'BusinessUnit(name: $name, tag: $tag, isPrimary: $isPrimary, screenType: $screenType, consultSource: $consultSource, decisions: $decisions, emptyMessage: $emptyMessage)';
}


}

/// @nodoc
abstract mixin class $BusinessUnitCopyWith<$Res>  {
  factory $BusinessUnitCopyWith(BusinessUnit value, $Res Function(BusinessUnit) _then) = _$BusinessUnitCopyWithImpl;
@useResult
$Res call({
 String name, String tag, bool isPrimary, String screenType, String? consultSource, List<Decision> decisions, String? emptyMessage
});




}
/// @nodoc
class _$BusinessUnitCopyWithImpl<$Res>
    implements $BusinessUnitCopyWith<$Res> {
  _$BusinessUnitCopyWithImpl(this._self, this._then);

  final BusinessUnit _self;
  final $Res Function(BusinessUnit) _then;

/// Create a copy of BusinessUnit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? tag = null,Object? isPrimary = null,Object? screenType = null,Object? consultSource = freezed,Object? decisions = null,Object? emptyMessage = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,screenType: null == screenType ? _self.screenType : screenType // ignore: cast_nullable_to_non_nullable
as String,consultSource: freezed == consultSource ? _self.consultSource : consultSource // ignore: cast_nullable_to_non_nullable
as String?,decisions: null == decisions ? _self.decisions : decisions // ignore: cast_nullable_to_non_nullable
as List<Decision>,emptyMessage: freezed == emptyMessage ? _self.emptyMessage : emptyMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BusinessUnit].
extension BusinessUnitPatterns on BusinessUnit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessUnit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessUnit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessUnit value)  $default,){
final _that = this;
switch (_that) {
case _BusinessUnit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessUnit value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessUnit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String tag,  bool isPrimary,  String screenType,  String? consultSource,  List<Decision> decisions,  String? emptyMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessUnit() when $default != null:
return $default(_that.name,_that.tag,_that.isPrimary,_that.screenType,_that.consultSource,_that.decisions,_that.emptyMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String tag,  bool isPrimary,  String screenType,  String? consultSource,  List<Decision> decisions,  String? emptyMessage)  $default,) {final _that = this;
switch (_that) {
case _BusinessUnit():
return $default(_that.name,_that.tag,_that.isPrimary,_that.screenType,_that.consultSource,_that.decisions,_that.emptyMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String tag,  bool isPrimary,  String screenType,  String? consultSource,  List<Decision> decisions,  String? emptyMessage)?  $default,) {final _that = this;
switch (_that) {
case _BusinessUnit() when $default != null:
return $default(_that.name,_that.tag,_that.isPrimary,_that.screenType,_that.consultSource,_that.decisions,_that.emptyMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusinessUnit implements BusinessUnit {
  const _BusinessUnit({required this.name, required this.tag, this.isPrimary = true, this.screenType = 'detail', this.consultSource, final  List<Decision> decisions = const [], this.emptyMessage}): _decisions = decisions;
  factory _BusinessUnit.fromJson(Map<String, dynamic> json) => _$BusinessUnitFromJson(json);

@override final  String name;
@override final  String tag;
@override@JsonKey() final  bool isPrimary;
@override@JsonKey() final  String screenType;
@override final  String? consultSource;
 final  List<Decision> _decisions;
@override@JsonKey() List<Decision> get decisions {
  if (_decisions is EqualUnmodifiableListView) return _decisions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_decisions);
}

@override final  String? emptyMessage;

/// Create a copy of BusinessUnit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessUnitCopyWith<_BusinessUnit> get copyWith => __$BusinessUnitCopyWithImpl<_BusinessUnit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessUnitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessUnit&&(identical(other.name, name) || other.name == name)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.screenType, screenType) || other.screenType == screenType)&&(identical(other.consultSource, consultSource) || other.consultSource == consultSource)&&const DeepCollectionEquality().equals(other._decisions, _decisions)&&(identical(other.emptyMessage, emptyMessage) || other.emptyMessage == emptyMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,tag,isPrimary,screenType,consultSource,const DeepCollectionEquality().hash(_decisions),emptyMessage);

@override
String toString() {
  return 'BusinessUnit(name: $name, tag: $tag, isPrimary: $isPrimary, screenType: $screenType, consultSource: $consultSource, decisions: $decisions, emptyMessage: $emptyMessage)';
}


}

/// @nodoc
abstract mixin class _$BusinessUnitCopyWith<$Res> implements $BusinessUnitCopyWith<$Res> {
  factory _$BusinessUnitCopyWith(_BusinessUnit value, $Res Function(_BusinessUnit) _then) = __$BusinessUnitCopyWithImpl;
@override @useResult
$Res call({
 String name, String tag, bool isPrimary, String screenType, String? consultSource, List<Decision> decisions, String? emptyMessage
});




}
/// @nodoc
class __$BusinessUnitCopyWithImpl<$Res>
    implements _$BusinessUnitCopyWith<$Res> {
  __$BusinessUnitCopyWithImpl(this._self, this._then);

  final _BusinessUnit _self;
  final $Res Function(_BusinessUnit) _then;

/// Create a copy of BusinessUnit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? tag = null,Object? isPrimary = null,Object? screenType = null,Object? consultSource = freezed,Object? decisions = null,Object? emptyMessage = freezed,}) {
  return _then(_BusinessUnit(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,screenType: null == screenType ? _self.screenType : screenType // ignore: cast_nullable_to_non_nullable
as String,consultSource: freezed == consultSource ? _self.consultSource : consultSource // ignore: cast_nullable_to_non_nullable
as String?,decisions: null == decisions ? _self._decisions : decisions // ignore: cast_nullable_to_non_nullable
as List<Decision>,emptyMessage: freezed == emptyMessage ? _self.emptyMessage : emptyMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Metric {

 String get label; String get value;
/// Create a copy of Metric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetricCopyWith<Metric> get copyWith => _$MetricCopyWithImpl<Metric>(this as Metric, _$identity);

  /// Serializes this Metric to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Metric&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value);

@override
String toString() {
  return 'Metric(label: $label, value: $value)';
}


}

/// @nodoc
abstract mixin class $MetricCopyWith<$Res>  {
  factory $MetricCopyWith(Metric value, $Res Function(Metric) _then) = _$MetricCopyWithImpl;
@useResult
$Res call({
 String label, String value
});




}
/// @nodoc
class _$MetricCopyWithImpl<$Res>
    implements $MetricCopyWith<$Res> {
  _$MetricCopyWithImpl(this._self, this._then);

  final Metric _self;
  final $Res Function(Metric) _then;

/// Create a copy of Metric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? value = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Metric].
extension MetricPatterns on Metric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Metric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Metric() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Metric value)  $default,){
final _that = this;
switch (_that) {
case _Metric():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Metric value)?  $default,){
final _that = this;
switch (_that) {
case _Metric() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Metric() when $default != null:
return $default(_that.label,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String value)  $default,) {final _that = this;
switch (_that) {
case _Metric():
return $default(_that.label,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String value)?  $default,) {final _that = this;
switch (_that) {
case _Metric() when $default != null:
return $default(_that.label,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Metric implements Metric {
  const _Metric({required this.label, required this.value});
  factory _Metric.fromJson(Map<String, dynamic> json) => _$MetricFromJson(json);

@override final  String label;
@override final  String value;

/// Create a copy of Metric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetricCopyWith<_Metric> get copyWith => __$MetricCopyWithImpl<_Metric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Metric&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value);

@override
String toString() {
  return 'Metric(label: $label, value: $value)';
}


}

/// @nodoc
abstract mixin class _$MetricCopyWith<$Res> implements $MetricCopyWith<$Res> {
  factory _$MetricCopyWith(_Metric value, $Res Function(_Metric) _then) = __$MetricCopyWithImpl;
@override @useResult
$Res call({
 String label, String value
});




}
/// @nodoc
class __$MetricCopyWithImpl<$Res>
    implements _$MetricCopyWith<$Res> {
  __$MetricCopyWithImpl(this._self, this._then);

  final _Metric _self;
  final $Res Function(_Metric) _then;

/// Create a copy of Metric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? value = null,}) {
  return _then(_Metric(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Trend {

 String get text;@JsonKey(fromJson: _parseDirection) TrendDirection get direction;
/// Create a copy of Trend
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendCopyWith<Trend> get copyWith => _$TrendCopyWithImpl<Trend>(this as Trend, _$identity);

  /// Serializes this Trend to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trend&&(identical(other.text, text) || other.text == text)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,direction);

@override
String toString() {
  return 'Trend(text: $text, direction: $direction)';
}


}

/// @nodoc
abstract mixin class $TrendCopyWith<$Res>  {
  factory $TrendCopyWith(Trend value, $Res Function(Trend) _then) = _$TrendCopyWithImpl;
@useResult
$Res call({
 String text,@JsonKey(fromJson: _parseDirection) TrendDirection direction
});




}
/// @nodoc
class _$TrendCopyWithImpl<$Res>
    implements $TrendCopyWith<$Res> {
  _$TrendCopyWithImpl(this._self, this._then);

  final Trend _self;
  final $Res Function(Trend) _then;

/// Create a copy of Trend
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? direction = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TrendDirection,
  ));
}

}


/// Adds pattern-matching-related methods to [Trend].
extension TrendPatterns on Trend {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trend value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trend() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trend value)  $default,){
final _that = this;
switch (_that) {
case _Trend():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trend value)?  $default,){
final _that = this;
switch (_that) {
case _Trend() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text, @JsonKey(fromJson: _parseDirection)  TrendDirection direction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trend() when $default != null:
return $default(_that.text,_that.direction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text, @JsonKey(fromJson: _parseDirection)  TrendDirection direction)  $default,) {final _that = this;
switch (_that) {
case _Trend():
return $default(_that.text,_that.direction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text, @JsonKey(fromJson: _parseDirection)  TrendDirection direction)?  $default,) {final _that = this;
switch (_that) {
case _Trend() when $default != null:
return $default(_that.text,_that.direction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trend implements Trend {
  const _Trend({required this.text, @JsonKey(fromJson: _parseDirection) this.direction = TrendDirection.flat});
  factory _Trend.fromJson(Map<String, dynamic> json) => _$TrendFromJson(json);

@override final  String text;
@override@JsonKey(fromJson: _parseDirection) final  TrendDirection direction;

/// Create a copy of Trend
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendCopyWith<_Trend> get copyWith => __$TrendCopyWithImpl<_Trend>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrendToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trend&&(identical(other.text, text) || other.text == text)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,direction);

@override
String toString() {
  return 'Trend(text: $text, direction: $direction)';
}


}

/// @nodoc
abstract mixin class _$TrendCopyWith<$Res> implements $TrendCopyWith<$Res> {
  factory _$TrendCopyWith(_Trend value, $Res Function(_Trend) _then) = __$TrendCopyWithImpl;
@override @useResult
$Res call({
 String text,@JsonKey(fromJson: _parseDirection) TrendDirection direction
});




}
/// @nodoc
class __$TrendCopyWithImpl<$Res>
    implements _$TrendCopyWith<$Res> {
  __$TrendCopyWithImpl(this._self, this._then);

  final _Trend _self;
  final $Res Function(_Trend) _then;

/// Create a copy of Trend
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? direction = null,}) {
  return _then(_Trend(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TrendDirection,
  ));
}


}


/// @nodoc
mixin _$FuncCard {

 String get name; List<Metric> get metrics; Trend? get trend; String? get warning; bool get isWarning;
/// Create a copy of FuncCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FuncCardCopyWith<FuncCard> get copyWith => _$FuncCardCopyWithImpl<FuncCard>(this as FuncCard, _$identity);

  /// Serializes this FuncCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FuncCard&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.metrics, metrics)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.isWarning, isWarning) || other.isWarning == isWarning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(metrics),trend,warning,isWarning);

@override
String toString() {
  return 'FuncCard(name: $name, metrics: $metrics, trend: $trend, warning: $warning, isWarning: $isWarning)';
}


}

/// @nodoc
abstract mixin class $FuncCardCopyWith<$Res>  {
  factory $FuncCardCopyWith(FuncCard value, $Res Function(FuncCard) _then) = _$FuncCardCopyWithImpl;
@useResult
$Res call({
 String name, List<Metric> metrics, Trend? trend, String? warning, bool isWarning
});


$TrendCopyWith<$Res>? get trend;

}
/// @nodoc
class _$FuncCardCopyWithImpl<$Res>
    implements $FuncCardCopyWith<$Res> {
  _$FuncCardCopyWithImpl(this._self, this._then);

  final FuncCard _self;
  final $Res Function(FuncCard) _then;

/// Create a copy of FuncCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? metrics = null,Object? trend = freezed,Object? warning = freezed,Object? isWarning = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as List<Metric>,trend: freezed == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as Trend?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,isWarning: null == isWarning ? _self.isWarning : isWarning // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of FuncCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrendCopyWith<$Res>? get trend {
    if (_self.trend == null) {
    return null;
  }

  return $TrendCopyWith<$Res>(_self.trend!, (value) {
    return _then(_self.copyWith(trend: value));
  });
}
}


/// Adds pattern-matching-related methods to [FuncCard].
extension FuncCardPatterns on FuncCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FuncCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FuncCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FuncCard value)  $default,){
final _that = this;
switch (_that) {
case _FuncCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FuncCard value)?  $default,){
final _that = this;
switch (_that) {
case _FuncCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<Metric> metrics,  Trend? trend,  String? warning,  bool isWarning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FuncCard() when $default != null:
return $default(_that.name,_that.metrics,_that.trend,_that.warning,_that.isWarning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<Metric> metrics,  Trend? trend,  String? warning,  bool isWarning)  $default,) {final _that = this;
switch (_that) {
case _FuncCard():
return $default(_that.name,_that.metrics,_that.trend,_that.warning,_that.isWarning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<Metric> metrics,  Trend? trend,  String? warning,  bool isWarning)?  $default,) {final _that = this;
switch (_that) {
case _FuncCard() when $default != null:
return $default(_that.name,_that.metrics,_that.trend,_that.warning,_that.isWarning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FuncCard implements FuncCard {
  const _FuncCard({required this.name, required final  List<Metric> metrics, this.trend, this.warning, this.isWarning = false}): _metrics = metrics;
  factory _FuncCard.fromJson(Map<String, dynamic> json) => _$FuncCardFromJson(json);

@override final  String name;
 final  List<Metric> _metrics;
@override List<Metric> get metrics {
  if (_metrics is EqualUnmodifiableListView) return _metrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_metrics);
}

@override final  Trend? trend;
@override final  String? warning;
@override@JsonKey() final  bool isWarning;

/// Create a copy of FuncCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FuncCardCopyWith<_FuncCard> get copyWith => __$FuncCardCopyWithImpl<_FuncCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FuncCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FuncCard&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._metrics, _metrics)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.isWarning, isWarning) || other.isWarning == isWarning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_metrics),trend,warning,isWarning);

@override
String toString() {
  return 'FuncCard(name: $name, metrics: $metrics, trend: $trend, warning: $warning, isWarning: $isWarning)';
}


}

/// @nodoc
abstract mixin class _$FuncCardCopyWith<$Res> implements $FuncCardCopyWith<$Res> {
  factory _$FuncCardCopyWith(_FuncCard value, $Res Function(_FuncCard) _then) = __$FuncCardCopyWithImpl;
@override @useResult
$Res call({
 String name, List<Metric> metrics, Trend? trend, String? warning, bool isWarning
});


@override $TrendCopyWith<$Res>? get trend;

}
/// @nodoc
class __$FuncCardCopyWithImpl<$Res>
    implements _$FuncCardCopyWith<$Res> {
  __$FuncCardCopyWithImpl(this._self, this._then);

  final _FuncCard _self;
  final $Res Function(_FuncCard) _then;

/// Create a copy of FuncCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? metrics = null,Object? trend = freezed,Object? warning = freezed,Object? isWarning = null,}) {
  return _then(_FuncCard(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,metrics: null == metrics ? _self._metrics : metrics // ignore: cast_nullable_to_non_nullable
as List<Metric>,trend: freezed == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as Trend?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,isWarning: null == isWarning ? _self.isWarning : isWarning // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of FuncCard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrendCopyWith<$Res>? get trend {
    if (_self.trend == null) {
    return null;
  }

  return $TrendCopyWith<$Res>(_self.trend!, (value) {
    return _then(_self.copyWith(trend: value));
  });
}
}


/// @nodoc
mixin _$Dashboard {

 List<BusinessUnit> get businessUnits; List<FuncCard> get functionCards;
/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardCopyWith<Dashboard> get copyWith => _$DashboardCopyWithImpl<Dashboard>(this as Dashboard, _$identity);

  /// Serializes this Dashboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dashboard&&const DeepCollectionEquality().equals(other.businessUnits, businessUnits)&&const DeepCollectionEquality().equals(other.functionCards, functionCards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(businessUnits),const DeepCollectionEquality().hash(functionCards));

@override
String toString() {
  return 'Dashboard(businessUnits: $businessUnits, functionCards: $functionCards)';
}


}

/// @nodoc
abstract mixin class $DashboardCopyWith<$Res>  {
  factory $DashboardCopyWith(Dashboard value, $Res Function(Dashboard) _then) = _$DashboardCopyWithImpl;
@useResult
$Res call({
 List<BusinessUnit> businessUnits, List<FuncCard> functionCards
});




}
/// @nodoc
class _$DashboardCopyWithImpl<$Res>
    implements $DashboardCopyWith<$Res> {
  _$DashboardCopyWithImpl(this._self, this._then);

  final Dashboard _self;
  final $Res Function(Dashboard) _then;

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessUnits = null,Object? functionCards = null,}) {
  return _then(_self.copyWith(
businessUnits: null == businessUnits ? _self.businessUnits : businessUnits // ignore: cast_nullable_to_non_nullable
as List<BusinessUnit>,functionCards: null == functionCards ? _self.functionCards : functionCards // ignore: cast_nullable_to_non_nullable
as List<FuncCard>,
  ));
}

}


/// Adds pattern-matching-related methods to [Dashboard].
extension DashboardPatterns on Dashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dashboard value)  $default,){
final _that = this;
switch (_that) {
case _Dashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dashboard value)?  $default,){
final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BusinessUnit> businessUnits,  List<FuncCard> functionCards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
return $default(_that.businessUnits,_that.functionCards);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BusinessUnit> businessUnits,  List<FuncCard> functionCards)  $default,) {final _that = this;
switch (_that) {
case _Dashboard():
return $default(_that.businessUnits,_that.functionCards);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BusinessUnit> businessUnits,  List<FuncCard> functionCards)?  $default,) {final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
return $default(_that.businessUnits,_that.functionCards);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dashboard implements Dashboard {
  const _Dashboard({required final  List<BusinessUnit> businessUnits, required final  List<FuncCard> functionCards}): _businessUnits = businessUnits,_functionCards = functionCards;
  factory _Dashboard.fromJson(Map<String, dynamic> json) => _$DashboardFromJson(json);

 final  List<BusinessUnit> _businessUnits;
@override List<BusinessUnit> get businessUnits {
  if (_businessUnits is EqualUnmodifiableListView) return _businessUnits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_businessUnits);
}

 final  List<FuncCard> _functionCards;
@override List<FuncCard> get functionCards {
  if (_functionCards is EqualUnmodifiableListView) return _functionCards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_functionCards);
}


/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardCopyWith<_Dashboard> get copyWith => __$DashboardCopyWithImpl<_Dashboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dashboard&&const DeepCollectionEquality().equals(other._businessUnits, _businessUnits)&&const DeepCollectionEquality().equals(other._functionCards, _functionCards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_businessUnits),const DeepCollectionEquality().hash(_functionCards));

@override
String toString() {
  return 'Dashboard(businessUnits: $businessUnits, functionCards: $functionCards)';
}


}

/// @nodoc
abstract mixin class _$DashboardCopyWith<$Res> implements $DashboardCopyWith<$Res> {
  factory _$DashboardCopyWith(_Dashboard value, $Res Function(_Dashboard) _then) = __$DashboardCopyWithImpl;
@override @useResult
$Res call({
 List<BusinessUnit> businessUnits, List<FuncCard> functionCards
});




}
/// @nodoc
class __$DashboardCopyWithImpl<$Res>
    implements _$DashboardCopyWith<$Res> {
  __$DashboardCopyWithImpl(this._self, this._then);

  final _Dashboard _self;
  final $Res Function(_Dashboard) _then;

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessUnits = null,Object? functionCards = null,}) {
  return _then(_Dashboard(
businessUnits: null == businessUnits ? _self._businessUnits : businessUnits // ignore: cast_nullable_to_non_nullable
as List<BusinessUnit>,functionCards: null == functionCards ? _self._functionCards : functionCards // ignore: cast_nullable_to_non_nullable
as List<FuncCard>,
  ));
}


}

// dart format on
