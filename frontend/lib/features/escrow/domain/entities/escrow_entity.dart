import 'package:equatable/equatable.dart';

class EscrowTransactionEntity extends Equatable {
  final String id;
  final String orderId;
  final double amount;
  final String currency;
  final String payerId;
  final String payerName;
  final String beneficiaryId;
  final String beneficiaryName;
  final String paymentRail; // 'bKash', 'Nagad', 'Rocket'
  final String status; // 'LOCKED', 'RELEASED', 'REFUNDED', 'DISPUTED'
  final String holdStartedAt;
  final String? releasedAt;

  const EscrowTransactionEntity({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.payerId,
    required this.payerName,
    required this.beneficiaryId,
    required this.beneficiaryName,
    required this.paymentRail,
    required this.status,
    required this.holdStartedAt,
    this.releasedAt,
  });

  @override
  List<Object?> get props => [id, orderId, amount, status];
}

class DisputeEntity extends Equatable {
  final String id;
  final String orderId;
  final String raisedByUserId;
  final String raisedByName;
  final String againstUserId;
  final String againstByName;
  final String reason;
  final String status; // 'PENDING_REVIEW', 'RESOLVED_SELLER_PAID', 'RESOLVED_BUYER_REFUNDED'
  final List<String> evidencePhotos;
  final String? adminNotes;
  final String? resolution;
  final String createdAt;

  const DisputeEntity({
    required this.id,
    required this.orderId,
    required this.raisedByUserId,
    required this.raisedByName,
    required this.againstUserId,
    required this.againstByName,
    required this.reason,
    required this.status,
    required this.evidencePhotos,
    this.adminNotes,
    this.resolution,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, orderId, status];
}

