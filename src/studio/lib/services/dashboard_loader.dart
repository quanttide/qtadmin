import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';

class DashboardLoader {
  static final Map<TenantType, DashboardData> _cache = {};

  static Future<DashboardData> load({TenantType tenant = TenantType.customer}) async {
    if (_cache.containsKey(tenant)) return _cache[tenant]!;
    final jsonStr = await rootBundle.loadString(
      'assets/fixtures/${_tenantDir(tenant)}/dashboard.json',
    );
    final data = DashboardData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache[tenant] = data;
    return data;
  }

  static String _tenantDir(TenantType tenant) {
    switch (tenant) {
      case TenantType.internal:
        return 'founder';
      case TenantType.customer:
        return 'company';
    }
  }

  static void clearCache() {
    _cache.clear();
  }
}
