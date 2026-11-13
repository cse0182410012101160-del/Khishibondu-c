import 'package:agro_bridge/features/weather/domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.division,
    required super.district,
    required super.temperatureC,
    required super.humidityPct,
    required super.windSpeedKmh,
    required super.rainfallForecastMm,
    required super.condition,
    required super.conditionBn,
    required super.riskLevel,
    required super.floodAlert,
    required super.cycloneAlert,
    required super.advisoryEn,
    required super.advisoryBn,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      division: json['division'] ?? 'Rajshahi',
      district: json['district'] ?? 'Bogura',
      temperatureC: (json['temperatureC'] != null) ? (json['temperatureC'] as num).toDouble() : 28.0,
      humidityPct: json['humidityPct'] ?? 60,
      windSpeedKmh: json['windSpeedKmh'] ?? 10,
      rainfallForecastMm: (json['rainfallForecastMm'] != null)
          ? (json['rainfallForecastMm'] as num).toDouble()
          : 0.0,
      condition: json['condition'] ?? 'Clear',
      conditionBn: json['conditionBn'] ?? 'পরিষ্কার',
      riskLevel: json['riskLevel'] ?? 'LOW',
      floodAlert: json['floodAlert'] ?? false,
      cycloneAlert: json['cycloneAlert'] ?? false,
      advisoryEn: json['advisoryEn'] ?? 'Weather suitable for fieldwork.',
      advisoryBn: json['advisoryBn'] ?? 'মাঠের কাজের জন্য অনুকূল আবহাওয়া।',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'division': division,
      'district': district,
      'temperatureC': temperatureC,
      'humidityPct': humidityPct,
      'windSpeedKmh': windSpeedKmh,
      'rainfallForecastMm': rainfallForecastMm,
      'condition': condition,
      'conditionBn': conditionBn,
      'riskLevel': riskLevel,
      'floodAlert': floodAlert,
      'cycloneAlert': cycloneAlert,
      'advisoryEn': advisoryEn,
      'advisoryBn': advisoryBn,
    };
  }
}
