import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qtadmin_studio/models/qtconsult.dart';

class FixtureConfig {
  static String get _basePath {
    const envKey = 'QTADMIN_FIXTURES_PATH';
    final path = dotenv.env[envKey];
    if (path == null || path.isEmpty) {
      throw StateError(
        '环境变量 $envKey 未设置。\n'
        '请在 .env 文件中设置: $envKey=<fixtures 目录绝对路径>',
      );
    }
    return path;
  }

  static String get rootMetadataPath => '$_basePath/metadata.json';

  static String metadataPath(String dir) => '$_basePath/$dir/metadata.json';

  static String dashboardPath(TenantType tenant) {
    switch (tenant) {
      case TenantType.internal:
        return '$_basePath/founder/dashboard.json';
      case TenantType.customer:
        return '$_basePath/company/dashboard.json';
    }
  }

  static String get qtclassPath => '$_basePath/company/qtclass.json';

  static String get thinkingPath => '$_basePath/founder/thinking.json';

  static String qtconsultPath(TenantType tenant) {
    switch (tenant) {
      case TenantType.customer:
        return '$_basePath/company/qtconsult.json';
      case TenantType.internal:
        return '$_basePath/founder/qtconsult.json';
    }
  }
}
