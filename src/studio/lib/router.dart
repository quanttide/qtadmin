import 'package:flutter/material.dart';
import 'package:qtadmin_qtconsult/consult.dart';
import 'package:qtadmin_org/org_barrel.dart';
import 'package:qtadmin_studio/models/recruitment.dart';
import 'package:qtadmin_studio/screens/recruitment_screen.dart';

class ScreenContext {
  final String workspaceName;
  final int selectedWorkspace;
  final QtConsult? consultData;
  final OrgDashboard? orgData;
  final RecruitmentPlan? recruitmentData;

  ScreenContext({
    required this.workspaceName,
    required this.selectedWorkspace,
    this.consultData,
    this.orgData,
    this.recruitmentData,
  });
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
    'consulting': RouteConfig(
      id: 'consulting',
      label: '量潮咨询',
      icon: Icons.support_agent_outlined,
      builder: (ctx) => const QtConsultScreen(),
    ),
    'org': RouteConfig(
      id: 'org',
      label: '组织管理',
      icon: Icons.account_tree_outlined,
      builder: (ctx) => OrgScreen(data: ctx.orgData!),
    ),
    'recruitment': RouteConfig(
      id: 'recruitment',
      label: '招聘计划',
      icon: Icons.people_outline,
      builder: (ctx) => RecruitmentScreen(data: ctx.recruitmentData!),
    ),
  };

  static RouteConfig find(String id) {
    final route = all[id];
    if (route == null) throw StateError('未找到路由配置: $id');
    return route;
  }
}
