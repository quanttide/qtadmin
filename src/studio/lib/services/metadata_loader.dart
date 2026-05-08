import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtadmin_studio/models/metadata.dart';

class MetadataLoader {
  static final Map<String, NavMetadata> _cache = {};
  static RootMetadata? _root;

  static Future<RootMetadata> loadRoot() async {
    if (_root != null) return _root!;
    final jsonStr = await rootBundle.loadString('assets/fixtures/metadata.json');
    _root = RootMetadata.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    return _root!;
  }

  static Future<NavMetadata> load(String dir) async {
    if (_cache.containsKey(dir)) return _cache[dir]!;
    final jsonStr = await rootBundle.loadString('assets/fixtures/$dir/metadata.json');
    final data = NavMetadata.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache[dir] = data;
    return data;
  }

  static void clearCache() {
    _cache.clear();
    _root = null;
  }
}
