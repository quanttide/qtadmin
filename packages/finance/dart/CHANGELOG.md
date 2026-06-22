# CHANGELOG

## [0.2.0] - 2026-06-01

### Added

- SourceRecordDto — 原始记录 DTO（@JsonSerializable + @JsonKey snake_case）
- NormalizedRecordDto — 标准化记录 DTO（同上）
- 5 枚举 — SourceType, IngestionStatus, RecordType, Direction, NormalizationStatus（@JsonEnum + @JsonValue 显式映射 + unknown 兜底）
- 枚举 wire-value 对齐测试，与 doc/entities.md 值表一致

## [0.1.1] - 2026-05-29

### Fixed

- 添加 LICENSE 文件，满足 pub.dev 发布要求

## [0.1.0] - 2026-05-29

### Added

- Journal — 日记账实体（id, name, createdAt）
- JournalEntry — 凭证实体（id, journalId, createdAt, description, lines）
- JournalEntryLine — 分录行（id, type, amount, description, createdAt），支持多行
- LineType 枚举（debit / credit）
- 基于 freezed 的不可变模型，支持 copyWith 与 JSON 序列化
