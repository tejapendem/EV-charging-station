import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ev_connect_india/providers/auth_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _otpSent = false;
  bool _isLoading = false;
  String _selectedCountryCode = '+91';
  int _resendSeconds = 30;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    super.dispose();
  }

  void _sendOtp() {
    setState(() => _isLoading = true);
    final phone = '$_selectedCountryCode${_phoneController.text}';
    ref.read(authProvider.notifier).sendPhoneOtp(
      phoneNumber: phone,
      verificationCompleted: (cred) {
        setState(() => _isLoading = false);
      },
      verificationFailed: (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${e.message}'), behavior: SnackBarBehavior.floating),
        );
      },
      codeSent: (verificationId, forceResendToken) {
        _verificationId = verificationId;
        setState(() {
          _otpSent = true;
          _isLoading = false;
        });
        _startResendTimer();
        _otpFocusNodes[0].requestFocus();
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() { if (_resendSeconds > 0) _resendSeconds--; });
      return _resendSeconds > 0 && mounted;
    });
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6 && _verificationId != null) {
      setState(() => _isLoading = true);
      ref.read(authProvider.notifier).verifyPhoneOtp(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) _otpFocusNodes[index + 1].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_otpSent ? 'Verify OTP' : 'Phone Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(Icons.phone_android, size: 64, color: colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                _otpSent ? 'Enter Verification Code' : 'Enter Phone Number',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _otpSent
                    ? 'We\'ve sent a 6-digit code to $_selectedCountryCode ${_phoneController.text}'
                    : 'We\'ll send you a one-time password',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),
              if (!_otpSent) ...[
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountryCode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        items: const [
                          DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                          DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                          DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                        ],
                        onChanged: (v) { if (v != null) setState(() => _selectedCountryCode = v); },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                        decoration: InputDecoration(
                          hintText: '9876543210',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _phoneController.text.length >= 10 && !_isLoading ? _sendOtp : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Send OTP'),
                ),
              ] else ...[
                Form(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          onChanged: (v) => _onOtpChanged(v, index),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _otpControllers.every((c) => c.text.isNotEmpty) && !_isLoading ? _verifyOtp : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Verify & Continue'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _resendSeconds == 0 ? _sendOtp : null,
                  child: Text(_resendSeconds > 0 ? 'Resend code in $_resendSeconds seconds' : 'Resend Code'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      for (final c in _otpControllers) c.clear();
                    });
                  },
                  child: const Text('Change Phone Number'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
