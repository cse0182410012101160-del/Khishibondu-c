import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String phone;
  const RoleSelectionScreen({super.key, required this.phone});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _extraController = TextEditingController(); // Company or Org name
  String _selectedRole = 'farmer';
  String _selectedDivision = 'Rajshahi';
  String _selectedMfs = 'bKash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile & Role')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Select Your Primary Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _roleOption(
                          roleId: 'farmer',
                          label: 'Farmer (কৃষক)',
                          icon: Icons.person_pin,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _roleOption(
                          roleId: 'buyer',
                          label: 'Buyer (ক্রেতা)',
                          icon: Icons.storefront,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _roleOption(
                          roleId: 'ngo',
                          label: 'NGO/MFI Partner',
                          icon: Icons.account_balance,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _roleOption(
                          roleId: 'admin',
                          label: 'Admin',
                          icon: Icons.admin_panel_settings,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name (পূর্ণ নাম)'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter name' : null,
                  ),
                  const SizedBox(height: 14),
                  if (_selectedRole == 'buyer' || _selectedRole == 'ngo') ...[
                    TextFormField(
                      controller: _extraController,
                      decoration: InputDecoration(
                        labelText: _selectedRole == 'buyer' ? 'Company Name (কোম্পানি)' : 'Organization Name (সংস্থা)',
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDivision,
                    decoration: const InputDecoration(labelText: 'Division (বিভাগ)'),
                    items: AppConstants.divisions
                        .where((d) => d != 'All')
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedDivision = val!),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMfs,
                    decoration: const InputDecoration(labelText: 'Primary Payout MFS (বিকাশ/নগদ)'),
                    items: AppConstants.mfsProviders
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedMfs = val!),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                    RegisterUserEvent({
                                      'phone': widget.phone,
                                      'name': _nameController.text.trim(),
                                      'role': _selectedRole,
                                      'division': _selectedDivision,
                                      'district': 'Bogura',
                                      'mfsProvider': _selectedMfs,
                                      'companyName': _selectedRole == 'buyer' ? _extraController.text.trim() : null,
                                      'organizationName': _selectedRole == 'ngo' ? _extraController.text.trim() : null,
                                    }),
                                  );
                            }
                          },
                    child: Text(isLoading ? 'Creating Profile...' : 'Complete & Enter App'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _roleOption({required String roleId, required String label, required IconData icon}) {
    final isSelected = _selectedRole == roleId;
    return InkWell(
      onTap: () => setState(() => _selectedRole = roleId),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey.shade600),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

