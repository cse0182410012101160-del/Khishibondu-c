import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/order_entity.dart';

class OrderTimelineWidget extends StatelessWidget {
  final String currentStatus;
  final List<OrderTimelineItem> timeline;

  const OrderTimelineWidget({
    super.key,
    required this.currentStatus,
    required this.timeline,
  });

  static const List<String> _stages = [
    'Listed',
    'Negotiating',
    'Confirmed',
    'Delivered',
    'Paid',
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stages.indexOf(currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Lifecycle & Escrow State', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_stages.length, (index) {
            final stage = _stages[index];
            final isCompleted = currentIndex >= index;
            final isCurrent = currentIndex == index;

            Color nodeColor = Colors.grey.shade300;
            if (isCompleted) nodeColor = AppColors.primary;
            if (currentStatus == 'Disputed' && stage == 'Confirmed') nodeColor = AppColors.warning;

            return Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: isCurrent ? 14 : 10,
                    backgroundColor: nodeColor,
                    child: isCompleted
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : Text('${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                  if (index < _stages.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: currentIndex > index ? AppColors.primary : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _stages.map((stage) {
            final isCurrent = stage == currentStatus;
            return Text(
              stage,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? AppColors.primary : Colors.grey.shade600,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const Text('Activity Audit Log', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        ...timeline.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.radio_button_checked, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(item.note, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  Text(
                    item.timestamp.length >= 10 ? item.timestamp.substring(0, 10) : '',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

