import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ev_connect_india/providers/auth_provider.dart';
import 'package:ev_connect_india/config/routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEmailLogin = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _signInWithGoogle() {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Icon(Icons.ev_station, size: 72, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'EV Connect India',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find, navigate & charge your EV',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: authState.status == AuthStatus.loading ? null : _signInWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text('Continue with Google'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push(Routes.phoneLogin),
                icon: const Icon(Icons.phone_android),
                label: const Text('Continue with Phone'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: colorScheme.outline),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ),
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),
              if (_isEmailLogin) ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty
                      ? () {
                          ref.read(authProvider.notifier).clearError();
                          ref.read(authProvider.notifier).signInWithEmail(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sign In'),
                ),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      authState.error!,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ] else ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    prefixText: '+91 ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _phoneController.text.length >= 10 ? () => context.push(Routes.phoneLogin) : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Get OTP'),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isEmailLogin = !_isEmailLogin),
                child: Text(_isEmailLogin ? 'Use Phone Number Instead' : 'Use Email & Password Instead'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    height: 24, width: 24,
                    child: Checkbox(value: _agreedToTerms, onChanged: (v) => setState(() => _agreedToTerms = v ?? false)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        children: [
                          TextSpan(text: 'Terms of Service', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                          TextSpan(text: ' and '),
                          TextSpan(text: 'Privacy Policy', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
