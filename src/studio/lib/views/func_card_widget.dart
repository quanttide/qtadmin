import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/dashboard.dart';

class FuncCardWidget extends StatelessWidget {
  final FuncCard data;

  const FuncCardWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: data.isWarning ? const Color(0xFFFFFDF5) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: data.isWarning
            ? const Border(left: BorderSide(color: Color(0xFFC8690A), width: 3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF444444)),
          ),
          const SizedBox(height: 8),
          ...data.metrics.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(m.label, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                    Text(m.value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
          if (data.trend != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                data.trend!.text,
                style: TextStyle(
                  fontSize: 10,
                  color: data.trend!.direction == TrendDirection.up
                      ? const Color(0xFF1A7F37)
                      : data.trend!.direction == TrendDirection.down
                          ? const Color(0xFFB71C1C)
                          : const Color(0xFF888888),
                ),
              ),
            ),
          if (data.warning != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  data.warning!,
                  style: const TextStyle(fontSize: 10, color: Color(0xFFC8690A)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
