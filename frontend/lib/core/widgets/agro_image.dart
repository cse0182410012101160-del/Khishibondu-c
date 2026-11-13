import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AgroImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Widget? child;

  const AgroImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2.2, sigmaY: 2.2),
              child: Image.network(
                imageUrl,
                fit: fit,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.agriculture_outlined, color: AppColors.textLight, size: 38),
                ),
              ),
            ),
            Container(color: Colors.black.withValues(alpha: 0.28)),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class AgroHeroImage extends StatelessWidget {
  final String imageUrl;
  final Widget child;

  const AgroHeroImage({super.key, required this.imageUrl, required this.child});

  @override
  Widget build(BuildContext context) {
    return AgroImage(
      imageUrl: imageUrl,
      height: 300,
      width: double.infinity,
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.fromLTRB(24, 70, 24, 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xE610252A)],
          ),
        ),
        child: child,
      ),
    );
  }
}

class AgroAppBackdrop extends StatelessWidget {
  final Widget child;

  const AgroAppBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
          child: Image.network(
            'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=1600&auto=format&fit=crop',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.background),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xD90B1716), Color(0xF20B1716)],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
