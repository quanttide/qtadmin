import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/human.dart';
import 'package:qtadmin_studio/screens/human_screen.dart';

class ScreenContext {
  final RecruitmentPlan? recruitmentData;

  ScreenContext({this.recruitmentData});
}

class RouteConfig {
  final String id;
  final String label;
  final IconData icon;
  final Widget Function(ScreenContext ctx) builder;

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
      builder: (ctx) => const Center(child: Text('即将上线')),
    ),
    'recruitment': RouteConfig(
      id: 'recruitment',
      label: '招聘计划',
      icon: Icons.people_outline,
      builder: (ctx) => HumanScreen(data: ctx.recruitmentData!),
    ),
  };

  static RouteConfig find(String id) {
    final route = all[id];
    if (route == null) throw StateError('未找到路由配置: $id');
    return route;
  }
}
