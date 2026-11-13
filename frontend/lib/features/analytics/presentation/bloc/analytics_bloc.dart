import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agro_bridge/features/analytics/domain/entities/analytics_entity.dart';
import 'package:agro_bridge/features/analytics/domain/repositories/analytics_repository.dart';

// Events
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class FetchFarmerAnalyticsEvent extends AnalyticsEvent {
  final String? farmerId;
  const FetchFarmerAnalyticsEvent({this.farmerId});
  @override
  List<Object?> get props => [farmerId];
}

class FetchAdminAnalyticsEvent extends AnalyticsEvent {}

// States
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class FarmerAnalyticsLoadedState extends AnalyticsState {
  final FarmerAnalyticsEntity analytics;
  const FarmerAnalyticsLoadedState(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

class AdminAnalyticsLoadedState extends AnalyticsState {
  final AdminAnalyticsEntity analytics;
  const AdminAnalyticsLoadedState(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

class AnalyticsErrorState extends AnalyticsState {
  final String message;
  const AnalyticsErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsBloc(this._repository) : super(AnalyticsInitial()) {
    on<FetchFarmerAnalyticsEvent>(_onFetchFarmerAnalytics);
    on<FetchAdminAnalyticsEvent>(_onFetchAdminAnalytics);
  }

  Future<void> _onFetchFarmerAnalytics(FetchFarmerAnalyticsEvent event, Emitter<AnalyticsState> emit) async {
    emit(AnalyticsLoading());
    try {
      final a = await _repository.getFarmerAnalytics(farmerId: event.farmerId);
      emit(FarmerAnalyticsLoadedState(a));
    } catch (e) {
      emit(AnalyticsErrorState(e.toString()));
    }
  }

  Future<void> _onFetchAdminAnalytics(FetchAdminAnalyticsEvent event, Emitter<AnalyticsState> emit) async {
    emit(AnalyticsLoading());
    try {
      final a = await _repository.getAdminAnalytics();
      emit(AdminAnalyticsLoadedState(a));
    } catch (e) {
      emit(AnalyticsErrorState(e.toString()));
    }
  }
}
