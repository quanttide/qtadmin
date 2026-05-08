import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';

class QtConsultLoader {
  static final Map<TenantType, QtConsultData?> _cache = {};

  static Future<QtConsultData> load({TenantType tenant = TenantType.customer}) async {
    if (_cache[tenant] != null) return _cache[tenant]!;
    final jsonStr = await rootBundle.loadString(
      'assets/fixtures/${_tenantDir(tenant)}/qtconsult.json',
    );
    final data = QtConsultData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
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

  static void clearCache({TenantType? tenant}) {
    if (tenant != null) {
      _cache.remove(tenant);
    } else {
      _cache.clear();
    }
  }
}
