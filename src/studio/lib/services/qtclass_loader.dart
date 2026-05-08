import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/qtclass.dart';

class QtClassLoader {
  static QtClass? _cache;

  static Future<QtClass> load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await File('data/company/qtclass.json').readAsString();
    final data = QtClass.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache = data;
    return data;
  }

  static void inject(QtClass data) {
    _cache = data;
  }

  static void clearCache() {
    _cache = null;
  }
}
