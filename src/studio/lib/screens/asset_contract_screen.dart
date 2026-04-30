import 'package:flutter/material.dart';

class AssetContractScreen extends StatelessWidget {
  const AssetContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数字资产契约'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '资产注册表',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '基于记忆模型的多仓架构数字资产管理，与 .gitmodules 对齐',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Expanded(child: _AssetGrid()),
          ],
        ),
      ),
    );
  }
}

class _AssetGrid extends StatelessWidget {
  const _AssetGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildHeader('宪法层'),
        _buildHeader('法律层'),
        _buildHeader('法理层'),
        _buildCell('Bylaw', '工作章程', Colors.orange.shade100),
        _buildCell('Handbook', '工作手册', Colors.blue.shade100),
        _buildCell('Tutorial', '工作教程', Colors.green.shade100),
        _buildCell('Specification', '工程标准', Colors.purple.shade100),
        _buildCell('Gallery', '工作案例', Colors.teal.shade100),
        _buildCell('Essay', '工作札记', Colors.cyan.shade100),
        _buildCell('Qtadmin', '管理后台', Colors.red.shade100),
        _buildCell('Qtcloud', '数据云', Colors.pink.shade100),
        _buildCell('Library', '图书馆', Colors.indigo.shade100),
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
