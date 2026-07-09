import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/ui.dart';
import 'widgets/auth_widgets.dart';

/// Teachers sign up before they can log in, same pattern as students but
/// with a Subject instead of a Class/Age.
class TeacherSignUpScreen extends ConsumerStatefulWidget {
  const TeacherSignUpScreen({super.key});

  @override
  ConsumerState<TeacherSignUpScreen> createState() => _TeacherSignUpScreenState();
}

class _TeacherSignUpScreenState extends ConsumerState<TeacherSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Subject _subject = Subject.tech;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorText = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signUpTeacher(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            subject: _subject,
          );
      // Router redirect sends the now-logged-in teacher to /teacher.
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
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              children: [
                AuthBackButton(onTap: () => context.go(AppRoutes.roleSelect)),
                const SizedBox(height: 22),
                const AuthHeroHeader(
                  icon: Icons.co_present_rounded,
                  title: 'Create your\nteacher account',
                  subtitle: 'Set up your profile so you can start teaching, grading and mentoring students.',
                ),
                const SizedBox(height: 28),
                if (_errorText != null) AuthErrorBanner(_errorText!),

                const AuthFieldLabel('Full name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: AppBrand.ink),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Ananya Rao',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),

                const AuthFieldLabel('Email address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppBrand.ink),
                  decoration: const InputDecoration(
                    hintText: 'teacher@example.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Enter your email';
                    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
                    return valid ? null : 'Enter a valid email address';
                  },
                ),
                const SizedBox(height: 16),

                const AuthFieldLabel('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: AppBrand.ink),
                  decoration: InputDecoration(
                    hintText: 'Minimum 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),

                const AuthFieldLabel('Confirm password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  style: const TextStyle(color: AppBrand.ink),
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) =>
                      (v != _passwordController.text) ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 16),

                const AuthFieldLabel('Subject'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Subject.values.map((s) {
                    final selected = s == _subject;
                    return ChoiceChip(
                      label: Text(s.label),
                      selected: selected,
                      avatar: Icon(s.icon, size: 16, color: selected ? Colors.white : s.color),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppBrand.ink,
                      ),
                      selectedColor: s.color,
                      backgroundColor: s.color.withValues(alpha: .14),
                      side: BorderSide(color: s.color.withValues(alpha: .4)),
                      onSelected: (_) => setState(() => _subject = s),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                GradientButton(
                  label: 'Create Teacher Account',
                  icon: Icons.arrow_forward_rounded,
                  loading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
                const SizedBox(height: 16),

                AuthFooterLink(
                  question: 'Already have an account?',
                  actionLabel: 'Sign In',
                  onTap: () => context.go(AppRoutes.teacherLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
