import '../models/compensation.dart';

/// 薪酬计算服务
class CompensationService {
  final CompensationRuleConfig config;

  const CompensationService({CompensationRuleConfig? config})
    : config = config ?? CompensationRuleConfig();

  /// 按规则计算薪酬
  CompensationResult calculate(CompensationParams params) {
    final baseSalary = params.baseHours * params.hourlyRate;
    final overtimePay =
        params.overtimeHours * params.hourlyRate * config.overtimeMultiplier;
    final performanceBonus = baseSalary * config.performanceBonusRatio;
    final netSalary =
        baseSalary + overtimePay + performanceBonus - params.deductions;

    return CompensationResult(
      baseSalary: _round(baseSalary),
      overtimePay: _round(overtimePay),
      performanceBonus: _round(performanceBonus),
      deduction: params.deductions,
      netSalary: _round(netSalary < 0 ? 0 : netSalary),
    );
  }

  double _round(double value) => (value * 100).roundToDouble() / 100;
}
