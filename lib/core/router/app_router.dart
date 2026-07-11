import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_enums.dart';
import '../../models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/audit_log_screen.dart';
import '../../screens/admin/course_editor_screen.dart';
import '../../screens/admin/course_management_screen.dart';
import '../../screens/admin/import_users_screen.dart';
import '../../screens/admin/manage_teachers_screen.dart';
import '../../screens/admin/parent_report_screen.dart';
import '../../screens/admin/platform_classes_screen.dart';
import '../../screens/admin/recordings_screen.dart';
import '../../screens/admin/revenue_dashboard_screen.dart';
import '../../screens/admin/student_progress_detail_screen.dart';
import '../../screens/admin/student_progress_list_screen.dart';
import '../../screens/admin/teacher_performance_screen.dart';
import '../../screens/onboarding/forgot_password_screen.dart';
import '../../screens/onboarding/student_login_screen.dart';
import '../../screens/onboarding/student_otp_verify_screen.dart';
import '../../screens/onboarding/student_signup_screen.dart';
import '../../screens/onboarding/teacher_login_screen.dart';
import '../../screens/student/assessment_attempt_screen.dart';
import '../../screens/student/assessments_screen.dart';
import '../../screens/student/attendance_screen.dart';
import '../../screens/student/calendar_screen.dart';
import '../../screens/student/certificates_screen.dart';
import '../../screens/student/course_detail_screen.dart';
import '../../screens/student/courses_screen.dart';
import '../../screens/student/dashboard_screen.dart';
import '../../screens/student/doubt_chat_screen.dart';
import '../../screens/student/assignments_screen.dart';
import '../../screens/student/coding_ide_screen.dart';
import '../../screens/student/game_screen.dart';
import '../../screens/student/leaderboard_screen.dart';
import '../../screens/student/live_classes_screen.dart';
import '../../screens/student/mini_projects_screen.dart';
import '../../screens/student/notes_screen.dart';
import '../../screens/student/notifications_screen.dart';
import '../../screens/student/profile_screen.dart';
import '../../screens/student/quiz_screen.dart';
import '../../screens/student/recorded_videos_screen.dart';
import '../../screens/shared/doubt_thread_screen.dart';
import '../../screens/admin/syllabus_screen.dart';
import '../../screens/student/syllabus_screen.dart';
import '../../screens/teacher/syllabus_screen.dart';
import '../../screens/teacher/announcements_screen.dart';
import '../../screens/teacher/assigned_courses_screen.dart';
import '../../screens/teacher/attendance_marking_screen.dart';
import '../../screens/teacher/availability_screen.dart';
import '../../screens/teacher/batches_screen.dart';
import '../../screens/teacher/upload_content_screen.dart';
import '../../screens/teacher/doubt_chat_list_screen.dart';
import '../../screens/teacher/earnings_screen.dart';
import '../../screens/teacher/my_students_screen.dart';
import '../../screens/teacher/review_queue_screen.dart';
import '../../screens/teacher/start_class_screen.dart';
import '../../screens/teacher/teacher_dashboard_screen.dart';
import '../../screens/admin/payments_screen.dart';

/// Route paths centralized so screens don't hardcode strings when
/// navigating (context.go(AppRoutes.dashboard) instead of '/dashboard').
class AppRoutes {
  static const roleSelect = '/'; // Welcome screen ("Continue as Student/Teacher")

  static const studentSignUp = '/auth/student/signup';
  static const studentVerifyOtp = '/auth/student/verify-otp';
  static const studentLogin = '/auth/student/login';
  static const teacherLogin = '/auth/teacher/login';
  static const forgotPassword = '/auth/forgot-password';

