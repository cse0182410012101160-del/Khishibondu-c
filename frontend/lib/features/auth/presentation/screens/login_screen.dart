import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/agro_image.dart';
import '../bloc/auth_bloc.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '01711223344');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeCubit = context.read<LocaleCubit>();
    final isBn = loc.isBangla;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('appName')),
        actions: [
          // Prominent Bangla / English switcher pill button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: InkWell(
              onTap: () => localeCubit.toggleLocale(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.g_translate_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      isBn ? 'English' : 'বাংলা (Bangla)',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSentState) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpScreen(phone: state.phone, mockOtp: state.mockOtp),
              ),
            );
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Header
                AgroHeroImage(
                  imageUrl: 'https://images.unsplash.com/photo-1521791055366-0d553872125f?w=1200&auto=format&fit=crop',
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.agriculture_rounded, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        loc.translate('appName'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.translate('tagline'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Language reminder chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          isBn ? '✓ সম্পূর্ণ অ্যাপ বাংলায় প্রদর্শিত হচ্ছে' : 'Tip: Click top-right button to view entire app in Bangla',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // OTP Login Form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('phoneAuth'),
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isBn ? 'আপনার বাংলাদেশী মোবাইল নম্বর লিখুন (+৮৮০ ফরম্যাট)' : 'Enter your Bangladeshi mobile number (+880 format)',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  child: Text('+880', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                                ),
                                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                hintText: loc.translate('phoneHint'),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return isBn ? 'দয়া করে মোবাইল নম্বর লিখুন' : 'Please enter phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<AuthBloc>().add(
                                                RequestOtpEvent(_phoneController.text.trim()),
                                              );
                                        }
                                      },
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.arrow_forward),
                                label: Text(isLoading ? (isBn ? 'পাঠানো হচ্ছে...' : 'Sending...') : loc.translate('sendOtp')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Quick Demo Role Switcher
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            loc.translate('quickDemoLogin'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _demoRoleCard(
                              title: isBn ? 'কৃষক (Farmer)' : 'Farmer (কৃষক)',
                              subtitle: isBn ? 'মোঃ রফিকুল (বগুড়া)' : 'Md. Rafiqul (Bogura)',
                              icon: Icons.person_pin,
                              color: AppColors.primary,
                              onTap: () => context.read<AuthBloc>().add(const DemoLoginEvent('farmer')),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _demoRoleCard(
                              title: isBn ? 'পাইকারি ক্রেতা (Buyer)' : 'Buyer (ক্রেতা)',
                              subtitle: isBn ? 'ঢাকা এগ্রো হোলসেল' : 'Dhaka Agro Ltd',
                              icon: Icons.storefront,
                              color: AppColors.secondary,
                              onTap: () => context.read<AuthBloc>().add(const DemoLoginEvent('buyer')),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _demoRoleCard(
                              title: isBn ? 'ক্ষুদ্রঋণ সংস্থা (NGO)' : 'NGO/MFI Partner',
                              subtitle: isBn ? 'ব্র্যাক মাইক্রোফাইন্যান্স' : 'BRAC Microfinance',
                              icon: Icons.account_balance,
                              color: AppColors.primaryLight,
                              onTap: () => context.read<AuthBloc>().add(const DemoLoginEvent('ngo')),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _demoRoleCard(
                              title: isBn ? 'অ্যাডমিন (Admin)' : 'Platform Admin',
                              subtitle: isBn ? 'এসক্রো ও অভিযোগ' : 'Disputes & Escrow',
                              icon: Icons.admin_panel_settings,
                              color: AppColors.primaryDark,
                              onTap: () => context.read<AuthBloc>().add(const DemoLoginEvent('admin')),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _demoRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
