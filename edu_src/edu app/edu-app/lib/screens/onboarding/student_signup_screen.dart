import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/ui.dart';
import 'widgets/auth_widgets.dart';

/// New students sign up before they can log in — this is the first screen
/// a student sees after choosing "Student" on the Welcome screen.
class StudentSignUpScreen extends ConsumerStatefulWidget {
  const StudentSignUpScreen({super.key});

  @override
  ConsumerState<StudentSignUpScreen> createState() => _StudentSignUpScreenState();
}

class _StudentSignUpScreenState extends ConsumerState<StudentSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _ageController = TextEditingController();

  Grade? _grade;
  String? _gender;
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
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorText = null);
    final formOk = _formKey.currentState!.validate();
    if (_grade == null) {
      setState(() => _errorText = 'Please select your class.');
    }
    if (!formOk || _grade == null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signUpStudent(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            age: int.parse(_ageController.text.trim()),
            grade: _grade!,
            gender: _gender,
          );
      // Router redirect sends the now-logged-in student to /student.
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
                  icon: Icons.backpack_rounded,
                  title: 'Create your\nstudent account',
                  subtitle:
                      'Tell us a little about yourself so we can tailor classes, quizzes and doubt-solving to your level.',
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
                    hintText: 'e.g. Aarav Sharma',
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
                    hintText: 'you@example.com',
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

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AuthFieldLabel('Age'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppBrand.ink),
                            decoration: const InputDecoration(
                              hintText: 'e.g. 15',
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              if (n == null) return 'Numeric only';
                              if (n < 5 || n > 25) return 'Enter a valid age';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const AuthFieldLabel('Class'),
                const SizedBox(height: 8),
                DropdownButtonFormField<Grade>(
                  value: _grade,
                  dropdownColor: AppBrand.cardAlt,
                  style: const TextStyle(color: AppBrand.ink, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Select your class',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: Grade.values
                      .map((g) => DropdownMenuItem(value: g, child: Text(g.label)))
                      .toList(),
                  onChanged: (g) => setState(() => _grade = g),
                ),
                const SizedBox(height: 16),

                const AuthFieldLabel('Gender', optional: true),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _gender,
                  dropdownColor: AppBrand.cardAlt,
                  style: const TextStyle(color: AppBrand.ink, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Prefer not to say',
                    prefixIcon: Icon(Icons.wc_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (g) => setState(() => _gender = g),
                ),
                const SizedBox(height: 30),

                GradientButton(
                  label: 'Create Student Account',
                  icon: Icons.arrow_forward_rounded,
                  loading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
                const SizedBox(height: 16),

                AuthFooterLink(
                  question: 'Already have an account?',
                  actionLabel: 'Sign In',
                  onTap: () => context.go(AppRoutes.studentLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