  static const studentDashboard = '/student';
  static const studentCourses = '/student/courses';
  static const studentCourseDetail = '/student/courses/:courseId';
  static const studentQuiz = '/student/quiz/:quizId';
  static const studentCalendar = '/student/calendar';
  static const studentDoubtChat = '/student/doubt-chat';
  static const studentProfile = '/student/profile';
  static const studentAssessments = '/student/assessments';
  static const studentAssessment = '/student/assessments/:assessmentId';
  static const studentProjects = '/student/projects';
  static const studentCertificates = '/student/certificates';
  static const studentAttendance = '/student/attendance';
  static const studentLeaderboard = '/student/leaderboard';
  static const studentNotifications = '/student/notifications';
  static const studentGame = '/student/game';
  static const studentLiveClasses = '/student/live-classes';
  static const studentRecordedVideos = '/student/recorded-videos';
  static const studentNotes = '/student/notes';
  static const studentAssignments = '/student/assignments';
  static const studentCodingIde = '/student/coding-ide';
  static const studentSyllabus = '/student/syllabus';

  static const teacherDashboard = '/teacher';
  static const teacherAssignedCourses = '/teacher/courses';
  static const teacherMyStudents = '/teacher/students';
  static const teacherSyllabus = '/teacher/syllabus';
  static const teacherStartClass = '/teacher/start-class';
  static const teacherDoubtChat = '/teacher/doubt-chat';
  static const teacherEarnings = '/teacher/earnings';
  static const teacherReviewQueue = '/teacher/review-queue';
  static const teacherAssessmentGrading = '/teacher/grading/:assessmentId';
  static const teacherAttendance = '/teacher/attendance';
  static const teacherAnnouncements = '/teacher/announcements';
  static const teacherAvailability = '/teacher/availability';
  static const teacherBatches = '/teacher/batches';
  static const teacherContentUpload = '/teacher/content-upload';

  static const adminDashboard = '/admin';
  static const adminManageTeachers = '/admin/teachers';
  static const adminSyllabus = '/admin/syllabus';
  static const adminPayments = '/admin/payments';
  static const adminStudentProgress = '/admin/students';
  static const adminStudentProgressDetail = '/admin/students/:studentId';
  static const adminClasses = '/admin/classes';
  static const adminRevenue = '/admin/revenue';
  static const adminCourses = '/admin/courses';
  static const adminCourseEditor = '/admin/courses/editor';
  static const adminTeacherPerformance = '/admin/teacher-performance';
  static const adminRecordings = '/admin/recordings';
  static const adminAuditLog = '/admin/audit-log';
  static const adminImportUsers = '/admin/import-users';
  static const adminParentReport = '/admin/parent-report/:studentId';

