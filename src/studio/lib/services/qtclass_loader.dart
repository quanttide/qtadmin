import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/qtclass.dart';
import 'package:qtadmin_studio/services/fixture_config.dart';

class QtClassLoader {
  static QtClassData? _cache;

  static Future<QtClassData> load() async {
    if (_cache != null) return _cache!;
    final file = File(FixtureConfig.qtclassPath);
    final jsonStr = await file.readAsString();
    final data = QtClassData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache = data;
    return data;
  }

  static void clearCache() {
    _cache = null;
  }
}
