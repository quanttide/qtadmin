import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtadmin_studio/models/qtclass.dart';

class QtClassLoader {
  static QtClassData? _cache;

  static Future<QtClassData> load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString('assets/fixtures/company/qtclass.json');
    final data = QtClassData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache = data;
    return data;
  }

  static void clearCache() {
    _cache = null;
  }
}
