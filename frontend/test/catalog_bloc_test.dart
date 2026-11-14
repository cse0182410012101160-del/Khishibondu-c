import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agro_bridge/features/catalog/domain/entities/catalog_entities.dart';
import 'package:agro_bridge/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:agro_bridge/features/catalog/presentation/bloc/catalog_bloc.dart';

class MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late MockCatalogRepository repository;
  final category = const ProductCategory(id: 'c-1', slug: 'seeds', nameEn: 'Seeds', nameBn: 'বীজ', productCount: 1);
  final product = const Product(id: 'p-1', slug: 'rice', nameEn: 'Rice', nameBn: 'চাল', unit: 'KG', price: 45, minOrderQty: 1, imageUrl: null, verified: true, priceUpdatedAt: null, categorySlug: 'seeds');

  setUp(() => repository = MockCatalogRepository());

  blocTest<CatalogBloc, CatalogState>(
    'loads categories into loaded state',
    build: () {
      when(() => repository.getCategories()).thenAnswer((_) async => [category]);
      return CatalogBloc(repository);
    },
    act: (bloc) => bloc.add(LoadCategories()),
    expect: () => [isA<CatalogLoading>(), isA<CatalogLoaded>()],
  );

  blocTest<CatalogBloc, CatalogState>(
    'emits empty when category has no products',
    build: () {
      when(() => repository.getProducts(category: 'seeds', query: null)).thenAnswer((_) async => const CatalogProductsPage(products: []));
      return CatalogBloc(repository);
    },
    act: (bloc) => bloc.add(LoadProducts(category: 'seeds')),
    expect: () => [isA<CatalogLoading>(), isA<CatalogEmpty>()],
  );

  blocTest<CatalogBloc, CatalogState>(
    'loads products and preserves the server price',
    build: () {
      when(() => repository.getProducts(category: 'seeds', query: null)).thenAnswer((_) async => CatalogProductsPage(products: [product], nextCursor: 'next'));
      return CatalogBloc(repository);
    },
    act: (bloc) => bloc.add(LoadProducts(category: 'seeds')),
    expect: () => [isA<CatalogLoading>(), predicate<CatalogLoaded>((state) => state.products.single.price == 45 && state.nextCursor == 'next')],
  );
}