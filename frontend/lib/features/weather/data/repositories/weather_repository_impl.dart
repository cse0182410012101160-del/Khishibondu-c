import 'package:agro_bridge/core/storage/cache_service.dart';
import 'package:agro_bridge/features/weather/domain/entities/weather_entity.dart';
import 'package:agro_bridge/features/weather/domain/repositories/weather_repository.dart';
import 'package:agro_bridge/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:agro_bridge/features/weather/data/models/weather_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  WeatherRepositoryImpl(this._remoteDataSource, this._cacheService);

  @override
  Future<WeatherEntity> getWeather({String? division, String? district}) async {
    try {
      final w = await _remoteDataSource.getWeather(division: division, district: district);
      await _cacheService.cacheWeather(w.toJson());
      return w;
    } catch (e) {
      final cached = _cacheService.getCachedWeather();
      if (cached != null) {
        return WeatherModel.fromJson(cached);
      }
      rethrow;
    }
  }
}
