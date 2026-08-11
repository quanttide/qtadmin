import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/human.dart';

void main() {
  group('HumanPosition', () {
    test('fromJson parses full record', () {
      final json = {
        'id': 'p1',
        'name': '后端工程师',
        'department': '技术部',
        'level': 'P5',
        'description': '前后端全栈开发',
        'responsibilities': '服务端开发',
        'requirements': '3 年以上',
        'active': true,
      };
      final pos = HumanPosition.fromJson(json);

      expect(pos.id, 'p1');
      expect(pos.name, '后端工程师');
      expect(pos.department, '技术部');
      expect(pos.level, 'P5');
      expect(pos.description, '前后端全栈开发');
      expect(pos.responsibilities, '服务端开发');
      expect(pos.requirements, '3 年以上');
      expect(pos.active, isTrue);
    });

    test('fromJson defaults optional fields', () {
      final json = {'id': 'p2', 'name': '前端工程师'};
      final pos = HumanPosition.fromJson(json);

      expect(pos.department, isNull);
      expect(pos.level, isNull);
      expect(pos.active, isTrue);
    });
  });

  group('PositionsFile', () {
    test('fromJson parses records map', () {
      final json = {
        'records': {
          'p1': {'id': 'p1', 'name': '后端工程师', 'active': true},
          'p2': {'id': 'p2', 'name': '前端工程师', 'active': false},
        },
      };
      final file = PositionsFile.fromJson(json);

      expect(file.records.length, 2);
      expect(file.records['p1']!.name, '后端工程师');
      expect(file.records['p2']!.active, isFalse);
    });

    test('all sorts by name', () {
      final json = {
        'records': {
          'p1': {'id': 'p1', 'name': '后端工程师', 'active': true},
          'p2': {'id': 'p2', 'name': '前端工程师', 'active': true},
        },
      };
      final file = PositionsFile.fromJson(json);

      expect(file.all.map((p) => p.name).toList(), ['前端工程师', '后端工程师']);
    });
  });

  group('RecruitmentPlan', () {
    test('fromJson parses correctly', () {
      final json = {
        'month': '2026-06',
        'positions': [
          {
            'name': '数据工程师',
            'headcount': 2,
            'filled': 1,
            'in_progress': 1,
            'note': '试用期',
          },
          {
            'name': '新媒体运营',
            'headcount': 1,
            'filled': 0,
            'in_progress': 0,
            'note': '',
          },
        ],
      };
      final plan = RecruitmentPlan.fromJson(json);

      expect(plan.month, '2026-06');
      expect(plan.positions.length, 2);
      expect(plan.totalHeadcount, 3);
      expect(plan.totalFilled, 1);
      expect(plan.totalInProgress, 1);
      expect(plan.vacancies, 2);
    });

    test('fromJson with empty positions', () {
      final json = {'month': '2026-06', 'positions': []};
      final plan = RecruitmentPlan.fromJson(json);

      expect(plan.positions, isEmpty);
      expect(plan.totalHeadcount, 0);
      expect(plan.vacancies, 0);
    });

    test('default positions from CLI data file', () {
      final json = {
        'month': '2026-06',
        'positions': [
          {
            'name': '数据工程师',
            'headcount': 2,
            'filled': 0,
            'in_progress': 0,
            'note': '',
          },
          {
            'name': '项目经理',
            'headcount': 1,
            'filled': 0,
            'in_progress': 0,
            'note': '',
          },
          {
            'name': '销售经理',
            'headcount': 1,
            'filled': 0,
            'in_progress': 0,
            'note': '',
          },
          {
            'name': '新媒体运营',
            'headcount': 1,
            'filled': 0,
            'in_progress': 0,
            'note': '',
          },
          {
            'name': '课程助教',
            'headcount': 1,
            'filled': 0,
            'in_progress': 0,
            'note': '',
          },
          {
            'name': '咨询助理',
            'headcount': 1,
            'filled': 0,
            'in_progress': 0,
            'note': '',
          },
          {
            'name': '商务经理',
            'headcount': 1,
            'filled': 0,
            'in_progress': 0,
            'note': '',
          },
          {
            'name': '执行助理',
            'headcount': 2,
            'filled': 0,
            'in_progress': 0,
            'note': '',
          },
        ],
      };
      final plan = RecruitmentPlan.fromJson(json);

      expect(plan.positions.length, 8);
      expect(plan.totalHeadcount, 10);
    });
  });

  group('PositionPlan', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': '数据工程师',
        'headcount': 2,
        'filled': 1,
        'in_progress': 1,
        'note': '面试中',
      };
      final pos = PositionPlan.fromJson(json);

      expect(pos.name, '数据工程师');
      expect(pos.headcount, 2);
      expect(pos.filled, 1);
      expect(pos.inProgress, 1);
      expect(pos.note, '面试中');
    });

    test('fromJson handles missing note', () {
      final json = {
        'name': '测试',
        'headcount': 1,
        'filled': 0,
        'in_progress': 0,
      };
      final pos = PositionPlan.fromJson(json);

      expect(pos.note, '');
    });
  });
}
