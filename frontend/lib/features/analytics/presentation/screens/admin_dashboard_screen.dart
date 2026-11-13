import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/analytics_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../escrow/presentation/bloc/escrow_bloc.dart';
import 'package:agro_bridge/features/plugins/screens/plugins_catalog_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserEntity currentUser;
  const AdminDashboardScreen({super.key, required this.currentUser});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(FetchAdminAnalyticsEvent());
    context.read<EscrowBloc>().add(FetchDisputesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Moderation & Escrow Ops'),
        actions: [
          IconButton(
            icon: const Icon(Icons.extension),
            tooltip: 'Plugin & Feature-Flag Registry',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PluginsCatalogScreen(currentUserRole: widget.currentUser.role)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AnalyticsBloc>().add(FetchAdminAnalyticsEvent());
              context.read<EscrowBloc>().add(FetchDisputesEvent());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Analytics Metrics Grid
            BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdminAnalyticsLoadedState) {
                  final a = state.analytics;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _statCard('Total Platform GMV', '৳ ${a.totalGmvBdt.toStringAsFixed(0)}', AppColors.primary, Icons.storefront),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard('Escrow Vault Held', '৳ ${a.totalEscrowLockedBdt.toStringAsFixed(0)}', AppColors.secondary, Icons.lock),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard('Active Disputes', '${a.activeDisputesCount} Tickets', AppColors.error, Icons.gavel),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard('MFI Credit Disbursed', '৳ ${a.totalLoanVolumeDisbursedBdt.toStringAsFixed(0)}', const Color(0xFF6B21A8), Icons.account_balance),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),

            const SizedBox(height: 20),

            // Feature Flags Quick Shortcut
            Card(
              color: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0F172A),
                  child: Icon(Icons.tune, color: Colors.white, size: 20),
                ),
                title: const Text('Pluggable Module Registry & Flags', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Toggle AI leaf disease detector, satellite NDVI, subsidy directory', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PluginsCatalogScreen(currentUserRole: widget.currentUser.role)),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Active Disputes Queue
            const Text('Escrow Dispute Mediation Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            BlocBuilder<EscrowBloc, EscrowState>(
              builder: (context, state) {
                if (state is DisputesLoadedState) {
                  final disputes = state.disputes;
                  if (disputes.isEmpty) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Zero active dispute tickets.')));
                  }

                  return Column(
                    children: disputes.map((d) {
                      final isPending = d.status == 'PENDING_REVIEW';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Dispute #${d.id.split("_").last.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isPending ? AppColors.error.withValues(alpha: 0.12) : AppColors.success.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      d.status,
                                      style: TextStyle(
                                        color: isPending ? AppColors.error : AppColors.success,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Raised by: ${d.raisedByName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text('Against: ${d.againstByName}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                              const SizedBox(height: 6),
                              Text('Reason: ${d.reason}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                              if (isPending) ...[
                                const Divider(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                        ),
                                        onPressed: () {
                                          context.read<EscrowBloc>().add(
                                                ResolveDisputeEvent(d.id, 'PAY_SELLER', adminNotes: 'Moderator validated farmer delivery quality.'),
                                              );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Ruled in favor of seller. Escrow disbursed.'), backgroundColor: AppColors.success),
                                          );
                                        },
                                        child: const Text('Rule for Seller'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                        onPressed: () {
                                          context.read<EscrowBloc>().add(
                                                ResolveDisputeEvent(d.id, 'REFUND_BUYER', adminNotes: 'Moisture above limit. Order cancelled and refunded.'),
                                              );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Ruled in favor of buyer. Escrow refunded.'), backgroundColor: AppColors.error),
                                          );
                                        },
                                        child: const Text('Refund Buyer'),
                                      ),
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }
}

