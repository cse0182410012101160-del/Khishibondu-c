import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/orders_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../widgets/order_timeline_widget.dart';
import 'package:agro_bridge/features/traceability/presentation/screens/batch_qr_view_screen.dart';
import 'package:agro_bridge/features/escrow/presentation/screens/dispute_ticket_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderEntity order;
  final UserEntity currentUser;

  const OrderDetailScreen({super.key, required this.order, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isBuyer = currentUser.id == order.buyerId || currentUser.role == 'buyer' || currentUser.role == 'admin';
    final canConfirmDelivery = isBuyer && (order.status == 'Confirmed' || order.status == 'Delivered');

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.split("_").last.toUpperCase()}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BatchQrViewScreen(batchQrCode: order.batchQrCode),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -3)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canConfirmDelivery) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  _showConfirmDialog(context);
                },
                icon: const Icon(Icons.verified),
                label: const Text('Verify Delivery & Release Escrow'),
              ),
              const SizedBox(height: 8),
            ],
            if (order.status != 'Paid' && order.status != 'Disputed') ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DisputeTicketScreen(orderId: order.id),
                    ),
                  );
                },
                icon: const Icon(Icons.report_problem_outlined, size: 16),
                label: const Text('Raise Escrow Dispute / Quality Issue'),
              ),
            ]
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Escrow Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: order.escrowStatus == 'LOCKED'
                    ? const Color(0xFFFFFBEB)
                    : (order.escrowStatus == 'RELEASED' ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: order.escrowStatus == 'LOCKED'
                      ? const Color(0xFFFDE68A)
                      : (order.escrowStatus == 'RELEASED' ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    order.escrowStatus == 'LOCKED'
                        ? Icons.lock_outline
                        : (order.escrowStatus == 'RELEASED' ? Icons.check_circle_outline : Icons.warning_amber),
                    color: order.escrowStatus == 'LOCKED'
                        ? AppColors.warning
                        : (order.escrowStatus == 'RELEASED' ? AppColors.success : AppColors.error),
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agro-Bridge Escrow: ${order.escrowStatus}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: order.escrowStatus == 'LOCKED'
                                ? AppColors.warning
                                : (order.escrowStatus == 'RELEASED' ? AppColors.success : AppColors.error),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.escrowStatus == 'LOCKED'
                              ? 'Funds of ৳ ${order.totalAmount.toStringAsFixed(0)} are securely held in escrow until delivery inspection.'
                              : (order.escrowStatus == 'RELEASED'
                                  ? 'Funds disbursed to seller wallet via ${order.mfsPaymentMethod}.'
                                  : 'Escrow payment frozen due to active dispute.'),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Order details card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.cropTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 8),
                    _detailRow('Farmer (Seller)', order.farmerName),
                    _detailRow('Buyer (Wholesaler)', order.buyerName),
                    _detailRow('Lot Quantity', '${order.quantity} ${order.unit}'),
                    _detailRow('Agreed Price', '${order.pricePerUnit} BDT / ${order.unit.split(" ").first}'),
                    _detailRow('Total Value', '৳ ${order.totalAmount.toStringAsFixed(0)}'),
                    _detailRow('Payment Rail', '${order.mfsPaymentMethod} (Txn: ${order.mfsTransactionId})'),
                    _detailRow('Delivery Hub', order.deliveryAddress),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // State Machine Timeline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OrderTimelineWidget(
                  currentStatus: order.status,
                  timeline: order.timeline,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delivery & Release Funds?'),
        content: Text(
          'Have you inspected the ${order.quantity} ${order.unit} of ${order.cropTitle}?\n\n'
          'Confirming will immediately disburse ৳ ${order.totalAmount.toStringAsFixed(0)} from Escrow to ${order.farmerName}\'s ${order.mfsPaymentMethod} account.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrdersBloc>().add(ConfirmDeliveryEvent(order.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delivery confirmed! Escrow released to farmer.'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Confirm & Release Payout'),
          ),
        ],
      ),
    );
  }
}

