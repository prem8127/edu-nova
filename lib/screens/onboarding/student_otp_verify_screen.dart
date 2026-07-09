import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/ui.dart';
import 'widgets/auth_widgets.dart';

/// Shown right after [StudentSignUpScreen] submits. The student's account
/// exists in Supabase Auth but is unconfirmed until they enter the 6-digit
/// code emailed to them (sent via the Gmail SMTP configured on the
/// Supabase project — see supabase/SETUP.md). Verifying creates their
/// session, so the router then sends them straight to the dashboard —
/// their class/grade was captured once at sign-up and is never asked again.
class StudentOtpVerifyScreen extends ConsumerStatefulWidget {
  const StudentOtpVerifyScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<StudentOtpVerifyScreen> createState() => _StudentOtpVerifyScreenState();
}

class _StudentOtpVerifyScreenState extends ConsumerState<StudentOtpVerifyScreen> {
  final _codeController = TextEditingController();
  bool _submitting = false;
  bool _resending = false;
  String? _errorText;
  String? _infoText;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _codeController.dispose();
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

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      setState(() => _errorText = 'Enter the 6-digit code from your email.');
      return;
    }
    setState(() {
      _errorText = null;
      _infoText = null;
      _submitting = true;
    });
    try {
      await ref.read(authControllerProvider.notifier).verifyStudentSignUpOtp(
            email: widget.email,
            token: code,
          );
      // Router redirect sends the now-logged-in student to /student.
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
      await ref.read(authControllerProvider.notifier).resendStudentSignUpOtp(email: widget.email);
      setState(() => _infoText = 'A new code was sent to ${widget.email}.');
      _startCooldown();
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
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
              AuthBackButton(onTap: () => context.go(AppRoutes.studentSignUp)),
              const SizedBox(height: 22),
              AuthHeroHeader(
                icon: Icons.mark_email_read_rounded,
                title: 'Verify your\nemail',
                subtitle: 'Enter the 6-digit code we sent to ${widget.email} to activate your account.',
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
              const SizedBox(height: 22),

              GradientButton(
                label: 'Verify & Continue',
                icon: Icons.check_rounded,
                loading: _submitting,
                onPressed: _submitting ? null : _verify,
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
          ),
        ),
      ),
    );
  }
}
