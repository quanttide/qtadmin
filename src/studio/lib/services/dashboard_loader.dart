import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/services/fixture_config.dart';

class DashboardLoader {
  static final Map<TenantType, DashboardData> _cache = {};

  static Future<DashboardData> load({TenantType tenant = TenantType.customer}) async {
    if (_cache.containsKey(tenant)) return _cache[tenant]!;
    final file = File(FixtureConfig.dashboardPath(tenant));
    final jsonStr = await file.readAsString();
    final data = DashboardData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache[tenant] = data;
    return data;
  }

  static void clearCache() {
    _cache.clear();
  }
}
