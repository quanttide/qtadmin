import 'package:flutter/material.dart';

class ThinkingScreen extends StatelessWidget {
  const ThinkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 28),
                _buildSectionLabel('情境意识', Icons.explore_outlined, const Color(0xFF5B8DEF)),
                const SizedBox(height: 16),
                _buildPeriod(isMobile),
                const SizedBox(height: 20),
                _buildStage(
                  icon: Icons.construction_outlined,
                  title: '奠基期（3月中旬 - 3月底）',
                  subtitle: '方法与工具的归档',
                  points: const [
                    '核心：日志格式、知识库、AI模型、工作手册',
                    '有意识地设计一套思维脚手架，为深度探索打下方法论基础',
                  ],
                  color: const Color(0xFF5B8DEF),
                ),
                const SizedBox(height: 14),
                _buildStage(
                  icon: Icons.auto_awesome_outlined,
                  title: '爆发与深化期（4月）',
                  subtitle: '认知内核的建模与重构',
                  points: const [
                    '4月23日达思想高峰（单日12,748字，启发61次），认知集中突破',
                    '触及元认知层面——反思"我是如何思考的"',
                    '将AI作为新的认知工具和比较对象纳入思维过程',
                  ],
                  color: const Color(0xFFE8A838),
                ),
                const SizedBox(height: 14),
                _buildStage(
                  icon: Icons.rocket_launch_outlined,
                  title: '外化与应用期（4月底 - 5月初）',
                  subtitle: '从思想到产品与叙事',
                  points: const [
                    '思考重心从内部认知架构转向外部的实践与产品化',
                    '开始面向"用户"和"市场"——"这台机器的用户是谁？"',
                    '"困惑"增多，反映将想法落地的实际挑战',
                  ],
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 24),
                _buildEmotionSection(isMobile),
                const SizedBox(height: 40),
                _buildSectionLabel('心智模型', Icons.psychology_outlined, const Color(0xFF7C4DFF)),
                const SizedBox(height: 16),
                _buildInsightSection(isMobile),
                const SizedBox(height: 24),
                _buildClosing(isMobile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String label, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '认知建构与思维演进',
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '基于 2026.03.11 - 2026.05.05 日志的分析报告',
          style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  Widget _buildPeriod(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_outlined, size: 20, color: Color(0xFF666666)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '46天日志记录了一次从"方法的建立"到"系统的反思"再到"视角的外化"的连贯心智旅程。',
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                color: const Color(0xFF444444),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> points,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 10),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('·  ', style: TextStyle(color: Color(0xFFAAAAAA))),
                Expanded(
                  child: Text(
                    p,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmotionSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '情绪底色',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _emotionChip('启发/顿悟', '450次', const Color(0xFF4CAF50))),
              const SizedBox(width: 8),
              Expanded(child: _emotionChip('困惑/混沌', '127次', const Color(0xFFE8A838))),
              const SizedBox(width: 8),
              Expanded(child: _emotionChip('压力/焦虑', '80次', const Color(0xFFEF5350))),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '主导情绪是"启发/顿悟"——这不是情绪日记，而是一份认知收获日记。困难是启发的燃料。',
            style: TextStyle(fontSize: 12, color: Color(0xFF888888), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _emotionChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _insightCard(
          icon: Icons.chat_outlined,
          title: 'AI 作为持续对话者与参照系',
          desc: 'AI 不只是工具，更是对等的思考伙伴。通过与之互动，反身性地定义和理解人类思维的独特性。',
        ),
        const SizedBox(height: 10),
        _insightCard(
          icon: Icons.transform_outlined,
          title: '从"动词"到"名词"的认知固化',
          desc: '早期多为"整理""归档"等动作，后期"资产""标准""平台"等名词性概念更为核心——流动的想法正凝结为可迭代的实体。',
        ),
        const SizedBox(height: 10),
        _insightCard(
          icon: Icons.touch_app_outlined,
          title: '"感觉"作为探测器与压力测试器',
          desc: '"感觉"出现 309 次，既是发现问题的探测器（"感觉哪里不对"），也是系统设计的压力测试器（"这个用起来感觉很奇怪"）。',
        ),
        const SizedBox(height: 10),
        _insightCard(
          icon: Icons.short_text_outlined,
          title: '"就是说"作为思维连接词',
          desc: '高频出现（175次），标志持续的自我解释与精炼——将模糊想法用更底层的方式重新表述，是深度思维的显著特征。',
        ),
      ],
    );
  }

  Widget _insightCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF666666)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosing(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '感知 — 建模 — 应用',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '46天的日志清晰地构建并记录了一条"感知-建模-应用"的认知演化路径。已经从单纯的记录者，成长为主动构建个人思想和知识系统的架构师。',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.6),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF7C4DFF)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '最宝贵的资产，是日志中所展现的那种持续、敏锐、并不断尝试自我超越的思维习惯本身。',
                    style: TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
