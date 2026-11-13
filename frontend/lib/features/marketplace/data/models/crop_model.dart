import 'package:agro_bridge/features/marketplace/domain/entities/crop_entity.dart';

class CropModel extends CropEntity {
  const CropModel({
    required super.id,
    required super.farmerId,
    required super.farmerName,
    required super.farmerRating,
    required super.title,
    required super.titleBn,
    required super.category,
    required super.categoryBn,
    required super.quantity,
    required super.unit,
    required super.pricePerUnit,
    required super.totalValue,
    required super.minOrderQuantity,
    required super.description,
    required super.descriptionBn,
    required super.division,
    required super.district,
    required super.upazila,
    required super.harvestDate,
    required super.grade,
    required super.organicCertified,
    required super.images,
    required super.batchQrCode,
    required super.status,
    required super.bidsCount,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? 'Farmer',
      farmerRating: (json['farmerRating'] != null) ? (json['farmerRating'] as num).toDouble() : 5.0,
      title: json['title'] ?? '',
      titleBn: json['titleBn'] ?? json['title'] ?? '',
      category: json['category'] ?? 'General',
      categoryBn: json['categoryBn'] ?? json['category'] ?? 'সাধারণ',
      quantity: (json['quantity'] != null) ? (json['quantity'] as num).toDouble() : 0.0,
      unit: json['unit'] ?? 'Maund (মন)',
      pricePerUnit: (json['pricePerUnit'] != null) ? (json['pricePerUnit'] as num).toDouble() : 0.0,
      totalValue: (json['totalValue'] != null) ? (json['totalValue'] as num).toDouble() : 0.0,
      minOrderQuantity: (json['minOrderQuantity'] != null) ? (json['minOrderQuantity'] as num).toDouble() : 1.0,
      description: json['description'] ?? '',
      descriptionBn: json['descriptionBn'] ?? json['description'] ?? '',
      division: json['division'] ?? 'Rajshahi',
      district: json['district'] ?? 'Bogura',
      upazila: json['upazila'] ?? 'Sadar',
      harvestDate: json['harvestDate'] ?? '',
      grade: json['grade'] ?? 'A',
      organicCertified: json['organicCertified'] ?? false,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      batchQrCode: json['batchQrCode'] ?? '',
      status: json['status'] ?? 'Listed',
      bidsCount: json['bidsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerRating': farmerRating,
      'title': title,
      'titleBn': titleBn,
      'category': category,
      'categoryBn': categoryBn,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'totalValue': totalValue,
      'minOrderQuantity': minOrderQuantity,
      'description': description,
      'descriptionBn': descriptionBn,
      'division': division,
      'district': district,
      'upazila': upazila,
      'harvestDate': harvestDate,
      'grade': grade,
      'organicCertified': organicCertified,
      'images': images,
      'batchQrCode': batchQrCode,
      'status': status,
      'bidsCount': bidsCount,
    };
  }
}

class BidModel extends BidEntity {
  const BidModel({
    required super.id,
    required super.cropId,
    required super.buyerId,
    required super.buyerName,
    required super.farmerId,
    required super.quantityRequested,
    required super.unit,
    required super.offeredPricePerUnit,
    required super.totalOfferedAmount,
    required super.note,
    required super.status,
    required super.createdAt,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'] ?? '',
      cropId: json['cropId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? 'Buyer',
      farmerId: json['farmerId'] ?? '',
      quantityRequested: (json['quantityRequested'] != null) ? (json['quantityRequested'] as num).toDouble() : 0.0,
      unit: json['unit'] ?? 'Maund',
      offeredPricePerUnit: (json['offeredPricePerUnit'] != null) ? (json['offeredPricePerUnit'] as num).toDouble() : 0.0,
      totalOfferedAmount: (json['totalOfferedAmount'] != null) ? (json['totalOfferedAmount'] as num).toDouble() : 0.0,
      note: json['note'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropId': cropId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'farmerId': farmerId,
      'quantityRequested': quantityRequested,
      'unit': unit,
      'offeredPricePerUnit': offeredPricePerUnit,
      'totalOfferedAmount': totalOfferedAmount,
      'note': note,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

