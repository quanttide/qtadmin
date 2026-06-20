import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'metadata.freezed.dart';
part 'metadata.g.dart';

class NavEntry {
  final String name;
  const NavEntry({required this.name});
  factory NavEntry.fromJson(String name) => NavEntry(name: name);
  String toJson() => name;
}

@freezed
abstract class NavSectionDef with _$NavSectionDef {
  const factory NavSectionDef({
    required String id,
    required List<NavEntry> items,
  }) = _NavSectionDef;

  factory NavSectionDef.fromJson(Map<String, dynamic> json) =>
      _$NavSectionDefFromJson(json);
}

@freezed
abstract class WorkspaceInfo with _$WorkspaceInfo {
  const factory WorkspaceInfo({
    required String name,
    required String icon,
    required String dir,
  }) = _WorkspaceInfo;

  factory WorkspaceInfo.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceInfoFromJson(json);
}

extension WorkspaceInfoX on WorkspaceInfo {
  IconData resolveIcon() {
    const icons = {
      'person_outline': Icons.person_outline,
      'business_outlined': Icons.business_outlined,
    };
    return icons[icon] ?? Icons.circle_outlined;
  }
}

@freezed
abstract class NavMetadata with _$NavMetadata {
  const factory NavMetadata({
    required List<NavSectionDef> sections,
  }) = _NavMetadata;

  factory NavMetadata.fromJson(Map<String, dynamic> json) =>
      _$NavMetadataFromJson(json);
}

extension NavMetadataX on NavMetadata {
  List<NavEntry> get allItems => sections.expand((s) => s.items).toList();
}

@freezed
abstract class SectionDef with _$SectionDef {
  const factory SectionDef({
    required String id,
    required bool dividerBefore,
  }) = _SectionDef;

  factory SectionDef.fromJson(Map<String, dynamic> json) =>
      _$SectionDefFromJson(json);
}

@freezed
abstract class RootMetadata with _$RootMetadata {
  const factory RootMetadata({
    required List<WorkspaceInfo> workspaces,
    required List<SectionDef> sections,
  }) = _RootMetadata;

  factory RootMetadata.fromJson(Map<String, dynamic> json) =>
      _$RootMetadataFromJson(json);
}

extension RootMetadataX on RootMetadata {
  WorkspaceInfo workspaceById(String id) =>
      workspaces.firstWhere((t) => t.dir == id);
  SectionDef sectionById(String id) =>
      sections.firstWhere((s) => s.id == id);
}
