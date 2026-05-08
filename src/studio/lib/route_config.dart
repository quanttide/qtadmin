import 'package:flutter/material.dart';

class RouteConfig {
  final String id;
  final String label;
  final IconData icon;
  final String screenType;

  const RouteConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.screenType,
  });

  static const List<RouteConfig> all = [
    RouteConfig(id: 'dashboard', label: '仪表盘', icon: Icons.today_outlined, screenType: 'dashboard'),
    RouteConfig(id: 'thinking', label: '思考', icon: Icons.psychology_outlined, screenType: 'thinking'),
    RouteConfig(id: 'writing', label: '写作', icon: Icons.edit_outlined, screenType: 'writing'),
    RouteConfig(id: 'consulting', label: '量潮咨询', icon: Icons.support_agent_outlined, screenType: 'consulting'),
    RouteConfig(id: 'classroom', label: '量潮课堂', icon: Icons.school_outlined, screenType: 'classroom'),
    RouteConfig(id: 'org', label: '组织管理', icon: Icons.account_tree_outlined, screenType: 'org'),
    RouteConfig(id: 'data', label: '量潮数据', icon: Icons.storage_outlined, screenType: 'business_detail'),
    RouteConfig(id: 'cloud', label: '量潮云', icon: Icons.cloud_outlined, screenType: 'business_detail'),
    RouteConfig(id: 'hr', label: '人力资源', icon: Icons.people_outline, screenType: 'function_detail'),
    RouteConfig(id: 'finance', label: '财务管理', icon: Icons.account_balance_outlined, screenType: 'function_detail'),
    RouteConfig(id: 'strategy', label: '战略管理', icon: Icons.track_changes_outlined, screenType: 'function_detail'),
    RouteConfig(id: 'media', label: '新媒体', icon: Icons.campaign_outlined, screenType: 'function_detail'),
  ];

  static RouteConfig find(String id) {
    return all.firstWhere(
      (r) => r.id == id,
      orElse: () => throw StateError('未找到路由配置: $id'),
    );
  }
}
