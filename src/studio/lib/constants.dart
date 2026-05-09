import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/qtclass.dart';
import 'package:qtadmin_qtconsult/qtconsult.dart';

// --- Thinking ---

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

// --- QtClass ---

String qtClassComponentLabel(QtClassComponentType type) {
  switch (type) {
    case QtClassComponentType.schoolEnterprise:
      return '校企合作';
    case QtClassComponentType.trainingBase:
      return '实训基地';
    case QtClassComponentType.internalTeaching:
      return '内部教学';
    case QtClassComponentType.oneOnOne:
      return '一对一';
  }
}

IconData qtClassComponentIcon(QtClassComponentType type) {
  switch (type) {
    case QtClassComponentType.schoolEnterprise:
      return Icons.business_outlined;
    case QtClassComponentType.trainingBase:
      return Icons.school_outlined;
    case QtClassComponentType.internalTeaching:
      return Icons.group_outlined;
    case QtClassComponentType.oneOnOne:
      return Icons.person_outline;
  }
}

Color qtClassComponentColor(QtClassComponentType type) {
  switch (type) {
    case QtClassComponentType.schoolEnterprise:
      return const Color(0xFF1565C0);
    case QtClassComponentType.trainingBase:
      return const Color(0xFF2E7D32);
    case QtClassComponentType.internalTeaching:
      return const Color(0xFF6A1B9A);
    case QtClassComponentType.oneOnOne:
      return const Color(0xFFE65100);
  }
}

// --- QtConsult ---

Color discoveryDotColor(DiscoveryType type) {
  switch (type) {
    case DiscoveryType.risk:
      return const Color(0xFFB71C1C);
    case DiscoveryType.concern:
      return const Color(0xFFC8690A);
    case DiscoveryType.opportunity:
      return const Color(0xFF1A7F37);
    case DiscoveryType.neutral:
      return const Color(0xFF1A5FDC);
  }
}

Color stanceColor(StakeStance stance) {
  switch (stance) {
    case StakeStance.support:
      return const Color(0xFF1A7F37);
    case StakeStance.neutral:
      return const Color(0xFF777777);
    case StakeStance.oppose:
      return const Color(0xFFB71C1C);
  }
}

Color stanceBgColor(StakeStance stance) {
  switch (stance) {
    case StakeStance.support:
      return const Color(0xFFE8F5E9);
    case StakeStance.neutral:
      return const Color(0xFFF5F5F5);
    case StakeStance.oppose:
      return const Color(0xFFFFEBEE);
  }
}
