import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/catalog_entities.dart';
import '../../domain/repositories/catalog_repository.dart';

sealed class CatalogEvent {}

class LoadCategories extends CatalogEvent {}

class LoadProducts extends CatalogEvent {
  final String category;
  final String? query;
  final String? cursor;

  LoadProducts({required this.category, this.query, this.cursor});
}

class LoadMoreProducts extends CatalogEvent {}

sealed class CatalogState {}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogError extends CatalogState {
  final String message;
  CatalogError(this.message);
}

class CatalogEmpty extends CatalogState {
  final List<ProductCategory> categories;
  CatalogEmpty({this.categories = const []});
}

class CatalogLoaded extends CatalogState {
  final List<ProductCategory> categories;
  final List<Product> products;
  final String? selectedCategory;
  final String? query;
  final String? nextCursor;
  final bool loadingMore;

  CatalogLoaded({
    this.categories = const [],
    this.products = const [],
    this.selectedCategory,
    this.query,
    this.nextCursor,
    this.loadingMore = false,
  });

  CatalogLoaded copyWith({
    List<ProductCategory>? categories,
    List<Product>? products,
    String? selectedCategory,
    String? query,
    String? nextCursor,
    bool clearCursor = false,
    bool? loadingMore,
  }) => CatalogLoaded(
        categories: categories ?? this.categories,
        products: products ?? this.products,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        query: query ?? this.query,
        nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final CatalogRepository repository;

  CatalogBloc(this.repository) : super(CatalogInitial()) {
    on<LoadCategories>(_loadCategories);
    on<LoadProducts>(_loadProducts);
    on<LoadMoreProducts>(_loadMoreProducts);
  }

  Future<void> _loadCategories(LoadCategories event, Emitter<CatalogState> emit) async {
    emit(CatalogLoading());
    try {
      final categories = await repository.getCategories();
      if (categories.isEmpty) {
        emit(CatalogEmpty());
      } else {
        emit(CatalogLoaded(categories: categories));
      }
    } catch (error) {
      emit(CatalogError(error.toString()));
    }
  }

  Future<void> _loadProducts(LoadProducts event, Emitter<CatalogState> emit) async {
    final previous = state is CatalogLoaded ? state as CatalogLoaded : CatalogLoaded();
    emit(CatalogLoading());
    try {
      final page = await repository.getProducts(category: event.category, query: event.query);
      if (page.products.isEmpty) {
        emit(CatalogEmpty(categories: previous.categories));
      } else {
        emit(CatalogLoaded(categories: previous.categories, products: page.products, selectedCategory: event.category, query: event.query, nextCursor: page.nextCursor));
      }
    } catch (error) {
      emit(CatalogError(error.toString()));
    }
  }

  Future<void> _loadMoreProducts(LoadMoreProducts event, Emitter<CatalogState> emit) async {
    final current = state;
    if (current is! CatalogLoaded || current.nextCursor == null || current.loadingMore || current.selectedCategory == null) return;
    emit(current.copyWith(loadingMore: true));
    try {
      final page = await repository.getProducts(category: current.selectedCategory!, query: current.query, cursor: current.nextCursor);
      emit(current.copyWith(products: [...current.products, ...page.products], nextCursor: page.nextCursor, loadingMore: false));
    } catch (error) {
      emit(CatalogError(error.toString()));
    }
  }
}