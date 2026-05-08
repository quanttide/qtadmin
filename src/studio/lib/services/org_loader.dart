import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtadmin_studio/models/org.dart';

class OrgLoader {
  static OrgDashboardData? _cache;

  static Future<OrgDashboardData> load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString(
      'assets/fixtures/company/org.json',
    );
    final data = OrgDashboardData.fromJson(
      json.decode(jsonStr) as Map<String, dynamic>,
    );
    _cache = data;
    return data;
  }

  static void clearCache() {
    _cache = null;
  }
}
