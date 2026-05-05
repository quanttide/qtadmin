import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtadmin_studio/models/panorama.dart';

class PanoramaLoader {
  static PanoramaData? _cached;

  static Future<PanoramaData> load() async {
    if (_cached != null) return _cached!;
    final jsonStr = await rootBundle.loadString('assets/panorama.json');
    final data = PanoramaData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cached = data;
    return data;
  }

  static void clearCache() {
    _cached = null;
  }
}
