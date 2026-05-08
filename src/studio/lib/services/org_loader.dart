import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/org.dart';

class OrgLoader {
  static OrgDashboard? _cache;

  static Future<OrgDashboard> load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await File('data/company/org.json').readAsString();
    final data = OrgDashboard.fromJson(
      json.decode(jsonStr) as Map<String, dynamic>,
    );
    _cache = data;
    return data;
  }

  static void inject(OrgDashboard data) {
    _cache = data;
  }

  static void clearCache() {
    _cache = null;
  }
}
