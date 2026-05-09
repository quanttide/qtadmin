import 'package:flutter/material.dart';
import 'package:qtadmin_dashboard/dashboard_barrel.dart';

class DecisionCardWidget extends StatefulWidget {
  final Decision data;

  const DecisionCardWidget({super.key, required this.data});

  @override
  State<DecisionCardWidget> createState() => _DecisionCardWidgetState();
}

class _DecisionCardWidgetState extends State<DecisionCardWidget> {
  String? _resolvedAction;

  @override
  Widget build(BuildContext context) {
    if (_resolvedAction != null) {
      return _buildResolved();
    }
    return _buildPending();
  }

  Widget _buildPending() {
    final d = widget.data;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: d.isUrgent ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: d.isUrgent
            ? const Border(left: BorderSide(color: Color(0xFFB71C1C), width: 3))
            : Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d.fromPerson, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
              Text(d.deadline, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
            ],
          ),
          const SizedBox(height: 4),
          Text(d.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(d.context, style: const TextStyle(fontSize: 11, color: Color(0xFF666666), height: 1.4)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              d.teamAdvice,
              style: const TextStyle(fontSize: 10, color: Color(0xFF1A7F37)),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: d.actions.map((a) => _buildActionButton(a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResolved() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(
            color: _resolvedAction == '批准' || _resolvedAction == '同意加需求' || _resolvedAction == '同意延期'
                ? const Color(0xFF1A7F37)
                : const Color(0xFFCCCCCC),
            width: 3,
          ),
        ),
      ),
      child: Center(
        child: Text(
          '✓ 已$_resolvedAction · 通知已发送',
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
      ),
    );
  }

  Widget _buildActionButton(DecisionAction action) {
    return SizedBox(
      height: 26,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: action.isPrimary ? const Color(0xFF1A1A1A) : Colors.white,
          foregroundColor: action.isPrimary ? Colors.white : const Color(0xFF222222),
          side: BorderSide(color: action.isPrimary ? const Color(0xFF1A1A1A) : const Color(0xFFD0D0D0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          setState(() {
            _resolvedAction = action.label;
          });
        },
        child: Text(action.label, style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}
