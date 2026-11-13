import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import 'role_selection_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String mockOtp;

  const OtpScreen({super.key, required this.phone, required this.mockOtp});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController(text: widget.mockOtp);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('verifyOtp'))),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is NewUserNeedsRegistrationState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => RoleSelectionScreen(phone: state.phone)),
            );
          } else if (state is AuthenticatedState) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.primary),
                const SizedBox(height: 20),
                Text(
                  loc.translate('enterOtp'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sent to ${widget.phone}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Demo Testing OTP: ${widget.mockOtp}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  maxLength: 6,
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '123456',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                                VerifyOtpEvent(widget.phone, _otpController.text.trim()),
                              );
                        },
                  child: Text(isLoading ? 'Verifying...' : loc.translate('verifyOtp')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

