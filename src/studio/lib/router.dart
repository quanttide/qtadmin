import 'package:flutter/material.dart';

class RouteConfig {
  final String id;
  final String label;
  final IconData icon;
  final Widget Function() builder;

  RouteConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.builder,
  });

  static final Map<String, RouteConfig> all = {
    'writing': RouteConfig(
      id: 'writing',
      label: '写作',
      icon: Icons.edit_outlined,
      builder: () => const Center(child: Text('即将上线')),
    ),
  };

  static RouteConfig find(String id) {
    final route = all[id];
    if (route == null) throw StateError('未找到路由配置: $id');
    return route;
  }
}
