import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String value;

  const StatItem({
    super.key,
    required this.dotColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
      ],
    );
  }
}
