import 'package:flutter/material.dart';
import '../theme/hr_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? label;

  const StatusBadge({super.key, required this.status, this.label});

  @override
  Widget build(BuildContext context) {
    final color = context.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label ?? status,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}
