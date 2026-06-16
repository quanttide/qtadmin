import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/recruitment.dart';

const _contractPath = '../../tests/contract/recruitment.json';

void main() {
  group('Contract: recruitment.json', () {
    RecruitmentPlan? _plan;

    setUp(() {
      final file = File(_contractPath);
      if (!file.existsSync()) {
        throw Exception('契约文件不存在: ${file.absolute.path}\n'
            '请从 CLI 目录运行: cargo test --test test_contract');
      }
      final jsonStr = file.readAsStringSync();
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      _plan = RecruitmentPlan.fromJson(json);
    });

    test('月份为 2026-06', () {
      expect(_plan!.month, '2026-06');
    });

    test('包含 8 个岗位', () {
      expect(_plan!.positions.length, 8);
    });

    test('总编制为 10', () {
      expect(_plan!.totalHeadcount, 10);
    });

    test('每个岗位含必需字段', () {
      for (final pos in _plan!.positions) {
        expect(pos.name, isNotEmpty);
        expect(pos.headcount, greaterThan(0));
        expect(pos.filled, greaterThanOrEqualTo(0));
        expect(pos.inProgress, greaterThanOrEqualTo(0));
        expect(pos.note, isNotNull);
      }
    });

    test('默认所有岗位空缺', () {
      expect(_plan!.totalFilled, 0);
      expect(_plan!.vacancies, 10);
    });
  });
}
