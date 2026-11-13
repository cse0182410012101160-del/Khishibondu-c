import 'package:equatable/equatable.dart';

class CreditProfileEntity extends Equatable {
  final int score; // 300 to 850
  final String tier; // Platinum, Gold, Silver, Bronze
  final String riskGrade;
  final double totalSalesBdt;
  final int fulfilledOrdersCount;
  final int fulfillmentRatePct;
  final double buyerRating;
  final double maxPreApprovedLoanBdt;
  final double interestRateModifier;
  final Map<String, dynamic> breakdown;

  const CreditProfileEntity({
    required this.score,
    required this.tier,
    required this.riskGrade,
    required this.totalSalesBdt,
    required this.fulfilledOrdersCount,
    required this.fulfillmentRatePct,
    required this.buyerRating,
    required this.maxPreApprovedLoanBdt,
    required this.interestRateModifier,
    required this.breakdown,
  });

  @override
  List<Object?> get props => [score, tier, maxPreApprovedLoanBdt];
}

class LoanApplicationEntity extends Equatable {
  final String id;
  final String farmerId;
  final String farmerName;
  final String ngoId;
  final String ngoName;
  final String programName;
  final double requestedAmount;
  final int tenureMonths;
  final double interestRateAnnual;
  final double monthlyEmiBdt;
  final String purpose;
  final int farmerCreditScoreSnapshot;
  final double farmerRatingSnapshot;
  final double historicalSalesVolumeBdt;
  final String collateralType;
  final String status; // 'SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'DISBURSED', 'REJECTED'
  final double? approvedAmount;
  final String? disbursedViaMfs;
  final String? disbursedTxnId;
  final String submittedAt;
  final String? approvedAt;

  const LoanApplicationEntity({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.ngoId,
    required this.ngoName,
    required this.programName,
    required this.requestedAmount,
    required this.tenureMonths,
    required this.interestRateAnnual,
    required this.monthlyEmiBdt,
    required this.purpose,
    required this.farmerCreditScoreSnapshot,
    required this.farmerRatingSnapshot,
    required this.historicalSalesVolumeBdt,
    required this.collateralType,
    required this.status,
    this.approvedAmount,
    this.disbursedViaMfs,
    this.disbursedTxnId,
    required this.submittedAt,
    this.approvedAt,
  });

  @override
  List<Object?> get props => [id, farmerId, status, requestedAmount];
}

