import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_enums.dart';
import '../models/platform_models.dart';
import '../services/assessment_ai.dart';
import '../services/interfaces/platform_repository.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// ===========================================================================
/// Shared user lookups (used by teacher grading + admin screens)
/// ===========================================================================

/// A quick id -> display name map for showing student names on submissions.
final userNameMapProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final users = await ref.watch(userRepositoryProvider).getAllUsers();
  return {for (final u in users) u.id: u.name};
});

/// ===========================================================================
/// Assessments
/// ===========================================================================

final assessmentsForCourseProvider = FutureProvider.autoDispose
    .family<List<Assessment>, String>((ref, courseId) async {
  return ref.watch(platformRepositoryProvider).getAssessmentsByCourse(courseId);
});

final assessmentByIdProvider =
    FutureProvider.autoDispose.family<Assessment?, String>((ref, id) async {
  return ref.watch(platformRepositoryProvider).getAssessmentById(id);
});

/// Every assessment across all of a grade's courses (all subjects), so the
/// student can browse them in one place.
final assessmentsForGradeProvider = FutureProvider.autoDispose
    .family<List<Assessment>, Grade>((ref, grade) async {
  final courses = await ref.watch(courseRepositoryProvider).getAllCourses();
  final platform = ref.watch(platformRepositoryProvider);
  final result = <Assessment>[];
  for (final c in courses.where((c) => c.grade == grade)) {
    result.addAll(await platform.getAssessmentsByCourse(c.id));
  }
  return result;
});

/// The signed-in student's submissions (all assessments).
final mySubmissionsProvider =
    FutureProvider.autoDispose<List<AssessmentSubmission>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return const [];
  return ref.watch(platformRepositoryProvider).getSubmissionsForStudent(user.id);
});

/// The current student's submission for one assessment (if any).
final mySubmissionForAssessmentProvider = FutureProvider.autoDispose
    .family<AssessmentSubmission?, String>((ref, assessmentId) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return null;
  return ref
      .watch(platformRepositoryProvider)
      .getSubmission(assessmentId, user.id);
});

/// Teacher grading queue for a single assessment.
final assessmentSubmissionsProvider = FutureProvider.autoDispose
    .family<List<AssessmentSubmission>, String>((ref, assessmentId) async {
  return ref
      .watch(platformRepositoryProvider)
      .getSubmissionsForAssessment(assessmentId);
});

/// Teacher review queue for writing submissions that need a human grade
/// (auto-graded types never land here). Newest first.
final writingReviewQueueProvider =
    FutureProvider.autoDispose<List<AssessmentSubmission>>((ref) async {
  final all =
      await ref.watch(platformRepositoryProvider).getAllAssessmentSubmissions();
  final queue = all
      .where((s) =>
          s.type == AssessmentType.writing &&
          (s.status == SubmissionStatus.underReview ||
              s.status == SubmissionStatus.aiFlagged))
      .toList();
  queue.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  return queue;
});

class AssessmentController extends StateNotifier<AsyncValue<void>> {
  AssessmentController(this._ref) : super(const AsyncValue.data(null));
  final Ref _ref;
  PlatformRepository get _repo => _ref.read(platformRepositoryProvider);

