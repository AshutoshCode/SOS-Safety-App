import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _otpController;
  bool _showOtpField = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
    context.read<AuthProvider>().sendOtp(formattedPhone);
    setState(() => _showOtpField = true);
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    final success = await context.read<AuthProvider>().verifyOtp(otp);
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Icon(
                    Icons.emergency_share,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Silent Emergency Alert',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trigger SOS without unlocking your phone',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Phone field
                  TextField(
                    controller: _phoneController,
                    enabled: !_showOtpField && !authProvider.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '9876543210',
                      prefixText: '+91 ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText: authProvider.error != null && !_showOtpField
                          ? authProvider.error
                          : null,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // OTP field (conditional)
                  if (_showOtpField)
                    TextField(
                      controller: _otpController,
                      enabled: !authProvider.isLoading,
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        hintText: '000000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: authProvider.error != null && _showOtpField
                            ? authProvider.error
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                  const SizedBox(height: 24),

                  // Send OTP / Verify OTP button
                  ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : (_showOtpField ? _verifyOtp : _sendOtp),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(
                      _showOtpField ? 'Verify OTP' : 'Send OTP',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  // Back button (conditional)
                  if (_showOtpField) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() => _showOtpField = false);
                        _otpController.clear();
                        context.read<AuthProvider>().clearError();
                      },
                      child: const Text('Change Phone Number'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
