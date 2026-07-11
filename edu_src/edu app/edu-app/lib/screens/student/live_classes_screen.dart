import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/grade_themes.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/grade_scaffold.dart';

/// Student — Live Classes.
/// Lists live-now and upcoming sessions with a join action. Local demo data.
class StudentLiveClassesScreen extends ConsumerWidget {
  const StudentLiveClassesScreen({super.key});

  static final _classes = <_LiveClass>[
    _LiveClass('Algebra — Quadratic Equations', 'Mr. Sharma', 'Mathematics',
        Icons.functions_rounded, true, 'Live now', 42),
    _LiveClass('Newton\'s Laws of Motion', 'Ms. Reddy', 'Physics',
        Icons.science_rounded, false, 'Today · 4:30 PM', 0),
    _LiveClass('Organic Chemistry Basics', 'Dr. Nair', 'Chemistry',
        Icons.biotech_rounded, false, 'Tomorrow · 10:00 AM', 0),
    _LiveClass('Essay Writing Workshop', 'Mrs. Iyer', 'English',
        Icons.edit_note_rounded, false, 'Fri · 2:00 PM', 0),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final palette = GradePalette.of(user?.grade);

    return GradeScaffold(
      title: 'Live Classes',
      subtitle: 'Join live sessions with your teachers',
      icon: Icons.videocam_rounded,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
        itemCount: _classes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _LiveCard(cls: _classes[i], palette: palette),
      ),
    );
  }
}

class _LiveClass {
  const _LiveClass(this.title, this.teacher, this.subject, this.icon,
      this.isLive, this.when, this.watching);
  final String title;
  final String teacher;
  final String subject;
  final IconData icon;
  final bool isLive;
  final String when;
  final int watching;
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.cls, required this.palette});
  final _LiveClass cls;
  final GradePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cls.isLive
              ? const Color(0xFFF43F5E).withValues(alpha: .5)
              : (palette.isDark
                  ? Colors.white.withValues(alpha: .06)
                  : Colors.black.withValues(alpha: .05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(cls.icon, color: palette.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cls.title,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: palette.onSurface)),
                    const SizedBox(height: 3),
                    Text('${cls.subject} · ${cls.teacher}',
                        style: TextStyle(
                            color: palette.onSurfaceMuted, fontSize: 12.5)),
                  ],
                ),
              ),
              if (cls.isLive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.circle, size: 8, color: Colors.white),
                    SizedBox(width: 5),
                    Text('LIVE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10)),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(cls.isLive ? Icons.people_alt_rounded : Icons.schedule_rounded,
                  size: 15, color: palette.onSurfaceMuted),
              const SizedBox(width: 6),
              Text(cls.isLive ? '${cls.watching} watching' : cls.when,
                  style: TextStyle(
                      color: palette.onSurfaceMuted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor:
                        cls.isLive ? const Color(0xFFF43F5E) : palette.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(cls.isLive
                          ? 'Joining "${cls.title}"…'
                          : 'Reminder set for "${cls.title}"')));
                },
                icon: Icon(cls.isLive ? Icons.login_rounded : Icons.notifications_active_rounded,
                    size: 18),
                label: Text(cls.isLive ? 'Join now' : 'Remind me'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
