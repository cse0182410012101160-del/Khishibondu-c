import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agro_bridge/features/weather/domain/entities/weather_entity.dart';
import 'package:agro_bridge/features/weather/domain/repositories/weather_repository.dart';

// Events
abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
  @override
  List<Object?> get props => [];
}

class FetchWeatherEvent extends WeatherEvent {
  final String? division;
  final String? district;
  const FetchWeatherEvent({this.division, this.district});
  @override
  List<Object?> get props => [division, district];
}

// States
abstract class WeatherState extends Equatable {
  const WeatherState();
  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoadedState extends WeatherState {
  final WeatherEntity weather;
  const WeatherLoadedState(this.weather);
  @override
  List<Object?> get props => [weather];
}

class WeatherErrorState extends WeatherState {
  final String message;
  const WeatherErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository _repository;

  WeatherBloc(this._repository) : super(WeatherInitial()) {
    on<FetchWeatherEvent>(_onFetchWeather);
  }

  Future<void> _onFetchWeather(FetchWeatherEvent event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final w = await _repository.getWeather(division: event.division, district: event.district);
      emit(WeatherLoadedState(w));
    } catch (e) {
      emit(WeatherErrorState(e.toString()));
    }
  }
}
