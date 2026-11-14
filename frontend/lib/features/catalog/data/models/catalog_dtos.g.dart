// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductCategoryDto _$ProductCategoryDtoFromJson(Map<String, dynamic> json) =>
    ProductCategoryDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      nameEn: json['nameEn'] as String,
      nameBn: json['nameBn'] as String,
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      children: (json['children'] as List<dynamic>?)
              ?.map(
                  (e) => ProductCategoryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProductCategoryDtoToJson(ProductCategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'nameEn': instance.nameEn,
      'nameBn': instance.nameBn,
      'productCount': instance.productCount,
      'children': instance.children,
    };

ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => ProductDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      nameEn: json['nameEn'] as String,
      nameBn: json['nameBn'] as String,
      unit: json['unit'] as String,
      price: (json['price'] as num).toDouble(),
      minOrderQty: (json['minOrderQty'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      verified: json['verified'] as bool,
      priceUpdatedAt: json['priceUpdatedAt'] == null
          ? null
          : DateTime.parse(json['priceUpdatedAt'] as String),
      categorySlug: json['categorySlug'] as String,
    );

Map<String, dynamic> _$ProductDtoToJson(ProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'nameEn': instance.nameEn,
      'nameBn': instance.nameBn,
      'unit': instance.unit,
      'price': instance.price,
      'minOrderQty': instance.minOrderQty,
      'imageUrl': instance.imageUrl,
      'verified': instance.verified,
      'priceUpdatedAt': instance.priceUpdatedAt?.toIso8601String(),
      'categorySlug': instance.categorySlug,
    };
