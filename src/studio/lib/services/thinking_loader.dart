import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtadmin_studio/models/thinking.dart';

class ThinkingLoader {
  static ThinkingData? _cache;

  static Future<ThinkingData> load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString('assets/fixtures/founder/thinking.json');
    final data = ThinkingData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache = data;
    return data;
  }

  static void clearCache() {
    _cache = null;
  }
}
