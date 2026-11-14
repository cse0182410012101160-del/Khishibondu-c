import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agro_bridge/core/localization/app_localizations.dart';
import 'package:agro_bridge/core/theme/app_theme.dart';
import '../../domain/entities/catalog_entities.dart';
import '../bloc/catalog_bloc.dart';
import 'category_products_screen.dart';

class CatalogHomeScreen extends StatelessWidget {
  final String role;

  const CatalogHomeScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('catalogTitle'))),
      body: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (context, state) {
          if (state is CatalogLoading || state is CatalogInitial) return const Center(child: CircularProgressIndicator());
          if (state is CatalogError) return Center(child: Text('${loc.translate('catalogError')}: ${state.message}'));
          if (state is CatalogEmpty) return Center(child: Text(loc.translate('catalogEmpty')));
          final categories = state is CatalogLoaded ? state.categories : <ProductCategory>[];
          return RefreshIndicator(
            onRefresh: () async => context.read<CatalogBloc>().add(LoadCategories()),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _priceBanner(context),
                const SizedBox(height: 16),
                Text(loc.translate('catalogCategories'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.05),
                  itemBuilder: (context, index) => _CategoryCard(category: categories[index]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _priceBanner(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.price_check, color: AppColors.secondary, size: 30),
        const SizedBox(width: 12),
        Expanded(child: Text('${loc.translate('catalogPriceViewing')}: ${_tierLabel(loc, role)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ]),
    );
  }

  String _tierLabel(AppLocalizations loc, String role) {
    switch (role) {
      case 'farmer': return loc.translate('catalogFarmerPrice');
      case 'buyer': return loc.translate('catalogWholesalePrice');
      case 'ngo': return loc.translate('catalogRetailerPrice');
      default: return loc.translate('catalogCustomerPrice');
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final ProductCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final name = loc.isBangla ? category.nameBn : category.nameEn;
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: category))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.category_outlined, size: 40, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${category.productCount} ${loc.translate('catalogProducts')}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}