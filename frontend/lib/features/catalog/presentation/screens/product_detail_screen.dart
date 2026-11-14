import 'package:flutter/material.dart';
import 'package:agro_bridge/core/localization/app_localizations.dart';
import 'package:agro_bridge/core/theme/app_theme.dart';
import '../../domain/entities/catalog_entities.dart';
import '../widgets/product_card.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final name = loc.isBangla ? product.nameBn : product.nameEn;
    final otherName = loc.isBangla ? product.nameEn : product.nameBn;
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SizedBox(height: 230, child: product.imageUrl == null || product.imageUrl!.isEmpty ? Container(color: AppColors.surfaceVariant, child: const Icon(Icons.agriculture_outlined, size: 70, color: AppColors.primary)) : Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceVariant, child: const Icon(Icons.agriculture_outlined, size: 70, color: AppColors.primary)))),
        const SizedBox(height: 18),
        Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(otherName, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 18),
        ProductCard(product: product),
        const SizedBox(height: 12),
        if (product.priceUpdatedAt != null) Text('${loc.translate('catalogPriceUpdated')}: ${product.priceUpdatedAt!.toLocal().toString().split(' ').first}', style: TextStyle(color: Colors.grey.shade600)),
      ]),
    );
  }
}