import 'package:agro_bridge/core/localization/app_localizations.dart';
import 'package:agro_bridge/features/catalog/domain/entities/catalog_entities.dart';
import 'package:agro_bridge/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product({bool verified = true, String? imageUrl = 'https://example.com/image.jpg'}) => Product(
      id: 'p-1',
      slug: 'rice-seed',
      nameEn: 'Rice Seed',
      nameBn: 'ধানের বীজ',
      unit: 'KG',
      price: 45,
      minOrderQty: 5,
      imageUrl: imageUrl,
      verified: verified,
      priceUpdatedAt: null,
      categorySlug: 'seeds',
    );

Widget _app(Product product, Locale locale) => MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('bn')],
      home: Scaffold(body: ProductCard(product: product)),
    );

void main() {
  testWidgets('ProductCard renders English price and names', (tester) async {
    await tester.pumpWidget(_app(_product(), const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Rice Seed'), findsOneWidget);
    expect(find.text('৳45 / kg'), findsOneWidget);
  });

  testWidgets('ProductCard renders Bangla name, digits, and unit', (tester) async {
    await tester.pumpWidget(_app(_product(), const Locale('bn')));
    await tester.pumpAndSettle();
    expect(find.text('ধানের বীজ'), findsOneWidget);
    expect(find.text('৳৪৫ / কেজি'), findsOneWidget);
  });

  testWidgets('ProductCard marks unverified prices as indicative', (tester) async {
    await tester.pumpWidget(_app(_product(verified: false), const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Indicative price'), findsOneWidget);
  });

  testWidgets('ProductCard shows a category placeholder without an image', (tester) async {
    await tester.pumpWidget(_app(_product(imageUrl: null), const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.grass), findsOneWidget);
  });
}