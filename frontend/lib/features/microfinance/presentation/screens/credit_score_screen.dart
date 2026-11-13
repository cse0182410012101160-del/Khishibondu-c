import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../bloc/microfinance_bloc.dart';
import 'emi_calculator_screen.dart';
import 'loan_application_screen.dart';
import '../../../auth/domain/entities/user_entity.dart';

class CreditScoreScreen extends StatefulWidget {
  final UserEntity currentUser;
  const CreditScoreScreen({super.key, required this.currentUser});

  @override
  State<CreditScoreScreen> createState() => _CreditScoreScreenState();
}

class _CreditScoreScreenState extends State<CreditScoreScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MicrofinanceBloc>().add(FetchCreditProfileEvent(farmerId: widget.currentUser.id));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'কৃষিঋণ যোগ্যতা ও ক্রেডিট স্কোর' : 'Credit Score & Microfinance'),
      ),
      body: BlocBuilder<MicrofinanceBloc, MicrofinanceState>(
        builder: (context, state) {
          if (state is MicrofinanceLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is MicrofinanceErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text('Error: ${state.message}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<MicrofinanceBloc>().add(
                            FetchCreditProfileEvent(farmerId: widget.currentUser.id),
                          ),
                      child: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is CreditProfileLoadedState) {
            final profile = state.creditProfile;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Circular Score Card (Palette: #193940 primary, #9BF272 accent score, #BAC8D9 border)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.steelMist.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.accent, width: 1),
                          ),
                          child: Text(
                            '${profile.tier.toUpperCase()} TIER • ${profile.riskGrade}',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 145,
                          height: 145,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent, width: 5),
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${profile.score}',
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 46,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Scale 300 - 850',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          isBn ? 'অনুমোদিত সুদের হার সুবিধা' : 'Interest Discount Benefit',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBn
                              ? 'বেস সুদে ${((1.0 - profile.interestRateModifier) * 100).toStringAsFixed(0)}% বিশেষ কনসেশনাল ছাড়'
                              : '${((1.0 - profile.interestRateModifier) * 100).toStringAsFixed(0)}% Discount Applied on Standard MFI Base Interest',
                          style: const TextStyle(color: AppColors.steelMist, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pre-Approved Limit Banner (#BAC8D9 border, #7ABF5A / #9BF272 actions)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isBn ? 'অনুমোদিত সর্বোচ্চ ঋণের সীমা' : 'Pre-Approved Microloan Limit',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isBn ? 'জামানতমুক্ত' : 'Zero Collateral',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '৳ ${profile.maxPreApprovedLoanBdt.toStringAsFixed(0)} BDT',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.translate('noCollateralNotice'),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const EmiCalculatorScreen()),
                                  );
                                },
                                icon: const Icon(Icons.calculate_outlined, size: 18),
                                label: Text(isBn ? 'কিস্তির হিসাব' : 'EMI Simulator'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoanApplicationScreen(
                                        currentUser: widget.currentUser,
                                        creditScore: profile.score,
                                        maxLimit: profile.maxPreApprovedLoanBdt,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.payments_rounded, size: 18),
                                label: Text(
                                  isBn ? 'ঋণ নিন (Get Credit)' : 'Get Credit Now',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Scoring Factor Breakdown
                  Text(
                    isBn ? 'ক্রেডিট স্কোর নির্ধারণের বিস্তারিত মানদণ্ড' : 'Dynamic Scoring Factor Breakdown',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  _factorTile(
                    title: isBn ? 'যাচাইকৃত মোট বিক্রির পরিমাণ' : 'Verified Sales Volume',
                    value: '৳ ${profile.totalSalesBdt.toStringAsFixed(0)} BDT',
                    scoreDetail: '+${profile.breakdown['salesVolumePoints'] ?? 150} pts (Max 180)',
                    icon: Icons.payments_outlined,
                  ),
                  _factorTile(
                    title: isBn ? 'অর্ডার সময়মতো সফল ডেলিভারি হার' : 'Order Fulfillment Reliability',
                    value: '${profile.fulfillmentRatePct}% Delivered',
                    scoreDetail: '+${profile.breakdown['fulfillmentPoints'] ?? 120} pts (Max 120)',
                    icon: Icons.assignment_turned_in_outlined,
                  ),
                  _factorTile(
                    title: isBn ? 'ক্রেতাদের রেটিং ও মূল্যায়ন' : 'Buyer Ratings & Feedback',
                    value: '★ ${profile.buyerRating.toStringAsFixed(1)} / 5.0',
                    scoreDetail: '+${profile.breakdown['ratingPoints'] ?? 96} pts (Max 100)',
                    icon: Icons.star_border,
                  ),
                  _factorTile(
                    title: isBn ? 'জাতীয় পরিচয়পত্র ও বাজার অভিজ্ঞতা' : 'NID KYC & Marketplace Tenure',
                    value: isBn ? 'এনআইডি যাচাইকৃত' : 'NID Verified',
                    scoreDetail: '+${profile.breakdown['tenureAndKycPoints'] ?? 90} pts (Max 100)',
                    icon: Icons.verified_user_outlined,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _factorTile({
    required String title,
    required String value,
    required String scoreDetail,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceVariant,
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
        subtitle: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            scoreDetail,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
