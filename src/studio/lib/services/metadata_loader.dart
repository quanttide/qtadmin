import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/metadata.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';
import 'package:qtadmin_studio/services/fixture_config.dart';

class MetadataLoader {
  static final Map<TenantType, NavMetadata> _cache = {};

  static Future<NavMetadata> load({TenantType tenant = TenantType.customer}) async {
    if (_cache.containsKey(tenant)) return _cache[tenant]!;
    final file = File(FixtureConfig.metadataPath(tenant));
    final jsonStr = await file.readAsString();
    final data = NavMetadata.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache[tenant] = data;
    return data;
  }

  static void clearCache() {
    _cache.clear();
  }
}
