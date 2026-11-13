import 'package:agro_bridge/features/orders/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.cropId,
    super.bidId,
    required super.buyerId,
    required super.buyerName,
    required super.farmerId,
    required super.farmerName,
    required super.cropTitle,
    required super.quantity,
    required super.unit,
    required super.pricePerUnit,
    required super.totalAmount,
    required super.status,
    required super.escrowStatus,
    required super.mfsPaymentMethod,
    required super.mfsTransactionId,
    required super.deliveryAddress,
    required super.batchQrCode,
    super.disputeId,
    required super.timeline,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      cropId: json['cropId'] ?? '',
      bidId: json['bidId'],
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? 'Buyer',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? 'Farmer',
      cropTitle: json['cropTitle'] ?? 'Harvest Lot',
      quantity: (json['quantity'] != null) ? (json['quantity'] as num).toDouble() : 0.0,
      unit: json['unit'] ?? 'Maund',
      pricePerUnit: (json['pricePerUnit'] != null) ? (json['pricePerUnit'] as num).toDouble() : 0.0,
      totalAmount: (json['totalAmount'] != null) ? (json['totalAmount'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'Confirmed',
      escrowStatus: json['escrowStatus'] ?? 'LOCKED',
      mfsPaymentMethod: json['mfsPaymentMethod'] ?? 'bKash',
      mfsTransactionId: json['mfsTransactionId'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? 'Wholesale Depot',
      batchQrCode: json['batchQrCode'] ?? '',
      disputeId: json['disputeId'],
      timeline: json['timeline'] != null
          ? (json['timeline'] as List).map((t) => OrderTimelineItem.fromJson(t)).toList()
          : [],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropId': cropId,
      'bidId': bidId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'cropTitle': cropTitle,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'totalAmount': totalAmount,
      'status': status,
      'escrowStatus': escrowStatus,
      'mfsPaymentMethod': mfsPaymentMethod,
      'mfsTransactionId': mfsTransactionId,
      'deliveryAddress': deliveryAddress,
      'batchQrCode': batchQrCode,
      'disputeId': disputeId,
      'timeline': timeline.map((t) => t.toJson()).toList(),
      'createdAt': createdAt,
    };
  }
}

