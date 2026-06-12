import '../models/recruitment.dart';

/// 简历筛选服务
class RecruitmentService {
  /// 执行初筛
  ScreeningResult screen(Resume resume, JobPosition position) {
    final reasons = <String>[];
    final rules = position.screeningRules;

    // 硬性条件检查
    if (_compareEducation(resume.education, rules.minEducation) < 0) {
      reasons.add('学历不达标: 要求 ${rules.minEducation}，实际 ${resume.education}');
    }

    if (resume.experienceYears < rules.minExperienceYears) {
      reasons.add(
        '工作经验不足: 要求 ${rules.minExperienceYears} 年，实际 ${resume.experienceYears} 年',
      );
    }

    final missingSkills = rules.requiredSkills
        .where(
          (s) => !resume.skills.any(
            (rs) => rs.toLowerCase().contains(s.toLowerCase()),
          ),
        )
        .toList();
    if (missingSkills.isNotEmpty) {
      reasons.add('缺少必备技能: ${missingSkills.join("、")}');
    }

    if (reasons.isNotEmpty) {
      return ScreeningResult(
        resumeId: resume.id,
        decision: Decision.reject,
        reasons: reasons,
        confidence: 1.0,
      );
    }

    // 加分项评估
    final hasBonus = rules.bonusSkills.any(
      (s) =>
          resume.skills.any((rs) => rs.toLowerCase().contains(s.toLowerCase())),
    );
    final decision = hasBonus ? Decision.priority : Decision.pass;

    return ScreeningResult(
      resumeId: resume.id,
      decision: decision,
      reasons: ['所有硬性条件满足'],
      confidence: hasBonus ? 0.9 : 0.8,
    );
  }

  int _compareEducation(String actual, String required) {
    const levels = ['高中', '大专', '本科', '硕士', '博士'];
    return levels.indexOf(actual).compareTo(levels.indexOf(required));
  }
}
