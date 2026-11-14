import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/catalog_entities.dart';

part 'catalog_dtos.g.dart';

@JsonSerializable()
class ProductCategoryDto {
  final String id;
  final String slug;
  final String nameEn;
  final String nameBn;
  final int productCount;
  final List<ProductCategoryDto> children;

  const ProductCategoryDto({
    required this.id,
    required this.slug,
    required this.nameEn,
    required this.nameBn,
    this.productCount = 0,
    this.children = const [],
  });

  factory ProductCategoryDto.fromJson(Map<String, dynamic> json) => _$ProductCategoryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCategoryDtoToJson(this);

  ProductCategory toEntity() => ProductCategory(
        id: id,
        slug: slug,
        nameEn: nameEn,
        nameBn: nameBn,
        productCount: productCount,
        children: children.map((child) => child.toEntity()).toList(),
      );
}

@JsonSerializable()
class ProductDto {
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

  const ProductDto({
    required this.id,
    required this.slug,
    required this.nameEn,
    required this.nameBn,
    required this.unit,
    required this.price,
    required this.minOrderQty,
    this.imageUrl,
    required this.verified,
    this.priceUpdatedAt,
    required this.categorySlug,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) => _$ProductDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductDtoToJson(this);

  Product toEntity() => Product(
        id: id,
        slug: slug,
        nameEn: nameEn,
        nameBn: nameBn,
        unit: unit,
        price: price,
        minOrderQty: minOrderQty,
        imageUrl: imageUrl,
        verified: verified,
        priceUpdatedAt: priceUpdatedAt,
        categorySlug: categorySlug,
      );
}