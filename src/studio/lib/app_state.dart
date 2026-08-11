import 'package:flutter/widgets.dart';
import 'package:qtadmin_studio/data_sources/data_sources.dart';
import 'package:qtadmin_studio/models/org.dart';
import 'package:qtadmin_studio/models/human.dart';

final _source = const FileSource();

final _orgLoader = DataLoader<OrgDashboard>(
  _source,
  'data/company/org.json',
  OrgDashboard.fromJson,
);
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
  final OrgDashboard orgData;
  final RecruitmentPlan? recruitmentData;

  const AppData({required this.orgData, this.recruitmentData});
}

Future<void> loadAppData(ValueNotifier<AppState> state) async {
  state.value = const AppLoading();
  final results = await Future.wait([
    _orgLoader.load(),
    _recruitmentLoader.load(),
  ]);

  for (final r in results) {
    if (r case DataError(:final message)) {
      state.value = AppError(message);
      return;
    }
  }

  final recruitmentResult = results[1] as DataResult<RecruitmentPlan>;
  state.value = AppLoaded(
    AppData(
      orgData: (results[0] as DataSuccess<OrgDashboard>).data,
      recruitmentData: switch (recruitmentResult) {
        DataSuccess(:final data) => data,
        DataError() => null,
      },
    ),
  );
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
