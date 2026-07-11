import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/progress_provider.dart';
import '../../shared/widgets/ui.dart';
import '../shared/app_nav_drawer.dart';

String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final stats = ref.watch(studentStatsProvider);
    final progress = ref.watch(subjectProgressProvider);
    final laggingAsync = ref.watch(laggingSubjectsProvider);
    final allCoursesAsync = ref.watch(coursesForCurrentStudentProvider(null));
    final purchasedIdsAsync = ref.watch(purchasedCourseIdsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: const AppNavDrawer(),
      body: AppGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              // ---- Greeting header ----
              Row(
                children: [
                  Builder(
                    builder: (ctx) => IconButton(
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                      icon: const Icon(Icons.menu_rounded),
                      color: AppBrand.ink,
                      tooltip: 'Menu',
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${greetingForNow()},',
                          style: const TextStyle(color: AppBrand.inkSoft, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.name.split(' ').first ?? 'there',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppBrand.ink,
                            letterSpacing: -.4,
                          ),
                        ),
                        if ((user?.grade?.label ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            user!.grade!.label,
                            style: const TextStyle(color: AppBrand.inkSoft, fontSize: 12.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                  stats.when(
                    data: (s) => s.streakDays > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppBrand.amber.withValues(alpha: .16),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department_rounded,
                                    color: AppBrand.amber, size: 18),
                                const SizedBox(width: 4),
                                Text('${s.streakDays}',
                                    style: const TextStyle(
                                        color: AppBrand.amber, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => context.push(AppRoutes.studentNotifications),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppBrand.purpleSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_rounded,
                          color: AppBrand.ink, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => context.push(AppRoutes.studentProfile),
                    customBorder: const CircleBorder(),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppBrand.purpleSoft,
                      child: Text(
                        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppBrand.ink, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ---- Overall progress card ----
              stats.when(
                data: (s) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppBrand.heroGradient,
                    borderRadius: BorderRadius.circular(AppBrand.radiusCard),
                    boxShadow: [
                      BoxShadow(
                        color: AppBrand.purple.withValues(alpha: .35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 62,
                        height: 62,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: s.overallAverage / 100,
                              strokeWidth: 6,
                              backgroundColor: Colors.white.withValues(alpha: .25),
                              color: Colors.white,
                            ),
                            Text('${s.overallAverage.round()}%',
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your overall progress',
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(
                              '${s.coursesEnrolled} course${s.coursesEnrolled == 1 ? '' : 's'} · ${s.quizzesTaken} quiz${s.quizzesTaken == 1 ? '' : 'zes'} taken',
                              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox(
                  height: 98,
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 22),

              // ---- Search bar ----
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push(AppRoutes.studentCourses),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: AppBrand.cardAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppBrand.line),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppBrand.inkSoft, size: 20),
                      SizedBox(width: 10),
                      Text('Search courses', style: TextStyle(color: AppBrand.inkSoft)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ---- Category pills ----
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: Subject.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final s = Subject.values[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => context.push(AppRoutes.studentCourses),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: s.color.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: s.color.withValues(alpha: .4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(s.icon, size: 15, color: s.color),
                            const SizedBox(width: 6),
                            Text(s.label,
                                style: TextStyle(
                                    color: s.color, fontWeight: FontWeight.w700, fontSize: 12.5)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 26),

              // ---- Continue learning ----
              const _SectionTitle('Continue learning'),
              const SizedBox(height: 12),
              _ContinueLearning(allCoursesAsync: allCoursesAsync, purchasedIdsAsync: purchasedIdsAsync),
              const SizedBox(height: 26),

              // ---- Progress by subject (what they've learned) ----
              const _SectionTitle("What you've learned so far"),
              const SizedBox(height: 12),
              progress.when(
                data: (list) => Column(
                  children: list.map((p) => _SubjectRow(progress: p)).toList(),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Could not load progress: $e',
                    style: const TextStyle(color: AppBrand.inkSoft)),
              ),
              const SizedBox(height: 16),

              // ---- Lagging alert ----
              laggingAsync.when(
                data: (lagging) {
                  if (lagging.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppBrand.greenSoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppBrand.green.withValues(alpha: .3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.celebration_rounded, color: AppBrand.green),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text("You're on track in every subject",
                                style: TextStyle(fontWeight: FontWeight.w700, color: AppBrand.ink)),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A1524),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: .4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFFF87171)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You\'re lagging in ${lagging.map((p) => p.subject.label).join(', ')}. Review those courses to catch up.',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFCA5A5),
                                fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.studentCourses),
                          child: const Text('Review'),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Text('Could not load progress: $e',
                    style: const TextStyle(color: AppBrand.inkSoft)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppBrand.ink),
      );
}

class _ContinueLearning extends ConsumerWidget {
  const _ContinueLearning({required this.allCoursesAsync, required this.purchasedIdsAsync});
  final AsyncValue<List<CourseModel>> allCoursesAsync;
  final AsyncValue<List<String>> purchasedIdsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (allCoursesAsync.isLoading || purchasedIdsAsync.isLoading) {
      return const SizedBox(height: 130, child: Center(child: CircularProgressIndicator()));
    }
    final allCourses = allCoursesAsync.value ?? [];
    final purchasedIds = (purchasedIdsAsync.value ?? []).toSet();
    final enrolled = allCourses.where((c) => purchasedIds.contains(c.id)).toList();

    if (enrolled.isEmpty) {
      return GlassCard(
        color: AppBrand.cardAlt,
        child: Row(
          children: [
            const Icon(Icons.explore_outlined, color: AppBrand.inkSoft),
            const SizedBox(width: 10),
            const Expanded(
              child: Text("You haven't enrolled in any course yet.",
                  style: TextStyle(color: AppBrand.inkSoft)),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.studentCourses),
              child: const Text('Browse'),
            ),
          ],
        ),
      );
    }

    // Most recently opened course -> the first enrolled course gets a
    // full-width "hero" continue card with a progress bar.
    final recent = enrolled.first;
    final rest = enrolled.skip(1).toList();

    return Column(
      children: [
        _ContinueHeroCard(course: recent),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: rest.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _CourseMiniCard(course: rest[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _ContinueHeroCard extends ConsumerWidget {
  const _ContinueHeroCard({required this.course});
  final CourseModel course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(courseCompletionProvider(course));
    final color = course.subject.color;
    return GlassCard(
      onTap: () => context.push('/student/courses/${course.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(course.subject.icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.subject.label.toUpperCase(),
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: .6)),
                    const SizedBox(height: 3),
                    Text(course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: AppBrand.ink, fontSize: 15)),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    gradient: AppBrand.heroGradient, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          completion.when(
            data: (v) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    backgroundColor: AppBrand.line,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text('${(v * 100).round()}% complete · tap to continue',
                    style: const TextStyle(fontSize: 11.5, color: AppBrand.inkSoft)),
              ],
            ),
            loading: () => const SizedBox(height: 16),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CourseMiniCard extends ConsumerWidget {
  const _CourseMiniCard({required this.course});
  final CourseModel course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(courseCompletionProvider(course));
    return GlassCard(
      onTap: () => context.push('/student/courses/${course.id}'),
      padding: const EdgeInsets.all(14),
      color: AppBrand.cardAlt,
      child: SizedBox(
        width: 196,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: course.subject.color.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(course.subject.icon, size: 18, color: course.subject.color),
            ),
            const SizedBox(height: 10),
            Text(course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: AppBrand.ink, fontSize: 13)),
            const Spacer(),
            completion.when(
              data: (v) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: AppBrand.line,
                      color: course.subject.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${(v * 100).round()}% complete',
                      style: const TextStyle(fontSize: 10.5, color: AppBrand.inkSoft)),
                ],
              ),
              loading: () => const SizedBox(height: 14),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.progress});
  final SubjectProgress progress;

  @override
  Widget build(BuildContext context) {
    final started = progress.attemptCount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppBrand.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppBrand.line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: progress.subject.color.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(progress.subject.icon, color: progress.subject.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(progress.subject.label,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppBrand.ink)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: started ? progress.averagePercentage / 100 : 0,
                    minHeight: 6,
                    backgroundColor: AppBrand.line,
                    color: progress.isLagging ? const Color(0xFFF87171) : progress.subject.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  started
                      ? '${progress.averagePercentage.toStringAsFixed(0)}% avg over ${progress.attemptCount} quiz${progress.attemptCount == 1 ? '' : 'zes'}'
                      : 'Not started yet',
                  style: const TextStyle(fontSize: 11.5, color: AppBrand.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppBrand.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppBrand.line),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppBrand.ink)),
          ],
        ),
      ),
    );
  }
}
