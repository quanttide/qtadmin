// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thinking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThinkingEmotion _$ThinkingEmotionFromJson(Map<String, dynamic> json) =>
    _ThinkingEmotion(
      label: json['label'] as String,
      value: json['value'] as String,
      colorValue: parseHexColor(json['color'] as String),
    );

Map<String, dynamic> _$ThinkingEmotionToJson(_ThinkingEmotion instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      'color': instance.colorValue,
    };

_ThinkingStage _$ThinkingStageFromJson(Map<String, dynamic> json) =>
    _ThinkingStage(
      iconName: json['icon'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      points: (json['points'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      colorValue: parseHexColor(json['color'] as String),
    );

Map<String, dynamic> _$ThinkingStageToJson(_ThinkingStage instance) =>
    <String, dynamic>{
      'icon': instance.iconName,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'points': instance.points,
      'color': instance.colorValue,
    };

_ThinkingInsight _$ThinkingInsightFromJson(Map<String, dynamic> json) =>
    _ThinkingInsight(
      iconName: json['icon'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$ThinkingInsightToJson(_ThinkingInsight instance) =>
    <String, dynamic>{
      'icon': instance.iconName,
      'title': instance.title,
      'description': instance.description,
    };

_ThinkingClosing _$ThinkingClosingFromJson(Map<String, dynamic> json) =>
    _ThinkingClosing(
      title: json['title'] as String,
      description: json['description'] as String,
      quote: json['quote'] as String,
    );

Map<String, dynamic> _$ThinkingClosingToJson(_ThinkingClosing instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'quote': instance.quote,
    };
