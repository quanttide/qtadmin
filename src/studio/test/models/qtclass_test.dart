import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/qtclass.dart';
import 'package:qtadmin_studio/constants/app_constants.dart';

void main() {
  group('QtClassComponentType', () {
    test('byName resolves correctly', () {
      expect(QtClassComponentType.values.byName('schoolEnterprise'), QtClassComponentType.schoolEnterprise);
      expect(QtClassComponentType.values.byName('trainingBase'), QtClassComponentType.trainingBase);
      expect(QtClassComponentType.values.byName('internalTeaching'), QtClassComponentType.internalTeaching);
      expect(QtClassComponentType.values.byName('oneOnOne'), QtClassComponentType.oneOnOne);
    });
  });

  group('QtClassComponent', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'schoolEnterprise',
        'name': '校企合作',
        'description': '与高校合作开展人才培养',
        'status': '进行中',
        'studentCount': 128,
        'projectCount': 6,
        'deadline': '2026-Q2',
        'highlights': ['杭电Python实训项目进行中', '浙大数据科学课程共建已签约'],
      };
      final component = QtClassComponent.fromJson(json);

      expect(component.type, QtClassComponentType.schoolEnterprise);
      expect(component.name, '校企合作');
      expect(component.description, '与高校合作开展人才培养');
      expect(component.status, '进行中');
      expect(component.studentCount, 128);
      expect(component.projectCount, 6);
      expect(component.deadline, '2026-Q2');
      expect(component.highlights.length, 2);
      expect(component.highlights[0], '杭电Python实训项目进行中');
    });

    test('fromJson defaults deadline to null', () {
      final json = {
        'type': 'trainingBase',
        'name': '实训基地',
        'description': '提供实战化技能训练',
        'status': '运营中',
        'studentCount': 256,
        'projectCount': 12,
        'highlights': ['数据分析实训营第4期即将开营'],
      };
      final component = QtClassComponent.fromJson(json);

      expect(component.deadline, isNull);
      expect(component.type, QtClassComponentType.trainingBase);
      expect(component.studentCount, 256);
    });

    test('fromJson handles all component types', () {
      final types = ['schoolEnterprise', 'trainingBase', 'internalTeaching', 'oneOnOne'];
      for (final type in types) {
        final json = {
          'type': type,
          'name': '测试',
          'description': '测试描述',
          'status': '测试中',
          'studentCount': 0,
          'projectCount': 0,
          'highlights': <String>[],
        };
        final component = QtClassComponent.fromJson(json);
        expect(QtClassComponentType.values.byName(type), component.type);
      }
    });
  });

  group('QtClass', () {
    test('fromJson parses full class data', () {
      final json = {
        'components': [
          {
            'type': 'schoolEnterprise',
            'name': '校企合作',
            'description': '与高校合作开展人才培养',
            'status': '进行中',
            'studentCount': 128,
            'projectCount': 6,
            'deadline': '2026-Q2',
            'highlights': ['杭电Python实训项目进行中'],
          },
          {
            'type': 'trainingBase',
            'name': '实训基地',
            'description': '提供实战化技能训练',
            'status': '运营中',
            'studentCount': 256,
            'projectCount': 12,
            'highlights': ['数据分析实训营第4期即将开营'],
          },
        ],
      };
      final data = QtClass.fromJson(json);

      expect(data.components.length, 2);
      expect(data.components[0].type, QtClassComponentType.schoolEnterprise);
      expect(data.components[1].type, QtClassComponentType.trainingBase);
    });

    test('fromJson handles empty components list', () {
      final json = {
        'components': <Map<String, dynamic>>[],
      };
      final data = QtClass.fromJson(json);

      expect(data.components, isEmpty);
    });
  });

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