  static const doubtThread = '/doubt-thread/:threadId';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.roleSelect,
    redirect: (context, state) {
      // Still resolving current user from local storage — don't redirect yet.
      if (authState.isLoading) return null;

      final user = authState.value;

      // Every screen reachable before signing in: the Welcome screen, the
      // student sign-up + OTP verification + sign-in screens, and the
      // teacher/admin sign-in screen. Teachers/admins never sign up in the
      // app — those accounts are created directly in Supabase.
      const authRoutes = {
        AppRoutes.roleSelect,
        AppRoutes.studentSignUp,
        AppRoutes.studentVerifyOtp,
        AppRoutes.studentLogin,
        AppRoutes.teacherLogin,
        AppRoutes.forgotPassword,
      };
      final goingToAuthRoute = authRoutes.contains(state.matchedLocation);

      if (user == null) {
        // Not logged in: only the auth routes above are reachable.
        if (goingToAuthRoute) return null;
        return AppRoutes.roleSelect;
      }

      // Logged in but landed on an auth route -> send to their home.
      if (goingToAuthRoute) {
        return _homeForRole(user.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.roleSelect,
        // Student sign-in is the app's landing screen.
        builder: (context, state) => const StudentLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentSignUp,
        builder: (context, state) => const StudentSignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentVerifyOtp,
        builder: (context, state) => StudentOtpVerifyScreen(
          email: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.studentLogin,
        builder: (context, state) => const StudentLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherLogin,
        builder: (context, state) => const TeacherLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => ForgotPasswordScreen(
          initialEmail: state.extra as String?,
        ),
      ),

      // Student
      GoRoute(
        path: AppRoutes.studentDashboard,
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCourses,
        builder: (context, state) => const CoursesScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCourseDetail,
        builder: (context, state) => CourseDetailScreen(
          courseId: state.pathParameters['courseId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.studentQuiz,
        builder: (context, state) => QuizScreen(
          quizId: state.pathParameters['quizId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.studentCalendar,
        builder: (context, state) => const StudentCalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentDoubtChat,
        builder: (context, state) => const StudentDoubtChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAssessments,
        builder: (context, state) => const AssessmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAssessment,
        builder: (context, state) => AssessmentAttemptScreen(
          assessmentId: state.pathParameters['assessmentId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.studentProjects,
        builder: (context, state) => const MiniProjectsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCertificates,
        builder: (context, state) => const CertificatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAttendance,
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentLeaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentNotifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentGame,
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentLiveClasses,
        builder: (context, state) => const StudentLiveClassesScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentRecordedVideos,
        builder: (context, state) => const RecordedVideosScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentNotes,
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentAssignments,
        builder: (context, state) => const AssignmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentCodingIde,
        builder: (context, state) => const CodingIdeScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentSyllabus,
        builder: (context, state) => const StudentSyllabusScreen(),
      ),

      // Teacher
      GoRoute(
        path: AppRoutes.teacherDashboard,
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherAssignedCourses,
        builder: (context, state) => const AssignedCoursesScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherMyStudents,
        builder: (context, state) => const MyStudentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherSyllabus,
        builder: (context, state) => const TeacherSyllabusScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherStartClass,
        builder: (context, state) => const StartClassScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherDoubtChat,
        builder: (context, state) => const TeacherDoubtChatListScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherEarnings,
        builder: (context, state) => const TeacherEarningsScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherReviewQueue,
        builder: (context, state) => const ReviewQueueScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherAttendance,
        builder: (context, state) => const AttendanceMarkingScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherAnnouncements,
        builder: (context, state) => const TeacherAnnouncementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherAvailability,
        builder: (context, state) => const AvailabilityScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherBatches,
        builder: (context, state) => const BatchesScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherContentUpload,
        builder: (context, state) => const UploadContentScreen(),
      ),

      // Admin
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminManageTeachers,
        builder: (context, state) => const ManageTeachersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSyllabus,
        builder: (context, state) => const AdminSyllabusScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPayments,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminStudentProgress,
        builder: (context, state) => const StudentProgressListScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminStudentProgressDetail,
        builder: (context, state) => StudentProgressDetailScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminClasses,
        builder: (context, state) => const PlatformClassesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminRevenue,
        builder: (context, state) => const RevenueDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCourses,
        builder: (context, state) => const CourseManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCourseEditor,
        builder: (context, state) => CourseEditorScreen(
          course: state.extra as CourseModel?,
        ),
      ),
      GoRoute(
        path: AppRoutes.adminTeacherPerformance,
        builder: (context, state) => const TeacherPerformanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminRecordings,
        builder: (context, state) => const RecordingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAuditLog,
        builder: (context, state) => const AuditLogScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminImportUsers,
        builder: (context, state) => const ImportUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminParentReport,
        builder: (context, state) => ParentReportScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),

      // Shared
      GoRoute(
        path: AppRoutes.doubtThread,
        builder: (context, state) => DoubtThreadScreen(
          threadId: state.pathParameters['threadId']!,
        ),
      ),
    ],
  );
});

String _homeForRole(UserRole role) {
  switch (role) {
    case UserRole.student:
      return AppRoutes.studentDashboard;
    case UserRole.teacher:
      return AppRoutes.teacherDashboard;
    case UserRole.admin:
      return AppRoutes.adminDashboard;
  }
}