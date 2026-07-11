import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_enums.dart';
import '../models/course_model.dart';
import '../models/transaction_model.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';
import 'revenue_provider.dart';

/// All courses visible to the logged-in student's grade, optionally
/// filtered by subject tab (Tech/Business/Finance/Content Creation).
final coursesForCurrentStudentProvider =
    FutureProvider.family<List<CourseModel>, Subject?>((ref, subject) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null || user.grade == null) return [];
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getCoursesByGradeAndSubject(user.grade!, subject);
});

final coursesForTeacherProvider =
    FutureProvider.family<List<CourseModel>, String>((ref, teacherId) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getCoursesByTeacher(teacherId);
});

final purchasedCourseIdsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getPurchasedCourseIds();
});

/// Paywall action: purchase, record the payment as a transaction (so the
/// admin revenue dashboard and teacher earnings view have something to
/// aggregate), then invalidate the dependent providers so UI refreshes to
/// "unlocked" state immediately.
final purchaseCourseProvider =
    Provider<Future<void> Function(String courseId)>((ref) {
  return (String courseId) async {
    final courseRepo = ref.read(courseRepositoryProvider);
    await courseRepo.purchaseCourse(courseId);

    final student = ref.read(authControllerProvider).value;
    final course = await courseRepo.getCourseById(courseId);
    if (student != null && course != null && course.requiresPurchase) {
      await ref.read(transactionRepositoryProvider).recordTransaction(
            TransactionModel(
              id: const Uuid().v4(),
              studentId: student.id,
              courseId: course.id,
              teacherId: course.teacherId,
              amount: course.price,
              createdAt: DateTime.now(),
            ),
          );
      ref.invalidate(allTransactionsProvider);
    }

    ref.invalidate(purchasedCourseIdsProvider);
    ref.invalidate(coursesForCurrentStudentProvider);
  };
});

final isCourseUnlockedProvider =
    FutureProvider.family<bool, String>((ref, courseId) async {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.isCourseUnlocked(courseId);
});
