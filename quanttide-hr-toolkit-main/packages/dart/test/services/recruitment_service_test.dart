import 'package:test/test.dart';
import 'package:quanttide_hr/quanttide_hr.dart';

void main() {
  group('RecruitmentService', () {
    late RecruitmentService service;
    late JobPosition position;

    setUp(() {
      service = RecruitmentService();
      position = const JobPosition(
        id: 'job-1',
        title: '软件工程师',
        description: '负责后端开发',
        screeningRules: ScreeningRules(
          requiredSkills: ['Python', 'Flutter'],
          minExperienceYears: 3,
          minEducation: '本科',
          bonusSkills: ['大厂经验'],
        ),
      );
    });

    test('初筛通过 - 满足所有硬性条件', () {
      final resume = const Resume(
        id: 'res-1',
        name: '张三',
        skills: ['Python', 'Flutter', 'Docker'],
        experienceYears: 5,
        education: '本科',
      );

      final result = service.screen(resume, position);

      expect(result.decision, Decision.pass);
      expect(result.reasons, contains('所有硬性条件满足'));
    });

    test('初筛优先 - 满足硬性条件且有加分项', () {
      final resume = const Resume(
        id: 'res-2',
        name: '李四',
        skills: ['Python', 'Flutter', '大厂经验'],
        experienceYears: 4,
        education: '硕士',
      );

      final result = service.screen(resume, position);

      expect(result.decision, Decision.priority);
    });

    test('初筛淘汰 - 缺少必备技能', () {
      final resume = const Resume(
        id: 'res-3',
        name: '王五',
        skills: ['Java'],
        experienceYears: 5,
        education: '本科',
      );

      final result = service.screen(resume, position);

      expect(result.decision, Decision.reject);
      expect(result.reasons.any((r) => r.contains('必备技能')), isTrue);
    });

    test('初筛淘汰 - 工作经验不足', () {
      final resume = const Resume(
        id: 'res-4',
        name: '赵六',
        skills: ['Python', 'Flutter'],
        experienceYears: 1,
        education: '本科',
      );

      final result = service.screen(resume, position);

      expect(result.decision, Decision.reject);
      expect(result.reasons.any((r) => r.contains('工作经验')), isTrue);
    });

    test('初筛淘汰 - 学历不达标', () {
      final resume = const Resume(
        id: 'res-5',
        name: '孙七',
        skills: ['Python', 'Flutter'],
        experienceYears: 5,
        education: '高中',
      );

      final result = service.screen(resume, position);

      expect(result.decision, Decision.reject);
      expect(result.reasons.any((r) => r.contains('学历')), isTrue);
    });
  });
}
