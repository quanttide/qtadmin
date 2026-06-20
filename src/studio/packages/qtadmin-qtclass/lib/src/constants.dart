import 'package:flutter/material.dart';
import 'package:qtadmin_qtclass/qtclass.dart';

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
