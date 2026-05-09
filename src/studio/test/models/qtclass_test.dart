import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_qtclass/class.dart';

void main() {
  group('Helper functions', () {
    test('qtClassComponentLabel returns correct Chinese labels', () {
      expect(qtClassComponentLabel(QtClassComponentType.schoolEnterprise), '校企合作');
      expect(qtClassComponentLabel(QtClassComponentType.trainingBase), '实训基地');
      expect(qtClassComponentLabel(QtClassComponentType.internalTeaching), '内部教学');
      expect(qtClassComponentLabel(QtClassComponentType.oneOnOne), '一对一');
    });

    test('qtClassComponentIcon returns correct icons', () {
      expect(qtClassComponentIcon(QtClassComponentType.schoolEnterprise), Icons.business_outlined);
      expect(qtClassComponentIcon(QtClassComponentType.trainingBase), Icons.school_outlined);
      expect(qtClassComponentIcon(QtClassComponentType.internalTeaching), Icons.group_outlined);
      expect(qtClassComponentIcon(QtClassComponentType.oneOnOne), Icons.person_outline);
    });

    test('qtClassComponentColor returns correct colors', () {
      expect(qtClassComponentColor(QtClassComponentType.schoolEnterprise), const Color(0xFF1565C0));
      expect(qtClassComponentColor(QtClassComponentType.trainingBase), const Color(0xFF2E7D32));
      expect(qtClassComponentColor(QtClassComponentType.internalTeaching), const Color(0xFF6A1B9A));
      expect(qtClassComponentColor(QtClassComponentType.oneOnOne), const Color(0xFFE65100));
    });
  });
}
