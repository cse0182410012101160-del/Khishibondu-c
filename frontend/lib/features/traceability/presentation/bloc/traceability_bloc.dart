import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agro_bridge/features/traceability/domain/entities/traceability_entity.dart';
import 'package:agro_bridge/features/traceability/domain/repositories/traceability_repository.dart';

// Events
abstract class TraceabilityEvent extends Equatable {
  const TraceabilityEvent();
  @override
  List<Object?> get props => [];
}

class FetchTraceabilityEvent extends TraceabilityEvent {
  final String batchQrCode;
  const FetchTraceabilityEvent(this.batchQrCode);
  @override
  List<Object?> get props => [batchQrCode];
}

// States
abstract class TraceabilityState extends Equatable {
  const TraceabilityState();
  @override
  List<Object?> get props => [];
}

class TraceabilityInitial extends TraceabilityState {}

class TraceabilityLoading extends TraceabilityState {}

class TraceabilityLoadedState extends TraceabilityState {
  final TraceabilityEntity provenance;
  const TraceabilityLoadedState(this.provenance);
  @override
  List<Object?> get props => [provenance];
}

class TraceabilityErrorState extends TraceabilityState {
  final String message;
  const TraceabilityErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class TraceabilityBloc extends Bloc<TraceabilityEvent, TraceabilityState> {
  final TraceabilityRepository _repository;

  TraceabilityBloc(this._repository) : super(TraceabilityInitial()) {
    on<FetchTraceabilityEvent>(_onFetchTraceability);
  }

  Future<void> _onFetchTraceability(FetchTraceabilityEvent event, Emitter<TraceabilityState> emit) async {
    emit(TraceabilityLoading());
    try {
      final res = await _repository.getTraceability(event.batchQrCode);
      emit(TraceabilityLoadedState(res));
    } catch (e) {
      emit(TraceabilityErrorState(e.toString()));
    }
  }
}
