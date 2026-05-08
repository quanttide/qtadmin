import 'dart:io' show File;
import 'data_source.dart';

class FileSource extends DataSource {
  const FileSource();

  @override
  Future<String> read(String path) => File(path).readAsString();
}