  /// Grade an attempt with the in-house engine and persist it.
  Future<AssessmentSubmission> submit({
    required Assessment assessment,
    String content = '',
    int? selectedOption,
    double? numericAnswer,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authControllerProvider).value;

      late final GradeResult result;
      switch (assessment.type) {
        case AssessmentType.coding:
          result = AssessmentGrader.gradeCoding(assessment, content);
          break;
        case AssessmentType.calculation:
          result = AssessmentGrader.gradeCalculation(assessment, numericAnswer ?? 0);
          break;
        case AssessmentType.mcq:
          result = AssessmentGrader.gradeMcq(assessment, selectedOption ?? -1);
          break;
        case AssessmentType.writing:
          final pre = AiPrecheck.reviewWriting(content, assessment.minWords);
          result = GradeResult(
            0,
            pre.flagged ? SubmissionStatus.aiFlagged : SubmissionStatus.underReview,
            pre.summary,
          );
          break;
      }

      final autoGraded = assessment.type.autoGraded;
      final submission = AssessmentSubmission(
        id: 'asub_${DateTime.now().microsecondsSinceEpoch}',
        assessmentId: assessment.id,
        courseId: assessment.courseId,
        studentId: user?.id ?? 'anon',
        type: assessment.type,
        content: content,
        numericAnswer: numericAnswer,
        selectedOption: selectedOption,
        status: result.status,
        autoScore: autoGraded ? result.score : null,
        aiFeedback: result.feedback,
        submittedAt: DateTime.now(),
      );
      await _repo.upsertAssessmentSubmission(submission);

      // Notify the student of an auto-graded result.
      if (autoGraded && user != null) {
        await _repo.addNotification(NotificationItem(
          id: 'ntf_${DateTime.now().microsecondsSinceEpoch}',
          userId: user.id,
          type: NotificationType.submissionResult,
          title: 'Assessment graded: ${assessment.title}',
          body: 'You scored ${result.score}%. ${result.feedback}',
          createdAt: DateTime.now(),
        ));
      }

      _invalidate(assessment.id);
      state = const AsyncValue.data(null);
      return submission;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Teacher grades a writing submission that needs a human.
  Future<void> teacherReview({
    required AssessmentSubmission submission,
    required int score,
    required String feedback,
    required bool approved,
  }) async {
    final updated = submission.copyWith(
      teacherScore: score,
      teacherFeedback: feedback,
      status: approved ? SubmissionStatus.approved : SubmissionStatus.needsWork,
    );
    await _repo.upsertAssessmentSubmission(updated);
    await _repo.addNotification(NotificationItem(
      id: 'ntf_${DateTime.now().microsecondsSinceEpoch}',
      userId: submission.studentId,
      type: NotificationType.submissionResult,
      title: 'Your writing task was reviewed',
      body: '${approved ? 'Approved' : 'Needs work'} · $score%. $feedback',
      createdAt: DateTime.now(),
    ));
    _invalidate(submission.assessmentId);
  }

  void _invalidate(String assessmentId) {
    _ref.invalidate(mySubmissionsProvider);
    _ref.invalidate(mySubmissionForAssessmentProvider(assessmentId));
    _ref.invalidate(assessmentSubmissionsProvider(assessmentId));
  }
}

final assessmentControllerProvider =
    StateNotifierProvider<AssessmentController, AsyncValue<void>>(
        (ref) => AssessmentController(ref));

/// ===========================================================================
/// Mini-projects
/// ===========================================================================

final projectsForCourseProvider = FutureProvider.autoDispose
    .family<List<MiniProject>, String>((ref, courseId) async {
  return ref.watch(platformRepositoryProvider).getProjectsByCourse(courseId);
});

/// Every mini-project across all of a grade's courses.
final projectsForGradeProvider = FutureProvider.autoDispose
    .family<List<MiniProject>, Grade>((ref, grade) async {
  final courses = await ref.watch(courseRepositoryProvider).getAllCourses();
  final platform = ref.watch(platformRepositoryProvider);
  final result = <MiniProject>[];
  for (final c in courses.where((c) => c.grade == grade)) {
    result.addAll(await platform.getProjectsByCourse(c.id));
  }
  return result;
});

final myProjectSubmissionsProvider =
    FutureProvider.autoDispose<List<ProjectSubmission>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return const [];
  return ref
      .watch(platformRepositoryProvider)
      .getProjectSubmissionsForStudent(user.id);
});

/// Teacher review queue: everything not yet approved, newest first.
final projectReviewQueueProvider =
    FutureProvider.autoDispose<List<ProjectSubmission>>((ref) async {
  final all =
      await ref.watch(platformRepositoryProvider).getAllProjectSubmissions();
  final queue =
      all.where((s) => s.status != SubmissionStatus.approved).toList();
  queue.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  return queue;
});

class ProjectController extends StateNotifier<AsyncValue<void>> {
  ProjectController(this._ref) : super(const AsyncValue.data(null));
  final Ref _ref;
  PlatformRepository get _repo => _ref.read(platformRepositoryProvider);

