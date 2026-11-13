import 'package:agro_bridge/features/escrow/domain/entities/escrow_entity.dart';

class EscrowTransactionModel extends EscrowTransactionEntity {
  const EscrowTransactionModel({
    required super.id,
    required super.orderId,
    required super.amount,
    required super.currency,
    required super.payerId,
    required super.payerName,
    required super.beneficiaryId,
    required super.beneficiaryName,
    required super.paymentRail,
    required super.status,
    required super.holdStartedAt,
    super.releasedAt,
  });

  factory EscrowTransactionModel.fromJson(Map<String, dynamic> json) {
    return EscrowTransactionModel(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] != null) ? (json['amount'] as num).toDouble() : 0.0,
      currency: json['currency'] ?? 'BDT',
      payerId: json['payerId'] ?? '',
      payerName: json['payerName'] ?? '',
      beneficiaryId: json['beneficiaryId'] ?? '',
      beneficiaryName: json['beneficiaryName'] ?? '',
      paymentRail: json['paymentRail'] ?? 'bKash',
      status: json['status'] ?? 'LOCKED',
      holdStartedAt: json['holdStartedAt'] ?? '',
      releasedAt: json['releasedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'payerId': payerId,
      'payerName': payerName,
      'beneficiaryId': beneficiaryId,
      'beneficiaryName': beneficiaryName,
      'paymentRail': paymentRail,
      'status': status,
      'holdStartedAt': holdStartedAt,
      'releasedAt': releasedAt,
    };
  }
}

class DisputeModel extends DisputeEntity {
  const DisputeModel({
    required super.id,
    required super.orderId,
    required super.raisedByUserId,
    required super.raisedByName,
    required super.againstUserId,
    required super.againstByName,
    required super.reason,
    required super.status,
    required super.evidencePhotos,
    super.adminNotes,
    super.resolution,
    required super.createdAt,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      raisedByUserId: json['raisedByUserId'] ?? '',
      raisedByName: json['raisedByName'] ?? '',
      againstUserId: json['againstUserId'] ?? '',
      againstByName: json['againstByName'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING_REVIEW',
      evidencePhotos: json['evidencePhotos'] != null ? List<String>.from(json['evidencePhotos']) : [],
      adminNotes: json['adminNotes'],
      resolution: json['resolution'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'raisedByUserId': raisedByUserId,
      'raisedByName': raisedByName,
      'againstUserId': againstUserId,
      'againstByName': againstByName,
      'reason': reason,
      'status': status,
      'evidencePhotos': evidencePhotos,
      'adminNotes': adminNotes,
      'resolution': resolution,
      'createdAt': createdAt,
    };
  }
}

