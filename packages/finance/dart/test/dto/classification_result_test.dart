import 'package:test/test.dart';
import 'package:quanttide_finance/quanttide_finance.dart';

void main() {
  group('ClassificationResultDto fromJson round-trip', () {
    test('parses full response', () {
      final json = {
        'id': 1,
        'normalized_record_id': 42,
        'taxonomy': 'expense_type',
        'category': 'office_supplies',
        'tags': {'brand': 'Staples'},
        'classifier_kind': 'ai',
        'confidence': 0.95,
        'model_version': 'gpt-4o-2026-05-01',
        'review_status': 'candidate',
        'is_active': true,
        'created_at': '2026-06-01T12:00:00Z',
        'updated_at': '2026-06-01T12:30:00Z',
      };

      final dto = ClassificationResultDto.fromJson(json);
      expect(dto.id, 1);
      expect(dto.normalizedRecordId, 42);
      expect(dto.taxonomy, 'expense_type');
      expect(dto.category, 'office_supplies');
      expect(dto.tags, {'brand': 'Staples'});
      expect(dto.classifierKind, ClassifierKind.ai);
      expect(dto.confidence, 0.95);
      expect(dto.modelVersion, 'gpt-4o-2026-05-01');
      expect(dto.reviewStatus, ReviewStatus.candidate);
      expect(dto.isActive, true);
    });

    test('toJson uses snake_case keys', () {
      final dto = ClassificationResultDto(
        id: 1,
        normalizedRecordId: 42,
        taxonomy: 'expense_type',
        category: 'office_supplies',
        classifierKind: ClassifierKind.manual,
        reviewStatus: ReviewStatus.accepted,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final json = dto.toJson();
      expect(json['normalized_record_id'], 42);
      expect(json['classifier_kind'], 'manual');
      expect(json['review_status'], 'accepted');
      expect(json['is_active'], true);
      expect(json['created_at'], isA<String>());
      expect(json['updated_at'], isA<String>());
    });

    test('round-trip preserves all fields', () {
      final original = ClassificationResultDto(
        id: 1,
        normalizedRecordId: 42,
        taxonomy: 'expense_type',
        category: 'office_supplies',
        tags: {'brand': 'Staples'},
        classifierKind: ClassifierKind.ai,
        confidence: 0.95,
        modelVersion: 'gpt-4o-2026-05-01',
        reviewStatus: ReviewStatus.candidate,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1, 0, 30),
      );

      final json = original.toJson();
      final restored = ClassificationResultDto.fromJson(json);
      expect(restored, original);
    });
  });

  group('ClassificationResultDto defaults', () {
    test('review_status defaults to candidate', () {
      const json = {
        'id': 1,
        'normalized_record_id': 1,
        'taxonomy': 'expense_type',
        'category': 'office_supplies',
        'classifier_kind': 'manual',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      };
      final dto = ClassificationResultDto.fromJson(json);
      expect(dto.reviewStatus, ReviewStatus.candidate);
      expect(dto.isActive, true);
    });

    test('unknown enum values fall back to unknown', () {
      const json = {
        'id': 1,
        'normalized_record_id': 1,
        'taxonomy': 'expense_type',
        'category': 'office_supplies',
        'classifier_kind': 'unknown_classifier',
        'review_status': 'unknown_status',
        'is_active': true,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      };
      final dto = ClassificationResultDto.fromJson(json);
      expect(dto.classifierKind, ClassifierKind.unknown);
      expect(dto.reviewStatus, ReviewStatus.unknown);
    });
  });

  group('ClassificationResultDto copyWith', () {
    test('copies with modified fields', () {
      final dto = ClassificationResultDto(
        id: 1,
        normalizedRecordId: 42,
        taxonomy: 'expense_type',
        category: 'office_supplies',
        classifierKind: ClassifierKind.ai,
        reviewStatus: ReviewStatus.candidate,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final updated = dto.copyWith(
        reviewStatus: ReviewStatus.accepted,
        isActive: false,
      );
      expect(updated.reviewStatus, ReviewStatus.accepted);
      expect(updated.isActive, false);
      expect(updated.id, 1); // unchanged
    });
  });
}
