import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  double _principal = 100000;
  int _tenureMonths = 6;
  double _annualRate = 9.0;
  String _method = 'declining';

  double get _monthlyEmi {
    if (_method == 'flat') {
      return _totalPayable / _tenureMonths;
    }
    final p = _principal;
    final r = (_annualRate / 100) / 12;
    final n = _tenureMonths;
    if (r == 0) return p / n;
    return (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  }

  double get _totalPayable {
    if (_method == 'flat') {
      return _principal +
          (_principal * (_annualRate / 100) * (_tenureMonths / 12));
    }
    final p = _principal;
    final r = (_annualRate / 100) / 12;
    final n = _tenureMonths;
    return r == 0 ? p : ((p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1)) * n;
  }

  double get _apr => _method == 'flat'
      ? _annualRate * (2 * _tenureMonths / (_tenureMonths + 1))
      : _annualRate;
  double get _totalInterest => _totalPayable - _principal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EMI & Loan Repayment Simulator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result Highlight Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Estimated Monthly Installment (EMI)',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '৳ ${_monthlyEmi.round().toString()}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text('/ month',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Divider(color: Colors.white24, height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Principal Amount',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('৳ ${_principal.round()}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                              'Total Interest (${_apr.toStringAsFixed(1)}% APR)',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('৳ ${_totalInterest.round()}',
                              style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Total Payable',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('৳ ${_totalPayable.round()}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('APR',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('${_apr.toStringAsFixed(1)}%',
                              style: TextStyle(
                                  color: _apr > 27
                                      ? Colors.redAccent
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sliders & Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Loan Principal (ঋণের পরিমাণ)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('৳ ${_principal.round()} BDT',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 15)),
                      ],
                    ),
                    Slider(
                      value: _principal,
                      min: 25000,
                      max: 500000,
                      divisions: 19,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _principal = val),
                    ),
                    const SizedBox(height: 14),
                    const Text('Interest Method',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['declining', 'flat'].map((method) {
                        final isSelected = _method == method;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(method == 'flat'
                                ? 'Flat rate'
                                : 'Declining balance'),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary),
                            onSelected: (selected) {
                              if (selected) setState(() => _method = method);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Text('Repayment Tenure (পরিশোধের মেয়াদ)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [3, 6, 9, 12].map((months) {
                        final isSelected = _tenureMonths == months;
                        return ChoiceChip(
                          label: Text('$months Months'),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _tenureMonths = months);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Annual Interest Rate',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('${_annualRate.toStringAsFixed(1)}% p.a.',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                    Slider(
                      value: _annualRate,
                      min: 0,
                      max: 40,
                      divisions: 80,
                      activeColor: AppColors.primary,
                      onChanged: (value) => setState(() => _annualRate = value),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_apr > 27)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDA4AF)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                    SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            'Warning: APR is above 27%. Review the repayment cost before applying.',
                            style: TextStyle(color: Color(0xFF9F1239)))),
                  ],
                ),
              ),

            if (_apr > 27) const SizedBox(height: 16),

            // Seasonal Repayment Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Optional: Farmers may select Seasonal Bullet Repayment to pay the principal lump-sum directly after the harvest sale via bKash escrow.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
