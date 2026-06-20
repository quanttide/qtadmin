import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtadmin_qtconsult/qtconsult.dart';

sealed class ConsultEvent {}

class ConfirmDiscovery extends ConsultEvent {
  final String id;
  ConfirmDiscovery(this.id);
}

class DismissDiscovery extends ConsultEvent {
  final String id;
  DismissDiscovery(this.id);
}

class AddDiscovery extends ConsultEvent {
  final String text;
  final DiscoveryType type;
  final String source;
  final String date;
  AddDiscovery({
    required this.text,
    required this.type,
    required this.source,
    required this.date,
  });
}

class ReviewRevision extends ConsultEvent {
  final String id;
  ReviewRevision(this.id);
}

class DeleteDiscovery extends ConsultEvent {
  final String id;
  DeleteDiscovery(this.id);
}

class ConsultState {
  final QtConsult data;
  const ConsultState({required this.data});
}

class ConsultBloc extends Bloc<ConsultEvent, ConsultState> {
  ConsultBloc(super.initialState) {
    on<ConfirmDiscovery>(_onConfirm);
    on<DismissDiscovery>(_onDismiss);
    on<AddDiscovery>(_onAdd);
    on<ReviewRevision>(_onReview);
    on<DeleteDiscovery>(_onDelete);
  }

  void _onConfirm(ConfirmDiscovery event, Emitter<ConsultState> emit) {
    final discoveries = state.data.discoveries.map((d) {
      if (d.id == event.id) return d.copyWith(status: DiscoveryStatus.confirmed);
      return d;
    }).toList();
    emit(ConsultState(data: state.data.copyWith(discoveries: discoveries)));
  }

  void _onDismiss(DismissDiscovery event, Emitter<ConsultState> emit) {
    final discoveries = state.data.discoveries.map((d) {
      if (d.id == event.id) return d.copyWith(status: DiscoveryStatus.dismissed);
      return d;
    }).toList();
    emit(ConsultState(data: state.data.copyWith(discoveries: discoveries)));
  }

  void _onAdd(AddDiscovery event, Emitter<ConsultState> emit) {
    final discovery = Discovery(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.text,
      type: event.type,
      source: event.source,
      date: event.date,
    );
    final discoveries = [...state.data.discoveries, discovery];
    emit(ConsultState(data: state.data.copyWith(discoveries: discoveries)));
  }

  void _onReview(ReviewRevision event, Emitter<ConsultState> emit) {
    final revisions = state.data.revisions.map((r) {
      if (r.id == event.id) return r.copyWith(isReviewed: true);
      return r;
    }).toList();
    emit(ConsultState(data: state.data.copyWith(revisions: revisions)));
  }

  void _onDelete(DeleteDiscovery event, Emitter<ConsultState> emit) {
    final discoveries =
        state.data.discoveries.where((d) => d.id != event.id).toList();
    final revisions = state.data.revisions
        .where((r) => r.relatedDiscoveryId != event.id)
        .toList();
    emit(ConsultState(
        data: state.data.copyWith(
            discoveries: discoveries, revisions: revisions)));
  }
}