  Future<ProjectSubmission> submit({
    required MiniProject project,
    required String title,
    required String description,
    required String link,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authControllerProvider).value;
      // AI pre-check runs before it reaches a teacher.
      final pre = project.subject == Subject.contentCreation
          ? AiPrecheck.reviewWriting(description, 80)
          : AiPrecheck.reviewCode(description);
      final submission = ProjectSubmission(
        id: 'psub_${DateTime.now().microsecondsSinceEpoch}',
        projectId: project.id,
        courseId: project.courseId,
        studentId: user?.id ?? 'anon',
        title: title,
        description: description,
        link: link,
        status: pre.flagged
            ? SubmissionStatus.aiFlagged
            : SubmissionStatus.underReview,
        aiPrecheck: pre.summary,
        submittedAt: DateTime.now(),
      );
      await _repo.upsertProjectSubmission(submission);
      _ref.invalidate(myProjectSubmissionsProvider);
      _ref.invalidate(projectReviewQueueProvider);
      state = const AsyncValue.data(null);
      return submission;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> review({
    required ProjectSubmission submission,
    required bool approved,
    required String feedback,
    Subject? subject,
    Grade? grade,
    String? studentName,
  }) async {
    final updated = submission.copyWith(
      status: approved ? SubmissionStatus.approved : SubmissionStatus.needsWork,
      teacherFeedback: feedback,
    );
    await _repo.upsertProjectSubmission(updated);
    await _repo.addNotification(NotificationItem(
      id: 'ntf_${DateTime.now().microsecondsSinceEpoch}',
      userId: submission.studentId,
      type: NotificationType.submissionResult,
      title: 'Project reviewed: ${submission.title}',
      body: approved ? 'Approved. $feedback' : 'Needs work. $feedback',
      createdAt: DateTime.now(),
    ));

    // Approving a project issues a certificate for the portfolio.
    if (approved && subject != null && grade != null) {
      final cert = Certificate(
        id: 'cert_${DateTime.now().microsecondsSinceEpoch}',
        studentId: submission.studentId,
        studentName: studentName ?? 'Student',
        courseId: submission.courseId,
        title: '${subject.label} Project — ${submission.title}',
        subject: subject,
        grade: grade,
        scorePercent: 100,
        issuedAt: DateTime.now(),
      );
      await _repo.upsertCertificate(cert);
    }

    _ref.invalidate(myProjectSubmissionsProvider);
    _ref.invalidate(projectReviewQueueProvider);
  }
}

final projectControllerProvider =
    StateNotifierProvider<ProjectController, AsyncValue<void>>(
        (ref) => ProjectController(ref));

/// ===========================================================================
/// Certificates & portfolio
/// ===========================================================================

final myCertificatesProvider =
    FutureProvider.autoDispose<List<Certificate>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return const [];
  final list = await ref
      .watch(platformRepositoryProvider)
      .getCertificatesForStudent(user.id);
  list.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
  return list;
});

/// ===========================================================================
/// Attendance
/// ===========================================================================

final myAttendanceProvider =
    FutureProvider.autoDispose<List<AttendanceRecord>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return const [];
  return ref
      .watch(platformRepositoryProvider)
      .getAttendanceForStudent(user.id);
});

final classAttendanceProvider = FutureProvider.autoDispose
    .family<List<AttendanceRecord>, String>((ref, classId) async {
  return ref.watch(platformRepositoryProvider).getAttendanceForClass(classId);
});

final attendanceControllerProvider =
    Provider((ref) => AttendanceController(ref));

class AttendanceController {
  AttendanceController(this._ref);
  final Ref _ref;

  Future<void> mark({
    required String classId,
    required String courseId,
    required String studentId,
    required AttendanceStatus status,
  }) async {
    await _ref.read(platformRepositoryProvider).upsertAttendance(
          AttendanceRecord(
            id: 'att_${classId}_$studentId',
            classId: classId,
            courseId: courseId,
            studentId: studentId,
            status: status,
            markedAt: DateTime.now(),
          ),
        );
    _ref.invalidate(myAttendanceProvider);
    _ref.invalidate(classAttendanceProvider(classId));
  }
}

