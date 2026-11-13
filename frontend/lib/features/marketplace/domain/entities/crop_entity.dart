import 'package:equatable/equatable.dart';

class CropEntity extends Equatable {
  final String id;
  final String farmerId;
  final String farmerName;
  final double farmerRating;
  final String title;
  final String titleBn;
  final String category;
  final String categoryBn;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalValue;
  final double minOrderQuantity;
  final String description;
  final String descriptionBn;
  final String division;
  final String district;
  final String upazila;
  final String harvestDate;
  final String grade;
  final bool organicCertified;
  final List<String> images;
  final String batchQrCode;
  final String status; // 'Listed', 'Negotiating', 'Confirmed', 'Delivered', 'Paid'
  final int bidsCount;

  const CropEntity({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerRating,
    required this.title,
    required this.titleBn,
    required this.category,
    required this.categoryBn,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalValue,
    required this.minOrderQuantity,
    required this.description,
    required this.descriptionBn,
    required this.division,
    required this.district,
    required this.upazila,
    required this.harvestDate,
    required this.grade,
    required this.organicCertified,
    required this.images,
    required this.batchQrCode,
    required this.status,
    required this.bidsCount,
  });

  @override
  List<Object?> get props => [id, title, pricePerUnit, quantity, status];
}

class BidEntity extends Equatable {
  final String id;
  final String cropId;
  final String buyerId;
  final String buyerName;
  final String farmerId;
  final double quantityRequested;
  final String unit;
  final double offeredPricePerUnit;
  final double totalOfferedAmount;
  final String note;
  final String status; // 'pending', 'accepted', 'rejected', 'countered'
  final String createdAt;

  const BidEntity({
    required this.id,
    required this.cropId,
    required this.buyerId,
    required this.buyerName,
    required this.farmerId,
    required this.quantityRequested,
    required this.unit,
    required this.offeredPricePerUnit,
    required this.totalOfferedAmount,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, cropId, buyerId, offeredPricePerUnit, status];
}

