import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/metadata.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/models/qtclass.dart';
import 'package:qtadmin_studio/models/thinking.dart';
import 'package:qtadmin_studio/models/org.dart';
import 'package:qtadmin_studio/route_config.dart';
import 'package:qtadmin_studio/screens/dashboard_screen.dart';
import 'package:qtadmin_studio/screens/thinking_screen.dart';
import 'package:qtadmin_studio/screens/qtconsult_screen.dart';
import 'package:qtadmin_studio/screens/qtclass_screen.dart';
import 'package:qtadmin_studio/screens/org_screen.dart';
import 'package:qtadmin_studio/screens/business_detail_screen.dart';
import 'package:qtadmin_studio/screens/function_detail_screen.dart';

class AppRouter {
  final Dashboard Function() data;
  final Thinking? thinkingData;
  final QtConsult? consultData;
  final QtClass? classData;
  final OrgDashboard? orgData;
  final List<WorkspaceInfo> workspaces;
  final int selectedWorkspace;

  const AppRouter({
    required this.data,
    this.thinkingData,
    this.consultData,
    this.classData,
    this.orgData,
    this.workspaces = const [],
    this.selectedWorkspace = 0,
  });

  Dashboard? get _dashboard => data();

  Widget buildScreen(RouteConfig route) {
    switch (route.screenType) {
      case 'dashboard':
        return DashboardScreen(
          data: _dashboard!,
          workspaceName: workspaces[selectedWorkspace].name,
        );
      case 'thinking':
        return ThinkingScreen(data: thinkingData!);
      case 'writing':
        return const Center(child: Text('即将上线'));
      case 'consulting':
        return QtConsultScreen(data: consultData!);
      case 'classroom':
        return QtClassScreen(data: classData!);
      case 'org':
        return OrgScreen(data: orgData!);
      case 'business_detail': {
        final unit = _dashboard!.businessUnits.firstWhere(
          (u) => u.name == route.label,
          orElse: () => throw StateError('未找到业务单元: ${route.label}'),
        );
        return BusinessDetailScreen(unit: unit);
      }
      case 'function_detail': {
        final card = _dashboard!.functionCards.firstWhere(
          (c) => c.name == route.label,
          orElse: () => throw StateError('未找到职能卡: ${route.label}'),
        );
        return FuncDetailScreen(card: card);
      }
      default:
        return const SizedBox.shrink();
    }
  }
}
