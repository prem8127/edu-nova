import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/platform_providers.dart';
import '../../shared/widgets/ui.dart';

/// Teacher marks attendance for a chosen course. Students of that course's
/// grade are listed; each can be set Present / Late / Absent. Marks persist
/// per course+day so re-opening shows what was recorded.
class AttendanceMarkingScreen extends ConsumerStatefulWidget {
  const AttendanceMarkingScreen({super.key});

  @override
  ConsumerState<AttendanceMarkingScreen> createState() =>
      _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState
    extends ConsumerState<AttendanceMarkingScreen> {
  CourseModel? _course;

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _classId(CourseModel c) => '${c.id}_$_todayKey';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final courses = ref.watch(coursesForTeacherProvider(user?.id ?? ''));
    final students = ref.watch(allStudentsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Attendance',
                subtitle: 'Mark who joined today\'s class',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: courses.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('$e'),
                  data: (list) {
                    if (list.isEmpty) {
                      return const Text('No assigned courses.',
                          style: TextStyle(color: AppBrand.inkSoft));
                    }
                    _course ??= list.first;
                    return DropdownButtonFormField<String>(
                      initialValue: _course?.id,
                      decoration: const InputDecoration(labelText: 'Course'),
                      items: [
                        for (final c in list)
                          DropdownMenuItem(value: c.id, child: Text(c.title)),
                      ],
                      onChanged: (v) => setState(
                          () => _course = list.firstWhere((c) => c.id == v)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: (_course == null)
                    ? const SizedBox.shrink()
                    : students.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('$e')),
                        data: (all) {
                          final roster = all
                              .where((s) => s.grade == _course!.grade)
                              .toList();
                          if (roster.isEmpty) {
                            return const EmptyState(
                              icon: Icons.group_off_rounded,
                              title: 'No students',
                              body: 'No students are enrolled in this grade yet.',
                            );
                          }
                          return _Roster(
                            course: _course!,
                            classId: _classId(_course!),
                            students: roster,
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

class _Roster extends ConsumerWidget {
  const _Roster({
    required this.course,
    required this.classId,
    required this.students,
  });
  final CourseModel course;
  final String classId;
  final List<AppUser> students;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marks = ref.watch(classAttendanceProvider(classId)).value ?? const [];
    AttendanceStatus? statusFor(String id) {
      for (final m in marks) {
        if (m.studentId == id) return m.status;
      }
      return null;
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = students[i];
        final current = statusFor(s.id);
        return GlassCard(
          child: Row(
            children: [
              Expanded(
                child: Text(s.name,
                    style: const TextStyle(
                        color: AppBrand.ink, fontWeight: FontWeight.w700)),
              ),
              for (final st in AttendanceStatus.values)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _MarkButton(
                    status: st,
                    active: current == st,
                    onTap: () => ref.read(attendanceControllerProvider).mark(
                          classId: classId,
                          courseId: course.id,
                          studentId: s.id,
                          status: st,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MarkButton extends StatelessWidget {
  const _MarkButton({required this.status, required this.active, required this.onTap});
  final AttendanceStatus status;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? status.color : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
                color: active ? status.color : AppBrand.line),
          ),
          child: Text(status.label[0],
              style: TextStyle(
                  color: active ? Colors.white : AppBrand.inkSoft,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
        ),
      ),
    );
  }
}
