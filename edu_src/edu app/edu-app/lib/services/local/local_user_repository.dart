import '../../models/user_model.dart';
import '../interfaces/user_repository.dart';
import 'local_storage_service.dart';

class LocalUserRepository implements UserRepository {
  final _storage = LocalStorageService.instance;

  @override
  Future<AppUser?> getCurrentUser() async {
    final json = await _storage.readObject(StorageKeys.currentUser);
    if (json == null) return null;
    return AppUser.fromJson(json);
  }

  @override
  Future<void> saveCurrentUser(AppUser user) async {
    await _storage.writeObject(StorageKeys.currentUser, user.toJson());
    await upsertUser(user);
  }

  @override
  Future<void> clearCurrentUser() async {
    await _storage.remove(StorageKeys.currentUser);
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final list = await _storage.readList(StorageKeys.users);
    return list.map(AppUser.fromJson).toList();
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertUser(AppUser user) async {
    final users = await getAllUsers();
    final idx = users.indexWhere((u) => u.id == user.id);
    if (idx >= 0) {
      users[idx] = user;
    } else {
      users.add(user);
    }
    await _storage.writeList(
      StorageKeys.users,
      users.map((u) => u.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteUser(String id) async {
    final users = await getAllUsers();
    users.removeWhere((u) => u.id == id);
    await _storage.writeList(
      StorageKeys.users,
      users.map((u) => u.toJson()).toList(),
    );
  }

  @override
  Future<bool> isOnboardingComplete() async {
    final json = await _storage.readObject(StorageKeys.onboardingComplete);
    return json?['value'] == true;
  }

  @override
  Future<void> setOnboardingComplete(bool value) async {
    await _storage.writeObject(StorageKeys.onboardingComplete, {'value': value});
  }
}
