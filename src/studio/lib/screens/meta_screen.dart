import 'package:flutter/material.dart';

class MetaScreen extends StatelessWidget {
  const MetaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('九宫格记忆模型'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '记忆分类框架',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '基于认知科学的记忆分类体系，定义了组织知识管理的认知基础。',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Expanded(child: _MemoryGrid()),
          ],
        ),
      ),
    );
  }
}

class _MemoryGrid extends StatelessWidget {
  const _MemoryGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        // 表头
        _buildHeader('过去'),
        _buildHeader('现在'),
        _buildHeader('未来'),
        // 事件类
        _buildCell('Archive', '归档', Colors.orange.shade100),
        _buildCell('Journal', '日志', Colors.blue.shade100),
        _buildCell('Report', '报告', Colors.green.shade100),
        // 语义类
        _buildCell('Tutorial', '教程', Colors.purple.shade100),
        _buildCell('Profile', '档案', Colors.teal.shade100),
        _buildCell('Notice', '公告', Colors.cyan.shade100),
        // 自我类
        _buildCell('History', '历史', Colors.red.shade100),
        _buildCell('Brochure', '宣传', Colors.pink.shade100),
        _buildCell('Roadmap', '路线图', Colors.indigo.shade100),
      ],
    );
  }

  Widget _buildHeader(String text) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCell(String title, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
