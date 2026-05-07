import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/services/fixture_config.dart';

class QtConsultLoader {
  static final Map<TenantType, QtConsultData?> _cache = {};

  static Future<QtConsultData> load({TenantType tenant = TenantType.customer}) async {
    if (_cache[tenant] != null) return _cache[tenant]!;
    final file = File(FixtureConfig.qtconsultPath(tenant));
    final jsonStr = await file.readAsString();
    final data = QtConsultData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache[tenant] = data;
    return data;
  }

  static void clearCache({TenantType? tenant}) {
    if (tenant != null) {
      _cache.remove(tenant);
    } else {
      _cache.clear();
    }
  }
}
