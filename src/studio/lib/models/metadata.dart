import 'package:flutter/material.dart';

class NavEntry {
  final String name;
  const NavEntry({required this.name});
  factory NavEntry.fromJson(String name) => NavEntry(name: name);
  String toJson() => name;
}

class NavSectionDef {
  final String id;
  final List<NavEntry> items;
  const NavSectionDef({required this.id, required this.items});

  factory NavSectionDef.fromJson(Map<String, dynamic> json) => NavSectionDef(
    id: json['id'] as String,
    items: (json['items'] as List<dynamic>)
        .map((e) => NavEntry.fromJson(e as String))
        .toList(),
  );
}

class WorkspaceInfo {
  final String name;
  final String icon;
  final String dir;
  const WorkspaceInfo({
    required this.name,
    required this.icon,
    required this.dir,
  });

  factory WorkspaceInfo.fromJson(Map<String, dynamic> json) => WorkspaceInfo(
    name: json['name'] as String,
    icon: json['icon'] as String,
    dir: json['dir'] as String,
  );
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

class NavMetadata {
  final List<NavSectionDef> sections;
  const NavMetadata({required this.sections});

  factory NavMetadata.fromJson(Map<String, dynamic> json) => NavMetadata(
    sections: (json['sections'] as List<dynamic>)
        .map((e) => NavSectionDef.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

extension NavMetadataX on NavMetadata {
  List<NavEntry> get allItems => sections.expand((s) => s.items).toList();
}

class SectionDef {
  final String id;
  final bool dividerBefore;
  const SectionDef({required this.id, required this.dividerBefore});

  factory SectionDef.fromJson(Map<String, dynamic> json) => SectionDef(
    id: json['id'] as String,
    dividerBefore: json['dividerBefore'] as bool,
  );
}

class RootMetadata {
  final List<WorkspaceInfo> workspaces;
  final List<SectionDef> sections;
  const RootMetadata({required this.workspaces, required this.sections});

  factory RootMetadata.fromJson(Map<String, dynamic> json) => RootMetadata(
    workspaces: (json['workspaces'] as List<dynamic>)
        .map((e) => WorkspaceInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    sections: (json['sections'] as List<dynamic>)
        .map((e) => SectionDef.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

extension RootMetadataX on RootMetadata {
  WorkspaceInfo workspaceById(String id) =>
      workspaces.firstWhere((t) => t.dir == id);
  SectionDef sectionById(String id) => sections.firstWhere((s) => s.id == id);
}
