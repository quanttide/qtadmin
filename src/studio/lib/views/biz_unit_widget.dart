import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/views/decision_card_widget.dart';

class BizUnitWidget extends StatelessWidget {
  final BusinessUnitData data;

  const BizUnitWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                data.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              _buildTag(),
            ],
          ),
          const SizedBox(height: 10),
          if (data.isEmpty)
            _buildEmpty()
          else
            ...data.decisions.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DecisionCardWidget(data: d),
                )),
        ],
      ),
    );
  }

  Widget _buildTag() {
    final isPrimary = data.isPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFE8F5E9) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        data.tag,
        style: TextStyle(
          fontSize: 10,
          color: isPrimary ? const Color(0xFF1A7F37) : const Color(0xFF888888),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          data.emptyMessage ?? '暂无待决策事项',
          style: const TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
