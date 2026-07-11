import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';
import '../../shared/widgets/ui.dart';

/// Super Admin view of each teacher's platform performance: number of
/// courses, scheduled classes and how many submissions they've reviewed.
class TeacherPerformanceScreen extends ConsumerWidget {
  const TeacherPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachers = ref.watch(allTeachersProvider);
    final courses = ref.watch(allCoursesForAdminProvider);
    final classes = ref.watch(allScheduledClassesOverviewProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Teacher performance',
                subtitle: 'Workload and output across the platform',
              ),
              Expanded(
                child: teachers.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (list) {
                    if (list.isEmpty) {
                      return const EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: 'No teachers',
                        body: 'Add teachers to see performance here.',
                      );
                    }
                    final courseRows = courses.value ?? const [];
                    final classRows = classes.value ?? const [];
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final t = list[i];
                        final courseCount = courseRows
                            .where((r) => r.course.teacherId == t.id)
                            .length;
                        final classCount = classRows
                            .where((r) => r.scheduledClass.teacherId == t.id)
                            .length;
                        return GlassCard(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    AppBrand.purple.withValues(alpha: .25),
                                child: Text(
                                  t.name.isNotEmpty
                                      ? t.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: AppBrand.ink,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.name,
                                        style: const TextStyle(
                                            color: AppBrand.ink,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(
                                      t.assignedSubjects
                                          .map((s) => s.label)
                                          .join(' · '),
                                      style: const TextStyle(
                                          color: AppBrand.inkSoft,
                                          fontSize: 12.5),
                                    ),
                                  ],
                                ),
                              ),
                              _Metric(value: '$courseCount', label: 'Courses'),
                              const SizedBox(width: 16),
                              _Metric(value: '$classCount', label: 'Classes'),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppBrand.ink,
                fontWeight: FontWeight.w900,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(color: AppBrand.inkSoft, fontSize: 11)),
      ],
    );
  }
}
