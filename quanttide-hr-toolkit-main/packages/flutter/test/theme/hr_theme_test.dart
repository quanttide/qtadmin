import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanttide_hr_kanban/theme/hr_theme.dart';

void main() {
  group('HrThemeExtension', () {
    test('has status colors for all 8 talent statuses', () {
      const theme = HrThemeExtension(
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

      expect(theme.statusNew, const Color(0xFF6B7280));
      expect(theme.statusContacted, const Color(0xFF3B82F6));
      expect(theme.statusExamSent, const Color(0xFF6366F1));
      expect(theme.statusExamReceived, const Color(0xFFA855F7));
      expect(theme.statusEvaluating, const Color(0xFFEC4899));
      expect(theme.statusInterview, const Color(0xFF10B981));
      expect(theme.statusOffer, const Color(0xFF059669));
      expect(theme.statusClosed, const Color(0xFF4B5563));
    });

    test('buildHrTheme returns ThemeData with HrThemeExtension', () {
      final theme = buildHrTheme();
      final ext = theme.extension<HrThemeExtension>();
      expect(ext, isNotNull);
      expect(ext!.statusNew, const Color(0xFF6B7280));
    });

    test('all status color lookups by name succeed', () {
      final theme = buildHrTheme();
      final ext = theme.extension<HrThemeExtension>()!;
      final statuses = <String, Color Function(HrThemeExtension)>{
        'new': (e) => e.statusNew,
        'contacted': (e) => e.statusContacted,
        'exam_sent': (e) => e.statusExamSent,
        'exam_received': (e) => e.statusExamReceived,
        'evaluating': (e) => e.statusEvaluating,
        'interview': (e) => e.statusInterview,
        'offer': (e) => e.statusOffer,
        'closed': (e) => e.statusClosed,
      };
      for (final entry in statuses.entries) {
        expect(() => entry.value(ext), returnsNormally,
            reason: 'Status "${entry.key}" should have a color');
      }
    });
  });
}
