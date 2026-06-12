import 'package:test/test.dart';
import 'package:quanttide_hr/quanttide_hr.dart';

void main() {
  group('CompensationService', () {
    test('正常试算 - 基础薪资 + 加班 + 绩效', () {
      final service = CompensationService();
      final result = service.calculate(
        const CompensationParams(
          baseHours: 160,
          hourlyRate: 25,
          overtimeHours: 10,
          deductions: 200,
        ),
      );

      expect(result.baseSalary, 4000);
      expect(result.overtimePay, 375); // 10 * 25 * 1.5
      expect(result.performanceBonus, 400); // 4000 * 0.1
      expect(result.deduction, 200);
      expect(result.netSalary, 4575); // 4000 + 375 + 400 - 200
    });

    test('扣款超过应发总额 - 净薪资为 0', () {
      final service = CompensationService();
      final result = service.calculate(
        const CompensationParams(
          baseHours: 160,
          hourlyRate: 25,
          deductions: 5000,
        ),
      );

      expect(result.netSalary, 0);
    });

    test('自定义加班倍数', () {
      final config = CompensationRuleConfig(overtimeMultiplier: 2.0);
      final service = CompensationService(config: config);
      final result = service.calculate(
        const CompensationParams(
          baseHours: 160,
          hourlyRate: 25,
          overtimeHours: 10,
        ),
      );

      expect(result.overtimePay, 500); // 10 * 25 * 2.0
    });

    test('自定义绩效比例', () {
      final config = CompensationRuleConfig(performanceBonusRatio: 0.15);
      final service = CompensationService(config: config);
      final result = service.calculate(
        const CompensationParams(baseHours: 160, hourlyRate: 25),
      );

      expect(result.performanceBonus, 600); // 4000 * 0.15
    });
  });
}
