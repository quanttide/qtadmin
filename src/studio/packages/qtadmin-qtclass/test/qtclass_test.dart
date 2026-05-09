import 'package:qtadmin_qtclass/qtclass.dart';
import 'package:test/test.dart';

void main() {
  group('QtClassComponent', () {
    test('fromJson parses correctly', () {
      final json = {
        'type': 'schoolEnterprise',
        'name': 'XX大学校企合作',
        'description': '与XX大学共建实训基地',
        'status': 'active',
        'studentCount': 120,
        'projectCount': 3,
        'deadline': '2025-12-31',
        'highlights': ['获得企业捐赠设备'],
      };
      final component = QtClassComponent.fromJson(json);

      expect(component.type, QtClassComponentType.schoolEnterprise);
      expect(component.name, 'XX大学校企合作');
      expect(component.studentCount, 120);
      expect(component.projectCount, 3);
    });

    test('fromJson works without deadline', () {
      final json = {
        'type': 'trainingBase',
        'name': '校内实训基地',
        'description': '描述',
        'status': 'active',
        'studentCount': 60,
        'projectCount': 2,
        'highlights': [],
      };
      final component = QtClassComponent.fromJson(json);

      expect(component.type, QtClassComponentType.trainingBase);
      expect(component.deadline, isNull);
    });
  });

  group('QtClass', () {
    test('fromJson parses correctly', () {
      final json = {
        'components': [
          {
            'type': 'schoolEnterprise',
            'name': 'XX大学校企合作',
            'description': '描述',
            'status': 'active',
            'studentCount': 120,
            'projectCount': 3,
            'highlights': [],
          },
        ],
      };
      final data = QtClass.fromJson(json);

      expect(data.components.length, 1);
      expect(data.components.first.name, 'XX大学校企合作');
    });
  });
}