/// ===========================================================================
/// Notifications
/// ===========================================================================

final notificationsProvider =
    FutureProvider.autoDispose<List<NotificationItem>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return const [];
  return ref.watch(platformRepositoryProvider).getNotifications(user.id);
});

final unreadNotificationCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final list = await ref.watch(notificationsProvider.future);
  return list.where((n) => !n.read).length;
});

final notificationControllerProvider =
    Provider((ref) => NotificationController(ref));

class NotificationController {
  NotificationController(this._ref);
  final Ref _ref;

  Future<void> markRead(String id) async {
    await _ref.read(platformRepositoryProvider).markNotificationRead(id);
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllRead() async {
    final user = _ref.read(authControllerProvider).value;
    if (user == null) return;
    await _ref
        .read(platformRepositoryProvider)
        .markAllNotificationsRead(user.id);
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(unreadNotificationCountProvider);
  }
}

/// ===========================================================================
/// Announcements
/// ===========================================================================

final announcementsForCourseProvider = FutureProvider.autoDispose
    .family<List<Announcement>, String>((ref, courseId) async {
  return ref
      .watch(platformRepositoryProvider)
      .getAnnouncementsByCourse(courseId);
});

final announcementsForTeacherProvider = FutureProvider.autoDispose
    .family<List<Announcement>, String>((ref, teacherId) async {
  return ref
      .watch(platformRepositoryProvider)
      .getAnnouncementsByTeacher(teacherId);
});

final announcementControllerProvider =
    Provider((ref) => AnnouncementController(ref));

class AnnouncementController {
  AnnouncementController(this._ref);
  final Ref _ref;

  Future<void> post({
    required String courseId,
    required String title,
    required String body,
  }) async {
    final user = _ref.read(authControllerProvider).value;
    await _ref.read(platformRepositoryProvider).addAnnouncement(
          Announcement(
            id: 'ann_${DateTime.now().microsecondsSinceEpoch}',
            courseId: courseId,
            teacherId: user?.id ?? 'teacher',
            title: title,
            body: body,
            createdAt: DateTime.now(),
          ),
        );
    _ref.invalidate(announcementsForCourseProvider(courseId));
    if (user != null) {
      _ref.invalidate(announcementsForTeacherProvider(user.id));
    }
  }
}

/// ===========================================================================
/// Recordings library (48h auto-expiry, permanent samples)
/// ===========================================================================

final allRecordingsProvider =
    FutureProvider.autoDispose<List<Recording>>((ref) async {
  final list = await ref.watch(platformRepositoryProvider).getAllRecordings();
  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list;
});

final recordingsForCourseProvider = FutureProvider.autoDispose
    .family<List<Recording>, String>((ref, courseId) async {
  final list = await ref
      .watch(platformRepositoryProvider)
      .getRecordingsByCourse(courseId);
  // Hide expired non-sample recordings from students.
  return list.where((r) => r.isSample || !r.isExpired).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final recordingControllerProvider =
    Provider((ref) => RecordingController(ref));

class RecordingController {
  RecordingController(this._ref);
  final Ref _ref;

  Future<void> markAsSample(Recording r, bool isSample) async {
    await _ref
        .read(platformRepositoryProvider)
        .upsertRecording(r.copyWith(isSample: isSample));
    _ref.invalidate(allRecordingsProvider);
    _ref.invalidate(recordingsForCourseProvider(r.courseId));
  }

  Future<void> delete(Recording r) async {
    await _ref.read(platformRepositoryProvider).deleteRecording(r.id);
    _ref.invalidate(allRecordingsProvider);
    _ref.invalidate(recordingsForCourseProvider(r.courseId));
  }
}

/// ===========================================================================
/// Teacher availability
/// ===========================================================================

final availabilityProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, teacherId) async {
  return ref.watch(platformRepositoryProvider).getAvailability(teacherId);
});

final availabilityControllerProvider =
    Provider((ref) => AvailabilityController(ref));

class AvailabilityController {
  AvailabilityController(this._ref);
  final Ref _ref;

