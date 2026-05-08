// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NavSectionDef _$NavSectionDefFromJson(Map<String, dynamic> json) =>
    _NavSectionDef(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => NavEntry.fromJson(e as String))
          .toList(),
    );

Map<String, dynamic> _$NavSectionDefToJson(_NavSectionDef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

_WorkspaceInfo _$WorkspaceInfoFromJson(Map<String, dynamic> json) =>
    _WorkspaceInfo(
      name: json['name'] as String,
      icon: json['icon'] as String,
      dir: json['dir'] as String,
    );

Map<String, dynamic> _$WorkspaceInfoToJson(_WorkspaceInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'icon': instance.icon,
      'dir': instance.dir,
    };

_NavMetadata _$NavMetadataFromJson(Map<String, dynamic> json) => _NavMetadata(
  sections: (json['sections'] as List<dynamic>)
      .map((e) => NavSectionDef.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NavMetadataToJson(_NavMetadata instance) =>
    <String, dynamic>{
      'sections': instance.sections.map((e) => e.toJson()).toList(),
    };

_SectionDef _$SectionDefFromJson(Map<String, dynamic> json) => _SectionDef(
  id: json['id'] as String,
  dividerBefore: json['dividerBefore'] as bool,
);

Map<String, dynamic> _$SectionDefToJson(_SectionDef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dividerBefore': instance.dividerBefore,
    };

_RootMetadata _$RootMetadataFromJson(Map<String, dynamic> json) =>
    _RootMetadata(
      workspaces: (json['workspaces'] as List<dynamic>)
          .map((e) => WorkspaceInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      sections: (json['sections'] as List<dynamic>)
          .map((e) => SectionDef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RootMetadataToJson(_RootMetadata instance) =>
    <String, dynamic>{
      'workspaces': instance.workspaces.map((e) => e.toJson()).toList(),
      'sections': instance.sections.map((e) => e.toJson()).toList(),
    };
