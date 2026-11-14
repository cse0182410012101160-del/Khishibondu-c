import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  final String id;
  final String slug;
  final String nameEn;
  final String nameBn;
  final int productCount;
  final List<ProductCategory> children;

  const ProductCategory({
    required this.id,
    required this.slug,
    required this.nameEn,
    required this.nameBn,
    this.productCount = 0,
    this.children = const [],
  });

  @override
  List<Object?> get props => [id, slug, nameEn, nameBn, productCount, children];
}

class Product extends Equatable {
  final String id;
  final String slug;
  final String nameEn;
  final String nameBn;
  final String unit;
  final double price;
  final double minOrderQty;
  final String? imageUrl;
  final bool verified;
  final DateTime? priceUpdatedAt;
  final String categorySlug;

  const Product({
    required this.id,
    required this.slug,
    required this.nameEn,
    required this.nameBn,
    required this.unit,
    required this.price,
    required this.minOrderQty,
    required this.imageUrl,
    required this.verified,
    required this.priceUpdatedAt,
    required this.categorySlug,
  });

  @override
  List<Object?> get props => [id, slug, price, unit, verified];
}