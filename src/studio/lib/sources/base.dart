import 'dart:convert';

sealed class DataResult<T> {
  const DataResult();
}

class DataSuccess<T> extends DataResult<T> {
  final T data;
  const DataSuccess(this.data);
}

class DataError<T> extends DataResult<T> {
  final String message;
  const DataError(this.message);
}

abstract class DataSource {
  const DataSource();
  Future<String> read(String path);
}

class DataLoader<T extends Object> {
  final DataSource source;
  final String path;
  final T Function(Map<String, dynamic>) fromJson;
  T? _cached;
  T? _injected;

  DataLoader(this.source, this.path, this.fromJson);

  Future<DataResult<T>> load() async {
    if (_injected != null) return DataSuccess(_injected!);
    if (_cached != null) return DataSuccess(_cached!);
    try {
      final jsonStr = await source.read(path);
      final data = fromJson(json.decode(jsonStr) as Map<String, dynamic>);
      _cached = data;
      return DataSuccess(data);
    } catch (e) {
      return DataError('$e');
    }
  }

  void inject(T data) => _injected = data;
  void clearCache() { _cached = null; _injected = null; }
}
