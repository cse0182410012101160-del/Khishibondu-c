import 'package:agro_bridge/features/analytics/domain/entities/analytics_entity.dart';
import 'package:agro_bridge/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:agro_bridge/features/analytics/data/datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;

  AnalyticsRepositoryImpl(this._remoteDataSource);

  @override
  Future<FarmerAnalyticsEntity> getFarmerAnalytics({String? farmerId}) {
    return _remoteDataSource.getFarmerAnalytics(farmerId: farmerId);
  }

  @override
  Future<AdminAnalyticsEntity> getAdminAnalytics() {
    return _remoteDataSource.getAdminAnalytics();
  }
}
