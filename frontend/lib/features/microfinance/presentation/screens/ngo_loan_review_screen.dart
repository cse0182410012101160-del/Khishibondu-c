import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/microfinance_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';

class NgoLoanReviewScreen extends StatefulWidget {
  final UserEntity currentUser;
  const NgoLoanReviewScreen({super.key, required this.currentUser});

  @override
  State<NgoLoanReviewScreen> createState() => _NgoLoanReviewScreenState();
}

class _NgoLoanReviewScreenState extends State<NgoLoanReviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MicrofinanceBloc>().add(const FetchLoanApplicationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MFI Credit Audit & Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MicrofinanceBloc>().add(const FetchLoanApplicationsEvent()),
          ),
        ],
      ),
      body: BlocBuilder<MicrofinanceBloc, MicrofinanceState>(
        builder: (context, state) {
          if (state is MicrofinanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MicrofinanceErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is LoanApplicationsLoadedState) {
            final apps = state.applications;
            if (apps.isEmpty) {
              return const Center(child: Text('No pending loan applications.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final isApproved = app.status == 'APPROVED';
                final isDisbursed = app.status == 'DISBURSED';

                Color statusColor = AppColors.warning;
                if (isApproved) statusColor = AppColors.info;
                if (isDisbursed) statusColor = AppColors.success;
                if (app.status == 'REJECTED') statusColor = AppColors.error;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              app.programName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                app.status,
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Applicant: ${app.farmerName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(app.purpose, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        const Divider(height: 20),
                        // Audit Metrics
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _auditItem('Credit Score', '${app.farmerCreditScoreSnapshot}', AppColors.primary),
                            _auditItem('Verified Sales', '৳ ${app.historicalSalesVolumeBdt.toStringAsFixed(0)}', AppColors.textPrimary),
                            _auditItem('Requested', '৳ ${app.requestedAmount.toStringAsFixed(0)}', AppColors.secondary),
                            _auditItem('Tenure', '${app.tenureMonths} Mos', AppColors.textPrimary),
                          ],
                        ),
                        if (app.status == 'SUBMITTED' || app.status == 'UNDER_REVIEW') ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(color: AppColors.error),
                                  ),
                                  onPressed: () {
                                    context.read<MicrofinanceBloc>().add(
                                          UpdateLoanStatusEvent(app.id, 'REJECTED'),
                                        );
                                  },
                                  child: const Text('Decline'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                  onPressed: () {
                                    context.read<MicrofinanceBloc>().add(
                                          UpdateLoanStatusEvent(
                                            app.id,
                                            'DISBURSED',
                                            approvedAmount: app.requestedAmount,
                                            mfsProvider: 'bKash',
                                          ),
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Loan of ৳ ${app.requestedAmount.toStringAsFixed(0)} approved and disbursed to farmer via bKash!'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  },
                                  child: const Text('Approve & Disburse'),
                                ),
                              ),
                            ],
                          ),
                        ] else if (isDisbursed) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Disbursed via ${app.disbursedViaMfs} • Txn: ${app.disbursedTxnId}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _auditItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
      ],
    );
  }
}

