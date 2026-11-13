import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agro_bridge/features/microfinance/domain/entities/credit_profile_entity.dart';
import 'package:agro_bridge/features/microfinance/domain/repositories/microfinance_repository.dart';

// Events
abstract class MicrofinanceEvent extends Equatable {
  const MicrofinanceEvent();
  @override
  List<Object?> get props => [];
}

class FetchCreditProfileEvent extends MicrofinanceEvent {
  final String? farmerId;
  const FetchCreditProfileEvent({this.farmerId});
  @override
  List<Object?> get props => [farmerId];
}

class SimulateEmiEvent extends MicrofinanceEvent {
  final double principal;
  final double rate;
  final int tenure;
  const SimulateEmiEvent(this.principal, this.rate, this.tenure);
  @override
  List<Object?> get props => [principal, rate, tenure];
}

class ApplyLoanEvent extends MicrofinanceEvent {
  final Map<String, dynamic> data;
  const ApplyLoanEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class FetchLoanApplicationsEvent extends MicrofinanceEvent {
  final String? status;
  const FetchLoanApplicationsEvent({this.status});
  @override
  List<Object?> get props => [status];
}

class UpdateLoanStatusEvent extends MicrofinanceEvent {
  final String id;
  final String status;
  final double? approvedAmount;
  final String? mfsProvider;
  const UpdateLoanStatusEvent(this.id, this.status, {this.approvedAmount, this.mfsProvider});
  @override
  List<Object?> get props => [id, status, approvedAmount, mfsProvider];
}

// States
abstract class MicrofinanceState extends Equatable {
  const MicrofinanceState();
  @override
  List<Object?> get props => [];
}

class MicrofinanceInitial extends MicrofinanceState {}

class MicrofinanceLoading extends MicrofinanceState {}

class CreditProfileLoadedState extends MicrofinanceState {
  final CreditProfileEntity creditProfile;
  final Map<String, dynamic> farmer;
  final List partnerSchemes;
  const CreditProfileLoadedState(this.creditProfile, this.farmer, this.partnerSchemes);
  @override
  List<Object?> get props => [creditProfile, farmer];
}

class EmiSimulatedState extends MicrofinanceState {
  final Map<String, dynamic> simulation;
  const EmiSimulatedState(this.simulation);
  @override
  List<Object?> get props => [simulation];
}

class LoanAppliedSuccessState extends MicrofinanceState {
  final LoanApplicationEntity application;
  const LoanAppliedSuccessState(this.application);
  @override
  List<Object?> get props => [application];
}

class LoanApplicationsLoadedState extends MicrofinanceState {
  final List<LoanApplicationEntity> applications;
  const LoanApplicationsLoadedState(this.applications);
  @override
  List<Object?> get props => [applications];
}

class MicrofinanceErrorState extends MicrofinanceState {
  final String message;
  const MicrofinanceErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class MicrofinanceBloc extends Bloc<MicrofinanceEvent, MicrofinanceState> {
  final MicrofinanceRepository _repository;

  MicrofinanceBloc(this._repository) : super(MicrofinanceInitial()) {
    on<FetchCreditProfileEvent>(_onFetchCreditProfile);
    on<SimulateEmiEvent>(_onSimulateEmi);
    on<ApplyLoanEvent>(_onApplyLoan);
    on<FetchLoanApplicationsEvent>(_onFetchLoanApplications);
    on<UpdateLoanStatusEvent>(_onUpdateLoanStatus);
  }

  Future<void> _onFetchCreditProfile(FetchCreditProfileEvent event, Emitter<MicrofinanceState> emit) async {
    emit(MicrofinanceLoading());
    try {
      final res = await _repository.getFarmerCreditProfile(farmerId: event.farmerId);
      emit(CreditProfileLoadedState(res['creditProfile'], res['farmer'], res['partnerSchemes']));
    } catch (e) {
      emit(MicrofinanceErrorState(e.toString()));
    }
  }

  Future<void> _onSimulateEmi(SimulateEmiEvent event, Emitter<MicrofinanceState> emit) async {
    emit(MicrofinanceLoading());
    try {
      final sim = await _repository.simulateEmi(event.principal, event.rate, event.tenure);
      emit(EmiSimulatedState(sim));
    } catch (e) {
      emit(MicrofinanceErrorState(e.toString()));
    }
  }

  Future<void> _onApplyLoan(ApplyLoanEvent event, Emitter<MicrofinanceState> emit) async {
    emit(MicrofinanceLoading());
    try {
      final app = await _repository.applyForLoan(event.data);
      emit(LoanAppliedSuccessState(app));
      add(const FetchLoanApplicationsEvent());
    } catch (e) {
      emit(MicrofinanceErrorState(e.toString()));
    }
  }

  Future<void> _onFetchLoanApplications(FetchLoanApplicationsEvent event, Emitter<MicrofinanceState> emit) async {
    emit(MicrofinanceLoading());
    try {
      final apps = await _repository.getLoanApplications(status: event.status);
      emit(LoanApplicationsLoadedState(apps));
    } catch (e) {
      emit(MicrofinanceErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateLoanStatus(UpdateLoanStatusEvent event, Emitter<MicrofinanceState> emit) async {
    emit(MicrofinanceLoading());
    try {
      await _repository.updateLoanStatus(event.id, event.status, approvedAmount: event.approvedAmount, mfsProvider: event.mfsProvider);
      add(const FetchLoanApplicationsEvent());
    } catch (e) {
      emit(MicrofinanceErrorState(e.toString()));
    }
  }
}
