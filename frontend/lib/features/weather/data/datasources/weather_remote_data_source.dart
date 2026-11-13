import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import 'package:agro_bridge/features/weather/data/models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeather({String? division, String? district});
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiClient _client;

  WeatherRemoteDataSourceImpl(this._client);

  @override
  Future<WeatherModel> getWeather({String? division, String? district}) async {
    final query = <String, dynamic>{};
    if (division != null && division != 'All') query['division'] = division;
    if (district != null) query['district'] = district;

    final res = await _client.get(ApiEndpoints.weather, queryParameters: query);
    return WeatherModel.fromJson(res.data['weather']);
  }
}

