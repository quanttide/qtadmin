import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/qtclass.dart';

class QtClassLoader {
  static QtClassData? _cache;

  static Future<QtClassData> load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await File('data/company/qtclass.json').readAsString();
    final data = QtClassData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache = data;
    return data;
  }

  static void inject(QtClassData data) {
    _cache = data;
  }

  static void clearCache() {
    _cache = null;
  }
}
