import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum SourceType {
  @JsonValue('image')
  image,
  @JsonValue('chat')
  chat,
  @JsonValue('form')
  form,
  @JsonValue('csv_row')
  csvRow,
  @JsonValue('bank_tx')
  bankTx,
  @JsonValue('api')
  api,
  @JsonValue('manual')
  manual,
  @JsonValue('other')
  other,

  /// Fallback for unrecognized wire values — triggered by @JsonKey(unknownEnumValue:)
  /// on DTO fields, not directly from this enum.
  @JsonValue('__unknown__')
  unknown,
}

@JsonEnum()
enum IngestionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('parsed')
  parsed,
  @JsonValue('reviewed')
  reviewed,
  @JsonValue('failed')
  failed,
  @JsonValue('__unknown__')
  unknown,
}

@JsonEnum()
enum RecordType {
  @JsonValue('expense')
  expense,
  @JsonValue('income')
  income,
  @JsonValue('transfer')
  transfer,
  @JsonValue('reimbursement')
  reimbursement,
  @JsonValue('other')
  other,
  @JsonValue('__unknown__')
  unknown,
}

@JsonEnum()
enum Direction {
  @JsonValue('outflow')
  outflow,
  @JsonValue('inflow')
  inflow,
  @JsonValue('__unknown__')
  unknown,
}

@JsonEnum()
enum NormalizationStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('normalized')
  normalized,
  @JsonValue('reviewed')
  reviewed,
  @JsonValue('merged')
  merged,
  @JsonValue('__unknown__')
  unknown,
}

@JsonEnum()
enum ClassifierKind {
  @JsonValue('ai')
  ai,
  @JsonValue('rule')
  rule,
  @JsonValue('manual')
  manual,
  @JsonValue('__unknown__')
  unknown,
}

@JsonEnum()
enum ReviewStatus {
  @JsonValue('candidate')
  candidate,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
  @JsonValue('__unknown__')
  unknown,
}
