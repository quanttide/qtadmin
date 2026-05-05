import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/panorama.dart';
import 'package:qtadmin_studio/widgets/business_section_widget.dart';
import 'package:qtadmin_studio/widgets/function_section_widget.dart';

class PanoramaScreen extends StatelessWidget {
  final PanoramaData data;

  const PanoramaScreen({super.key, required this.data});

  String _dateString() {
    final now = DateTime.now();
    const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    final wd = weekdays[now.weekday - 1];
    return '${now.year}年${now.month}月${now.day}日 · $wd';
  }

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
                BusinessSectionWidget(
                  units: data.businessUnits,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 32),
                FunctionSectionWidget(
                  cards: data.functionCards,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 28),
                _buildBottomNote(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '量潮科技',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _dateString(),
          style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  Widget _buildBottomNote() {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: const Text(
        '其余5位成员无需你介入 · 今日无待审批报销 · 本周全员周报已提交',
        style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
      ),
    );
  }
}
