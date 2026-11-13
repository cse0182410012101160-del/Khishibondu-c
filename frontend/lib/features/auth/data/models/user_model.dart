import 'package:agro_bridge/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phone,
    required super.name,
    required super.role,
    required super.division,
    required super.district,
    required super.upazila,
    super.avatar,
    required super.mfsProvider,
    required super.mfsNumber,
    super.nidNumber,
    super.companyName,
    super.tradeLicense,
    super.organizationName,
    super.rating = 5.0,
    super.ratingCount = 0,
    super.totalFulfilledOrders = 0,
    super.totalSalesVolumeBdt = 0,
    super.isKycVerified = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'farmer',
      division: json['division'] ?? 'Rajshahi',
      district: json['district'] ?? 'Bogura',
      upazila: json['upazila'] ?? 'Sadar',
      avatar: json['avatar'],
      mfsProvider: json['mfsProvider'] ?? 'bKash',
      mfsNumber: json['mfsNumber'] ?? json['phone'] ?? '',
      nidNumber: json['nidNumber'],
      companyName: json['companyName'],
      tradeLicense: json['tradeLicense'],
      organizationName: json['organizationName'],
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : 5.0,
      ratingCount: json['ratingCount'] ?? 0,
      totalFulfilledOrders: json['totalFulfilledOrders'] ?? 0,
      totalSalesVolumeBdt: (json['totalSalesVolumeBdt'] != null)
          ? (json['totalSalesVolumeBdt'] as num).toDouble()
          : 0.0,
      isKycVerified: json['isKycVerified'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'role': role,
      'division': division,
      'district': district,
      'upazila': upazila,
      'avatar': avatar,
      'mfsProvider': mfsProvider,
      'mfsNumber': mfsNumber,
      'nidNumber': nidNumber,
      'companyName': companyName,
      'tradeLicense': tradeLicense,
      'organizationName': organizationName,
      'rating': rating,
      'ratingCount': ratingCount,
      'totalFulfilledOrders': totalFulfilledOrders,
      'totalSalesVolumeBdt': totalSalesVolumeBdt,
      'isKycVerified': isKycVerified,
    };
  }
}
