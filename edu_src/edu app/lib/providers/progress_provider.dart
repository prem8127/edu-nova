import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_enums.dart';
import '../models/course_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// One row of a lagging-area tracker: how a student is doing in a given
/// subject, based on their quiz attempt history.
class SubjectProgress {
  final Subject subject;
  final double averagePercentage;
  final int attemptCount;

  const SubjectProgress({
    required this.subject,
    required this.averagePercentage,
    required this.attemptCount,
  });

  /// Below this average, a subject is flagged as "lagging". Tune this
  /// single constant to change sensitivity app-wide (student dashboard
  /// AND admin monitoring both read it from here).
  static const double laggingThreshold = 60.0;

  bool get isLagging => attemptCount > 0 && averagePercentage < laggingThreshold;
}

/// Computes per-subject progress for ANY student by joining their quiz
/// attempts back to the course each quiz belongs to (for its subject).
/// This is the shared core used by both the student dashboard and the
/// admin monitoring screens — one calculation, two consumers.
final subjectProgressForStudentProvider =
    FutureProvider.family<List<SubjectProgress>, String>((ref, studentId) async {
  final quizRepo = ref.watch(quizRepositoryProvider);
  final courseRepo = ref.watch(courseRepositoryProvider);

  final attempts = await quizRepo.getAttemptsForStudent(studentId);
  if (attempts.isEmpty) {
    return Subject.values
        .map((s) => SubjectProgress(subject: s, averagePercentage: 0, attemptCount: 0))
        .toList();
  }

  final Map<Subject, List<double>> bySubject = {for (final s in Subject.values) s: []};

  for (final attempt in attempts) {
    final course = await courseRepo.getCourseById(attempt.courseId);
    if (course == null) continue;
    bySubject[course.subject]!.add(attempt.percentage);
  }

  return bySubject.entries.map((entry) {
    final scores = entry.value;
    final avg = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
    return SubjectProgress(
      subject: entry.key,
      averagePercentage: avg,
      attemptCount: scores.length,
    );
  }).toList();
});

final laggingSubjectsForStudentProvider =
    FutureProvider.family<List<SubjectProgress>, String>((ref, studentId) async {
  final all = await ref.watch(subjectProgressForStudentProvider(studentId).future);
  final lagging = all.where((p) => p.isLagging).toList()
    ..sort((a, b) => a.averagePercentage.compareTo(b.averagePercentage));
  return lagging;
});

/// Convenience wrappers bound to whoever is currently logged in — this is
/// what the student dashboard actually watches.
final subjectProgressProvider = FutureProvider<List<SubjectProgress>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return [];
  return ref.watch(subjectProgressForStudentProvider(user.id).future);
});

final laggingSubjectsProvider = FutureProvider<List<SubjectProgress>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return [];
  return ref.watch(laggingSubjectsForStudentProvider(user.id).future);
});

/// Headline numbers for the profile page / dashboard: courses enrolled,
/// quizzes taken, overall average score, and a simple day-streak (how
/// many consecutive days — counting back from today — the student has
/// taken at least one quiz).
class StudentStats {
  final int coursesEnrolled;
  final int quizzesTaken;
  final double overallAverage;
  final int streakDays;

  const StudentStats({
    required this.coursesEnrolled,
    required this.quizzesTaken,
    required this.overallAverage,
    required this.streakDays,
  });

  static const empty =
      StudentStats(coursesEnrolled: 0, quizzesTaken: 0, overallAverage: 0, streakDays: 0);
}

final studentStatsProvider = FutureProvider<StudentStats>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return StudentStats.empty;

  final courseRepo = ref.watch(courseRepositoryProvider);
  final quizRepo = ref.watch(quizRepositoryProvider);

  final purchased = await courseRepo.getPurchasedCourseIds();
  final attempts = await quizRepo.getAttemptsForStudent(user.id);

  final overallAverage = attempts.isEmpty
      ? 0.0
      : attempts.map((a) => a.percentage).reduce((a, b) => a + b) / attempts.length;

  // Streak: count back from today, day by day, while at least one
  // attempt landed on that calendar day.
  final attemptDays = attempts.map((a) {
    final d = a.takenAt;
    return DateTime(d.year, d.month, d.day);
  }).toSet();
  var streak = 0;
  var cursor = DateTime.now();
  cursor = DateTime(cursor.year, cursor.month, cursor.day);
  while (attemptDays.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return StudentStats(
    coursesEnrolled: purchased.length,
    quizzesTaken: attempts.length,
    overallAverage: overallAverage,
    streakDays: streak,
  );
});

/// How far the current student has gotten in one specific course — the
/// fraction of that course's quizzes they've attempted at least once.
/// Powers the "Continue learning" progress bar on the dashboard.
final courseCompletionProvider =
    FutureProvider.family<double, CourseModel>((ref, course) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null || course.quizIds.isEmpty) return 0.0;
  final quizRepo = ref.watch(quizRepositoryProvider);
  final attempts = await quizRepo.getAttemptsForStudent(user.id);
  final attemptedQuizIds = attempts.where((a) => a.courseId == course.id).map((a) => a.quizId).toSet();
  return (attemptedQuizIds.length / course.quizIds.length).clamp(0.0, 1.0);
});
