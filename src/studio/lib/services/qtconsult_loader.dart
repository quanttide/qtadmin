import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';

class QtConsultLoader {
  static final Map<WorkspaceType, QtConsultData?> _cache = {};

  static Future<QtConsultData> load({WorkspaceType workspace = WorkspaceType.customer}) async {
    if (_cache[workspace] != null) return _cache[workspace]!;
    final jsonStr = await rootBundle.loadString(
      'assets/fixtures/${_workspaceDir(workspace)}/qtconsult.json',
    );
    final data = QtConsultData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
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

  static void clearCache({WorkspaceType? workspace}) {
    if (workspace != null) {
      _cache.remove(workspace);
    } else {
      _cache.clear();
    }
  }
}
