import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/thinking.dart';
import 'package:qtadmin_studio/utils/thinking_icons.dart';

class ThinkingScreen extends StatelessWidget {
  final Thinking data;

  const ThinkingScreen({super.key, required this.data});

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
                _buildSectionLabel(
                  data.awarenessSectionLabel,
                  resolveThinkingIcon(data.awarenessSectionIcon),
                  Color(data.awarenessSectionColor),
                ),
                const SizedBox(height: 16),
                _buildPeriod(isMobile),
                const SizedBox(height: 20),
                ...data.stages.map((stage) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildStage(stage),
                )),
                const SizedBox(height: 24),
                _buildEmotionSection(isMobile),
                const SizedBox(height: 40),
                _buildSectionLabel(
                  data.insightSectionLabel,
                  resolveThinkingIcon(data.insightSectionIcon),
                  Color(data.insightSectionColor),
                ),
                const SizedBox(height: 16),
                ...data.insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _insightCard(insight),
                )),
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
          data.title,
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data.subtitle,
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
              data.period,
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

  Widget _buildStage(ThinkingStage stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: stage.color, width: 3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(resolveThinkingIcon(stage.iconName), size: 20, color: stage.color),
              const SizedBox(width: 8),
              Text(
                stage.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: stage.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            stage.subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 10),
          ...stage.points.map((p) => Padding(
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
            children: data.emotions.map((e) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: data.emotions.last == e ? 0 : 8),
                child: _emotionChip(e.label, e.value, e.color),
              ),
            )).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            data.emotionNote,
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888), height: 1.5),
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

  Widget _insightCard(ThinkingInsight insight) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(resolveThinkingIcon(insight.iconName), size: 20, color: const Color(0xFF666666)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
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
          Text(
            data.closing.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.closing.description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.6),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF7C4DFF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.closing.quote,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.5),
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
