// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qtclass.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QtClassComponent _$QtClassComponentFromJson(Map<String, dynamic> json) =>
    _QtClassComponent(
      type: $enumDecode(_$QtClassComponentTypeEnumMap, json['type']),
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      studentCount: (json['studentCount'] as num).toInt(),
      projectCount: (json['projectCount'] as num).toInt(),
      deadline: json['deadline'] as String?,
      highlights: (json['highlights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$QtClassComponentToJson(_QtClassComponent instance) =>
    <String, dynamic>{
      'type': _$QtClassComponentTypeEnumMap[instance.type]!,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'studentCount': instance.studentCount,
      'projectCount': instance.projectCount,
      'deadline': instance.deadline,
      'highlights': instance.highlights,
    };

const _$QtClassComponentTypeEnumMap = {
  QtClassComponentType.schoolEnterprise: 'schoolEnterprise',
  QtClassComponentType.trainingBase: 'trainingBase',
  QtClassComponentType.internalTeaching: 'internalTeaching',
  QtClassComponentType.oneOnOne: 'oneOnOne',
};

_QtClass _$QtClassFromJson(Map<String, dynamic> json) => _QtClass(
  components: (json['components'] as List<dynamic>)
      .map((e) => QtClassComponent.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QtClassToJson(_QtClass instance) => <String, dynamic>{
  'components': instance.components.map((e) => e.toJson()).toList(),
};
