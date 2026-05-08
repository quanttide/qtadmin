import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/thinking.dart';
import 'package:qtadmin_studio/services/fixture_config.dart';

class ThinkingLoader {
  static ThinkingData? _cache;

  static Future<ThinkingData> load() async {
    if (_cache != null) return _cache!;
    final file = File(FixtureConfig.thinkingPath);
    final jsonStr = await file.readAsString();
    final data = ThinkingData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache = data;
    return data;
  }

  static void clearCache() {
    _cache = null;
  }
}
