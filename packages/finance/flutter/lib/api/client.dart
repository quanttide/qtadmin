import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quanttide_finance/quanttide_finance.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class FinanceApiClient {
  FinanceApiClient(this.baseUrl, {http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  Future<List<SourceRecordDto>> listSourceRecords({
    int skip = 0,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$baseUrl/source-records').replace(
      queryParameters: {'skip': skip.toString(), 'limit': limit.toString()},
    );

    final response = await _http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to list source records',
        statusCode: response.statusCode,
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => SourceRecordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SourceRecordDto> getSourceRecord(int id) async {
    final uri = Uri.parse('$baseUrl/source-records/$id');
    final response = await _http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to get source record $id',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return SourceRecordDto.fromJson(data);
  }

  Future<List<NormalizedRecordDto>> listNormalizedRecords({
    int? sourceRecordId,
    int skip = 0,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };
    if (sourceRecordId != null) {
      params['source_record_id'] = sourceRecordId.toString();
    }

    final uri = Uri.parse(
      '$baseUrl/normalized-records',
    ).replace(queryParameters: params);

    final response = await _http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to list normalized records',
        statusCode: response.statusCode,
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => NormalizedRecordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NormalizedRecordDto> getNormalizedRecord(int id) async {
    final uri = Uri.parse('$baseUrl/normalized-records/$id');
    final response = await _http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to get normalized record $id',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return NormalizedRecordDto.fromJson(data);
  }

  Future<SourceRecordDto> createSourceRecord({
    required String sourceType,
    String? sourceChannel,
    String rawText = '',
    String ingestionStatus = 'pending',
  }) async {
    final body = <String, dynamic>{
      'source_type': sourceType,
      'raw_text': rawText,
      'ingestion_status': ingestionStatus,
    };
    if (sourceChannel != null) {
      body['source_channel'] = sourceChannel;
    }

    final response = await _http.post(
      Uri.parse('$baseUrl/source-records'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw ApiException(
        'Failed to create source record',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return SourceRecordDto.fromJson(data);
  }

  Future<List<NormalizedRecordDto>> normalizeSourceRecord(int id) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/source-records/$id/normalize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to normalize source record $id',
        statusCode: response.statusCode,
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => NormalizedRecordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ClassificationResultDto> createClassification(
    int normalizedRecordId, {
    required String category,
    required String classifierKind,
    String taxonomy = 'expense_type',
    double? confidence,
    String? modelVersion,
    Map<String, dynamic>? tags,
  }) async {
    final body = <String, dynamic>{
      'taxonomy': taxonomy,
      'category': category,
      'classifier_kind': classifierKind,
    };
    if (confidence != null) body['confidence'] = confidence;
    if (modelVersion != null) body['model_version'] = modelVersion;
    if (tags != null) body['tags'] = tags;

    final response = await _http.post(
      Uri.parse('$baseUrl/normalized-records/$normalizedRecordId/classifications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw ApiException(
        'Failed to create classification',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ClassificationResultDto.fromJson(data);
  }

  Future<List<ClassificationResultDto>> listClassifications(
    int normalizedRecordId, {
    String? reviewStatus,
  }) async {
    final params = <String, String>{};
    if (reviewStatus != null) {
      params['review_status'] = reviewStatus;
    }

    final uri = Uri.parse(
      '$baseUrl/normalized-records/$normalizedRecordId/classifications',
    ).replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await _http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to list classifications',
        statusCode: response.statusCode,
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) =>
            ClassificationResultDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ClassificationResultDto> reviewClassification(
    int id, {
    String? reviewStatus,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (reviewStatus != null) body['review_status'] = reviewStatus;
    if (isActive != null) body['is_active'] = isActive;

    final response = await _http.patch(
      Uri.parse('$baseUrl/classifications/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to review classification $id',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ClassificationResultDto.fromJson(data);
  }
}
