import 'package:flutter/services.dart' show rootBundle;
import 'base.dart';

class BundleSource extends DataSource {
  const BundleSource();

  @override
  Future<String> read(String path) => rootBundle.loadString(path);
}
