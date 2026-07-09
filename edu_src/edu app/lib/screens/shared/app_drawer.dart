import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'coming_soon_screen.dart';

/// A single row in the drawer's nav list. If [route] is set, tapping does
/// `context.go(route)`. If [route] is null, tapping opens [ComingSoonScreen]
/// with this label — used for prototype nav items that don't have a real
/// screen built yet, so the drawer stays fully clickable end to end.
class _DrawerNavItem {
  const _DrawerNavItem(this.label, this.icon, {this.route});
  final String label;
  final IconData icon;
  final String? route;
}

/// The hamburger-menu drawer. Mirrors the Aditya Globals prototype's left
/// sidebar nav list for the signed-in user's role (student / teacher /
/// admin), adapted to a mobile slide-out drawer instead of a permanent
/// desktop rail.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key, required this.role});
  final UserRole role;

  static const _student = [
    _DrawerNavItem('Dashboard', Icons.home_rounded, route: AppRoutes.studentDashboard),
    _DrawerNavItem('Live Classes', Icons.sensors_rounded),
    _DrawerNavItem('Calendar', Icons.calendar_month_rounded, route: AppRoutes.studentCalendar),
    _DrawerNavItem('Attendance', Icons.event_available_rounded, route: AppRoutes.studentAttendance),
    _DrawerNavItem('Notes & Homework', Icons.note_alt_rounded),
    _DrawerNavItem('Projects', Icons.build_circle_rounded, route: AppRoutes.studentProjects),
    _DrawerNavItem('Recorded Videos', Icons.ondemand_video_rounded),
    _DrawerNavItem('Syllabus', Icons.menu_book_rounded, route: AppRoutes.studentSyllabus),
    _DrawerNavItem('Assessments', Icons.fact_check_rounded, route: AppRoutes.studentAssessments),
    _DrawerNavItem('MCQ Practice', Icons.quiz_rounded),
    _DrawerNavItem('Code IDE', Icons.code_rounded),
    _DrawerNavItem('My Test Reports', Icons.bar_chart_rounded),
    _DrawerNavItem('Leaderboard', Icons.leaderboard_rounded, route: AppRoutes.studentLeaderboard),
    _DrawerNavItem('Certifications', Icons.workspace_premium_rounded, route: AppRoutes.studentCertificates),
    _DrawerNavItem('Notifications', Icons.notifications_rounded, route: AppRoutes.studentNotifications),
  ];

  static const _studentExtras = [
    _DrawerNavItem('My Courses', Icons.menu_book_outlined, route: AppRoutes.studentCourses),
    _DrawerNavItem('Doubt Chat', Icons.forum_rounded, route: AppRoutes.studentDoubtChat),
    _DrawerNavItem('Arcade', Icons.sports_esports_rounded, route: AppRoutes.studentGame),
    _DrawerNavItem('Profile', Icons.person_rounded, route: AppRoutes.studentProfile),
  ];

  static const _teacher = [
    _DrawerNavItem('Dashboard', Icons.home_rounded, route: AppRoutes.teacherDashboard),
    _DrawerNavItem('Schedule', Icons.event_note_rounded, route: AppRoutes.teacherAvailability),
    _DrawerNavItem('Attendance', Icons.event_available_rounded, route: AppRoutes.teacherAttendance),
    _DrawerNavItem('Upload Content', Icons.upload_rounded),
    _DrawerNavItem('Syllabus', Icons.menu_book_rounded, route: AppRoutes.teacherSyllabus),
    _DrawerNavItem('My Students', Icons.groups_rounded, route: AppRoutes.teacherAssignedCourses),
    _DrawerNavItem('Performance', Icons.insights_rounded),
    _DrawerNavItem('Grading Queue', Icons.fact_check_rounded, route: AppRoutes.teacherReviewQueue),
    _DrawerNavItem('Class Communication', Icons.campaign_rounded, route: AppRoutes.teacherAnnouncements),
  ];

  static const _teacherExtras = [
    _DrawerNavItem('Start Class', Icons.sensors_rounded, route: AppRoutes.teacherStartClass),
    _DrawerNavItem('Doubt Chat', Icons.forum_rounded, route: AppRoutes.teacherDoubtChat),
    _DrawerNavItem('Earnings', Icons.payments_rounded, route: AppRoutes.teacherEarnings),
  ];

  static const _admin = [
    _DrawerNavItem('Overview', Icons.home_rounded, route: AppRoutes.adminDashboard),
    _DrawerNavItem('User Management', Icons.person_rounded, route: AppRoutes.adminManageTeachers),
    _DrawerNavItem('Batches', Icons.school_rounded, route: AppRoutes.adminClasses),
    _DrawerNavItem('Subject Management', Icons.menu_book_rounded, route: AppRoutes.adminCourses),
    _DrawerNavItem('Syllabus', Icons.book_rounded, route: AppRoutes.adminSyllabus),
    _DrawerNavItem('Content Library', Icons.video_library_rounded, route: AppRoutes.adminRecordings),
    _DrawerNavItem('Attendance Analytics', Icons.fact_check_rounded),
    _DrawerNavItem('School Reports', Icons.bar_chart_rounded, route: AppRoutes.adminStudentProgress),
    _DrawerNavItem('Payments', Icons.payments_rounded, route: AppRoutes.adminRevenue),
    _DrawerNavItem('Audit Logs', Icons.shield_rounded, route: AppRoutes.adminAuditLog),
    _DrawerNavItem('Settings', Icons.settings_rounded),
  ];

  static const _adminExtras = [
    _DrawerNavItem('Teacher Performance', Icons.insights_rounded, route: AppRoutes.adminTeacherPerformance),
    _DrawerNavItem('Import Users', Icons.upload_file_rounded, route: AppRoutes.adminImportUsers),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final (items, extras, roleLabel) = switch (role) {
      UserRole.student => (_student, _studentExtras, 'Student'),
      UserRole.teacher => (_teacher, _teacherExtras, 'Teacher'),
      UserRole.admin => (_admin, _adminExtras, 'Admin'),
    };

    return Drawer(
      backgroundColor: AppBrand.card,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Brand header (navy, matches prototype sidebar) ----
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              color: AppBrand.navy,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppBrand.orange, shape: BoxShape.circle),
                    child: Text(
                      (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : roleLabel[0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? roleLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(roleLabel,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: .7),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final item in items) _DrawerTile(item: item),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Text('MORE',
                        style: TextStyle(
                            color: AppBrand.inkSoft, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .6)),
                  ),
                  for (final item in extras) _DrawerTile(item: item),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppBrand.red),
              title: const Text('Log out', style: TextStyle(color: AppBrand.red, fontWeight: FontWeight.w700)),
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.intro);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.item});
  final _DrawerNavItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.icon, color: AppBrand.inkSoft, size: 22),
      title: Text(item.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppBrand.ink)),
      onTap: () {
        Navigator.of(context).pop();
        if (item.route != null) {
          context.go(item.route!);
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ComingSoonScreen(title: item.label, icon: item.icon),
          ));
        }
      },
    );
  }
}
