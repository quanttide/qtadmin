import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/panorama.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/services/fixture_config.dart';

class PanoramaLoader {
  static final Map<TenantType, PanoramaData> _cache = {};

  static Future<PanoramaData> load({TenantType tenant = TenantType.customer}) async {
    if (_cache.containsKey(tenant)) return _cache[tenant]!;
    final file = File(FixtureConfig.panoramaPath(tenant));
    final jsonStr = await file.readAsString();
    final data = PanoramaData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache[tenant] = data;
    return data;
  }

  static void clearCache() {
    _cache.clear();
  }
}
