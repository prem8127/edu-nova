import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/interfaces/course_repository.dart';
import '../services/interfaces/doubt_chat_repository.dart';
import '../services/interfaces/quiz_repository.dart';
import '../services/interfaces/schedule_repository.dart';
import '../services/interfaces/platform_repository.dart';
import '../services/interfaces/transaction_repository.dart';
import '../services/interfaces/user_repository.dart';
import '../services/local/local_course_repository.dart';
import '../services/local/local_doubt_chat_repository.dart';
import '../services/local/local_platform_repository.dart';
import '../services/local/local_quiz_repository.dart';
import '../services/local/local_schedule_repository.dart';
import '../services/local/local_transaction_repository.dart';
import '../services/supabase/supabase_user_repository.dart';

/// ── SWAP POINT ─────────────────────────────────────────────────────────
/// Everything downstream (providers, screens) depends on the *interface*
/// types above, never the Local*/Supabase* classes directly. Users now run
/// through real Supabase Auth + the `profiles` table (see
/// supabase/schema.sql). Course/quiz/etc. data is still local-only until
/// those get the same treatment.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return SupabaseUserRepository();
});

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return LocalCourseRepository();
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return LocalQuizRepository();
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return LocalScheduleRepository();
});

final doubtChatRepositoryProvider = Provider<DoubtChatRepository>((ref) {
  return LocalDoubtChatRepository();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return LocalTransactionRepository();
});

final platformRepositoryProvider = Provider<PlatformRepository>((ref) {
  return LocalPlatformRepository();
});
