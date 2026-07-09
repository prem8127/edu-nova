import '../../models/user_model.dart';

/// Contract for user persistence. Implement this against Supabase/Firebase
/// later without touching a single provider or screen.
abstract class UserRepository {
  Future<AppUser?> getCurrentUser();
  Future<void> saveCurrentUser(AppUser user);
  Future<void> clearCurrentUser();

  Future<List<AppUser>> getAllUsers();
  Future<AppUser?> getUserById(String id);
  Future<void> upsertUser(AppUser user);
  Future<void> deleteUser(String id);

  Future<bool> isOnboardingComplete();
  Future<void> setOnboardingComplete(bool value);
}
