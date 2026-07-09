import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/ui.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  Grade? _selectedGrade;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedGrade == null) {
      if (_selectedGrade == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your class')),
        );
      }
      return;
    }
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).completeStudentOnboarding(
          name: _nameController.text.trim(),
          grade: _selectedGrade!,
          age: int.parse(_ageController.text.trim()),
        );
    // Router redirect handles navigation to /student once state updates.
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: AppBrand.card,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Padding(
                        padding: EdgeInsets.all(11),
                        child: Icon(Icons.arrow_back_rounded, color: AppBrand.ink, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // ---- Illustration area ----
                Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppBrand.heroGradient,
                      borderRadius: BorderRadius.circular(38),
                      boxShadow: [
                        BoxShadow(
                          color: AppBrand.purple.withValues(alpha: .45),
                          blurRadius: 34,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 62),
                  ),
                ),
                const SizedBox(height: 30),

                // ---- Bold two-line headline ----
                const Text(
                  'Let’s set up\nyour learning space',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: AppBrand.ink,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tell us a little about yourself so we can tailor classes, quizzes and doubt-solving to your level.',
                  style: TextStyle(color: AppBrand.inkSoft, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 28),

                _FieldLabel('Full name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppBrand.ink),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Aarav Sharma',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 18),

                _FieldLabel('Class'),
                const SizedBox(height: 8),
                DropdownButtonFormField<Grade>(
                  value: _selectedGrade,
                  dropdownColor: AppBrand.cardAlt,
                  style: const TextStyle(color: AppBrand.ink, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Select your class',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: Grade.values
                      .map((g) => DropdownMenuItem(value: g, child: Text(g.label)))
                      .toList(),
                  onChanged: (g) => setState(() => _selectedGrade = g),
                ),
                const SizedBox(height: 18),

                _FieldLabel('Age'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ageController,
                  style: const TextStyle(color: AppBrand.ink),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 15',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 5 || n > 25) return 'Enter a valid age';
                    return null;
                  },
                ),
                const SizedBox(height: 34),

                GradientButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  loading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppBrand.ink,
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
        ),
      );
}
