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
      queryParameters: {
        'skip': skip.toString(),
        'limit': limit.toString(),
      },
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
        .map((e) =>
            SourceRecordDto.fromJson(e as Map<String, dynamic>))
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

    final uri =
        Uri.parse('$baseUrl/normalized-records')
            .replace(queryParameters: params);

    final response = await _http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to list normalized records',
        statusCode: response.statusCode,
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) =>
            NormalizedRecordDto.fromJson(e as Map<String, dynamic>))
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
}
