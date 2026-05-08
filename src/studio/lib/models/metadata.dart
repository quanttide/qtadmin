import 'package:flutter/material.dart';

class NavItemData {
  final String name;

  const NavItemData({required this.name});

  factory NavItemData.fromJson(String name) => NavItemData(name: name);
}

class NavSectionData {
  final String id;
  final List<NavItemData> items;

  const NavSectionData({required this.id, required this.items});

  factory NavSectionData.fromJson(Map<String, dynamic> json) {
    return NavSectionData(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((i) => NavItemData.fromJson(i as String))
          .toList(),
    );
  }
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

  factory WorkspaceInfo.fromJson(Map<String, dynamic> json) {
    return WorkspaceInfo(
      name: json['name'] as String,
      icon: json['icon'] as String,
      dir: json['dir'] as String,
    );
  }

  IconData resolveIcon() {
    const icons = {
      'person_outline': Icons.person_outline,
      'business_outlined': Icons.business_outlined,
    };
    return icons[icon] ?? Icons.circle_outlined;
  }
}

class NavMetadata {
  final List<NavSectionData> sections;

  const NavMetadata({required this.sections});

  factory NavMetadata.fromJson(Map<String, dynamic> json) {
    return NavMetadata(
      sections: (json['sections'] as List<dynamic>)
          .map((s) => NavSectionData.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  List<NavItemData> get allItems => sections.expand((s) => s.items).toList();
}

class SectionDef {
  final String id;
  final bool dividerBefore;

  const SectionDef({required this.id, required this.dividerBefore});

  factory SectionDef.fromJson(Map<String, dynamic> json) {
    return SectionDef(
      id: json['id'] as String,
      dividerBefore: json['dividerBefore'] as bool,
    );
  }
}

class RootMetadata {
  final List<WorkspaceInfo> workspaces;
  final List<SectionDef> sections;

  const RootMetadata({required this.workspaces, required this.sections});

  factory RootMetadata.fromJson(Map<String, dynamic> json) {
    return RootMetadata(
      workspaces: (json['workspaces'] as List<dynamic>)
          .map((t) => WorkspaceInfo.fromJson(t as Map<String, dynamic>))
          .toList(),
      sections: (json['sections'] as List<dynamic>)
          .map((s) => SectionDef.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  WorkspaceInfo workspaceById(String id) {
    return workspaces.firstWhere((t) => t.dir == id);
  }

  SectionDef sectionById(String id) {
    return sections.firstWhere((s) => s.id == id);
  }
}
