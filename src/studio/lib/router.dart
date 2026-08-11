import 'package:flutter/material.dart';
import 'package:qtadmin_studio/screens/frictions_screen.dart';
import 'package:qtadmin_studio/screens/reviews_screen.dart';
import 'package:qtadmin_studio/screens/role_slots_screen.dart';
import 'package:qtadmin_studio/screens/tasks_screen.dart';

/// 导航分组：执行（分配与评审闭环）、制度（摩擦与角色槽位）。
enum NavGroup { execution, institution }

class RouteConfig {
  final String id;
  final String label;
  final IconData icon;
  final NavGroup group;
  final Widget Function() builder;

  RouteConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.group,
    required this.builder,
  });

  static final Map<String, RouteConfig> all = {
    'tasks': RouteConfig(
      id: 'tasks',
      label: '任务',
      icon: Icons.assignment_outlined,
      group: NavGroup.execution,
      builder: () => const TasksScreen(),
    ),
    'reviews': RouteConfig(
      id: 'reviews',
      label: '评审',
      icon: Icons.fact_check_outlined,
      group: NavGroup.execution,
      builder: () => const ReviewsScreen(),
    ),
    'frictions': RouteConfig(
      id: 'frictions',
      label: '摩擦',
      icon: Icons.report_problem_outlined,
      group: NavGroup.institution,
      builder: () => const FrictionsScreen(),
    ),
    'role-slots': RouteConfig(
      id: 'role-slots',
      label: '角色槽位',
      icon: Icons.people_outline,
      group: NavGroup.institution,
      builder: () => const RoleSlotsScreen(),
    ),
  };

  static RouteConfig find(String id) {
    final route = all[id];
    if (route == null) throw StateError('未找到路由配置: $id');
    return route;
  }
}
