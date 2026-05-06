import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';

class QtConsultLoader {
  static QtConsultData? _cached;

  static Future<QtConsultData> load() async {
    if (_cached != null) return _cached!;
    final jsonStr = await rootBundle.loadString('assets/qtconsult.json');
    final data = QtConsultData.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    _cached = data;
    return data;
  }

  static void clearCache() {
    _cached = null;
  }
}
