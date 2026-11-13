import 'package:agro_bridge/features/weather/domain/entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getWeather({String? division, String? district});
}

