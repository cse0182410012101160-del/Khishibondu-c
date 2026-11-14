import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agro_bridge/core/localization/app_localizations.dart';
import '../../domain/entities/catalog_entities.dart';
import '../bloc/catalog_bloc.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final ProductCategory category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  bool _grid = true;

  @override
  void initState() {
    super.initState();
    context.read<CatalogBloc>().add(LoadProducts(category: widget.category.slug));
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<CatalogBloc>().add(LoadMoreProducts());
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _searchProducts() {
    context.read<CatalogBloc>().add(
          LoadProducts(category: widget.category.slug, query: _search.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final categoryName = loc.isBangla ? widget.category.nameBn : widget.category.nameEn;
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        actions: [
          IconButton(
            icon: Icon(_grid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _grid = !_grid),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _search,
              onSubmitted: (_) => _searchProducts(),
              decoration: InputDecoration(
                labelText: loc.translate('catalogSearch'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _searchProducts,
                ),
              ),
            ),
          ),
          if (widget.category.children.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: widget.category.children.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final child = widget.category.children[index];
                  return ActionChip(
                    label: Text(loc.isBangla ? child.nameBn : child.nameEn),
                    onPressed: () => context.read<CatalogBloc>().add(
                      LoadProducts(category: child.slug),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: BlocBuilder<CatalogBloc, CatalogState>(
              builder: (context, state) {
                if (state is CatalogLoading || state is CatalogInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CatalogError) {
                  return Center(
                    child: Text('${loc.translate('catalogError')}: ${state.message}'),
                  );
                }
                if (state is CatalogEmpty) {
                  return Center(child: Text(loc.translate('catalogNoProducts')));
                }
                final products = state is CatalogLoaded ? state.products : <Product>[];
                if (_grid) {
                  return GridView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: .62,
                    ),
                    itemBuilder: (_, index) => ProductCard(
                      product: products[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: products[index]),
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => SizedBox(
                    height: 148,
                    child: ProductCard(
                      product: products[index],
                      compact: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: products[index]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
