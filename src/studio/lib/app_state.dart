import 'package:flutter/widgets.dart';
import 'package:qtadmin_studio/data_sources/data_sources.dart';
import 'package:qtadmin_studio/models/human.dart';

final _source = const FileSource();

final _recruitmentLoader = DataLoader<RecruitmentPlan>(
  _source,
  'data/recruitment.json',
  RecruitmentPlan.fromJson,
);

// States

sealed class AppState {
  const AppState();
}

class AppInitial extends AppState {
  const AppInitial();
}

class AppLoading extends AppState {
  const AppLoading();
}

class AppLoaded extends AppState {
  final AppData data;
  const AppLoaded(this.data);
}

class AppError extends AppState {
  final String message;
  const AppError(this.message);
}

class AppData {
  final RecruitmentPlan? recruitmentData;

  const AppData({this.recruitmentData});
}

Future<void> loadAppData(ValueNotifier<AppState> state) async {
  state.value = const AppLoading();
  final recruitmentResult = await _recruitmentLoader.load();

  state.value = switch (recruitmentResult) {
    DataSuccess(:final data) => AppLoaded(AppData(recruitmentData: data)),
    DataError(:final message) => AppError(message),
  };
}

/// 供路由层读取已加载数据，状态变化时重建依赖方。
class AppStateScope extends InheritedNotifier<ValueNotifier<AppState>> {
  const AppStateScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    final state = scope!.notifier!.value;
    return switch (state) {
      AppLoaded(:final data) => data,
      _ => throw StateError('AppStateScope 在非 AppLoaded 状态读取数据'),
    };
  }
}
