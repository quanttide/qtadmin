import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/app_state.dart';

void main() {
  group('AppState', () {
    test('AppInitial is initial state', () {
      const state = AppInitial();
      expect(state, isA<AppState>());
    });

    test('AppLoading is loading state', () {
      const state = AppLoading();
      expect(state, isA<AppState>());
    });

    test('AppError holds message', () {
      const state = AppError('错误信息');
      expect(state.message, '错误信息');
    });
  });

  group('AppStateNotifier', () {
    test('initial value is AppInitial', () {
      final notifier = ValueNotifier<AppState>(const AppInitial());
      expect(notifier.value, isA<AppInitial>());
      notifier.dispose();
    });
  });
}
