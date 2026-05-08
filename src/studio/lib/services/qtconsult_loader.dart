import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/qtconsult.dart';

class QtConsultLoader {
  static final Map<WorkspaceType, QtConsultData?> _cache = {};

  static Future<QtConsultData> load({WorkspaceType workspace = WorkspaceType.customer}) async {
    if (_cache[workspace] != null) return _cache[workspace]!;
    final jsonStr = await File(
      'data/${_workspaceDir(workspace)}/qtconsult.json',
    ).readAsString();
    final data = QtConsultData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache[workspace] = data;
    return data;
  }

  static void inject(WorkspaceType workspace, QtConsultData data) {
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

  static void clearCache({WorkspaceType? workspace}) {
    if (workspace != null) {
      _cache.remove(workspace);
    } else {
      _cache.clear();
    }
  }
}
