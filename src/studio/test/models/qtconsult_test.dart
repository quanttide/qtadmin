import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_qtconsult/qtconsult.dart';
import 'package:qtadmin_studio/constants.dart';

void main() {
  group('Color helper functions', () {
    test('discoveryDotColor returns correct colors', () {
      expect(discoveryDotColor(DiscoveryType.risk), const Color(0xFFB71C1C));
      expect(discoveryDotColor(DiscoveryType.concern), const Color(0xFFC8690A));
      expect(discoveryDotColor(DiscoveryType.opportunity), const Color(0xFF1A7F37));
      expect(discoveryDotColor(DiscoveryType.neutral), const Color(0xFF1A5FDC));
    });

    test('stanceColor returns correct colors', () {
      expect(stanceColor(StakeStance.support), const Color(0xFF1A7F37));
      expect(stanceColor(StakeStance.neutral), const Color(0xFF777777));
      expect(stanceColor(StakeStance.oppose), const Color(0xFFB71C1C));
    });

    test('stanceBgColor returns correct colors', () {
      expect(stanceBgColor(StakeStance.support), const Color(0xFFE8F5E9));
      expect(stanceBgColor(StakeStance.neutral), const Color(0xFFF5F5F5));
      expect(stanceBgColor(StakeStance.oppose), const Color(0xFFFFEBEE));
    });
  });
}
