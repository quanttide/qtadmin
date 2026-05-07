import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/metadata.dart';
import 'package:qtadmin_studio/services/fixture_config.dart';

class MetadataLoader {
  static final Map<String, NavMetadata> _cache = {};
  static RootMetadata? _root;

  static Future<RootMetadata> loadRoot() async {
    if (_root != null) return _root!;
    final file = File(FixtureConfig.rootMetadataPath);
    final jsonStr = await file.readAsString();
    _root = RootMetadata.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    return _root!;
  }

  static Future<NavMetadata> load(String dir) async {
    if (_cache.containsKey(dir)) return _cache[dir]!;
    final file = File(FixtureConfig.metadataPath(dir));
    final jsonStr = await file.readAsString();
    final data = NavMetadata.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cache[dir] = data;
    return data;
  }

  static void clearCache() {
    _cache.clear();
    _root = null;
  }
}