  Future<void> save(String teacherId, List<String> slots) async {
    await _ref
        .read(platformRepositoryProvider)
        .setAvailability(teacherId, slots);
    _ref.invalidate(availabilityProvider(teacherId));
  }
}

/// ===========================================================================
/// Audit log (super admin)
/// ===========================================================================

final auditLogProvider =
    FutureProvider.autoDispose<List<AuditEntry>>((ref) async {
  return ref.watch(platformRepositoryProvider).getAuditLog();
});

final auditControllerProvider = Provider((ref) => AuditController(ref));

class AuditController {
  AuditController(this._ref);
  final Ref _ref;

  Future<void> log(String action, String target) async {
    final user = _ref.read(authControllerProvider).value;
    await _ref.read(platformRepositoryProvider).addAuditEntry(
          AuditEntry(
            id: 'aud_${DateTime.now().microsecondsSinceEpoch}',
            actorId: user?.id ?? 'system',
            actorName: user?.name ?? 'System',
            action: action,
            target: target,
            createdAt: DateTime.now(),
          ),
        );
    _ref.invalidate(auditLogProvider);
  }
}

/// ===========================================================================
/// Gamification: arcade game personal-best + grade leaderboard
/// ===========================================================================

final gameScoresProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  return ref.watch(platformRepositoryProvider).getGameScores();
});

final gameControllerProvider = Provider((ref) => GameController(ref));

class GameController {
  GameController(this._ref);
  final Ref _ref;

  Future<void> recordScore(String gameKey, int score) async {
    await _ref.read(platformRepositoryProvider).recordGameScore(gameKey, score);
    _ref.invalidate(gameScoresProvider);
  }
}

/// Grade leaderboard, aggregated from every student's approved assessment
/// scores and certificates.
final leaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, Grade>((ref, grade) async {
  final users = await ref.watch(userRepositoryProvider).getAllUsers();
  final platform = ref.watch(platformRepositoryProvider);
  final students = users
      .where((u) => u.role == UserRole.student && u.grade == grade)
      .toList();

  final rows = <LeaderboardEntry>[];
  for (final s in students) {
    final subs = await platform.getSubmissionsForStudent(s.id);
    final certs = await platform.getCertificatesForStudent(s.id);
    final points = subs.fold<int>(0, (sum, x) => sum + (x.finalScore ?? 0)) +
        certs.length * 50;
    rows.add(LeaderboardEntry(
      studentId: s.id,
      studentName: s.name,
      points: points,
      badges: certs.length,
      rank: 0,
    ));
  }
  rows.sort((a, b) => b.points.compareTo(a.points));
  return [
    for (var i = 0; i < rows.length; i++)
      LeaderboardEntry(
        studentId: rows[i].studentId,
        studentName: rows[i].studentName,
        points: rows[i].points,
        badges: rows[i].badges,
        rank: i + 1,
      ),
  ];
});

/// ===========================================================================
/// Parent report
/// ===========================================================================

final parentReportProvider = FutureProvider.autoDispose
    .family<ParentReport, String>((ref, studentId) async {
  final platform = ref.watch(platformRepositoryProvider);
  final user = await ref.watch(userRepositoryProvider).getUserById(studentId);
  final attendance = await platform.getAttendanceForStudent(studentId);
  final subs = await platform.getSubmissionsForStudent(studentId);
  final certs = await platform.getCertificatesForStudent(studentId);

  final present =
      attendance.where((a) => a.status != AttendanceStatus.absent).length;
  final attendancePct = attendance.isEmpty
      ? 0
      : ((present / attendance.length) * 100).round();
  final approved =
      subs.where((s) => s.status == SubmissionStatus.approved).length;
  final scored = subs.where((s) => s.finalScore != null).toList();
  final avg = scored.isEmpty
      ? 0.0
      : scored.fold<int>(0, (sum, s) => sum + s.finalScore!) / scored.length;

  return ParentReport(
    studentId: studentId,
    studentName: user?.name ?? 'Student',
    attendancePercent: attendancePct,
    classesAttended: present,
    classesTotal: attendance.length,
    assignmentsApproved: approved,
    assignmentsSubmitted: subs.length,
    certificatesEarned: certs.length,
    averageScore: avg,
  );
});
