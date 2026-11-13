import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../bloc/orders_bloc.dart';
import 'order_detail_screen.dart';
import '../../../auth/domain/entities/user_entity.dart';

class OrdersListScreen extends StatefulWidget {
  final UserEntity currentUser;
  const OrdersListScreen({super.key, required this.currentUser});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<OrdersBloc>().add(const FetchOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('orders')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: loc.translate('allOrders')),
            Tab(text: loc.translate('escrowLocked')),
            Tab(text: loc.translate('delivered')),
            Tab(text: loc.translate('completed')),
          ],
        ),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrdersErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is OrdersLoadedState) {
            final allOrders = state.orders;

            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(allOrders),
                _buildOrderList(allOrders.where((o) => o.status == 'Confirmed' || o.escrowStatus == 'LOCKED').toList()),
                _buildOrderList(allOrders.where((o) => o.status == 'Delivered').toList()),
                _buildOrderList(allOrders.where((o) => o.status == 'Paid').toList()),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildOrderList(List orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('No orders in this state.', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isPaid = order.status == 'Paid';
        final isDelivered = order.status == 'Delivered';

        Color statusColor = AppColors.info;
        if (isPaid) statusColor = AppColors.success;
        if (isDelivered) statusColor = AppColors.secondary;
        if (order.status == 'Disputed') statusColor = AppColors.error;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(order: order, currentUser: widget.currentUser),
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id.split("_").last.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textLight),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.cropTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${order.quantity} ${order.unit} @ ${order.pricePerUnit} BDT',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: order.mfsPaymentMethod == 'bKash'
                                  ? AppColors.bkashPink.withValues(alpha: 0.12)
                                  : AppColors.nagadOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.mfsPaymentMethod,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: order.mfsPaymentMethod == 'bKash' ? AppColors.bkashPink : AppColors.nagadOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Escrow: ${order.escrowStatus}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text(
                        '৳ ${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

