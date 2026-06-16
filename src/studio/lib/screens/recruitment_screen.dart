import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/recruitment.dart';

class RecruitmentScreen extends StatefulWidget {
  final RecruitmentPlan data;
  const RecruitmentScreen({super.key, required this.data});

  @override
  State<RecruitmentScreen> createState() => _RecruitmentScreenState();
}

class _RecruitmentScreenState extends State<RecruitmentScreen> {
  @override
  Widget build(BuildContext context) {
    final plan = widget.data;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 10 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(plan, isMobile),
              const SizedBox(height: 16),
              _buildStatsRow(plan),
              const SizedBox(height: 16),
              _buildTable(plan),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(RecruitmentPlan plan, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${plan.month} 招聘计划',
          style: TextStyle(
            fontSize: isMobile ? 17 : 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '截至 6 月 16 日',
          style: TextStyle(fontSize: 12, color: const Color(0xFF999999)),
        ),
      ],
    );
  }

  Widget _buildStatsRow(RecruitmentPlan plan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          _statItem(const Color(0xFF1A7F37), '编制', plan.totalHeadcount.toString()),
          const SizedBox(width: 24),
          _statItem(const Color(0xFF1565C0), '已入职', plan.totalFilled.toString()),
          const SizedBox(width: 24),
          _statItem(const Color(0xFFC8690A), '进行中', plan.totalInProgress.toString()),
          const Spacer(),
          _statItem(const Color(0xFFB71C1C), '空缺', plan.vacancies.toString()),
        ],
      ),
    );
  }

  Widget _statItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222))),
          ],
        ),
      ],
    );
  }

  Widget _buildTable(RecruitmentPlan plan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('岗位明细',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333))),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(2),
            },
            children: [
              _tableRow([
                _th('岗位'),
                _th('编制'),
                _th('已入职'),
                _th('进行中'),
                _th('备注'),
              ], isHeader: true),
              ...plan.positions.map((p) => _tableRow([
                    _td(p.name),
                    _td(p.headcount.toString()),
                    _td(p.filled.toString()),
                    _td(p.inProgress.toString()),
                    _td(p.note.isEmpty ? '-' : p.note),
                  ])),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _tableRow(List<Widget> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            )
          : null,
      children: cells
          .map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: c,
              ))
          .toList(),
    );
  }

  Widget _th(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888)));
  }

  Widget _td(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF333333)));
  }
}
