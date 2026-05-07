import 'dart:convert';
import 'dart:io';
import 'package:qtadmin_studio/models/panorama.dart';
import 'package:qtadmin_studio/services/fixture_config.dart';

class PanoramaLoader {
  static PanoramaData? _cached;

  static Future<PanoramaData> load() async {
    if (_cached != null) return _cached!;
    final file = File(FixtureConfig.panoramaPath());
    final jsonStr = await file.readAsString();
    final data = PanoramaData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cached = data;
    return data;
  }

  static void clearCache() {
    _cached = null;
  }
}
