// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'normalized_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NormalizedRecordDtoImpl _$$NormalizedRecordDtoImplFromJson(
  Map<String, dynamic> json,
) => _$NormalizedRecordDtoImpl(
  id: (json['id'] as num).toInt(),
  recordType: $enumDecode(
    _$RecordTypeEnumMap,
    json['record_type'],
    unknownValue: RecordType.unknown,
  ),
  businessDate: json['business_date'] as String? ?? '',
  amountCents: (json['amount_cents'] as num?)?.toInt() ?? 0,
  direction: $enumDecode(
    _$DirectionEnumMap,
    json['direction'],
    unknownValue: Direction.unknown,
  ),
  department: json['department'] as String?,
  person: json['person'] as String?,
  description: json['description'] as String? ?? '',
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$NormalizedRecordDtoImplToJson(
  _$NormalizedRecordDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'record_type': _$RecordTypeEnumMap[instance.recordType]!,
  'business_date': instance.businessDate,
  'amount_cents': instance.amountCents,
  'direction': _$DirectionEnumMap[instance.direction]!,
  'department': instance.department,
  'person': instance.person,
  'description': instance.description,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$RecordTypeEnumMap = {
  RecordType.expense: 'expense',
  RecordType.income: 'income',
  RecordType.transfer: 'transfer',
  RecordType.reimbursement: 'reimbursement',
  RecordType.other: 'other',
  RecordType.unknown: '__unknown__',
};

const _$DirectionEnumMap = {
  Direction.outflow: 'outflow',
  Direction.inflow: 'inflow',
  Direction.unknown: '__unknown__',
};
