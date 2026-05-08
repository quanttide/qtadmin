import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/thinking.dart';

class ThinkingLoader {
  static Thinking? _cache;

  static Future<Thinking> load() async {
    if (_cache != null) return _cache!;
    final jsonStr = await File('data/founder/thinking.json').readAsString();
    final data = Thinking.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache = data;
    return data;
  }

  static void inject(Thinking data) {
    _cache = data;
  }

  static void clearCache() {
    _cache = null;
  }
}
