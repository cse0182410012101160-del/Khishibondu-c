import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agro_bridge/features/escrow/domain/entities/escrow_entity.dart';
import 'package:agro_bridge/features/escrow/domain/repositories/escrow_repository.dart';

// Events
abstract class EscrowEvent extends Equatable {
  const EscrowEvent();
  @override
  List<Object?> get props => [];
}

class FundEscrowEvent extends EscrowEvent {
  final Map<String, dynamic> data;
  const FundEscrowEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class ReleaseEscrowEvent extends EscrowEvent {
  final String escrowId;
  const ReleaseEscrowEvent(this.escrowId);
  @override
  List<Object?> get props => [escrowId];
}

class RaiseDisputeEvent extends EscrowEvent {
  final Map<String, dynamic> data;
  const RaiseDisputeEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class FetchDisputesEvent extends EscrowEvent {}

class ResolveDisputeEvent extends EscrowEvent {
  final String disputeId;
  final String decision;
  final String? adminNotes;
  const ResolveDisputeEvent(this.disputeId, this.decision, {this.adminNotes});
  @override
  List<Object?> get props => [disputeId, decision, adminNotes];
}

// States
abstract class EscrowState extends Equatable {
  const EscrowState();
  @override
  List<Object?> get props => [];
}

class EscrowInitial extends EscrowState {}

class EscrowLoading extends EscrowState {}

class EscrowFundedSuccessState extends EscrowState {
  final Map<String, dynamic> data;
  const EscrowFundedSuccessState(this.data);
  @override
  List<Object?> get props => [data];
}

class DisputeRaisedSuccessState extends EscrowState {
  final DisputeEntity dispute;
  const DisputeRaisedSuccessState(this.dispute);
  @override
  List<Object?> get props => [dispute];
}

class DisputesLoadedState extends EscrowState {
  final List<DisputeEntity> disputes;
  const DisputesLoadedState(this.disputes);
  @override
  List<Object?> get props => [disputes];
}

class DisputeResolvedSuccessState extends EscrowState {
  final Map<String, dynamic> data;
  const DisputeResolvedSuccessState(this.data);
  @override
  List<Object?> get props => [data];
}

class EscrowErrorState extends EscrowState {
  final String message;
  const EscrowErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class EscrowBloc extends Bloc<EscrowEvent, EscrowState> {
  final EscrowRepository _repository;

  EscrowBloc(this._repository) : super(EscrowInitial()) {
    on<FundEscrowEvent>(_onFundEscrow);
    on<ReleaseEscrowEvent>(_onReleaseEscrow);
    on<RaiseDisputeEvent>(_onRaiseDispute);
    on<FetchDisputesEvent>(_onFetchDisputes);
    on<ResolveDisputeEvent>(_onResolveDispute);
  }

  Future<void> _onFundEscrow(FundEscrowEvent event, Emitter<EscrowState> emit) async {
    emit(EscrowLoading());
    try {
      final res = await _repository.fundEscrow(event.data);
      emit(EscrowFundedSuccessState(res));
    } catch (e) {
      emit(EscrowErrorState(e.toString()));
    }
  }

  Future<void> _onReleaseEscrow(ReleaseEscrowEvent event, Emitter<EscrowState> emit) async {
    emit(EscrowLoading());
    try {
      final res = await _repository.releaseEscrow(event.escrowId);
      emit(EscrowFundedSuccessState(res));
    } catch (e) {
      emit(EscrowErrorState(e.toString()));
    }
  }

  Future<void> _onRaiseDispute(RaiseDisputeEvent event, Emitter<EscrowState> emit) async {
    emit(EscrowLoading());
    try {
      final dispute = await _repository.raiseDispute(event.data);
      emit(DisputeRaisedSuccessState(dispute));
    } catch (e) {
      emit(EscrowErrorState(e.toString()));
    }
  }

  Future<void> _onFetchDisputes(FetchDisputesEvent event, Emitter<EscrowState> emit) async {
    emit(EscrowLoading());
    try {
      final disputes = await _repository.getDisputes();
      emit(DisputesLoadedState(disputes));
    } catch (e) {
      emit(EscrowErrorState(e.toString()));
    }
  }

  Future<void> _onResolveDispute(ResolveDisputeEvent event, Emitter<EscrowState> emit) async {
    emit(EscrowLoading());
    try {
      final res = await _repository.resolveDispute(event.disputeId, event.decision, adminNotes: event.adminNotes);
      emit(DisputeResolvedSuccessState(res));
      add(FetchDisputesEvent());
    } catch (e) {
      emit(EscrowErrorState(e.toString()));
    }
  }
}
