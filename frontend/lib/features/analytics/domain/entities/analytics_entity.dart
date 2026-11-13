import 'package:equatable/equatable.dart';

class FarmerAnalyticsEntity extends Equatable {
  final String farmerId;
  final String farmerName;
  final double totalRevenueBdt;
  final double pendingEscrowBdt;
  final int activeListingsCount;
  final int completedOrdersCount;
  final int creditScore;
  final String creditTier;
  final int fulfillmentRatePct;
  final List<Map<String, dynamic>> topCrops;
  final List<Map<String, dynamic>> monthlyRevenue;

  const FarmerAnalyticsEntity({
    required this.farmerId,
    required this.farmerName,
    required this.totalRevenueBdt,
    required this.pendingEscrowBdt,
    required this.activeListingsCount,
    required this.completedOrdersCount,
    required this.creditScore,
    required this.creditTier,
    required this.fulfillmentRatePct,
    required this.topCrops,
    required this.monthlyRevenue,
  });

  @override
  List<Object?> get props => [farmerId, totalRevenueBdt, creditScore];
}

class AdminAnalyticsEntity extends Equatable {
  final int totalUsers;
  final int farmersCount;
  final int buyersCount;
  final int ngoCount;
  final double totalGmvBdt;
  final double totalEscrowLockedBdt;
  final int activeDisputesCount;
  final int totalDisputesCount;
  final int loansDisbursedCount;
  final double totalLoanVolumeDisbursedBdt;
  final int activeListingsCount;
  final int totalOrdersCount;

  const AdminAnalyticsEntity({
    required this.totalUsers,
    required this.farmersCount,
    required this.buyersCount,
    required this.ngoCount,
    required this.totalGmvBdt,
    required this.totalEscrowLockedBdt,
    required this.activeDisputesCount,
    required this.totalDisputesCount,
    required this.loansDisbursedCount,
    required this.totalLoanVolumeDisbursedBdt,
    required this.activeListingsCount,
    required this.totalOrdersCount,
  });

  @override
  List<Object?> get props => [totalUsers, totalGmvBdt, activeDisputesCount];
}

