/// 薪酬模块领域模型

/// 薪酬计算参数
class CompensationParams {
  final double baseHours;
  final double hourlyRate;
  final double overtimeHours;
  final double deductions;

  const CompensationParams({
    required this.baseHours,
    required this.hourlyRate,
    this.overtimeHours = 0,
    this.deductions = 0,
  }) : assert(
         baseHours >= 0 &&
             hourlyRate >= 0 &&
             overtimeHours >= 0 &&
             deductions >= 0,
         '所有参数必须为非负数',
       );
}

/// 薪酬计算结果明细
class CompensationResult {
  final double baseSalary;
  final double overtimePay;
  final double performanceBonus;
  final double deduction;
  final double netSalary;

  const CompensationResult({
    required this.baseSalary,
    required this.overtimePay,
    required this.performanceBonus,
    required this.deduction,
    required this.netSalary,
  });

  @override
  String toString() =>
      '基础薪资: $baseSalary, 加班薪资: $overtimePay, '
      '绩效奖金: $performanceBonus, 扣除: $deduction, 净薪资: $netSalary';
}

/// 薪资规则配置
class CompensationRuleConfig {
  double overtimeMultiplier;
  double performanceBonusRatio;

  CompensationRuleConfig({
    this.overtimeMultiplier = 1.5,
    this.performanceBonusRatio = 0.1,
  });
}
