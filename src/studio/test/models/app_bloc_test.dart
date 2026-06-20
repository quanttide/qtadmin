import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/blocs/app_bloc.dart';

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

  group('AppBloc', () {
    test('initial state is AppInitial', () {
      final bloc = AppBloc();
      expect(bloc.state, isA<AppInitial>());
      bloc.close();
    });
  });
}
