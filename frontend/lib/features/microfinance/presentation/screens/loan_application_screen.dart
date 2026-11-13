import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../bloc/microfinance_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';

class LoanApplicationScreen extends StatefulWidget {
  final UserEntity currentUser;
  final int creditScore;
  final double maxLimit;

  const LoanApplicationScreen({
    super.key,
    required this.currentUser,
    required this.creditScore,
    required this.maxLimit,
  });

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _purposeController = TextEditingController(
    text: 'উন্নত জাতের বীজধান, সার এবং সেচ খরচের জন্য ঋণের আবেদন।',
  );

  String _selectedNgoId = 'usr_ngo_1'; // BRAC
  int _selectedTenure = 6;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: (widget.maxLimit * 0.6).round().toString());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'সহজ কৃষিঋণের আবেদন (Get Credit)' : 'Apply for Harvest Microloan'),
      ),
      body: BlocConsumer<MicrofinanceBloc, MicrofinanceState>(
        listener: (context, state) {
          if (state is LoanAppliedSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isBn
                      ? 'অভিনন্দন! কৃষিঋণের আবেদন সফলভাবে জমা হয়েছে। এনজিও কর্মকর্তা আপনার প্রোফাইল যাচাই করবেন।'
                      : 'Microloan application submitted successfully! NGO partner will review your profile.',
                ),
                backgroundColor: AppColors.secondary,
              ),
            );
            Navigator.pop(context);
          } else if (state is MicrofinanceErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is MicrofinanceLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Collateral Notice (#BAC8D9 border, #193940 text, #7ABF5A icon)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified, color: AppColors.secondary, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn
                                    ? 'ক্রেডিট স্কোর: ${widget.creditScore} (অনুমোদিত)'
                                    : 'Credit Score Snapshot: ${widget.creditScore} (Prime)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isBn
                                    ? 'সর্বোচ্চ ৳ ${widget.maxLimit.toStringAsFixed(0)} টাকা পর্যন্ত জামানতহীন ঋণের সুবিধা।'
                                    : 'Pre-approved up to ৳ ${widget.maxLimit.toStringAsFixed(0)} without physical land deeds.',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    isBn ? 'ঋণ প্রদানকারী ক্ষুদ্রঋণ সংস্থা নির্বাচন করুন' : 'Select Microfinance / NGO Partner',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  _partnerTile(
                    ngoId: 'usr_ngo_1',
                    name: isBn ? 'ব্র্যাক মাইক্রোফাইন্যান্স' : 'BRAC Microfinance',
                    program: 'BRAC Krishi Shurokkha (কৃষি সুরক্ষা ঋণ)',
                    rate: '9.0% p.a.',
                    disbursement: isBn ? 'সরাসরি বিকাশ ওয়ালেট' : 'Direct bKash Wallet',
                  ),
                  const SizedBox(height: 8),
                  _partnerTile(
                    ngoId: 'usr_ngo_2',
                    name: isBn ? 'গ্রামীণ ব্যাংক কৃষি ঋণ' : 'Grameen Krishi Rin',
                    program: 'Grameen Seasonal Harvest Credit (মওসুমী ঋণ)',
                    rate: '8.5% p.a.',
                    disbursement: isBn ? 'সরাসরি নগদ ওয়ালেট' : 'Direct Nagad Wallet',
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isBn ? 'আবেদনকৃত ঋণের পরিমাণ (টাকা)' : 'Requested Loan Amount (BDT)',
                      prefixText: '৳ ',
                      helperText: isBn
                          ? 'সর্বোচ্চ অনুমোদিত সীমা: ৳ ${widget.maxLimit.toStringAsFixed(0)}'
                          : 'Maximum eligible ceiling: ৳ ${widget.maxLimit.toStringAsFixed(0)}',
                    ),
                    validator: (val) {
                      final num = double.tryParse(val ?? '');
                      if (num == null || num <= 0) {
                        return isBn ? 'সঠিক টাকার পরিমাণ লিখুন' : 'Enter valid amount';
                      }
                      if (num > widget.maxLimit) {
                        return isBn ? 'অনুমোদিত সীমার চেয়ে বেশি' : 'Exceeds maximum pre-approved ceiling';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    initialValue: _selectedTenure,
                    decoration: InputDecoration(
                      labelText: isBn ? 'পরিশোধের মেয়াদ' : 'Repayment Tenure',
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 3,
                        child: Text(isBn ? '৩ মাস (এক মওসুমী সুবিধা)' : '3 Months (Quick Seasonal Turnaround)'),
                      ),
                      DropdownMenuItem(
                        value: 6,
                        child: Text(isBn ? '৬ মাস (পূর্ণাঙ্গ ফসল চক্র)' : '6 Months (Full Crop Cycle)'),
                      ),
                      DropdownMenuItem(
                        value: 9,
                        child: Text(isBn ? '৯ মাস (বহু-ফসল বিনিয়োগ)' : '9 Months (Multi-crop Investment)'),
                      ),
                      DropdownMenuItem(
                        value: 12,
                        child: Text(isBn ? '১২ মাস (বার্ষিক সার্বিক সুবিধা)' : '12 Months (Annual Facility)'),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedTenure = val!),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _purposeController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: isBn ? 'ঋণ ব্যবহারের উদ্দেশ্য' : 'Utilization Purpose',
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<MicrofinanceBloc>().add(
                                    ApplyLoanEvent({
                                      'ngoId': _selectedNgoId,
                                      'requestedAmount': double.parse(_amountController.text.trim()),
                                      'tenureMonths': _selectedTenure,
                                      'purpose': _purposeController.text.trim(),
                                      'programName': _selectedNgoId == 'usr_ngo_1'
                                          ? 'BRAC Krishi Shurokkha'
                                          : 'Grameen Seasonal Credit',
                                    }),
                                  );
                            }
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      isLoading
                          ? (isBn ? 'আবেদন জমা হচ্ছে...' : 'Submitting Application...')
                          : (isBn ? 'ঋণের আবেদন সম্পন্ন করুন' : 'Submit Microloan Application'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _partnerTile({
    required String ngoId,
    required String name,
    required String program,
    required String rate,
    required String disbursement,
  }) {
    final isSelected = _selectedNgoId == ngoId;
    return InkWell(
      onTap: () => setState(() => _selectedNgoId = ngoId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceVariant : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceVariant,
              child: Icon(Icons.account_balance, color: isSelected ? AppColors.accent : AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                  Text(program, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(rate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.secondary)),
                      const SizedBox(width: 8),
                      Text('• $disbursement', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
