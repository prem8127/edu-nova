import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/local/seed_data_service.dart';
import '../../shared/widgets/ui.dart';

/// Real login UI (email/password style fields, gradient hero, social row)
/// over a functional demo-login underneath, since there's no backend yet.
/// Student always goes through onboarding; Teacher/Admin sign in with one
/// tap into a fixed seeded account so their dashboards show real content.
class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

enum _Tab { student, teacher, admin }

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen> {
  _Tab _tab = _Tab.student;
  Subject _teacherSubject = Subject.tech;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_tab == _Tab.student) {
      context.go(AppRoutes.onboarding);
      return;
    }
    setState(() => _submitting = true);
    if (_tab == _Tab.teacher) {
      final id = SeedIds.teacherFor(_teacherSubject);
      await ref.read(authControllerProvider.notifier).loginAs(AppUser(
            id: id,
            name: 'Demo Teacher',
            role: UserRole.teacher,
            assignedSubjects: [_teacherSubject],
          ));
    } else {
      await ref.read(authControllerProvider.notifier).loginAs(const AppUser(
            id: SeedIds.admin,
            name: 'Priya Sharma',
            role: UserRole.admin,
          ));
    }
    if (mounted) setState(() => _submitting = false);
  }

  void _comingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in is coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ---- Gradient hero ----
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 22, 28, 26),
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppBrand.heroGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppBrand.purple.withValues(alpha: .5),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Aditya Globals',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppBrand.purple,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Learn today.\nLead tomorrow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        color: AppBrand.ink,
                        letterSpacing: -.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Live classes, quizzes & doubt-solving for\nTech, Business, Finance and Content Creation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppBrand.inkSoft, fontSize: 13.5, height: 1.45),
                    ),
                  ],
                ),
              ),
              // ---- Dark sheet ----
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppBrand.card,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(top: BorderSide(color: AppBrand.line)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Role tabs
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppBrand.bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppBrand.line),
                          ),
                          child: Row(
                            children: [
                              _RoleTab(
                                label: 'Student',
                                icon: Icons.backpack_rounded,
                                selected: _tab == _Tab.student,
                                onTap: () => setState(() => _tab = _Tab.student),
                              ),
                              _RoleTab(
                                label: 'Teacher',
                                icon: Icons.co_present_rounded,
                                selected: _tab == _Tab.teacher,
                                onTap: () => setState(() => _tab = _Tab.teacher),
                              ),
                              _RoleTab(
                                label: 'Admin',
                                icon: Icons.admin_panel_settings_rounded,
                                selected: _tab == _Tab.admin,
                                onTap: () => setState(() => _tab = _Tab.admin),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          switch (_tab) {
                            _Tab.student => _isSignUp ? 'Create your account' : 'Start learning',
                            _Tab.teacher => _isSignUp ? 'Teacher sign up' : 'Teacher sign in',
                            _Tab.admin => 'Super Admin sign in',
                          },
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800, color: AppBrand.ink),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          switch (_tab) {
                            _Tab.student => "New here? We'll set your class and interests up in a minute.",
                            _Tab.teacher => 'Demo access — pick the subject you teach.',
                            _Tab.admin => 'Demo access with full platform visibility.',
                          },
                          style: const TextStyle(color: AppBrand.inkSoft, fontSize: 13),
                        ),
                        const SizedBox(height: 22),

                        if (_tab == _Tab.teacher) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: Subject.values.map((s) {
                              final selected = s == _teacherSubject;
                              return ChoiceChip(
                                label: Text(s.label),
                                selected: selected,
                                avatar: Icon(s.icon,
                                    size: 16, color: selected ? Colors.white : s.color),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : AppBrand.ink,
                                ),
                                selectedColor: s.color,
                                backgroundColor: s.color.withValues(alpha: .14),
                                side: BorderSide(color: s.color.withValues(alpha: .4)),
                                onSelected: (_) => setState(() => _teacherSubject = s),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                        ],

                        if (_tab != _Tab.student) ...[
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppBrand.ink),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: _tab == _Tab.teacher
                                  ? 'teacher@edunova.demo'
                                  : 'admin@edunova.demo',
                              prefixIcon: const Icon(Icons.mail_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            style: const TextStyle(color: AppBrand.ink),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _comingSoon('Password reset'),
                              child: const Text('Forgot password?'),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],

                        GradientButton(
                          label: _tab == _Tab.student
                              ? "I'm a Student — Get Started"
                              : (_isSignUp ? 'Create account' : 'Sign in'),
                          icon: _tab == _Tab.student ? Icons.arrow_forward_rounded : null,
                          loading: _submitting,
                          onPressed: _submitting ? null : _continue,
                        ),
                        const SizedBox(height: 14),

                        // Text-link toggle between sign-in / sign-up
                        if (_tab != _Tab.admin)
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  _isSignUp ? 'Already have an account?' : "Don't have an account?",
                                  style: const TextStyle(color: AppBrand.inkSoft, fontSize: 13),
                                ),
                                TextButton(
                                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                                  child: Text(_isSignUp ? 'Sign in' : 'Sign up'),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),

                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('or continue with',
                                  style: TextStyle(color: AppBrand.inkSoft, fontSize: 12)),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              onTap: () => _comingSoon('Google'),
                            ),
                            const SizedBox(width: 14),
                            _SocialButton(
                              icon: Icons.apple_rounded,
                              onTap: () => _comingSoon('Apple'),
                            ),
                            const SizedBox(width: 14),
                            _SocialButton(
                              icon: Icons.facebook_rounded,
                              onTap: () => _comingSoon('Facebook'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'By continuing you agree to Aditya Globals\' Terms of Service and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppBrand.inkSoft, fontSize: 11.5),
                        ),
                      ],
                    ),
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

class _RoleTab extends StatelessWidget {
  const _RoleTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: selected ? AppBrand.heroGradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppBrand.inkSoft),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppBrand.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppBrand.cardAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppBrand.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Icon(icon, size: 24, color: AppBrand.ink),
        ),
      ),
    );
  }
}
