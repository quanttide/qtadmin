import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';

class DashboardLoader {
  static final Map<WorkspaceType, Dashboard> _cache = {};

  static Future<Dashboard> load({WorkspaceType workspace = WorkspaceType.customer}) async {
    if (_cache.containsKey(workspace)) return _cache[workspace]!;
    final jsonStr = await File(
      'data/${_workspaceDir(workspace)}/dashboard.json',
    ).readAsString();
    final data = Dashboard.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache[workspace] = data;
    return data;
  }

  static void inject(WorkspaceType workspace, Dashboard data) {
    _cache[workspace] = data;
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
