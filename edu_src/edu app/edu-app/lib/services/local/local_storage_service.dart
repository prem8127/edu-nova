import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin generic wrapper so every repository doesn't reimplement
/// JSON-encode/decode + SharedPreferences boilerplate. When we swap to a
/// real backend, only the *_repository.dart files change — this class and
/// the repository interfaces stay untouched.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sp async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<Map<String, dynamic>>> readList(String key) async {
    final sp = await _sp;
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) async {
    final sp = await _sp;
    await sp.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> readObject(String key) async {
    final sp = await _sp;
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> writeObject(String key, Map<String, dynamic> value) async {
    final sp = await _sp;
    await sp.setString(key, jsonEncode(value));
  }

  Future<void> remove(String key) async {
    final sp = await _sp;
    await sp.remove(key);
  }

  Future<void> clearAll() async {
    final sp = await _sp;
    await sp.clear();
  }
}

/// Keys centralized here so nothing typos a string key across files.
class StorageKeys {
  static const currentUser = 'edunova_current_user';
  static const users = 'edunova_users';
  static const courses = 'edunova_courses';
  static const quizzes = 'edunova_quizzes';
  static const quizAttempts = 'edunova_quiz_attempts';
  static const scheduledClasses = 'edunova_scheduled_classes';
  static const doubtThreads = 'edunova_doubt_threads';
  static const doubtMessages = 'edunova_doubt_messages';
  static const purchasedCourseIds = 'edunova_purchased_course_ids';
  static const onboardingComplete = 'edunova_onboarding_complete';
  static const transactions = 'edunova_transactions';

  // Extended platform features
  static const assessments = 'edunova_assessments';
  static const assessmentSubmissions = 'edunova_assessment_submissions';
  static const miniProjects = 'edunova_mini_projects';
  static const projectSubmissions = 'edunova_project_submissions';
  static const certificates = 'edunova_certificates';
  static const attendance = 'edunova_attendance';
  static const notifications = 'edunova_notifications';
  static const announcements = 'edunova_announcements';
  static const recordings = 'edunova_recordings';
  static const auditLog = 'edunova_audit_log';
  static const teacherAvailability = 'edunova_teacher_availability';
  static const parentLinks = 'edunova_parent_links';
  static const gameScores = 'edunova_game_scores';

  // Auth: email -> password lookup for the local demo backend. Swap for a
  // real identity provider (Firebase Auth / Supabase Auth) later without
  // touching any screen — only CredentialService's implementation changes.
  static const credentials = 'edunova_credentials';
}
