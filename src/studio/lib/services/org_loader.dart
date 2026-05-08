import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/org.dart';

class OrgLoader {
  static OrgDashboardData? _cache;

  static Future<OrgDashboardData> load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await File('data/company/org.json').readAsString();
    final data = OrgDashboardData.fromJson(
      json.decode(jsonStr) as Map<String, dynamic>,
    );
    _cache = data;
    return data;
  }

  static void inject(OrgDashboardData data) {
    _cache = data;
  }

  static void clearCache() {
    _cache = null;
  }
}
