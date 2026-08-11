import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/router.dart';

void main() {
  group('RouteConfig', () {
    test('all routes map is not empty', () {
      expect(RouteConfig.all.isNotEmpty, true);
    });

    test('find returns correct route', () {
      final route = RouteConfig.find('tasks');
      expect(route.id, 'tasks');
      expect(route.label, '任务');
    });

    test('find throws for unknown route', () {
      expect(() => RouteConfig.find('nonexistent'), throwsA(isA<StateError>()));
    });

    test('all routes have unique ids', () {
      final ids = RouteConfig.all.values.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every route belongs to a nav group', () {
      for (final route in RouteConfig.all.values) {
        expect(NavGroup.values.contains(route.group), true);
      }
    });
  });
}
