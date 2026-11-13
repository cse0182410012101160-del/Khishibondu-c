import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/plugins/plugin_registry.dart';
import '../bloc/analytics_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'package:agro_bridge/features/microfinance/presentation/screens/credit_score_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  final UserEntity currentUser;
  const FarmerDashboardScreen({super.key, required this.currentUser});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(FetchFarmerAnalyticsEvent(farmerId: widget.currentUser.id));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final plugins = PluginRegistry().getPluginsForRole('farmer');

    return Scaffold(
      appBar: AppBar(
        title: Text('${loc.translate('analytics')} & Financial Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AnalyticsBloc>().add(FetchFarmerAnalyticsEvent(farmerId: widget.currentUser.id)),
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalyticsErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is FarmerAnalyticsLoadedState) {
            final a = state.analytics;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // KPI Overview Cards
                  Row(
                    children: [
                      Expanded(
                        child: _kpiCard(
                          title: 'Total Revenue',
                          value: '৳ ${a.totalRevenueBdt.toStringAsFixed(0)}',
                          sub: '${a.completedOrdersCount} Fulfilled Lots',
                          icon: Icons.payments,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _kpiCard(
                          title: 'In Escrow Vault',
                          value: '৳ ${a.pendingEscrowBdt.toStringAsFixed(0)}',
                          sub: 'Protected Buyer Funds',
                          icon: Icons.lock_clock,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Credit Score Action Card
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreditScoreScreen(currentUser: widget.currentUser)),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.steelMist.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(color: AppColors.accent, width: 2),
                            ),
                            child: Text(
                              '${a.creditScore}',
                              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Agro-Bridge Credit Tier: ${a.creditTier}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Tap to view loan pre-approval and Get Credit',
                                  style: TextStyle(color: AppColors.steelMist, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Get Credit', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Active Drop-in Feature Plugins
                  if (plugins.isNotEmpty) ...[
                    const Text('Pluggable Agricultural AI & Satellite Tools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    ...plugins.map((plugin) {
                      final card = plugin.buildDashboardCard(context);
                      if (card != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: card,
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 10),
                  ],

                  // Monthly Sales Trend
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Seasonal Revenue History (BDT)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 14),
                          ...a.monthlyRevenue.map((m) {
                            final maxRev = a.totalRevenueBdt > 0 ? a.totalRevenueBdt : 1.0;
                            final ratio = (m['revenue'] as num) / maxRev;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: Text(m['month'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: ratio.clamp(0.05, 1.0),
                                        minHeight: 12,
                                        backgroundColor: Colors.grey.shade200,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 80,
                                    child: Text('৳ ${m['revenue']}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Top Selling Produce
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Best-Selling Crops by Revenue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 10),
                          ...a.topCrops.map((crop) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.grass, color: AppColors.primary),
                                title: Text(crop['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                trailing: Text('৳ ${crop['revenue']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              )),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

