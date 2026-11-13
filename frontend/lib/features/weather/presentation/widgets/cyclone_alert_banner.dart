import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CycloneAlertBanner extends StatelessWidget {
  final bool isFloodAlert;
  final bool isCycloneAlert;
  final String advisoryBn;

  const CycloneAlertBanner({
    super.key,
    required this.isFloodAlert,
    required this.isCycloneAlert,
    required this.advisoryBn,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFloodAlert && !isCycloneAlert) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCycloneAlert ? '🚨 উপকূলীয় সতর্ক সংকেত (Cyclone Alert)' : '🌊 বন্যা সতর্কতা (Flood Warning)',
                      style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  advisoryBn,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

