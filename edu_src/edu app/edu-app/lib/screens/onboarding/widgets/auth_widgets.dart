import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Small bold label placed above a field — matches the style already used
/// on the onboarding screen, factored out so every auth screen looks the
/// same instead of re-declaring this widget four times.
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key, this.optional = false});
  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: AppBrand.ink,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          if (optional) ...[
            const SizedBox(width: 6),
            const Text(
              '(optional)',
              style: TextStyle(color: AppBrand.inkSoft, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      );
}

/// Rounded back button used at the top of every auth screen.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: AppBrand.card,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.all(11),
              child: Icon(Icons.arrow_back_rounded, color: AppBrand.ink, size: 20),
            ),
          ),
        ),
      );
}

/// The icon badge + headline + subtitle block shared by all four auth
/// screens (only the icon/copy differs per screen).
class AuthHeroHeader extends StatelessWidget {
  const AuthHeroHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppBrand.heroGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppBrand.purple.withValues(alpha: .40),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: AppBrand.ink,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: AppBrand.inkSoft, fontSize: 13.5, height: 1.45),
          ),
        ],
      );
}

/// "Already have an account? Sign In" style footer link.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });
  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(question, style: const TextStyle(color: AppBrand.inkSoft, fontSize: 13.5)),
            TextButton(onPressed: onTap, child: Text(actionLabel)),
          ],
        ),
      );
}

/// Inline error banner shown above the submit button when sign-up/login
/// fails (wrong password, duplicate email, etc.).
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: .12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}
