import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThinkingEmotion {
  final String label;
  final String value;
  final int colorValue;

  const ThinkingEmotion({
    required this.label,
    required this.value,
    required this.colorValue,
  });

  factory ThinkingEmotion.fromJson(Map<String, dynamic> json) {
    return ThinkingEmotion(
      label: json['label'] as String,
      value: json['value'] as String,
      colorValue: parseHexColor(json['color'] as String),
    );
  }

  Color get color => Color(colorValue);
}

class ThinkingStage {
  final String iconName;
  final String title;
  final String subtitle;
  final List<String> points;
  final int colorValue;

  const ThinkingStage({
    required this.iconName,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.colorValue,
  });

  factory ThinkingStage.fromJson(Map<String, dynamic> json) {
    return ThinkingStage(
      iconName: json['icon'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      points: (json['points'] as List<dynamic>).cast<String>(),
      colorValue: parseHexColor(json['color'] as String),
    );
  }

  Color get color => Color(colorValue);
}

class ThinkingInsight {
  final String iconName;
  final String title;
  final String description;

  const ThinkingInsight({
    required this.iconName,
    required this.title,
    required this.description,
  });

  factory ThinkingInsight.fromJson(Map<String, dynamic> json) {
    return ThinkingInsight(
      iconName: json['icon'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class ThinkingClosing {
  final String title;
  final String description;
  final String quote;

  const ThinkingClosing({
    required this.title,
    required this.description,
    required this.quote,
  });

  factory ThinkingClosing.fromJson(Map<String, dynamic> json) {
    return ThinkingClosing(
      title: json['title'] as String,
      description: json['description'] as String,
      quote: json['quote'] as String,
    );
  }
}

class ThinkingData {
  final String title;
  final String subtitle;
  final String period;
  final List<ThinkingStage> stages;
  final List<ThinkingEmotion> emotions;
  final String emotionNote;
  final String awarenessSectionLabel;
  final String awarenessSectionIcon;
  final int awarenessSectionColor;
  final List<ThinkingInsight> insights;
  final String insightSectionLabel;
  final String insightSectionIcon;
  final int insightSectionColor;
  final ThinkingClosing closing;

  const ThinkingData({
    required this.title,
    required this.subtitle,
    required this.period,
    required this.stages,
    required this.emotions,
    required this.emotionNote,
    required this.awarenessSectionLabel,
    required this.awarenessSectionIcon,
    required this.awarenessSectionColor,
    required this.insights,
    required this.insightSectionLabel,
    required this.insightSectionIcon,
    required this.insightSectionColor,
    required this.closing,
  });

  factory ThinkingData.fromJson(Map<String, dynamic> json) {
    final awareness = json['awarenessSection'] as Map<String, dynamic>;
    final insightSection = json['insightSection'] as Map<String, dynamic>;
    return ThinkingData(
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
      closing: ThinkingClosing.fromJson(json['closing'] as Map<String, dynamic>),
    );
  }
}



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
