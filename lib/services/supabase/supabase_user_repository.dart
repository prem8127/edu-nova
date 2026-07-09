import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_enums.dart';
import '../../models/user_model.dart';
import '../interfaces/user_repository.dart';
import '../local/local_storage_service.dart';
import 'supabase_config.dart';

/// Real backend implementation of [UserRepository], backed by Supabase
/// Auth (identity, password, email/OTP confirmation) and a `profiles`
/// table (name, role, grade, etc — everything Supabase Auth itself
/// doesn't store). See supabase/schema.sql for the table + RLS policies
/// this expects to already exist in the project.
///
/// "Current user" here just means "whoever Supabase's session says is
/// signed in" — there's no separate local cache to fall out of sync.
class SupabaseUserRepository implements UserRepository {
  AppUser _fromRow(Map<String, dynamic> row) {
    return AppUser(
      id: row['id'] as String,
      name: row['name'] as String? ?? '',
      role: UserRole.values.byName(row['role'] as String),
      email: row['email'] as String?,
      grade: row['grade'] != null ? Grade.values.byName(row['grade'] as String) : null,
      age: row['age'] as int?,
      gender: row['gender'] as String?,
      assignedSubjects: (row['assigned_subjects'] as List<dynamic>? ?? [])
          .map((s) => Subject.values.byName(s as String))
          .toList(),
    );
  }

  Map<String, dynamic> _toRow(AppUser user) => {
        'id': user.id,
        'name': user.name,
        'role': user.role.name,
        'email': user.email,
        'grade': user.grade?.name,
        'age': user.age,
        'gender': user.gender,
        'assigned_subjects': user.assignedSubjects.map((s) => s.name).toList(),
      };

  @override
  Future<AppUser?> getCurrentUser() async {
    final session = supabase.auth.currentSession;
    if (session == null) return null;
    final row = await supabase
        .from('profiles')
        .select()
        .eq('id', session.user.id)
        .maybeSingle();
    if (row == null) return null;
    return _fromRow(row);
  }

  /// There's no separate "current user" slot to write to — the session
  /// (set by sign-in/sign-up) is the source of truth. This just makes
  /// sure the profile row is up to date.
  @override
  Future<void> saveCurrentUser(AppUser user) async {
    await upsertUser(user);
  }

  @override
  Future<void> clearCurrentUser() async {
    await supabase.auth.signOut();
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final rows = await supabase.from('profiles').select();
    return (rows as List).map((r) => _fromRow(r as Map<String, dynamic>)).toList();
  }

  static final _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  Future<AppUser?> getUserById(String id) async {
    // Course/teacher demo data still has some hardcoded non-UUID ids left
    // over from the local mock system (e.g. "seed_teacher_tech"). Postgres
    // rejects those outright for a uuid column, so treat them the same way
    // the old local repo did: not found, rather than letting the query throw.
    if (!_uuidPattern.hasMatch(id)) return null;
    final row = await supabase.from('profiles').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return _fromRow(row);
  }

  @override
  Future<void> upsertUser(AppUser user) async {
    await supabase.from('profiles').upsert(_toRow(user));
  }

  @override
  Future<void> deleteUser(String id) async {
    await supabase.from('profiles').delete().eq('id', id);
  }

  // Onboarding-complete is a per-device UI flag only (used by the legacy
  // onboarding screen), not auth state, so it stays in local storage.
  @override
  Future<bool> isOnboardingComplete() async {
    final v = await LocalStorageService.instance.readObject(StorageKeys.onboardingComplete);
    return v?['value'] == true;
  }

  @override
  Future<void> setOnboardingComplete(bool value) async {
    await LocalStorageService.instance.writeObject(StorageKeys.onboardingComplete, {'value': value});
  }
}
