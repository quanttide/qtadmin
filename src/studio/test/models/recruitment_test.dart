import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/recruitment.dart';

void main() {
  group('RecruitmentPlan', () {
    test('fromJson parses correctly', () {
      final json = {
        'month': '2026-06',
        'positions': [
          {'name': '数据工程师', 'headcount': 2, 'filled': 1, 'in_progress': 1, 'note': '试用期'},
          {'name': '新媒体运营', 'headcount': 1, 'filled': 0, 'in_progress': 0, 'note': ''},
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
          {'name': '数据工程师', 'headcount': 2, 'filled': 0, 'in_progress': 0, 'note': ''},
          {'name': '项目经理', 'headcount': 1, 'filled': 0, 'in_progress': 0, 'note': ''},
          {'name': '销售经理', 'headcount': 1, 'filled': 0, 'in_progress': 0, 'note': ''},
          {'name': '新媒体运营', 'headcount': 1, 'filled': 0, 'in_progress': 0, 'note': ''},
          {'name': '课程助教', 'headcount': 1, 'filled': 0, 'in_progress': 0, 'note': ''},
          {'name': '咨询助理', 'headcount': 1, 'filled': 0, 'in_progress': 0, 'note': ''},
          {'name': '商务经理', 'headcount': 1, 'filled': 0, 'in_progress': 0, 'note': ''},
          {'name': '执行助理', 'headcount': 2, 'filled': 0, 'in_progress': 0, 'note': ''},
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
