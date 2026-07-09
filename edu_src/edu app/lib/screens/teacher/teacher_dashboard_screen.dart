import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/ui.dart';
import '../shared/app_drawer.dart';
import '../student/dashboard_screen.dart' show greetingForNow;

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: const AppDrawer(role: UserRole.teacher),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              // ---- Greeting header ----
              Row(
                children: [
                  Builder(
                    builder: (drawerContext) => InkWell(
                      onTap: () => Scaffold.of(drawerContext).openDrawer(),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppBrand.cardAlt,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppBrand.line),
                        ),
                        child: const Icon(Icons.menu_rounded, color: AppBrand.ink, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${greetingForNow()},',
                            style: const TextStyle(color: AppBrand.inkSoft, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(user?.name ?? 'Teacher',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppBrand.ink,
                                letterSpacing: -.4)),
                      ],
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.logout_rounded,
                    onTap: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) context.go(AppRoutes.roleSelect);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ---- Primary CTA ----
              GradientButton(
                label: 'Start a class',
                icon: Icons.video_call_rounded,
                onPressed: () => context.push(AppRoutes.teacherStartClass),
              ),
              const SizedBox(height: 22),

              const Text('Manage your teaching',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppBrand.ink)),
              const SizedBox(height: 12),

              _DashTile(
                icon: Icons.menu_book_rounded,
                color: AppBrand.purple,
                title: 'My assigned courses',
                subtitle: 'Courses you currently teach',
                onTap: () => context.push(AppRoutes.teacherAssignedCourses),
              ),
              _DashTile(
                icon: Icons.video_call_rounded,
                color: AppBrand.blue,
                title: 'Start a class',
                subtitle: 'Go live with your students',
                onTap: () => context.push(AppRoutes.teacherStartClass),
              ),
              _DashTile(
                icon: Icons.forum_rounded,
                color: AppBrand.green,
                title: 'Doubt chats',
                subtitle: 'Answer questions from your students',
                onTap: () => context.push(AppRoutes.teacherDoubtChat),
              ),
              _DashTile(
                icon: Icons.rate_review_rounded,
                color: AppBrand.purple,
                title: 'Review queue',
                subtitle: 'Grade student project submissions',
                onTap: () => context.push(AppRoutes.teacherReviewQueue),
              ),
              _DashTile(
                icon: Icons.how_to_reg_rounded,
                color: AppBrand.blue,
                title: 'Attendance',
                subtitle: "Mark today's class attendance",
                onTap: () => context.push(AppRoutes.teacherAttendance),
              ),
              _DashTile(
                icon: Icons.campaign_rounded,
                color: AppBrand.green,
                title: 'Announcements',
                subtitle: 'Broadcast updates to your courses',
                onTap: () => context.push(AppRoutes.teacherAnnouncements),
              ),
              _DashTile(
                icon: Icons.event_available_rounded,
                color: AppBrand.amber,
                title: 'My availability',
                subtitle: 'Set your weekly teaching slots',
                onTap: () => context.push(AppRoutes.teacherAvailability),
              ),
              _DashTile(
                icon: Icons.payments_rounded,
                color: AppBrand.amber,
                title: 'Earnings',
                subtitle: 'Your revenue and payouts',
                onTap: () => context.push(AppRoutes.teacherEarnings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  const _DashTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: AppBrand.ink, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppBrand.inkSoft),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppBrand.card,
        shape: const CircleBorder(side: BorderSide(color: AppBrand.line)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Icon(icon, color: AppBrand.ink, size: 20),
          ),
        ),
      );
}
