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


