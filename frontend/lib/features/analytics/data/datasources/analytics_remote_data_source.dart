import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import 'package:agro_bridge/features/analytics/data/models/analytics_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<FarmerAnalyticsModel> getFarmerAnalytics({String? farmerId});
  Future<AdminAnalyticsModel> getAdminAnalytics();
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient _client;

  AnalyticsRemoteDataSourceImpl(this._client);

  @override
  Future<FarmerAnalyticsModel> getFarmerAnalytics({String? farmerId}) async {
    final res = await _client.get(ApiEndpoints.farmerAnalytics(farmerId));
    return FarmerAnalyticsModel.fromJson(res.data['analytics']);
  }

  @override
  Future<AdminAnalyticsModel> getAdminAnalytics() async {
    final res = await _client.get(ApiEndpoints.adminAnalytics);
    return AdminAnalyticsModel.fromJson(res.data['analytics']);
  }
}

