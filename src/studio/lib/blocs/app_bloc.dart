import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtadmin_studio/models/metadata.dart';
import 'package:qtadmin_qtconsult/qtconsult.dart';
import 'package:qtadmin_qtclass/qtclass.dart';
import 'package:qtadmin_think/thinking.dart';
import 'package:qtadmin_org/org.dart';
import 'package:data_sources/data_sources.dart';

final _source = const FileSource();

final _rootMetaLoader =
    DataLoader<RootMetadata>(_source, 'data/metadata.json', RootMetadata.fromJson);
final _founderMetaLoader =
    DataLoader<NavMetadata>(_source, 'data/founder/metadata.json', NavMetadata.fromJson);
final _companyMetaLoader =
    DataLoader<NavMetadata>(_source, 'data/company/metadata.json', NavMetadata.fromJson);
final _consultLoader =
    DataLoader<QtConsult>(_source, 'data/company/qtconsult.json', QtConsult.fromJson);
final _classLoader =
    DataLoader<QtClass>(_source, 'data/company/qtclass.json', QtClass.fromJson);
final _thinkingLoader =
    DataLoader<Thinking>(_source, 'data/founder/thinking.json', Thinking.fromJson);
final _orgLoader =
    DataLoader<OrgDashboard>(_source, 'data/company/org.json', OrgDashboard.fromJson);

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
  final QtConsult consultData;
  final QtClass classData;
  final Thinking thinkingData;
  final OrgDashboard orgData;

  const AppData({
    required this.workspaces,
    required this.sectionDefs,
    required this.navData,
    required this.consultData,
    required this.classData,
    required this.thinkingData,
    required this.orgData,
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
      _consultLoader.load(),
      _classLoader.load(),
      _thinkingLoader.load(),
      _orgLoader.load(),
    ]);

    for (final r in results) {
      if (r case DataError(:final message)) {
        emit(AppError(message));
        return;
      }
    }

    final root = (results[0] as DataSuccess<RootMetadata>).data;
    emit(AppLoaded(AppData(
      workspaces: root.workspaces,
      sectionDefs: {for (final s in root.sections) s.id: s},
      navData: {
        'founder': (results[1] as DataSuccess<NavMetadata>).data,
        'company': (results[2] as DataSuccess<NavMetadata>).data,
      },
      consultData: (results[3] as DataSuccess<QtConsult>).data,
      classData: (results[4] as DataSuccess<QtClass>).data,
      thinkingData: (results[5] as DataSuccess<Thinking>).data,
      orgData: (results[6] as DataSuccess<OrgDashboard>).data,
    )));
  }
}
