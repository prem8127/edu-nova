import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';

/// A scaffold whose header + background are painted with the signed-in
/// student's [GradePalette], so every feature screen automatically carries
/// that class's identity. Falls back to the neutral palette for other roles.
class GradeScaffold extends ConsumerWidget {
  const GradeScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBack = true,
    this.gradeOverride,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBack;
  final Grade? gradeOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(gradeOverride ?? user?.grade);

    return Scaffold(
      backgroundColor: palette.background,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: palette.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Grade-themed hero header ----
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: palette.heroGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    if (showBack)
                      _CircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.pop(),
                      ),
                    if (showBack) const SizedBox(width: 12),
                    if (icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.3,
                            ),
                          ),
                          if (subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                subtitle!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .85),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: .18),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      );
}

/// A simple stat/label chip used across the new feature screens, tinted with
/// the grade palette.
class GradeStatCard extends StatelessWidget {
  const GradeStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.palette,
  });

  final String label;
  final String value;
  final IconData icon;
  final GradePalette palette;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: palette.isDark
                ? Colors.white.withValues(alpha: .06)
                : Colors.black.withValues(alpha: .05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: palette.primary, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: palette.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: palette.onSurfaceMuted,
              ),
            ),
          ],
        ),
      );
}
