import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/ui.dart';

/// First screen of the authentication flow. Deliberately minimal —
/// premium mark, one line of copy, and the two entry points every
/// Udemy/Unacademy-style app opens on: "Continue as Student / Teacher".
///
/// This replaces [RoleSelectScreen] as the screen mounted at
/// [AppRoutes.roleSelect] ('/'). RoleSelectScreen itself is left in place
/// (not deleted) per the "don't remove the existing login page" brief —
/// it's just no longer wired into the router.
///
/// Teachers and admins share the same real Supabase sign-in screen — those
/// accounts are provisioned directly in Supabase, never self-signed-up, so
/// there's no separate "Continue as Admin" shortcut anymore.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppBrand.heroGradient,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppBrand.purple.withValues(alpha: .5),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Welcome',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppBrand.ink,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Live classes, quizzes & doubt-solving for\nTech, Business, Finance and Content Creation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppBrand.inkSoft, fontSize: 13.5, height: 1.5),
                ),
                const Spacer(),
                const Text(
                  'Continue as',
                  style: TextStyle(
                    color: AppBrand.inkSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: Icons.backpack_rounded,
                  title: 'Student',
                  subtitle: 'Learn at your own pace',
                  onTap: () => context.go(AppRoutes.studentSignUp),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: Icons.co_present_rounded,
                  title: 'Teacher',
                  subtitle: 'Teach, mentor and grade',
                  onTap: () => context.go(AppRoutes.teacherLogin),
                ),
                const SizedBox(height: 22),
                TextButton(
                  onPressed: () => context.go(AppRoutes.teacherLogin),
                  child: const Text(
                    'Staff / Admin sign in',
                    style: TextStyle(color: AppBrand.inkSoft, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppBrand.purpleSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppBrand.purple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppBrand.ink, fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12.5)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppBrand.inkSoft, size: 16),
        ],
      ),
    );
  }
}
