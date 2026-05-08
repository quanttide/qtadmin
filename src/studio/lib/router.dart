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

Widget buildScreen({
  required String dir,
  required String page,
  required Dashboard founderDashboard,
  required Dashboard companyDashboard,
  required Thinking? thinkingData,
  required QtConsult? consultData,
  required QtClass? classData,
  required OrgDashboard? orgData,
  required List<String> workspaceNames,
  required int selectedWorkspace,
}) {
  final dashboard = dir == 'founder' ? founderDashboard : companyDashboard;
  final route = RouteConfig.find(page);

  switch (route.screenType) {
    case 'dashboard':
      return DashboardScreen(
        data: dashboard,
        workspaceName: workspaceNames[selectedWorkspace],
      );
    case 'thinking':
      return ThinkingScreen(data: thinkingData!);
    case 'writing':
      return const Center(child: Text('即将上线'));
    case 'consulting':
      return BlocProvider(
        create: (_) => ConsultBloc(ConsultState(data: consultData!)),
        child: const QtConsultScreen(),
      );
    case 'classroom':
      return QtClassScreen(data: classData!);
    case 'org':
      return OrgScreen(data: orgData!);
    case 'business_detail': {
      final unit = dashboard.businessUnits.firstWhere(
        (u) => u.name == route.label,
        orElse: () => throw StateError('未找到业务单元: ${route.label}'),
      );
      return BusinessDetailScreen(unit: unit);
    }
    case 'function_detail': {
      final card = dashboard.functionCards.firstWhere(
        (c) => c.name == route.label,
        orElse: () => throw StateError('未找到职能卡: ${route.label}'),
      );
      return FuncDetailScreen(card: card);
    }
    default:
      return const SizedBox.shrink();
  }
}
