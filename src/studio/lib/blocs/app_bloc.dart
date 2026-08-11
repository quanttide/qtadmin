import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtadmin_studio/models/metadata.dart';
import 'package:qtadmin_studio/models/org.dart';
import 'package:qtadmin_studio/models/recruitment.dart';
import 'package:qtadmin_studio/data_sources/data_sources.dart';

final _source = const FileSource();

final _rootMetaLoader = DataLoader<RootMetadata>(
  _source,
  'data/metadata.json',
  RootMetadata.fromJson,
);
final _founderMetaLoader = DataLoader<NavMetadata>(
  _source,
  'data/founder/metadata.json',
  NavMetadata.fromJson,
);
final _companyMetaLoader = DataLoader<NavMetadata>(
  _source,
  'data/company/metadata.json',
  NavMetadata.fromJson,
);
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

// Events

sealed class AppEvent {}

class AppLoad extends AppEvent {}

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
  final List<WorkspaceInfo> workspaces;
  final Map<String, SectionDef> sectionDefs;
  final Map<String, NavMetadata> navData;
  final OrgDashboard orgData;
  final RecruitmentPlan? recruitmentData;

  const AppData({
    required this.workspaces,
    required this.sectionDefs,
    required this.navData,
    required this.orgData,
    this.recruitmentData,
  });
}

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppInitial()) {
    on<AppLoad>(_onLoad);
  }

  Future<void> _onLoad(AppLoad event, Emitter<AppState> emit) async {
    emit(const AppLoading());
    final results = await Future.wait([
      _rootMetaLoader.load(),
      _founderMetaLoader.load(),
      _companyMetaLoader.load(),
      _orgLoader.load(),
      _recruitmentLoader.load(),
    ]);

    for (final r in results) {
      if (r case DataError(:final message)) {
        emit(AppError(message));
        return;
      }
    }

    final root = (results[0] as DataSuccess<RootMetadata>).data;
    final recruitmentResult = results[4] as DataResult<RecruitmentPlan>;
    emit(
      AppLoaded(
        AppData(
          workspaces: root.workspaces,
          sectionDefs: {for (final s in root.sections) s.id: s},
          navData: {
            'founder': (results[1] as DataSuccess<NavMetadata>).data,
            'company': (results[2] as DataSuccess<NavMetadata>).data,
          },
          orgData: (results[3] as DataSuccess<OrgDashboard>).data,
          recruitmentData: switch (recruitmentResult) {
            DataSuccess(:final data) => data,
            DataError() => null,
          },
        ),
      ),
    );
  }
}
