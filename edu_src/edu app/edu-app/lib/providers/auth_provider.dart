import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_enums.dart';
import '../models/user_model.dart';
import '../services/local/credential_service.dart';
import '../services/local/seed_data_service.dart';
import 'repository_providers.dart';

/// Thrown by sign-up/login so screens can show a friendly inline error
/// instead of a generic exception message.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Holds the logged-in user (student/teacher/admin) or null if nobody has
/// completed onboarding/login yet. GoRouter's redirect logic reads this to
/// decide whether to show onboarding, or the right role's home screen.
class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final repo = ref.read(userRepositoryProvider);
    return repo.getCurrentUser();
  }

  /// Called once, from the onboarding screen, for a new student.
  Future<void> completeStudentOnboarding({
    required String name,
    required Grade grade,
    required int age,
  }) async {
    final repo = ref.read(userRepositoryProvider);
    final user = AppUser(
      id: const Uuid().v4(),
      name: name,
      role: UserRole.student,
      grade: grade,
      age: age,
    );
    await repo.saveCurrentUser(user);
    await repo.setOnboardingComplete(true);
    state = AsyncData(user);

    // Give the new student a realistic starting point: a couple of
    // purchased courses, an uneven quiz history (so the lagging-subject
    // tracker has something real to show), and one open doubt thread.
    await SeedDataService.seedProgressForStudent(
      student: user,
      courseRepo: ref.read(courseRepositoryProvider),
      quizRepo: ref.read(quizRepositoryProvider),
      doubtRepo: ref.read(doubtChatRepositoryProvider),
      transactionRepo: ref.read(transactionRepositoryProvider),
      platformRepo: ref.read(platformRepositoryProvider),
    );
  }

  /// Student sign-up. New students always create an account first (no
  /// "log in" for a brand-new email) — mirrors [completeStudentOnboarding]
  /// but also records real email/password credentials so the student can
  /// come back later via [loginStudent] instead of onboarding again.
  Future<void> signUpStudent({
    required String name,
    required String email,
    required String password,
    required int age,
    required Grade grade,
    String? gender,
  }) async {
    final creds = CredentialService.instance;
    if (await creds.emailExists(email)) {
      throw AuthException('An account with this email already exists.');
    }

    final repo = ref.read(userRepositoryProvider);
    final user = AppUser(
      id: const Uuid().v4(),
      name: name,
      role: UserRole.student,
      email: email,
      grade: grade,
      age: age,
      gender: gender,
    );
    await creds.register(email, password);
    await repo.saveCurrentUser(user);
    await repo.setOnboardingComplete(true);
    state = AsyncData(user);

    // Same starter content a fresh onboarding gets: a couple of purchased
    // courses, quiz history and one open doubt thread.
    await SeedDataService.seedProgressForStudent(
      student: user,
      courseRepo: ref.read(courseRepositoryProvider),
      quizRepo: ref.read(quizRepositoryProvider),
      doubtRepo: ref.read(doubtChatRepositoryProvider),
      transactionRepo: ref.read(transactionRepositoryProvider),
      platformRepo: ref.read(platformRepositoryProvider),
    );
  }

  /// Student login: email + password against the local credential store,
  /// then loads the matching student record already saved at sign-up.
  Future<void> loginStudent({required String email, required String password}) async {
    final creds = CredentialService.instance;
    if (!await creds.verify(email, password)) {
      throw AuthException('Incorrect email or password.');
    }
    final repo = ref.read(userRepositoryProvider);
    final users = await repo.getAllUsers();
    final matches = users.where((u) => u.role == UserRole.student && u.email == email);
    if (matches.isEmpty) {
      throw AuthException('No student account found for this email.');
    }
    final user = matches.first;
    await repo.saveCurrentUser(user);
    state = AsyncData(user);
  }

  /// Teacher sign-up: same shape as student sign-up but stores a subject
  /// instead of a grade. Reuses the same credential store and user repo.
  Future<void> signUpTeacher({
    required String name,
    required String email,
    required String password,
    required Subject subject,
  }) async {
    final creds = CredentialService.instance;
    if (await creds.emailExists(email)) {
      throw AuthException('An account with this email already exists.');
    }

    final repo = ref.read(userRepositoryProvider);
    final user = AppUser(
      id: const Uuid().v4(),
      name: name,
      role: UserRole.teacher,
      email: email,
      assignedSubjects: [subject],
    );
    await creds.register(email, password);
    await repo.saveCurrentUser(user);
    state = AsyncData(user);
  }

  /// Teacher login: email + password against the local credential store.
  Future<void> loginTeacher({required String email, required String password}) async {
    final creds = CredentialService.instance;
    if (!await creds.verify(email, password)) {
      throw AuthException('Incorrect email or password.');
    }
    final repo = ref.read(userRepositoryProvider);
    final users = await repo.getAllUsers();
    final matches = users.where((u) => u.role == UserRole.teacher && u.email == email);
    if (matches.isEmpty) {
      throw AuthException('No teacher account found for this email.');
    }
    final user = matches.first;
    await repo.saveCurrentUser(user);
    state = AsyncData(user);
  }

  /// Simple local login stub for teacher/admin (no backend yet). A real
  /// auth flow slots in here later without changing callers. Signing in
  /// as "Teacher" reuses one of the seeded teacher accounts (fixed id) so
  /// the teacher dashboard shows real assigned courses/classes instead of
  /// a brand-new id nothing in storage points to.
  Future<void> loginAs(AppUser user) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.saveCurrentUser(user);
    state = AsyncData(user);
  }

  Future<void> updateProfile({String? name, Grade? grade, int? age}) async {
    final current = state.value;
    if (current == null) return;
    final repo = ref.read(userRepositoryProvider);
    final updated = current.copyWith(name: name, grade: grade, age: age);
    await repo.saveCurrentUser(updated);
    state = AsyncData(updated);
  }

  Future<void> logout() async {
    final repo = ref.read(userRepositoryProvider);
    await repo.clearCurrentUser();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

/// Convenience provider: has onboarding ever been completed on this device?
final onboardingCompleteProvider = FutureProvider<bool>((ref) {
  return ref.watch(userRepositoryProvider).isOnboardingComplete();
});
