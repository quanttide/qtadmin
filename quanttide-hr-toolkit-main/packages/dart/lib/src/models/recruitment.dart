/// 招聘模块领域模型

/// 候选人简历
class Resume {
  final String id;
  final String name;
  final List<String> skills;
  final int experienceYears;
  final String education;

  const Resume({
    required this.id,
    required this.name,
    required this.skills,
    required this.experienceYears,
    required this.education,
  });
}

/// 岗位描述
class JobPosition {
  final String id;
  final String title;
  final String description;
  final ScreeningRules screeningRules;

  const JobPosition({
    required this.id,
    required this.title,
    required this.description,
    required this.screeningRules,
  });
}

/// 筛选规则
class ScreeningRules {
  final List<String> requiredSkills;
  final int minExperienceYears;
  final String minEducation;
  final List<String> bonusSkills;

  const ScreeningRules({
    required this.requiredSkills,
    required this.minExperienceYears,
    required this.minEducation,
    this.bonusSkills = const [],
  });
}

/// 筛选结果
class ScreeningResult {
  final String resumeId;
  final Decision decision;
  final List<String> reasons;
  final double confidence;

  const ScreeningResult({
    required this.resumeId,
    required this.decision,
    required this.reasons,
    required this.confidence,
  });
}

/// 筛选决定
enum Decision { pass, reject, priority }
