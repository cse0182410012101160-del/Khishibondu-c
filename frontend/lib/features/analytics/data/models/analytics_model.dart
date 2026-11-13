import 'package:agro_bridge/features/analytics/domain/entities/analytics_entity.dart';

class FarmerAnalyticsModel extends FarmerAnalyticsEntity {
  const FarmerAnalyticsModel({
    required super.farmerId,
    required super.farmerName,
    required super.totalRevenueBdt,
    required super.pendingEscrowBdt,
    required super.activeListingsCount,
    required super.completedOrdersCount,
    required super.creditScore,
    required super.creditTier,
    required super.fulfillmentRatePct,
    required super.topCrops,
    required super.monthlyRevenue,
  });

  factory FarmerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return FarmerAnalyticsModel(
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? 'Farmer',
      totalRevenueBdt: (json['totalRevenueBdt'] != null) ? (json['totalRevenueBdt'] as num).toDouble() : 0.0,
      pendingEscrowBdt: (json['pendingEscrowBdt'] != null) ? (json['pendingEscrowBdt'] as num).toDouble() : 0.0,
      activeListingsCount: json['activeListingsCount'] ?? 0,
      completedOrdersCount: json['completedOrdersCount'] ?? 0,
      creditScore: json['creditScore'] ?? 650,
      creditTier: json['creditTier'] ?? 'Gold',
      fulfillmentRatePct: json['fulfillmentRatePct'] ?? 100,
      topCrops: json['topCrops'] != null ? List<Map<String, dynamic>>.from(json['topCrops']) : [],
      monthlyRevenue: json['monthlyRevenue'] != null ? List<Map<String, dynamic>>.from(json['monthlyRevenue']) : [],
    );
  }
}

class AdminAnalyticsModel extends AdminAnalyticsEntity {
  const AdminAnalyticsModel({
    required super.totalUsers,
    required super.farmersCount,
    required super.buyersCount,
    required super.ngoCount,
    required super.totalGmvBdt,
    required super.totalEscrowLockedBdt,
    required super.activeDisputesCount,
    required super.totalDisputesCount,
    required super.loansDisbursedCount,
    required super.totalLoanVolumeDisbursedBdt,
    required super.activeListingsCount,
    required super.totalOrdersCount,
  });

  factory AdminAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsModel(
      totalUsers: json['totalUsers'] ?? 0,
      farmersCount: json['farmersCount'] ?? 0,
      buyersCount: json['buyersCount'] ?? 0,
      ngoCount: json['ngoCount'] ?? 0,
      totalGmvBdt: (json['totalGmvBdt'] != null) ? (json['totalGmvBdt'] as num).toDouble() : 0.0,
      totalEscrowLockedBdt:
          (json['totalEscrowLockedBdt'] != null) ? (json['totalEscrowLockedBdt'] as num).toDouble() : 0.0,
      activeDisputesCount: json['activeDisputesCount'] ?? 0,
      totalDisputesCount: json['totalDisputesCount'] ?? 0,
      loansDisbursedCount: json['loansDisbursedCount'] ?? 0,
      totalLoanVolumeDisbursedBdt: (json['totalLoanVolumeDisbursedBdt'] != null)
          ? (json['totalLoanVolumeDisbursedBdt'] as num).toDouble()
          : 0.0,
      activeListingsCount: json['activeListingsCount'] ?? 0,
      totalOrdersCount: json['totalOrdersCount'] ?? 0,
    );
  }
}
