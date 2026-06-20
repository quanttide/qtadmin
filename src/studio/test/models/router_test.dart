import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/router.dart';

void main() {
  group('RouteConfig', () {
    test('all routes map is not empty', () {
      expect(RouteConfig.all.isNotEmpty, true);
    });

    test('find returns correct route', () {
      final route = RouteConfig.find('dashboard');
      expect(route.id, 'dashboard');
      expect(route.label, '仪表盘');
    });

    test('find throws for unknown route', () {
      expect(
        () => RouteConfig.find('nonexistent'),
        throwsA(isA<StateError>()),
      );
    });

    test('all routes have unique ids', () {
      final ids = RouteConfig.all.values.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('recruitment route is registered', () {
      final route = RouteConfig.find('recruitment');
      expect(route.id, 'recruitment');
      expect(route.label, '招聘计划');
    });
  });
}
