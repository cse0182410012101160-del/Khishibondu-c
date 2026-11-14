import 'package:agro_bridge/core/constants/api_endpoints.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import '../../domain/entities/catalog_entities.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../models/catalog_dtos.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final ApiClient _client;

  CatalogRepositoryImpl(this._client);

  @override
  Future<List<ProductCategory>> getCategories() async {
    final response = await _client.get(ApiEndpoints.catalogCategories);
    final categories = (response.data['categories'] as List? ?? const [])
        .map((item) => ProductCategoryDto.fromJson(Map<String, dynamic>.from(item as Map)).toEntity())
        .toList();
    return categories;
  }

  @override
  Future<CatalogProductsPage> getProducts({
    required String category,
    String? query,
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.get(
      ApiEndpoints.catalogCategoryProducts(category),
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
      },
    );
    final products = (response.data['products'] as List? ?? const [])
        .map((item) => ProductDto.fromJson(Map<String, dynamic>.from(item as Map)).toEntity())
        .toList();
    return CatalogProductsPage(products: products, nextCursor: response.data['nextCursor'] as String?);
  }

  @override
  Future<Product> getProduct(String slug) async {
    final response = await _client.get(ApiEndpoints.catalogProduct(slug));
    final product = response.data['product'] ?? response.data;
    return ProductDto.fromJson(Map<String, dynamic>.from(product as Map)).toEntity();
  }
}