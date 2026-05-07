import 'package:flutter/material.dart';

class NavItemData {
  final String label;
  final String icon;
  final String pageType;

  const NavItemData({
    required this.label,
    required this.icon,
    required this.pageType,
  });

  factory NavItemData.fromJson(Map<String, dynamic> json) {
    return NavItemData(
      label: json['label'] as String,
      icon: json['icon'] as String,
      pageType: json['pageType'] as String,
    );
  }

  IconData resolveIcon() {
    const icons = {
      'person_outline': Icons.person_outline,
      'business_outlined': Icons.business_outlined,
      'today_outlined': Icons.today_outlined,
      'storage_outlined': Icons.storage_outlined,
      'school_outlined': Icons.school_outlined,
      'support_agent_outlined': Icons.support_agent_outlined,
      'cloud_outlined': Icons.cloud_outlined,
      'psychology_outlined': Icons.psychology_outlined,
      'edit_outlined': Icons.edit_outlined,
      'people_outline': Icons.people_outline,
      'account_balance_outlined': Icons.account_balance_outlined,
      'account_tree_outlined': Icons.account_tree_outlined,
      'track_changes_outlined': Icons.track_changes_outlined,
      'campaign_outlined': Icons.campaign_outlined,
    };
    return icons[icon] ?? Icons.circle_outlined;
  }
}

class NavSectionData {
  final List<NavItemData> items;

  const NavSectionData({required this.items});

  factory NavSectionData.fromJson(Map<String, dynamic> json) {
    return NavSectionData(
      items: (json['items'] as List<dynamic>)
          .map((i) => NavItemData.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TenantInfo {
  final String name;
  final String icon;

  const TenantInfo({required this.name, required this.icon});

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      name: json['name'] as String,
      icon: json['icon'] as String,
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
  final TenantInfo tenant;
  final List<NavSectionData> sections;

  const NavMetadata({required this.tenant, required this.sections});

  factory NavMetadata.fromJson(Map<String, dynamic> json) {
    return NavMetadata(
      tenant: TenantInfo.fromJson(json['tenant'] as Map<String, dynamic>),
      sections: (json['sections'] as List<dynamic>)
          .map((s) => NavSectionData.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  List<NavItemData> get allItems => sections.expand((s) => s.items).toList();
}
