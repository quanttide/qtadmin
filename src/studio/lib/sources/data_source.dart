abstract class DataSource {
  const DataSource();
  Future<String> read(String path);
}
