import 'package:agro_bridge/features/microfinance/domain/entities/credit_profile_entity.dart';

class CreditProfileModel extends CreditProfileEntity {
  const CreditProfileModel({
    required super.score,
    required super.tier,
    required super.riskGrade,
    required super.totalSalesBdt,
    required super.fulfilledOrdersCount,
    required super.fulfillmentRatePct,
    required super.buyerRating,
    required super.maxPreApprovedLoanBdt,
    required super.interestRateModifier,
    required super.breakdown,
  });

  factory CreditProfileModel.fromJson(Map<String, dynamic> json) {
    return CreditProfileModel(
      score: json['score'] ?? 350,
      tier: json['tier'] ?? 'Bronze',
      riskGrade: json['riskGrade'] ?? 'High Risk',
      totalSalesBdt: (json['totalSalesBdt'] != null) ? (json['totalSalesBdt'] as num).toDouble() : 0.0,
      fulfilledOrdersCount: json['fulfilledOrdersCount'] ?? 0,
      fulfillmentRatePct: json['fulfillmentRatePct'] ?? 100,
      buyerRating: (json['buyerRating'] != null) ? (json['buyerRating'] as num).toDouble() : 5.0,
      maxPreApprovedLoanBdt: (json['maxPreApprovedLoanBdt'] != null)
          ? (json['maxPreApprovedLoanBdt'] as num).toDouble()
          : 50000.0,
      interestRateModifier: (json['interestRateModifier'] != null)
          ? (json['interestRateModifier'] as num).toDouble()
          : 1.0,
      breakdown: json['breakdown'] != null ? Map<String, dynamic>.from(json['breakdown']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'tier': tier,
      'riskGrade': riskGrade,
      'totalSalesBdt': totalSalesBdt,
      'fulfilledOrdersCount': fulfilledOrdersCount,
      'fulfillmentRatePct': fulfillmentRatePct,
      'buyerRating': buyerRating,
      'maxPreApprovedLoanBdt': maxPreApprovedLoanBdt,
      'interestRateModifier': interestRateModifier,
      'breakdown': breakdown,
    };
  }
}

class LoanApplicationModel extends LoanApplicationEntity {
  const LoanApplicationModel({
    required super.id,
    required super.farmerId,
    required super.farmerName,
    required super.ngoId,
    required super.ngoName,
    required super.programName,
    required super.requestedAmount,
    required super.tenureMonths,
    required super.interestRateAnnual,
    required super.monthlyEmiBdt,
    required super.purpose,
    required super.farmerCreditScoreSnapshot,
    required super.farmerRatingSnapshot,
    required super.historicalSalesVolumeBdt,
    required super.collateralType,
    required super.status,
    super.approvedAmount,
    super.disbursedViaMfs,
    super.disbursedTxnId,
    required super.submittedAt,
    super.approvedAt,
  });

  factory LoanApplicationModel.fromJson(Map<String, dynamic> json) {
    return LoanApplicationModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? 'Farmer',
      ngoId: json['ngoId'] ?? '',
      ngoName: json['ngoName'] ?? 'MFI Partner',
      programName: json['programName'] ?? 'Agro-Bridge Loan',
      requestedAmount: (json['requestedAmount'] != null) ? (json['requestedAmount'] as num).toDouble() : 0.0,
      tenureMonths: json['tenureMonths'] ?? 6,
      interestRateAnnual: (json['interestRateAnnual'] != null) ? (json['interestRateAnnual'] as num).toDouble() : 9.0,
      monthlyEmiBdt: (json['monthlyEmiBdt'] != null) ? (json['monthlyEmiBdt'] as num).toDouble() : 0.0,
      purpose: json['purpose'] ?? '',
      farmerCreditScoreSnapshot: json['farmerCreditScoreSnapshot'] ?? 650,
      farmerRatingSnapshot: (json['farmerRatingSnapshot'] != null) ? (json['farmerRatingSnapshot'] as num).toDouble() : 4.5,
      historicalSalesVolumeBdt: (json['historicalSalesVolumeBdt'] != null)
          ? (json['historicalSalesVolumeBdt'] as num).toDouble()
          : 0.0,
      collateralType: json['collateralType'] ?? 'Marketplace Sales Lien',
      status: json['status'] ?? 'SUBMITTED',
      approvedAmount: (json['approvedAmount'] != null) ? (json['approvedAmount'] as num).toDouble() : null,
      disbursedViaMfs: json['disbursedViaMfs'],
      disbursedTxnId: json['disbursedTxnId'],
      submittedAt: json['submittedAt'] ?? '',
      approvedAt: json['approvedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'programName': programName,
      'requestedAmount': requestedAmount,
      'tenureMonths': tenureMonths,
      'interestRateAnnual': interestRateAnnual,
      'monthlyEmiBdt': monthlyEmiBdt,
      'purpose': purpose,
      'farmerCreditScoreSnapshot': farmerCreditScoreSnapshot,
      'farmerRatingSnapshot': farmerRatingSnapshot,
      'historicalSalesVolumeBdt': historicalSalesVolumeBdt,
      'collateralType': collateralType,
      'status': status,
      'approvedAmount': approvedAmount,
      'disbursedViaMfs': disbursedViaMfs,
      'disbursedTxnId': disbursedTxnId,
      'submittedAt': submittedAt,
      'approvedAt': approvedAt,
    };
  }
}

