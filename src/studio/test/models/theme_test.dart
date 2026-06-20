import 'dart:ui' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/theme.dart';

void main() {
  group('hexColor', () {
    test('parses full hex with hash', () {
      final c = hexColor('#FF0000');
      expect(c, const Color(0xFFFF0000));
    });

    test('parses short hex without hash', () {
      final c = hexColor('00FF00');
      expect(c, const Color(0xFF00FF00));
    });

    test('parses black', () {
      final c = hexColor('#000000');
      expect(c, const Color(0xFF000000));
    });

    test('parses white', () {
      final c = hexColor('FFFFFF');
      expect(c, const Color(0xFFFFFFFF));
    });
  });

  group('parseHexColor', () {
    test('returns int with full alpha', () {
      final v = parseHexColor('#1A7F37');
      expect(v, 0xFF1A7F37);
    });

    test('returns int without hash', () {
      final v = parseHexColor('B71C1C');
      expect(v, 0xFFB71C1C);
    });
  });
}
