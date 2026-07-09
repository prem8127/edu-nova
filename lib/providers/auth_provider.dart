import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_enums.dart';
import '../models/user_model.dart';
import '../services/local/seed_data_service.dart';
import '../services/supabase/supabase_config.dart';
import 'repository_providers.dart';

/// Thrown by sign-up/login so screens can show a friendly inline error
/// instead of a generic exception message.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Holds the logged-in user (student/teacher/admin) or null if nobody is
/// signed in. GoRouter's redirect logic reads this to decide whether to
/// show onboarding, or the right role's home screen.
class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    // Keep AuthController in sync whenever Supabase's own session state
    // changes (sign-in, sign-out, token refresh, or the confirm-signup ->
    // session-created transition after OTP verification).
    supabase.auth.onAuthStateChange.listen((_) async {
      state = AsyncData(await ref.read(userRepositoryProvider).getCurrentUser());
    });
    final repo = ref.read(userRepositoryProvider);
    return repo.getCurrentUser();
  }

  /// Step 1 of student sign-up: creates the Supabase Auth user (unconfirmed)
  /// and stashes name/grade/age/gender as user metadata, which a database
  /// trigger copies into `profiles` once the row exists. No session/profile
  /// is usable yet — the student must verify the OTP emailed to them
  /// (step 2: [verifyStudentSignUpOtp]) before they can log in.
  Future<void> signUpStudent({
    required String name,
    required String email,
    required String password,
    required int age,
    required Grade grade,
    String? gender,
  }) async {
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': UserRole.student.name,
          'grade': grade.name,
          'age': age,
          'gender': gender,
        },
      );
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyAuthError(e));
    }
  }

  /// Step 2 of student sign-up: verifies the 6-digit code emailed to the
  /// student (Supabase Auth "Confirm signup" OTP — configure the email
  /// template + Gmail SMTP in the Supabase dashboard, see
  /// supabase/SETUP.md). Success creates a real session, i.e. the student
  /// is now logged in and their profile/grade is permanently on file, so
  /// they'll never be asked for it again.
  Future<void> verifyStudentSignUpOtp({required String email, required String token}) async {
    try {
      final res = await supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: token,
      );
      if (res.session == null) {
        throw AuthException("That code didn't work. Please try again.");
      }
      final user = await ref.read(userRepositoryProvider).getCurrentUser();
      state = AsyncData(user);
      if (user != null) {
        await SeedDataService.seedProgressForStudent(
          student: user,
          courseRepo: ref.read(courseRepositoryProvider),
          quizRepo: ref.read(quizRepositoryProvider),
          doubtRepo: ref.read(doubtChatRepositoryProvider),
          transactionRepo: ref.read(transactionRepositoryProvider),
          platformRepo: ref.read(platformRepositoryProvider),
        );
      }
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyAuthError(e, fallback: 'Incorrect or expired code.'));
    }
  }

  /// Resends the sign-up OTP (e.g. student didn't get the email in time).
  Future<void> resendStudentSignUpOtp({required String email}) async {
    try {
      await supabase.auth.resend(type: OtpType.signup, email: email);
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyAuthError(e));
    }
  }

  /// Student login: real Supabase Auth session, then loads the matching
  /// profile row. Rejects the credentials if that account isn't actually a
  /// student (e.g. someone tries a teacher email here).
  Future<void> loginStudent({required String email, required String password}) async {
    final user = await _signIn(email: email, password: password, expectedRoles: const {
      UserRole.student,
    });
    state = AsyncData(user);
  }

  /// Teacher/admin login: same Supabase Auth sign-in, but these accounts
  /// are never created from inside the app — they're added directly in
  /// Supabase (Authentication -> Users) by an admin. Whichever of the two
  /// roles the profile actually has is what signs the person in; the
  /// screen doesn't need to know in advance.
  Future<void> loginTeacher({required String email, required String password}) async {
    final user = await _signIn(email: email, password: password, expectedRoles: const {
      UserRole.teacher,
      UserRole.admin,
    });
    state = AsyncData(user);
  }

  Future<AppUser> _signIn({
    required String email,
    required String password,
    required Set<UserRole> expectedRoles,
  }) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyAuthError(e, fallback: 'Incorrect email or password.'));
    }

    final user = await ref.read(userRepositoryProvider).getCurrentUser();
    if (user == null || !expectedRoles.contains(user.role)) {
      await supabase.auth.signOut();
      throw AuthException('No account with that role was found for this email.');
    }
    return user;
  }

  /// Step 1 of "forgot password": emails a 6-digit recovery code to the
  /// given address (uses the same Supabase "Reset password" email
  /// template / Gmail SMTP as sign-up OTP — see supabase/SETUP.md).
  /// Doesn't reveal whether the account exists, so the UI copy should stay
  /// generic either way.
  Future<void> sendPasswordResetOtp({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyAuthError(e));
    }
  }

  /// Step 2: verifies the recovery code. Success opens a short-lived
  /// "recovery" session that only [updatePasswordAfterReset] should use.
  Future<void> verifyPasswordResetOtp({required String email, required String token}) async {
    try {
      final res = await supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: token,
      );
      if (res.session == null) {
        throw AuthException("That code didn't work. Please try again.");
      }
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyAuthError(e, fallback: 'Incorrect or expired code.'));
    }
  }

  /// Step 3: sets the new password on the recovery session opened above,
  /// then signs out so the person logs back in normally with it — keeps
  /// the "reset password" flow fully separate from being silently signed
  /// in as whoever's email that was.
  Future<void> updatePasswordAfterReset(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyAuthError(e));
    } finally {
      await supabase.auth.signOut();
    }
  }

  /// Resends the password-reset OTP (same call as step 1; separate name
  /// so screens can drive a resend-cooldown button like the sign-up flow).
  Future<void> resendPasswordResetOtp({required String email}) => sendPasswordResetOtp(email: email);

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

  String _friendlyAuthError(AuthApiException e, {String? fallback}) {
    final msg = e.message.toLowerCase();
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('invalid login credentials')) {
      return fallback ?? 'Incorrect email or password.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email with the code we sent you first.';
    }
    if (msg.contains('expired') || msg.contains('invalid') && msg.contains('otp')) {
      return 'That code is incorrect or has expired. Try resending it.';
    }
    return fallback ?? e.message;
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

/// Convenience provider: has onboarding ever been completed on this device?
/// (Legacy UI flag only -- not used by the reachable sign-up/login flow.)
final onboardingCompleteProvider = FutureProvider<bool>((ref) {
  return ref.watch(userRepositoryProvider).isOnboardingComplete();
});
