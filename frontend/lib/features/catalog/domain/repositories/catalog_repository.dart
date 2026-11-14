import '../entities/catalog_entities.dart';

abstract class CatalogRepository {
  Future<List<ProductCategory>> getCategories();

  Future<CatalogProductsPage> getProducts({
    required String category,
    String? query,
    String? cursor,
    int limit = 20,
  });

  Future<Product> getProduct(String slug);
}

class CatalogProductsPage {
  final List<Product> products;
  final String? nextCursor;

  const CatalogProductsPage({required this.products, this.nextCursor});

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}