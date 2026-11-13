import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String phone;
  final String name;
  final String role; // 'farmer', 'buyer', 'ngo', 'admin'
  final String division;
  final String district;
  final String upazila;
  final String? avatar;
  final String mfsProvider;
  final String mfsNumber;
  final String? nidNumber;
  final String? companyName;
  final String? tradeLicense;
  final String? organizationName;
  final double rating;
  final int ratingCount;
  final int totalFulfilledOrders;
  final double totalSalesVolumeBdt;
  final bool isKycVerified;

  const UserEntity({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.division,
    required this.district,
    required this.upazila,
    this.avatar,
    required this.mfsProvider,
    required this.mfsNumber,
    this.nidNumber,
    this.companyName,
    this.tradeLicense,
    this.organizationName,
    this.rating = 5.0,
    this.ratingCount = 0,
    this.totalFulfilledOrders = 0,
    this.totalSalesVolumeBdt = 0,
    this.isKycVerified = true,
  });

  @override
  List<Object?> get props => [id, phone, name, role, division, district];
}

