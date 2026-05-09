import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:data_sources/data_sources.dart';

sealed class DashboardEvent {}

class DashboardLoad extends DashboardEvent {}



final _founderDashLoader =
    DataLoader<Dashboard>(const FileSource(), 'data/founder/dashboard.json', Dashboard.fromJson);
final _companyDashLoader =
    DataLoader<Dashboard>(const FileSource(), 'data/company/dashboard.json', Dashboard.fromJson);

sealed class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final Dashboard founder;
  final Dashboard company;

  const DashboardLoaded({required this.founder, required this.company});

  Dashboard dashboard(String dir) =>
      dir == 'founder' ? founder : company;
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitial()) {
    on<DashboardLoad>(_onLoad);
  }

  Future<void> _onLoad(DashboardLoad event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    final results = await Future.wait([
      _founderDashLoader.load(),
      _companyDashLoader.load(),
    ]);

    for (final r in results) {
      if (r case DataError(:final message)) {
        emit(DashboardError(message));
        return;
      }
    }

    emit(DashboardLoaded(
      founder: (results[0] as DataSuccess<Dashboard>).data,
      company: (results[1] as DataSuccess<Dashboard>).data,
    ));
  }
}
