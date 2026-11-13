import 'package:equatable/equatable.dart';

class OrderTimelineItem extends Equatable {
  final String status;
  final String timestamp;
  final String note;

  const OrderTimelineItem({
    required this.status,
    required this.timestamp,
    required this.note,
  });

  factory OrderTimelineItem.fromJson(Map<String, dynamic> json) {
    return OrderTimelineItem(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'status': status, 'timestamp': timestamp, 'note': note};

  @override
  List<Object?> get props => [status, timestamp, note];
}

class OrderEntity extends Equatable {
  final String id;
  final String cropId;
  final String? bidId;
  final String buyerId;
  final String buyerName;
  final String farmerId;
  final String farmerName;
  final String cropTitle;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalAmount;
  final String status; // 'Listed', 'Negotiating', 'Confirmed', 'Delivered', 'Paid', 'Disputed', 'Cancelled'
  final String escrowStatus; // 'LOCKED', 'RELEASED', 'REFUNDED', 'DISPUTED'
  final String mfsPaymentMethod;
  final String mfsTransactionId;
  final String deliveryAddress;
  final String batchQrCode;
  final String? disputeId;
  final List<OrderTimelineItem> timeline;
  final String createdAt;

  const OrderEntity({
    required this.id,
    required this.cropId,
    this.bidId,
    required this.buyerId,
    required this.buyerName,
    required this.farmerId,
    required this.farmerName,
    required this.cropTitle,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.status,
    required this.escrowStatus,
    required this.mfsPaymentMethod,
    required this.mfsTransactionId,
    required this.deliveryAddress,
    required this.batchQrCode,
    this.disputeId,
    required this.timeline,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, status, escrowStatus, totalAmount];
}

