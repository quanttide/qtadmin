import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class HrThemeExtension extends ThemeExtension<HrThemeExtension> {
  const HrThemeExtension({
    required this.statusNew,
    required this.statusContacted,
    required this.statusExamSent,
    required this.statusExamReceived,
    required this.statusEvaluating,
    required this.statusInterview,
    required this.statusOffer,
    required this.statusClosed,
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.fontPageTitle,
    required this.fontSectionTitle,
    required this.fontBody,
    required this.fontCaption,
    required this.fontLabel,
  });

  final Color statusNew;
  final Color statusContacted;
  final Color statusExamSent;
  final Color statusExamReceived;
  final Color statusEvaluating;
  final Color statusInterview;
  final Color statusOffer;
  final Color statusClosed;
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double fontPageTitle;
  final double fontSectionTitle;
  final double fontBody;
  final double fontCaption;
  final double fontLabel;

  @override
  HrThemeExtension copyWith({
    Color? statusNew,
    Color? statusContacted,
    Color? statusExamSent,
    Color? statusExamReceived,
    Color? statusEvaluating,
    Color? statusInterview,
    Color? statusOffer,
    Color? statusClosed,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? fontPageTitle,
    double? fontSectionTitle,
    double? fontBody,
    double? fontCaption,
    double? fontLabel,
  }) {
    return HrThemeExtension(
      statusNew: statusNew ?? this.statusNew,
      statusContacted: statusContacted ?? this.statusContacted,
      statusExamSent: statusExamSent ?? this.statusExamSent,
      statusExamReceived: statusExamReceived ?? this.statusExamReceived,
      statusEvaluating: statusEvaluating ?? this.statusEvaluating,
      statusInterview: statusInterview ?? this.statusInterview,
      statusOffer: statusOffer ?? this.statusOffer,
      statusClosed: statusClosed ?? this.statusClosed,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      fontPageTitle: fontPageTitle ?? this.fontPageTitle,
      fontSectionTitle: fontSectionTitle ?? this.fontSectionTitle,
      fontBody: fontBody ?? this.fontBody,
      fontCaption: fontCaption ?? this.fontCaption,
      fontLabel: fontLabel ?? this.fontLabel,
    );
  }

  @override
  HrThemeExtension lerp(ThemeExtension<HrThemeExtension>? other, double t) {
    if (other is! HrThemeExtension) return this;
    return HrThemeExtension(
      statusNew: Color.lerp(statusNew, other.statusNew, t)!,
      statusContacted: Color.lerp(statusContacted, other.statusContacted, t)!,
      statusExamSent: Color.lerp(statusExamSent, other.statusExamSent, t)!,
      statusExamReceived: Color.lerp(statusExamReceived, other.statusExamReceived, t)!,
      statusEvaluating: Color.lerp(statusEvaluating, other.statusEvaluating, t)!,
      statusInterview: Color.lerp(statusInterview, other.statusInterview, t)!,
      statusOffer: Color.lerp(statusOffer, other.statusOffer, t)!,
      statusClosed: Color.lerp(statusClosed, other.statusClosed, t)!,
      spacingXs: lerpDouble(spacingXs, other.spacingXs, t)!,
      spacingSm: lerpDouble(spacingSm, other.spacingSm, t)!,
      spacingMd: lerpDouble(spacingMd, other.spacingMd, t)!,
      spacingLg: lerpDouble(spacingLg, other.spacingLg, t)!,
      fontPageTitle: lerpDouble(fontPageTitle, other.fontPageTitle, t)!,
      fontSectionTitle: lerpDouble(fontSectionTitle, other.fontSectionTitle, t)!,
      fontBody: lerpDouble(fontBody, other.fontBody, t)!,
      fontCaption: lerpDouble(fontCaption, other.fontCaption, t)!,
      fontLabel: lerpDouble(fontLabel, other.fontLabel, t)!,
    );
  }
}

ThemeData buildHrTheme() {
  const hrTheme = HrThemeExtension(
    statusNew: Color(0xFF6B7280),
    statusContacted: Color(0xFF3B82F6),
    statusExamSent: Color(0xFF6366F1),
    statusExamReceived: Color(0xFFA855F7),
    statusEvaluating: Color(0xFFEC4899),
    statusInterview: Color(0xFF10B981),
    statusOffer: Color(0xFF059669),
    statusClosed: Color(0xFF4B5563),
    spacingXs: 4.0,
    spacingSm: 8.0,
    spacingMd: 16.0,
    spacingLg: 24.0,
    fontPageTitle: 20.0,
    fontSectionTitle: 15.0,
    fontBody: 13.0,
    fontCaption: 11.0,
    fontLabel: 12.0,
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF94A3B8),
      secondary: Color(0xFF14B8A6),
      surface: Color(0xFF1E2A32),
    ),
    scaffoldBackgroundColor: const Color(0xFF141D24),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A2630),
      elevation: 0,
      titleTextStyle: TextStyle(color: Color(0xFFE2E8F0), fontSize: 18, fontWeight: FontWeight.w600),
      iconTheme: IconThemeData(color: Color(0xFF94A3B8)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1A2630),
      indicatorColor: const Color(0xFF334155),
      labelTextStyle: WidgetStatePropertyAll(const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E2A32),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    ),
    extensions: [hrTheme],
    useMaterial3: true,
  );
}

extension HrThemeContext on BuildContext {
  Color statusColor(String status) {
    final theme = Theme.of(this).extension<HrThemeExtension>()!;
    return switch (status) {
      'new' => theme.statusNew,
      'contacted' => theme.statusContacted,
      'exam_sent' => theme.statusExamSent,
      'exam_received' => theme.statusExamReceived,
      'evaluating' => theme.statusEvaluating,
      'interview' => theme.statusInterview,
      'offer' => theme.statusOffer,
      'closed' => theme.statusClosed,
      _ => theme.statusClosed,
    };
  }
}
