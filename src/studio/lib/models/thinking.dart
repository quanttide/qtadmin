import 'dart:ui' show Color;
import 'package:freezed_annotation/freezed_annotation.dart';
import '../theme.dart';

part 'thinking.freezed.dart';
part 'thinking.g.dart';

@freezed
abstract class ThinkingEmotion with _$ThinkingEmotion {
  const factory ThinkingEmotion({
    required String label,
    required String value,
    @JsonKey(name: 'color', fromJson: parseHexColor) required int colorValue,
  }) = _ThinkingEmotion;

  const ThinkingEmotion._();

  factory ThinkingEmotion.fromJson(Map<String, dynamic> json) =>
      _$ThinkingEmotionFromJson(json);

  Color get color => Color(colorValue);
}

@freezed
abstract class ThinkingStage with _$ThinkingStage {
  const factory ThinkingStage({
    @JsonKey(name: 'icon') required String iconName,
    required String title,
    required String subtitle,
    required List<String> points,
    @JsonKey(name: 'color', fromJson: parseHexColor) required int colorValue,
  }) = _ThinkingStage;

  const ThinkingStage._();

  factory ThinkingStage.fromJson(Map<String, dynamic> json) =>
      _$ThinkingStageFromJson(json);

  Color get color => Color(colorValue);
}

@freezed
abstract class ThinkingInsight with _$ThinkingInsight {
  const factory ThinkingInsight({
    @JsonKey(name: 'icon') required String iconName,
    required String title,
    required String description,
  }) = _ThinkingInsight;

  factory ThinkingInsight.fromJson(Map<String, dynamic> json) =>
      _$ThinkingInsightFromJson(json);
}

@freezed
abstract class ThinkingClosing with _$ThinkingClosing {
  const factory ThinkingClosing({
    required String title,
    required String description,
    required String quote,
  }) = _ThinkingClosing;

  factory ThinkingClosing.fromJson(Map<String, dynamic> json) =>
      _$ThinkingClosingFromJson(json);
}

@freezed
abstract class Thinking with _$Thinking {
  const factory Thinking({
    required String title,
    required String subtitle,
    required String period,
    required List<ThinkingStage> stages,
    required List<ThinkingEmotion> emotions,
    required String emotionNote,
    required String awarenessSectionLabel,
    required String awarenessSectionIcon,
    required int awarenessSectionColor,
    required List<ThinkingInsight> insights,
    required String insightSectionLabel,
    required String insightSectionIcon,
    required int insightSectionColor,
    required ThinkingClosing closing,
  }) = _Thinking;

  factory Thinking.fromJson(Map<String, dynamic> json) {
    final awareness = json['awarenessSection'] as Map<String, dynamic>;
    final insightSection = json['insightSection'] as Map<String, dynamic>;
    return Thinking(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      period: json['period'] as String,
      stages: (json['stages'] as List<dynamic>)
          .map((s) => ThinkingStage.fromJson(s as Map<String, dynamic>))
          .toList(),
      emotions: (json['emotions'] as List<dynamic>)
          .map((e) => ThinkingEmotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      emotionNote: json['emotionNote'] as String,
      awarenessSectionLabel: awareness['label'] as String,
      awarenessSectionIcon: awareness['icon'] as String,
      awarenessSectionColor: parseHexColor(awareness['color'] as String),
      insights: (json['insights'] as List<dynamic>)
          .map((i) => ThinkingInsight.fromJson(i as Map<String, dynamic>))
          .toList(),
      insightSectionLabel: insightSection['label'] as String,
      insightSectionIcon: insightSection['icon'] as String,
      insightSectionColor: parseHexColor(insightSection['color'] as String),
      closing:
          ThinkingClosing.fromJson(json['closing'] as Map<String, dynamic>),
    );
  }
}
