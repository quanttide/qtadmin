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
