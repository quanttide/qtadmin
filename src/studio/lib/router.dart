import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtadmin_studio/blocs/consult_bloc.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/models/qtclass.dart';
import 'package:qtadmin_studio/models/thinking.dart';
import 'package:qtadmin_studio/models/org.dart';
import 'package:qtadmin_studio/screens/dashboard_screen.dart';
import 'package:qtadmin_studio/screens/thinking_screen.dart';
import 'package:qtadmin_studio/screens/qtconsult_screen.dart';
import 'package:qtadmin_studio/screens/qtclass_screen.dart';
import 'package:qtadmin_studio/screens/org_screen.dart';
import 'package:qtadmin_studio/screens/business_detail_screen.dart';
import 'package:qtadmin_studio/screens/function_detail_screen.dart';

class ScreenContext {
  final Dashboard dashboard;
  final String workspaceName;
  final int selectedWorkspace;
  final Thinking? thinkingData;
  final QtConsult? consultData;
  final QtClass? classData;
  final OrgDashboard? orgData;

  ScreenContext({
    required this.dashboard,
    required this.workspaceName,
    required this.selectedWorkspace,
    this.thinkingData,
    this.consultData,
    this.classData,
    this.orgData,
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
    'dashboard': RouteConfig(
      id: 'dashboard', label: '仪表盘', icon: Icons.today_outlined,
      builder: (ctx) => DashboardScreen(data: ctx.dashboard, workspaceName: ctx.workspaceName),
    ),
    'thinking': RouteConfig(
      id: 'thinking', label: '思考', icon: Icons.psychology_outlined,
      builder: (ctx) => ThinkingScreen(data: ctx.thinkingData!),
    ),
    'writing': RouteConfig(
      id: 'writing', label: '写作', icon: Icons.edit_outlined,
      builder: (ctx) => const Center(child: Text('即将上线')),
    ),
    'consulting': RouteConfig(
      id: 'consulting', label: '量潮咨询', icon: Icons.support_agent_outlined,
      builder: (ctx) => BlocProvider(
        create: (_) => ConsultBloc(ConsultState(data: ctx.consultData!)),
        child: const QtConsultScreen(),
      ),
    ),
    'classroom': RouteConfig(
      id: 'classroom', label: '量潮课堂', icon: Icons.school_outlined,
      builder: (ctx) => QtClassScreen(data: ctx.classData!),
    ),
    'org': RouteConfig(
      id: 'org', label: '组织管理', icon: Icons.account_tree_outlined,
      builder: (ctx) => OrgScreen(data: ctx.orgData!),
    ),
    'data': RouteConfig(
      id: 'data', label: '量潮数据', icon: Icons.storage_outlined,
      builder: (ctx) {
        final unit = ctx.dashboard.businessUnits.firstWhere(
          (u) => u.name == '量潮数据',
          orElse: () => throw StateError('未找到业务单元: 量潮数据'),
        );
        return BusinessDetailScreen(unit: unit);
      },
    ),
    'cloud': RouteConfig(
      id: 'cloud', label: '量潮云', icon: Icons.cloud_outlined,
      builder: (ctx) {
        final unit = ctx.dashboard.businessUnits.firstWhere(
          (u) => u.name == '量潮云',
          orElse: () => throw StateError('未找到业务单元: 量潮云'),
        );
        return BusinessDetailScreen(unit: unit);
      },
    ),
    'hr': RouteConfig(
      id: 'hr', label: '人力资源', icon: Icons.people_outline,
      builder: (ctx) {
        final card = ctx.dashboard.functionCards.firstWhere(
          (c) => c.name == '人力资源',
          orElse: () => throw StateError('未找到职能卡: 人力资源'),
        );
        return FuncDetailScreen(card: card);
      },
    ),
    'finance': RouteConfig(
      id: 'finance', label: '财务管理', icon: Icons.account_balance_outlined,
      builder: (ctx) {
        final card = ctx.dashboard.functionCards.firstWhere(
          (c) => c.name == '财务管理',
          orElse: () => throw StateError('未找到职能卡: 财务管理'),
        );
        return FuncDetailScreen(card: card);
      },
    ),
    'strategy': RouteConfig(
      id: 'strategy', label: '战略管理', icon: Icons.track_changes_outlined,
      builder: (ctx) {
        final card = ctx.dashboard.functionCards.firstWhere(
          (c) => c.name == '战略管理',
          orElse: () => throw StateError('未找到职能卡: 战略管理'),
        );
        return FuncDetailScreen(card: card);
      },
    ),
    'media': RouteConfig(
      id: 'media', label: '新媒体', icon: Icons.campaign_outlined,
      builder: (ctx) {
        final card = ctx.dashboard.functionCards.firstWhere(
          (c) => c.name == '新媒体',
          orElse: () => throw StateError('未找到职能卡: 新媒体'),
        );
        return FuncDetailScreen(card: card);
      },
    ),
  };

  static RouteConfig find(String id) {
    final route = all[id];
    if (route == null) throw StateError('未找到路由配置: $id');
    return route;
  }
}
