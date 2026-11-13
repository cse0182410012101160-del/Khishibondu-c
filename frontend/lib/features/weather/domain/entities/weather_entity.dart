import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final String division;
  final String district;
  final double temperatureC;
  final int humidityPct;
  final int windSpeedKmh;
  final double rainfallForecastMm;
  final String condition;
  final String conditionBn;
  final String riskLevel; // 'LOW', 'MODERATE', 'HIGH', 'CRITICAL'
  final bool floodAlert;
  final bool cycloneAlert;
  final String advisoryEn;
  final String advisoryBn;

  const WeatherEntity({
    required this.division,
    required this.district,
    required this.temperatureC,
    required this.humidityPct,
    required this.windSpeedKmh,
    required this.rainfallForecastMm,
    required this.condition,
    required this.conditionBn,
    required this.riskLevel,
    required this.floodAlert,
    required this.cycloneAlert,
    required this.advisoryEn,
    required this.advisoryBn,
  });

  @override
  List<Object?> get props => [division, district, riskLevel, floodAlert, cycloneAlert];
}

