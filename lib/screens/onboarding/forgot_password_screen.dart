import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/ui.dart';
import 'widgets/auth_widgets.dart';

/// "Forgot password" flow, reachable from both the student and the
/// teacher/admin login screens. Two steps in one screen:
///   1. Enter email -> emails a 6-digit recovery code.
///   2. Enter that code + a new password -> account password is updated.
/// On success the person is sent back to sign in with the new password
/// (see [AuthController.updatePasswordAfterReset]).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});
  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final _emailController = TextEditingController(text: widget.initialEmail ?? '');
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _codeSent = false;
  bool _obscure = true;
  bool _submitting = false;
  bool _resending = false;
  String? _errorText;
  String? _infoText;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown <= 1) {
        t.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  bool get _emailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailController.text.trim());

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (!_emailValid) {
      setState(() => _errorText = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _errorText = null;
      _submitting = true;
    });
    try {
      await ref.read(authControllerProvider.notifier).sendPasswordResetOtp(email: email);
      setState(() {
        _codeSent = true;
        _infoText = 'If an account exists for $email, a 6-digit code was sent.';
      });
      _startCooldown();
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _errorText = null;
      _resending = true;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .resendPasswordResetOtp(email: _emailController.text.trim());
      setState(() => _infoText = 'A new code was sent to ${_emailController.text.trim()}.');
      _startCooldown();
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _resetPassword() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    setState(() => _errorText = null);

    if (code.length < 6) {
      setState(() => _errorText = 'Enter the 6-digit code from your email.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorText = 'Password must be at least 6 characters.');
      return;
    }
    if (password != _confirmController.text) {
      setState(() => _errorText = "Passwords don't match.");
      return;
    }

    setState(() => _submitting = true);
    final notifier = ref.read(authControllerProvider.notifier);
    try {
      await notifier.verifyPasswordResetOtp(
        email: _emailController.text.trim(),
        token: code,
      );
      await notifier.updatePasswordAfterReset(password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated — sign in with your new password.')),
      );
      context.go(AppRoutes.roleSelect);
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            children: [
              AuthBackButton(onTap: () => context.pop()),
              const SizedBox(height: 22),
              AuthHeroHeader(
                icon: Icons.lock_reset_rounded,
                title: 'Reset your\npassword',
                subtitle: _codeSent
                    ? 'Enter the code we sent to ${_emailController.text.trim()} and choose a new password.'
                    : 'Enter your account email and we\'ll send you a 6-digit reset code.',
              ),
              const SizedBox(height: 28),
              if (_errorText != null) AuthErrorBanner(_errorText!),
              if (_infoText != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppBrand.purpleSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(_infoText!,
                      style: const TextStyle(
                          color: AppBrand.purple, fontSize: 13, fontWeight: FontWeight.w600)),
                ),

              const AuthFieldLabel('Email address'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                enabled: !_codeSent,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppBrand.ink),
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),

              if (!_codeSent) ...[
                const SizedBox(height: 22),
                GradientButton(
                  label: 'Send reset code',
                  icon: Icons.send_rounded,
                  loading: _submitting,
                  onPressed: _submitting ? null : _sendCode,
                ),
              ] else ...[
                const SizedBox(height: 16),
                const AuthFieldLabel('Verification code'),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppBrand.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 10,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '000000',
                  ),
                ),

                const AuthFieldLabel('New password'),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  style: const TextStyle(color: AppBrand.ink),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const AuthFieldLabel('Confirm new password'),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  style: const TextStyle(color: AppBrand.ink),
                  decoration: const InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 22),

                GradientButton(
                  label: 'Reset password',
                  icon: Icons.check_rounded,
                  loading: _submitting,
                  onPressed: _submitting ? null : _resetPassword,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: (_resending || _resendCooldown > 0) ? null : _resend,
                    child: Text(
                      _resendCooldown > 0
                          ? 'Resend code in ${_resendCooldown}s'
                          : (_resending ? 'Sending…' : "Didn't get a code? Resend"),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
