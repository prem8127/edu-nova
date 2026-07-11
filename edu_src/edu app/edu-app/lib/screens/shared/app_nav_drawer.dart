import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

/// Aditya Globals side navigation drawer.
///
/// Replaces the old bottom tab bar so every mobile feature lives behind the
/// hamburger icon. Groups the primary tabs and the extra feature pages, styled
/// with the Aditya Globals navy + orange palette.
class AppNavDrawer extends ConsumerWidget {
  const AppNavDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final current = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: AppBrand.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Brand header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppBrand.heroGradient,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Aditya Globals',
                          style: TextStyle(
                              color: AppBrand.ink, fontWeight: FontWeight.w900, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('LEARNING PLATFORM',
                          style: TextStyle(
                              color: AppBrand.inkSoft,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 1)),
                    ],
                  ),
                ],
              ),
            ),
            // ---- User chip ----
            if (user != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppBrand.cardAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppBrand.line),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppBrand.purpleSoft,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppBrand.ink, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppBrand.ink, fontWeight: FontWeight.w800)),
                            if ((user.grade?.label ?? '').isNotEmpty)
                              Text(user.grade!.label,
                                  style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(indent: 16, endIndent: 16),
            // ---- Nav items ----
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                children: [
                  _label('MAIN'),
                  _item(context, current, Icons.home_rounded, 'Home', AppRoutes.studentDashboard, go: true),
                  _item(context, current, Icons.menu_book_rounded, 'My Courses', AppRoutes.studentCourses, go: true),
                  _item(context, current, Icons.calendar_month_rounded, 'Calendar', AppRoutes.studentCalendar, go: true),
                  _item(context, current, Icons.forum_rounded, 'Doubts', AppRoutes.studentDoubtChat, go: true),
                  _item(context, current, Icons.person_rounded, 'Profile', AppRoutes.studentProfile, go: true),
                  const SizedBox(height: 8),
                  _label('LEARNING'),
                  _item(context, current, Icons.videocam_rounded, 'Live Classes', AppRoutes.studentLiveClasses),
                  _item(context, current, Icons.smart_display_rounded, 'Recorded Videos', AppRoutes.studentRecordedVideos),
                  _item(context, current, Icons.description_rounded, 'Notes', AppRoutes.studentNotes),
                  _item(context, current, Icons.assignment_rounded, 'Assignments', AppRoutes.studentAssignments),
                  _item(context, current, Icons.terminal_rounded, 'Coding IDE', AppRoutes.studentCodingIde),
                  _item(context, current, Icons.fact_check_rounded, 'Assessments', AppRoutes.studentAssessments),
                  _item(context, current, Icons.build_circle_rounded, 'Projects', AppRoutes.studentProjects),
                  _item(context, current, Icons.workspace_premium_rounded, 'Certificates', AppRoutes.studentCertificates),
                  _item(context, current, Icons.event_available_rounded, 'Attendance', AppRoutes.studentAttendance),
                  _item(context, current, Icons.leaderboard_rounded, 'Leaderboard', AppRoutes.studentLeaderboard),
                  _item(context, current, Icons.sports_esports_rounded, 'Arcade', AppRoutes.studentGame),
                  const SizedBox(height: 8),
                  _label('ACCOUNT'),
                  _item(context, current, Icons.notifications_rounded, 'Notifications', AppRoutes.studentNotifications),
                ],
              ),
            ),
            const Divider(indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFF87171)),
                title: const Text('Log out',
                    style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w800)),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authControllerProvider.notifier).logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        child: Text(text,
            style: const TextStyle(
                color: AppBrand.inkSoft,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
      );

  Widget _item(BuildContext context, String current, IconData icon, String label, String route,
      {bool go = false}) {
    final selected = current == route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        selected: selected,
        selectedTileColor: AppBrand.purple.withValues(alpha: .16),
        leading: Icon(icon, color: selected ? AppBrand.purple : AppBrand.inkSoft, size: 22),
        title: Text(label,
            style: TextStyle(
                color: selected ? AppBrand.ink : AppBrand.ink,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
        onTap: () {
          Navigator.of(context).pop();
          if (selected) return;
          if (go) {
            context.go(route);
          } else {
            context.push(route);
          }
        },
      ),
    );
  }
}
