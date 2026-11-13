import 'package:agro_bridge/features/analytics/domain/entities/analytics_entity.dart';

abstract class AnalyticsRepository {
  Future<FarmerAnalyticsEntity> getFarmerAnalytics({String? farmerId});
  Future<AdminAnalyticsEntity> getAdminAnalytics();
}

