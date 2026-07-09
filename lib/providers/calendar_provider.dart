import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/class_schedule_model.dart';
import 'auth_provider.dart';
import 'course_provider.dart';
import 'repository_providers.dart';

/// Every class scheduled across the current student's purchased/free
/// courses — feeds the student calendar screen.
final studentCalendarProvider = FutureProvider<List<ScheduledClass>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null || user.grade == null) return [];

  final scheduleRepo = ref.watch(scheduleRepositoryProvider);
  final courses = await ref.watch(coursesForCurrentStudentProvider(null).future);

  final all = <ScheduledClass>[];
  for (final course in courses) {
    all.addAll(await scheduleRepo.getClassesForCourse(course.id));
  }
  all.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return all;
});

/// Classes a specific teacher has scheduled — feeds their "Start class"
/// screen where they manage the manual Zoom link per session.
final teacherScheduleProvider =
    FutureProvider.family<List<ScheduledClass>, String>((ref, teacherId) async {
  final repo = ref.watch(scheduleRepositoryProvider);
  final classes = await repo.getClassesForTeacher(teacherId);
  classes.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return classes;
});

/// Doubt chat is meant to be a *post-class* channel, not a live-call
/// substitute — so it only unlocks once at least one scheduled class for
/// the course has actually finished (start time + duration has passed).
final hasCourseHadClassProvider =
    FutureProvider.family<bool, String>((ref, courseId) async {
  final repo = ref.watch(scheduleRepositoryProvider);
  final classes = await repo.getClassesForCourse(courseId);
  return classes.any((c) => c.hasEnded);
});

final scheduleActionsProvider = Provider((ref) {
  final repo = ref.watch(scheduleRepositoryProvider);
  return (
    upsert: (ScheduledClass c) async {
      await repo.upsertScheduledClass(c);
      ref.invalidate(teacherScheduleProvider);
      ref.invalidate(studentCalendarProvider);
    },
    setZoomLink: (String classId, String link) async {
      await repo.setZoomLink(classId, link);
      ref.invalidate(teacherScheduleProvider);
      ref.invalidate(studentCalendarProvider);
    },
  );
});
