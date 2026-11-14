import 'package:flutter/material.dart';
import 'package:agro_bridge/core/localization/app_localizations.dart';
import 'package:agro_bridge/core/theme/app_theme.dart';
import '../../domain/entities/catalog_entities.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool compact;

  const ProductCard({super.key, required this.product, this.onTap, this.compact = false});

  static const _unitLabels = {
    'KG': ('kg', 'কেজি'),
    'PIECE': ('piece', 'পিস'),
    'DOZEN': ('dozen', 'ডজন'),
    'HALI': ('hali', 'হালি'),
    'HUNDRED': ('hundred', 'শত'),
    'LITRE': ('litre', 'লিটার'),
  };

  String _digits(String value, bool bangla) {
    if (!bangla) return value;
    const latin = '0123456789.';
    const banglaDigits = '০১২৩৪৫৬৭৮৯.';
    return value.split('').map((char) {
      final index = latin.indexOf(char);
      return index == -1 ? char : banglaDigits[index];
    }).join();
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(_categoryIcon(product.categorySlug), color: AppColors.primary, size: 42),
      );

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bangla = loc.isBangla;
    final unit = _unitLabels[product.unit.toUpperCase()] ?? (product.unit, product.unit);
    final name = bangla ? product.nameBn : product.nameEn;
    final otherName = bangla ? product.nameEn : product.nameBn;
    final price = _digits(product.price.toStringAsFixed(product.price.truncateToDouble() == product.price ? 0 : 2), bangla);
    final minOrder = _digits(product.minOrderQty.toStringAsFixed(product.minOrderQty.truncateToDouble() == product.minOrderQty ? 0 : 2), bangla);

    final details = Padding(
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(otherName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        const SizedBox(height: 8),
        Text('৳$price / ${bangla ? unit.$2 : unit.$1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        if (!product.verified)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(loc.translate('catalogIndicativePrice'), style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        const SizedBox(height: 4),
        Text('${loc.translate('catalogMinimumOrder')}: $minOrder ${bangla ? unit.$2 : unit.$1}', style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
      ]),
    );

    final image = SizedBox(
      height: compact ? double.infinity : 140,
      width: compact ? 120 : double.infinity,
      child: product.imageUrl == null || product.imageUrl!.isEmpty
          ? _placeholder()
          : Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: compact ? Row(children: [image, Expanded(child: details)]) : Column(children: [image, details]),
      ),
    );
  }
}

IconData _categoryIcon(String slug) {
  final normalized = slug.toLowerCase();
  if (normalized.contains('seed')) return Icons.grass;
  if (normalized.contains('fertil')) return Icons.science_outlined;
  if (normalized.contains('feed')) return Icons.pets_outlined;
  if (normalized.contains('tool')) return Icons.handyman_outlined;
  return Icons.agriculture_outlined;
}