import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/ui.dart';
import '../student/dashboard_screen.dart' show greetingForNow;

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final overviewAsync = ref.watch(platformOverviewProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              // ---- Greeting header ----
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${greetingForNow()},',
                            style: const TextStyle(color: AppBrand.inkSoft, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(user?.name ?? 'Super Admin',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppBrand.ink,
                                letterSpacing: -.4)),
                        const SizedBox(height: 2),
                        const Text('Platform overview',
                            style: TextStyle(color: AppBrand.inkSoft, fontSize: 12.5)),
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

              overviewAsync.when(
                data: (o) => Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                            label: 'Students', value: o.totalStudents, color: AppBrand.purple, icon: Icons.school_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                            label: 'Teachers', value: o.totalTeachers, color: AppBrand.blue, icon: Icons.co_present_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _StatCard(
                            label: 'Courses', value: o.totalCourses, color: AppBrand.green, icon: Icons.menu_book_rounded)),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppBrand.inkSoft)),
              ),
              const SizedBox(height: 24),

              const Text('Platform management',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppBrand.ink)),
              const SizedBox(height: 12),

              _DashTile(
                icon: Icons.people_alt_rounded,
                color: AppBrand.purple,
                title: 'Manage teachers',
                subtitle: 'Assign subjects and courses',
                onTap: () => context.push(AppRoutes.adminManageTeachers),
              ),
              _DashTile(
                icon: Icons.payments_rounded,
                color: AppBrand.amber,
                title: 'Revenue dashboard',
                subtitle: 'Platform earnings and teacher payouts',
                onTap: () => context.push(AppRoutes.adminRevenue),
              ),
              _DashTile(
                icon: Icons.menu_book_rounded,
                color: AppBrand.blue,
                title: 'Course authoring',
                subtitle: 'Create, edit and price courses',
                onTap: () => context.push(AppRoutes.adminCourses),
              ),
              _DashTile(
                icon: Icons.insights_rounded,
                color: AppBrand.blue,
                title: 'Student progress',
                subtitle: 'Platform-wide lagging-area visibility',
                onTap: () => context.push(AppRoutes.adminStudentProgress),
              ),
              _DashTile(
                icon: Icons.event_note_rounded,
                color: AppBrand.green,
                title: 'All classes',
                subtitle: 'Every scheduled class, every teacher',
                onTap: () => context.push(AppRoutes.adminClasses),
              ),
              _DashTile(
                icon: Icons.speed_rounded,
                color: AppBrand.purple,
                title: 'Teacher performance',
                subtitle: 'Workload and output per teacher',
                onTap: () => context.push(AppRoutes.adminTeacherPerformance),
              ),
              _DashTile(
                icon: Icons.video_library_rounded,
                color: AppBrand.blue,
                title: 'Recordings',
                subtitle: 'Class recordings and samples',
                onTap: () => context.push(AppRoutes.adminRecordings),
              ),
              _DashTile(
                icon: Icons.upload_file_rounded,
                color: AppBrand.green,
                title: 'Import students',
                subtitle: 'Bulk-create accounts from CSV',
                onTap: () => context.push(AppRoutes.adminImportUsers),
              ),
              _DashTile(
                icon: Icons.receipt_long_rounded,
                color: AppBrand.amber,
                title: 'Audit log',
                subtitle: 'Every significant platform action',
                onTap: () => context.push(AppRoutes.adminAuditLog),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text('$value',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppBrand.ink)),
          Text(label, style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12)),
        ],
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
