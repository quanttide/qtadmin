import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/qtclass.dart';

class QtClassScreen extends StatelessWidget {
  final QtClassData data;

  const QtClassScreen({super.key, required this.data});

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
                _buildHeader(),
                const SizedBox(height: 16),
                _buildStatsBar(),
                const SizedBox(height: 20),
                _buildComponentsGrid(isMobile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          '量潮课堂',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF222222)),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '主营',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A7F37)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    final totalStudents = data.components.fold<int>(0, (sum, c) => sum + c.studentCount);
    final totalProjects = data.components.fold<int>(0, (sum, c) => sum + c.projectCount);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          _statItem(const Color(0xFF1565C0), '总学员', totalStudents.toString()),
          const SizedBox(width: 24),
          _statItem(const Color(0xFF2E7D32), '总项目', totalProjects.toString()),
          const SizedBox(width: 24),
          _statItem(const Color(0xFF6A1B9A), '组成部分', data.components.length.toString()),
        ],
      ),
    );
  }

  Widget _statItem(Color dotColor, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF222222)),
        ),
      ],
    );
  }

  Widget _buildComponentsGrid(bool isMobile) {
    if (isMobile) {
      return Column(
        children: data.components.map(_buildComponentCard).toList(),
      );
    }
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: data.components.map((c) => SizedBox(
        width: 390,
        child: _buildComponentCard(c),
      )).toList(),
    );
  }

  Widget _buildComponentCard(QtClassComponentData component) {
    final color = qtClassComponentColor(component.type);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(qtClassComponentIcon(component.type), size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                component.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF222222)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  component.status,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            component.description,
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666), height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniStat(Icons.people_outline, '${component.studentCount}人'),
              const SizedBox(width: 16),
              _miniStat(Icons.folder_outlined, '${component.projectCount}个项目'),
              if (component.deadline != null) ...[
                const SizedBox(width: 16),
                _miniStat(Icons.schedule_outlined, component.deadline!),
              ],
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 10),
          ...component.highlights.map((h) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('· ', style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB))),
                Expanded(child: Text(h, style: const TextStyle(fontSize: 12, color: Color(0xFF444444)))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF999999)),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF777777))),
      ],
    );
  }
}
