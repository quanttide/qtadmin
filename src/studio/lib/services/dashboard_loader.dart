import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';

class DashboardLoader {
  static final Map<WorkspaceType, DashboardData> _cache = {};

  static Future<DashboardData> load({WorkspaceType workspace = WorkspaceType.customer}) async {
    if (_cache.containsKey(workspace)) return _cache[workspace]!;
    final jsonStr = await rootBundle.loadString(
      'assets/fixtures/${_workspaceDir(workspace)}/dashboard.json',
    );
    final data = DashboardData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache[workspace] = data;
    return data;
  }

  static String _workspaceDir(WorkspaceType workspace) {
    switch (workspace) {
      case WorkspaceType.internal:
        return 'founder';
      case WorkspaceType.customer:
        return 'company';
    }
  }

  static void clearCache() {
    _cache.clear();
  }
}
