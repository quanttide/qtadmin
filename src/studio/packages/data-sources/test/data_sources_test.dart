import 'package:data_sources/data_sources.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockSource extends DataSource {
  final String? data;
  final bool shouldThrow;
  const _MockSource([this.data, this.shouldThrow = false]);

  @override
  Future<String> read(String path) async {
    if (shouldThrow) throw Exception('read error');
    if (data != null) return data!;
    throw Exception('file not found: $path');
  }
}

void main() {
  group('DataResult', () {
    test('DataSuccess holds data', () {
      const result = DataSuccess(42);
      expect(result, isA<DataResult<int>>());
      expect(result.data, 42);
    });

    test('DataError holds message', () {
      const DataResult<int> result = DataError('something went wrong');
      expect(result, isA<DataResult<int>>());
      expect((result as DataError).message, 'something went wrong');
    });

    test('sealed class pattern works with switch', () {
      DataResult<String> result = const DataSuccess('ok');
      final output = switch (result) {
        DataSuccess(:final data) => data,
        DataError(:final message) => 'error: $message',
      };
      expect(output, 'ok');

      result = const DataError('fail');
      final output2 = switch (result) {
        DataSuccess(:final data) => data,
        DataError(:final message) => 'error: $message',
      };
      expect(output2, 'error: fail');
    });
  });

  group('DataLoader', () {
    test('load returns DataSuccess when source succeeds', () async {
      final source = _MockSource('{"value": 1}');
      final loader = DataLoader<_TestModel>(source, 'test.json', _TestModel.fromJson);

      final result = await loader.load();

      expect(result, isA<DataSuccess<_TestModel>>());
      expect((result as DataSuccess).data.value, 1);
    });

    test('load returns DataError when source throws', () async {
      final source = _MockSource(null);
      final loader = DataLoader<_TestModel>(source, 'missing.json', _TestModel.fromJson);

      final result = await loader.load();

      expect(result, isA<DataError<_TestModel>>());
      expect((result as DataError).message, contains('file not found'));
    });

    test('load returns DataError when JSON parse fails', () async {
      final source = _MockSource('{invalid json}');
      final loader = DataLoader<_TestModel>(source, 'bad.json', _TestModel.fromJson);

      final result = await loader.load();

      expect(result, isA<DataError<_TestModel>>());
    });

    test('inject bypasses source', () async {
      final source = _MockSource('{"value": 999}', true);
      final loader = DataLoader<_TestModel>(source, 'test.json', _TestModel.fromJson);
      loader.inject(const _TestModel(value: 42));

      final result = await loader.load();

      expect(result, isA<DataSuccess<_TestModel>>());
      expect((result as DataSuccess).data.value, 42);
    });

    test('load caches result and does not re-read source', () async {
      int readCount = 0;
      final source = _TestSource(() {
        readCount++;
        return '{"value": $readCount}';
      });
      final loader = DataLoader<_TestModel>(source, 'test.json', _TestModel.fromJson);

      await loader.load();
      await loader.load();
      await loader.load();

      expect(readCount, 1);
    });

    test('clearCache forces re-read from source', () async {
      int readCount = 0;
      final source = _TestSource(() {
        readCount++;
        return '{"value": $readCount}';
      });
      final loader = DataLoader<_TestModel>(source, 'test.json', _TestModel.fromJson);

      await loader.load();
      loader.clearCache();
      await loader.load();

      expect(readCount, 2);
    });
  });
}

class _TestModel {
  final int value;
  const _TestModel({required this.value});

  factory _TestModel.fromJson(Map<String, dynamic> json) =>
      _TestModel(value: json['value'] as int);
}

class _TestSource extends DataSource {
  final String Function() _factory;
  _TestSource(this._factory);

  @override
  Future<String> read(String path) async => _factory();
}
