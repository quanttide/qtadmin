import 'package:flutter/material.dart';

IconData resolveThinkingIcon(String name) {
  const icons = {
    'explore_outlined': Icons.explore_outlined,
    'construction_outlined': Icons.construction_outlined,
    'auto_awesome_outlined': Icons.auto_awesome_outlined,
    'rocket_launch_outlined': Icons.rocket_launch_outlined,
    'psychology_outlined': Icons.psychology_outlined,
    'chat_outlined': Icons.chat_outlined,
    'transform_outlined': Icons.transform_outlined,
    'touch_app_outlined': Icons.touch_app_outlined,
    'short_text_outlined': Icons.short_text_outlined,
  };
  return icons[name] ?? Icons.circle_outlined;
}
