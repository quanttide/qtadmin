import 'package:flutter/material.dart';

enum QtClassComponentType {
  schoolEnterprise,
  trainingBase,
  internalTeaching,
  oneOnOne,
}

class QtClassComponentData {
  final QtClassComponentType type;
  final String name;
  final String description;
  final String status;
  final int studentCount;
  final int projectCount;
  final String? deadline;
  final List<String> highlights;

  const QtClassComponentData({
    required this.type,
    required this.name,
    required this.description,
    required this.status,
    required this.studentCount,
    required this.projectCount,
    this.deadline,
    required this.highlights,
  });

  factory QtClassComponentData.fromJson(Map<String, dynamic> json) {
    return QtClassComponentData(
      type: QtClassComponentType.values.byName(json['type'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      studentCount: json['studentCount'] as int,
      projectCount: json['projectCount'] as int,
      deadline: json['deadline'] as String?,
      highlights: (json['highlights'] as List<dynamic>).cast<String>(),
    );
  }
}

class QtClassData {
  final List<QtClassComponentData> components;

  const QtClassData({required this.components});

  factory QtClassData.fromJson(Map<String, dynamic> json) {
    return QtClassData(
      components: (json['components'] as List<dynamic>)
          .map((c) => QtClassComponentData.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

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
