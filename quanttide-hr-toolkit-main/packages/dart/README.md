# QtCloud HR Toolkit

量潮人力资源工具包，提供招聘、薪酬等 HR 核心领域的 Dart 数据模型与业务逻辑。

## 功能

- **招聘** — 简历筛选规则、候选人匹配度评估
- **薪酬** — 计时工资计算、加班费与绩效奖金核算

## 使用

```dart
import 'package:quanttide_hr/quanttide_hr.dart';

final result = calculateCompensation(
  baseHours: 160,
  hourlyRate: 25,
  overtimeHours: 10,
  deductions: 200,
);
```

## 许可

CC BY 4.0
