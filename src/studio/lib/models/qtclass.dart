import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'qtclass.freezed.dart';
part 'qtclass.g.dart';

enum QtClassComponentType {
  schoolEnterprise,
  trainingBase,
  internalTeaching,
  oneOnOne,
}

@freezed
abstract class QtClassComponent with _$QtClassComponent {
  const factory QtClassComponent({
    required QtClassComponentType type,
    required String name,
    required String description,
    required String status,
    required int studentCount,
    required int projectCount,
    String? deadline,
    required List<String> highlights,
  }) = _QtClassComponent;

  factory QtClassComponent.fromJson(Map<String, dynamic> json) =>
      _$QtClassComponentFromJson(json);
}

@freezed
abstract class QtClass with _$QtClass {
  const factory QtClass({
    required List<QtClassComponent> components,
  }) = _QtClass;

  factory QtClass.fromJson(Map<String, dynamic> json) =>
      _$QtClassFromJson(json);
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
